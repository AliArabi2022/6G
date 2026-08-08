function cfg = parameters()
%PARAMETERS Central configuration for the CRB array-waveform reproduction project.
%
% Purpose:
%   Single source of truth for all symbols/constants used in the paper
%   "Jointly Optimal Array Geometries and Waveforms in Active Sensing:
%    New Insights into Array Design via the Cramer-Rao Bound".
%
% Outputs:
%   cfg - struct with all configuration fields (see below)
%
% Assumptions (explicitly flagged, see chat response Phase 0):
%   - cfg.kappa is a free calibration constant for the CRB prefactor.
%     The functional form CRB ~ 1/(kappa*(chi_t+chi_r)*SNR) follows the
%     paper's derivation; kappa=1 is the default and may need calibration
%     against the published Fig. 2 curve if exact dB values are required.
%
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    % ---- Array sizes (Fig. 1 / Fig. 2 example in the paper) ----
    cfg.Nt = 4;      % number of Tx sensors
    cfg.Nr = 6;      % number of Rx sensors (must be even for Theorem 1 / Corollary 1)

    % ---- Optimal aperture per Corollary 1, eq. (L = (Nt+1)*Nr/2 - 1) ----
    cfg.L_opt = (cfg.Nt + 1) * cfg.Nr / 2 - 1;   % = 14 for Nt=4, Nr=6

    % ---- Ground truth target parameters (Section 4) ----
    cfg.omega_true  = 0;      % true electrical angle (rad), broadside
    cfg.gamma_true  = 1;      % true complex reflectivity

    % ---- Waveform ----
    cfg.T = cfg.Nt;                 % number of fast-time samples, T = Nt (paper's example)
    cfg.u = (1/sqrt(cfg.T)) * ones(cfg.T,1);  % optimal beamforming weight vector, eq. (5)

    % ---- CRB calibration constant (see Assumptions above) ----
    cfg.kappa = 1;

    % ---- Monte Carlo simulation settings (Section 4) ----
    cfg.SNR_dB_range = -20:2.5:20;  % SNR sweep, matches Fig. 2 x-axis span
    cfg.n_trials     = 200;         % Monte Carlo trials per SNR point (paper: 10^4)
    cfg.omega_grid_N = 4096;        % grid resolution for MLE search over omega in [-pi,pi)

    % ---- Reproducibility ----
    cfg.rng_seed = 2026;

end
