function crb = compute_crb(D_t, D_r, gamma, sigma2, kappa)
%COMPUTE_CRB Computes the single-target CRB on the electrical angle
% omega, under the paper's optimal (coherent transmit-beamforming)
% waveform choice (eq. 5).
%
% Theory (eq. 6, confirmed by direct re-inspection of the paper's page
% image -- an earlier version of this file had this wrong, see below):
%
%       CRB(omega) = sigma^2 / ( kappa * 2 * Nt * Nr * |gamma|^2 * chi_r )
%
%   Per the paper's own text immediately preceding eq. (6): "the CRB
%   (given an optimal waveform) is independent of target angle omega
%   and only depends on the Tx array geometry via the number of Tx
%   sensors Nt. In contrast, ... the CRB depends on the Rx array
%   geometry via its spatial variance chi_r." I.e. CRB depends on D_t
%   ONLY through Nt (not through chi_t at all), and on D_r ONLY through
%   chi_r. There is no separate fast-time-sample count T in this
%   formula; T only enters the waveform construction (eq. 5), not the
%   resulting CRB.
%
%   CORRECTION HISTORY: an earlier version of this function used
%   sigma^2/(kappa*2*T*|gamma|^2*(chi_t+chi_r)) instead. This was wrong
%   in two ways (included chi_t; used T instead of Nt*Nr) and was only
%   caught because a real MATLAB run showed CRB(a) != CRB(b) for two
%   arrays with equal chi_r but different chi_t -- which directly
%   contradicts the paper's own stated independence from chi_t. Fixed
%   here.
%
% Inputs:
%   D_t    - 1xNt vector, Tx sensor positions (only numel(D_t)=Nt is used)
%   D_r    - 1xNr vector, Rx sensor positions
%   gamma  - complex scalar, target reflectivity
%   sigma2 - noise variance (scalar or vector, e.g. swept over SNR)
%   kappa  - calibration constant (default 1); see parameters.m.
%            Calibrated to kappa=0.028476547 against a data point read
%            directly off the paper's own published Fig. 2
%            (SNR=3 dB, CRB=0.01, array (a), chi_r=36.666667).
%
% Outputs:
%   crb - CRB value(s), same size as sigma2
%
% Equation reference: eq. (6).
%
% Potential numerical issues:
%   - chi_r = 0 only for a degenerate array (all Rx sensors at one
%     point), which cannot happen for the Nr>=2 arrays used in this
%     project; a defensive check is included regardless.
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    if nargin < 5 || isempty(kappa)
        kappa = 1;
    end

    Nt = numel(D_t);
    Nr = numel(D_r);
    chi_r = spatial_variance(D_r);

    if chi_r <= 0
        error('compute_crb:degenerateArray', ...
              'chi(D_r) must be positive (non-degenerate Rx array).');
    end

    crb = sigma2 ./ (kappa * 2 * Nt * Nr * abs(gamma)^2 * chi_r);

end