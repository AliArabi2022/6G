% Runner for Step 5: Detection performance evaluation (range/velocity errors, Pd vs Pfa ROC)
clear; close all; clc;

% --- 0) Parameters & force fs to high value for correct range resolution ---
params = initParams();
% override sampling rate to ensure proper range resolution for our targets
params.fs = 8e6;         % 8 MHz (as you noted is required for correct detection)
params.subcarrier_spacing = params.fs / params.Nfft;
params.dt = 1/params.fs;
fprintf('Using fs = %.1f MHz for Step 5 (range resolution = %.2f m)\n', params.fs/1e6, 3e8/(2*params.fs));

% --- 1) Generate TX once (same waveform for all trials) ---
[txTime, txSymMatrix, bits] = generateOFDM(params);

% --- 2) Define true targets (same format as channel_ISAC uses)
trueTargets = [
    150,  20;    % [range_m, velocity_m/s]
    320, -10
];

% --- 3) Single-run detection & metrics for visualization ---
rxTime_single = channel_ISAC(txTime, params);           % one realization (uses awgn internally)
sensingResults_single = sensingReceiver(rxTime_single, txSymMatrix, params);
detectOpts.peakSearchN = 6;
detectOpts.useCFAR = true;
res_single = evaluateDetection(sensingResults_single, params, trueTargets, detectOpts);

% Print single-run summary
fprintf('\nSingle-run detection summary:\n');
for k=1:size(trueTargets,1)
    fprintf('Target %d true range=%.1f m, detected range error = %.2f m, vel error = %.2f m/s\n', ...
        k, trueTargets(k,1), res_single.rangeErrors(k), res_single.velErrors(k));
end
fprintf('Top detected ranges: '); disp(res_single.detectedRanges.');
fprintf('Detection SNRs (dB) for top peaks: '); disp(res_single.detectionSNRs.');

% Plot RD map with CFAR mask overlay if available
figure('Name','RD map single run (dB) with CFAR overlay','NumberTitle','off');
imagesc(sensingResults_single.velocity_axis, sensingResults_single.range_axis, 20*log10(sensingResults_single.RD_map + eps));
axis xy; colorbar; xlabel('Velocity (m/s)'); ylabel('Range (m)'); title('RD map (dB)');
if ~isempty(res_single.cfarMask)
    hold on;
    [rInd, dInd] = find(res_single.cfarMask);
    scatter(sensingResults_single.velocity_axis(dInd), sensingResults_single.range_axis(rInd), 10, 'r', 'filled');
    legend('RD dB','CFAR detections');
end

% --- 4) ROC: Pd vs Pfa by Monte-Carlo over noise realizations ---
% Approach: for each trial, compute RD map and check if the RD bin nearest
% to a true target exceeds a threshold. For Pfa estimate, sample random empty bins.
nTrials = 200;                % adjust for speed vs accuracy
thresholds = linspace(min(sensingResults_single.RD_map(:)), max(sensingResults_single.RD_map(:)), 50);

Pd = zeros(length(thresholds), 1);
Pfa = zeros(length(thresholds), 1);

% Precompute target bin indices in RD map (rangeIdx, dopplerIdx) using the single-run peakIndices
% Alternatively, map true target ranges to the closest range bin and zero Doppler index (we detect across doppler)
for tIdx = 1:size(trueTargets,1)
    % map true range to index
    [~, rIdxTrue(tIdx)] = min(abs(sensingResults_single.range_axis - trueTargets(tIdx,1)));
    % assume doppler unknown: evaluate detection if ANY doppler bin at that range exceeds threshold
end

fprintf('\nMonte-Carlo ROC: running %d trials (this may take a moment)...\n', nTrials);
rng('shuffle'); % randomize

% For speed: we will only evaluate per-trial RD maps and take max over doppler for each target range bin
for th_i = 1:length(thresholds)
    thr = thresholds(th_i);
    detections = 0;
    falseAlarms = 0;
    nFalseSamples = 0;
    for tr = 1:nTrials
        rxTime_mc = channel_ISAC(txTime, params); % new noise realization per trial
        sensingRes_mc = sensingReceiver(rxTime_mc, txSymMatrix, params);
        RDmc = sensingRes_mc.RD_map;
        % For each true target, check if max across doppler at the target's range bin exceeds thr
        for tIdx = 1:size(trueTargets,1)
            rIdx = rIdxTrue(tIdx);
            if max(RDmc(rIdx, :)) >= thr
                detections = detections + 1;
            end
        end
        % For false alarm estimate: sample several random range bins not containing targets
        % choose 3 random range bins away from true targets
        candidateRanges = setdiff(1:size(RDmc,1), rIdxTrue);
        sampleIdx = randsample(candidateRanges, min(3, length(candidateRanges)));
        nFalseSamples = nFalseSamples + length(sampleIdx);
        for s = 1:length(sampleIdx)
            if max(RDmc(sampleIdx(s), :)) >= thr
                falseAlarms = falseAlarms + 1;
            end
        end
    end
    Pd(th_i) = detections / (nTrials * size(trueTargets,1));
    Pfa(th_i) = falseAlarms / nFalseSamples;
end

% Plot ROC (Pd vs Pfa)
figure('Name','ROC: Pd vs Pfa','NumberTitle','off');
plot(Pfa, Pd, '-o', 'LineWidth',1.2); grid on;
xlabel('Pfa'); ylabel('Pd'); title('ROC curve (Pd vs Pfa)');

% Print threshold that yields Pd ~0.9 (if exists)
[~, idx90] = min(abs(Pd - 0.9));
fprintf('Closest Pd to 0.9 at threshold index %d -> Pd=%.3f, Pfa=%.5f\n', idx90, Pd(idx90), Pfa(idx90));

% Save outputs to a results struct for further analysis
evalResults.single = res_single;
evalResults.Pd = Pd;
evalResults.Pfa = Pfa;
evalResults.thresholds = thresholds;
evalResults.rIdxTrue = rIdxTrue;
save('step5_eval_results.mat','evalResults');

fprintf('\nStep 5 completed: detection evaluation and ROC estimation done. Results saved to step5_eval_results.mat\n');

