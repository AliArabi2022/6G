function params = parameters()
%PARAMETERS Central configuration for CRB-Optimal DFRC Beamforming reproduction.
%
%   params = PARAMETERS() returns a struct containing every physical,
%   algorithmic, and Monte-Carlo parameter used throughout the
%   reproduction of:
%       F. Liu, Y.-F. Liu, A. Li, C. Masouros, Y. C. Eldar,
%       "Cramer-Rao Bound Optimization for Joint Radar-Communication
%       Design," arXiv:2101.12530v1.
%
%   All power/noise quantities are stored in LINEAR WATTS (never dBm),
%   converted once here via dBm2Watt(), to avoid unit-mismatch bugs
%   propagating through the SDP solvers (see Phase 3 Sec 3.10 table).
%
%   Outputs:
%       params : struct with fields listed below.
%
%   Author:  Ali Arabi Bavil
%   Date:    2026-07-03
%
%   ASSUMPTIONS (see Phase 1/2/6 logs for full justification):
%     A1 - Monte Carlo trial count not stated in paper -> Ntrials = 500
%     A2 - (resolved by user) Design 1/2 benchmarks use TOTAL power
%          constraint (not per-antenna equality as in refs [10]/[11])
%     A3 - (resolved by user) Fig. 5 uses K = 14 and K = 6 (legend values)
%     A4 - Point-target alpha phase not specified -> alpha_true = 1+0j
%     A5 - Angles stored internally in RADIANS; converted to degrees
%          only at the plotting boundary
%     A6 - Theorem 1 Case-2 x2 phase convention -> validated numerically
%          against CVX in Phase 11 (does not affect |w1| or any metric,
%          only the (non-unique) beamformer phase reference)
%     A7 - Design 1 (ref [10]) cross-correlation loss L_{r,2} = 0 for the
%          CRB paper's single-mainlobe target (only one direction of
%          interest, so there are no direction PAIRS to cross-correlate)
%     A8 - Global RNG seeded with rng(42) in main.m for reproducibility

    % ---------------------------------------------------------------
    % Array / system dimensions (Sec. V)
    % ---------------------------------------------------------------
    params.Nt = 16;                  % Tx antennas
    params.Nr = 20;                  % Rx antennas
    params.K  = 4;                   % Default number of users (overridden per-figure)
    params.L  = 30;                  % Frame / pulse length (snapshots)
    params.d_spacing = 0.5;          % ULA element spacing, in wavelengths (lambda/2)

    % ---------------------------------------------------------------
    % Power / noise (Sec. V): PT = 30 dBm, sigmaR2 = sigmaC2 = 0 dBm
    % ---------------------------------------------------------------
    params.PT      = dBm2Watt(30);   % Total transmit power budget [W]
    params.sigmaR2 = dBm2Watt(0);    % Radar noise variance [W]
    params.sigmaC2 = dBm2Watt(0);    % Communication noise variance [W]

    % ---------------------------------------------------------------
    % Point-target default geometry (Sec. V: theta = 0 deg)
    % ---------------------------------------------------------------
    params.theta_true_deg = 0;                       % [deg]
    params.theta_true_rad = deg2rad(params.theta_true_deg);
    params.alpha_true     = 1 + 0i;                  % Assumption A4

    % ---------------------------------------------------------------
    % Angle grid (beampattern / MLE search), Sec. V: -90:0.1:90 deg
    % ---------------------------------------------------------------
    params.angle_grid_res_deg = 0.1;
    params.angle_grid_deg     = -90:params.angle_grid_res_deg:90;
    params.angle_grid_rad     = deg2rad(params.angle_grid_deg);

    % ---------------------------------------------------------------
    % Benchmark desired-beampattern shape (Sec. V, shared by both
    % Design 1 and Design 2): single mainlobe at theta_true, 3 dB
    % width Delta = 10 deg.
    % ---------------------------------------------------------------
    params.mainlobe_width_deg = 10;
    params.mainlobe_width_rad = deg2rad(params.mainlobe_width_deg);
    params.wc_weight          = 1;    % Design-1 loss weighting factor w_c (Eq. 14 of [10])

    % ---------------------------------------------------------------
    % Monte Carlo settings
    % ---------------------------------------------------------------
    params.Ntrials = 500;             % Assumption A1

    % ---------------------------------------------------------------
    % Extended-target scatterer count (only used by the DISCRETE
    % generator variant; Sec. V reproduction uses the i.i.d. Gaussian
    % variant of generate_target.m, which does not need Ns)
    % ---------------------------------------------------------------
    params.Ns = 8;

    % ---------------------------------------------------------------
    % Numerical tolerances
    % ---------------------------------------------------------------
    params.rcond_tol       = 1e-10;   % Below this, inv() is replaced by pinv() with a warning
    params.psd_clip_tol    = 1e-6;    % Above this magnitude, a "negative PSD eigenvalue" is a real bug, not float noise
    params.rank1_gap_tol   = 1e-6;    % Expected lambda2/lambda1 ratio for a numerically-rank-1 SDR solution
    params.sinr_feas_tol   = 1e-6;    % Tolerance when checking gamma_k >= Gamma_k - tol

    % ---------------------------------------------------------------
    % Assumption flags (echoed into diagnostics/plots for traceability)
    % ---------------------------------------------------------------
    params.assumptions = struct( ...
        'A1_Ntrials',               500, ...
        'A2_benchmark_power_form',  'total', ...
        'A3_fig5_K_values',         [14 6], ...
        'A4_alpha_phase',           'fixed_real_positive', ...
        'A5_angle_convention',      'radians_internal', ...
        'A6_x2_phase',              'validated_vs_cvx_phase7_11', ...
        'A7_design1_Lr2',           'zero_single_target', ...
        'A8_rng_seed',              42);
end
