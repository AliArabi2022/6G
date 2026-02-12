function results = evaluateDetection(sensingResults, params, trueTargets, detectionOpts)
% evaluateDetection - evaluate detection performance on RD map and range profile
%
% INPUTS:
%   sensingResults : struct returned by sensingReceiver
%       .range_profile  (Nfft x M_sym) magnitude (abs) of range profiles
%       .RD_map         (Nfft x M_sym) magnitude of range-Doppler map
%       .range_axis     vector (Nfft x 1) [m]
%       .velocity_axis  vector (1 x M_sym) [m/s]
%       .H_est          channel estimate (Nfft x M_sym)
%   params : parameter struct (must contain fs, Nfft, M_sym)
%   trueTargets : K x 2 matrix [range_m, velocity_m_s] ground truth
%   detectionOpts : struct with fields:
%       .peakSearchN : number of peaks to return per trial (default 5)
%       .threshold   : absolute detection threshold (optional)
%       .useCFAR     : true/false to run CA-CFAR on RD map (default false)
%
% OUTPUT:
%   results : struct with fields:
%       .detectedRanges : detected ranges (m) (list)
%       .rangeErrors    : errors (m) compared to true targets
%       .detectedVels   : detected velocities (m/s)
%       .velErrors      : velocity errors
%       .detectionSNRs  : detection SNR estimates per detected peak (dB)
%       .cfarMask       : binary mask from CFAR if requested
%       .peakIndices    : indices of detected peaks [rangeIdx, dopplerIdx]
%
% NOTES:
%   - This evaluation assumes sensingResults.RD_map is magnitude (linear).
%   - Peak assignment to true targets done by nearest-range matching (simple).
%   - CA-CFAR implemented in 2D in a simple way for demonstration.

if nargin < 4 || isempty(detectionOpts)
    detectionOpts.peakSearchN = 6;
    detectionOpts.useCFAR = false;
    detectionOpts.threshold = [];
end

RD = sensingResults.RD_map; % Nfft x M_sym (linear magnitude)
range_axis = sensingResults.range_axis(:);
vel_axis = sensingResults.velocity_axis(:);

[Nrange, Ndop] = size(RD);

% 1) Find top peaks in RD map (global peaks)
% flatten RD and sort
RDvec = RD(:);
[sortedVals, sortedIdx] = sort(RDvec, 'descend');

nPick = min(detectionOpts.peakSearchN, length(sortedVals));
pickedIdx = sortedIdx(1:nPick);

% convert linear indices to subscripts
[rangeIdxs, dopIdxs] = ind2sub([Nrange, Ndop], pickedIdx);

detectedRanges = range_axis(rangeIdxs);
detectedVels = vel_axis(dopIdxs);

% 2) Compute detection SNR estimate: signal power / local noise floor
% For each detected peak, estimate noise as median of RD magnitudes excluding a small guard
detectionSNRs = zeros(nPick,1);
for i=1:nPick
    rI = rangeIdxs(i);
    dI = dopIdxs(i);
    % define window excluding guard
    winR = max(1,rI-8):min(Nrange,rI+8);
    winD = max(1,dI-2):min(Ndop,dI+2);
    % guard cell: 1 cell around peak
    mask = true(length(winR), length(winD));
    gR = (max(1,rI-1)-winR(1)+1):(min(Nrange,rI+1)-winR(1)+1);
    gD = (max(1,dI-1)-winD(1)+1):(min(Ndop,dI+1)-winD(1)+1);
    mask(gR, gD) = false;
    noiseCells = RD(winR, winD);
    noiseVals = noiseCells(mask);
    noiseFloor = median(noiseVals(:)) + eps;
    signalVal = RD(rI, dI);
    detectionSNRs(i) = 10*log10( (signalVal^2) / (noiseFloor^2) );
end

% 3) Assign detected peaks to true targets by nearest-range (could improve by 2D matching)
Ktrue = size(trueTargets,1);
rangeErrors = nan(Ktrue,1);
velErrors = nan(Ktrue,1);
assigned = false(nPick,1);
assignedIdx = nan(Ktrue,1);

for k=1:Ktrue
    trueR = trueTargets(k,1);
    % find nearest detected range
    [dR, idxMin] = min(abs(detectedRanges - trueR));
    % assign if reasonable (within half unambiguous range bin)
    rangeErrors(k) = detectedRanges(idxMin) - trueR;
    velErrors(k) = detectedVels(idxMin) - trueTargets(k,2);
    assigned(k) = true;
    assignedIdx(k) = idxMin;
    assignedIdx(k) = idxMin;
    assigned(idxMin) = true;
end

% 4) Optional CA-CFAR (very simple 2D implementation)
cfarMask = [];
if detectionOpts.useCFAR
    % CA-CFAR params
    guardR = 1; guardD = 1;
    trainR = 8; trainD = 3;
    Pfa = 1e-3;
    % compute noise average for each cell (skip edges)
    cfarMask = false(size(RD));
    alpha = []; % threshold multiplier will be computed locally
    for ii = 1+trainR+guardR : Nrange-(trainR+guardR)
        for jj = 1+trainD+guardD : Ndop-(trainD+guardD)
            rWin = ii-trainR-guardR : ii+trainR+guardR;
            dWin = jj-trainD-guardD : jj+trainD+guardD;
            block = RD(rWin, dWin);
            % exclude guard cells center
            gRlocal = (trainR+1) : (trainR+2*guardR+1);
            gDlocal = (trainD+1) : (trainD+2*guardD+1);
            block(gRlocal, gDlocal) = 0;
            noiseEstimate = sum(block(:)) / (numel(block) - numel(gRlocal)*numel(gDlocal));
            % threshold multiplier for desired Pfa (approx)
            % for CA-CFAR with Gaussian noise, alpha depends on training cells; here approximate using:
            % alpha = Ncells*(Pfa^(-1/Ncells) - 1) ; (rough approximation)
            Ncells = numel(block) - numel(gRlocal)*numel(gDlocal);
            alphaLoc = Ncells*(Pfa^(-1/Ncells) - 1);
            if RD(ii,jj) > alphaLoc * noiseEstimate
                cfarMask(ii,jj) = true;
            end
        end
    end
end

% 5) Populate results
results.detectedRanges = detectedRanges;
results.detectedVels = detectedVels;
results.rangeErrors = rangeErrors;
results.velErrors = velErrors;
results.detectionSNRs = detectionSNRs;
results.peakIndices = [rangeIdxs, dopIdxs];
results.cfarMask = cfarMask;
results.assignedIdx = assignedIdx;
end
