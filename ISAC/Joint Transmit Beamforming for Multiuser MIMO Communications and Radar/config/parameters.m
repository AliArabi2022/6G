function params = parameters()
%PARAMETERS Central configuration for the DFRC joint beamforming project.
%
%   params = PARAMETERS() returns a struct with every numerical constant
%   used in reproducing:
%   X. Liu, T. Huang, N. Shlezinger, Y. Liu, J. Zhou, Y. C. Eldar,
%   "Joint Transmit Beamforming for Multiuser MIMO Communications and
%   Radar," arXiv:1912.03420, 2020.
%
%   Every field below is annotated with the paper equation/section it
%   comes from. Fields marked "ASSUMPTION" are not explicitly stated in
%   the paper and are our best-practice choice for reproducibility.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

params = struct();

% ---------------------------------------------------------------------
% Array / power configuration (Section V, first paragraph)
% ---------------------------------------------------------------------
params.M           = 10;      % Number of transmit antennas (Sec. V)
params.Pt          = 1;       % Total transmit power, eq. (7) (Sec. V)
params.antenna_spacing_wavelengths = 0.5;  % Half-wavelength ULA (Sec. V)

% ---------------------------------------------------------------------
% Users / SINR sweep (Section V)
% ---------------------------------------------------------------------
params.K_list      = [2, 4, 6];           % Number of users tested (Sec. V)
params.Gamma_dB_sweep_full = 4:2:24;      % Full SINR sweep, "4dB to 24dB" (Sec. V)
params.Gamma_dB_sweep_fig  = 10:1:18;     % Main comparison figures use 10-18 dB (Figs. 5-9)
params.sigma2      = 0.01;    % Comm. AWGN variance, "sigma^2 = 0.01" (Sec. V)

% ---------------------------------------------------------------------
% Radar beam pattern design (Section V, eq. 45)
% ---------------------------------------------------------------------
params.target_dirs_deg = [-40, 0, 40];    % theta_1, theta_2, theta_3 (Sec. V)
params.beamwidth_deg   = 10;              % Delta, width of each ideal beam (Sec. V)
params.angle_grid_deg  = -90:0.1:90;      % {theta_l}, 0.1 deg resolution (Sec. V)
params.wc               = 1;              % Radar loss weighting factor, eq. (14) (Sec. V)

% ---------------------------------------------------------------------
% Monte Carlo simulation (Section V)
% ---------------------------------------------------------------------
params.MC_trials_design   = 1000;   % "averaged over 1000 Monte Carlo tests" (Sec. V)
params.MC_trials_detection_total = 1e6; % Sec. V-C, detection probability trials
params.N_block             = 1024;  % Transmit signal block size N (Sec. V)

% ---------------------------------------------------------------------
% SSP baseline method of [42] (Sec. V)
% ---------------------------------------------------------------------
params.ssp_rho1 = 1;   % Weighting factor rho_1 (Sec. V)
params.ssp_rho2 = 2;   % Weighting factor rho_2 (Sec. V)
% ASSUMPTION: exact gradient-projection step size / stopping tolerance for
% the SSP baseline is not stated in this paper (cited to [42]). We use a
% standard diminishing-step projected gradient scheme; see
% algorithms/ssp_baseline.m for the documented choice.
params.ssp_max_iter     = 2000;   % ASSUMPTION
params.ssp_tol          = 1e-6;   % ASSUMPTION
params.ssp_step0        = 0.05;   % ASSUMPTION (initial step size)

% ---------------------------------------------------------------------
% Radar receiver simulation (Section V-C)
% ---------------------------------------------------------------------
% Experiment 1: range/angle resolution, 5 targets
params.exp1_targets = struct( ...
    'range_bin', {10, 20, 20, 20, 30}, ...
    'angle_deg', {0, -40, 0, 40, 0}, ...
    'amplitude', {1, 1, 1, 1, 1});
params.exp1_num_range_bins = 40;   % covers bins 0..40 per Fig. 10 x-axis

% Experiment 2: angle RMSE + detection probability, 3 targets
params.exp2_target_angles_deg = [-40, 0, 40];
params.exp2_target_amplitude  = 1;

params.sigma_r2   = 1;       % Radar receive noise variance sigma_r^2 (Sec. V-C)
params.Pfa         = 1e-4;    % False alarm probability (Sec. V-C, Fig. 12)
params.K_for_receiver_demo = 2;    % K used for Figs. 10 (paper uses K=2)
params.Gamma_dB_for_receiver_demo = 12; % Gamma used for Figs. 10-12

% ASSUMPTION: RNG seed is not specified in the paper. Fixed here only for
% reproducibility of THIS codebase's demo runs; remove/change the seed to
% re-randomize.
params.rng_seed = 2024;    % ASSUMPTION

end
