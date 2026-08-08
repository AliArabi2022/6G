%% MAIN.M — Top-level driver for the DFRC Joint Transmit Beamforming reproduction
%
%   Reproduces: X. Liu, T. Huang, N. Shlezinger, Y. Liu, J. Zhou,
%   Y. C. Eldar, "Joint Transmit Beamforming for Multiuser MIMO
%   Communications and Radar," arXiv:1912.03420.
%
%   HOW TO RUN:
%     1. Open MATLAB, cd into this folder (DFRC_JointBeamforming/).
%     2. Make sure CVX is on the path (run cvx_setup once if you haven't).
%     3. Run this script: >> main
%     4. Choose DEMO_MODE below (fast, few trials) or FULL_MODE (paper's
%        1000 trials -- slow, see README.md for expected runtime).
%
%   EXECUTION ORDER (this script does it for you, in this order):
%     parameters -> radar_only_design -> monte_carlo_driver (design-stage
%     figures) -> plot_beam_patterns / plot_mse_vs_gamma / etc. ->
%     (optional) receiver_performance_sweep -> radar-receiver figures.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

clear; clc; close all;

% ---------------------------------------------------------------------
% 0. Path setup and CVX check
% ---------------------------------------------------------------------
this_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(this_dir, 'config'));
addpath(fullfile(this_dir, 'utilities'));
addpath(fullfile(this_dir, 'algorithms'));
addpath(fullfile(this_dir, 'preprocessing'));
addpath(fullfile(this_dir, 'postprocessing'));
addpath(fullfile(this_dir, 'plots'));

if exist('cvx_begin', 'file') ~= 2
    error(['CVX not found on the MATLAB path. Install CVX (with SDPT3) ', ...
           'and run cvx_setup, then re-run this script. See README.md.']);
end

params = parameters();
rng(params.rng_seed); % ASSUMPTION: seed not specified by the paper (see config/parameters.m)

% ---------------------------------------------------------------------
% 1. Choose run mode
% ---------------------------------------------------------------------
DEMO_MODE = true;   % <-- set to false for the paper's full 1000-trial sweep or true

if DEMO_MODE
    fprintf('=== DEMO MODE: fast, reduced-trial-count run ===\n');
    Gamma_dB_list = 10:2:18;      % coarser than paper's 10:1:18
    K_list        = [2, 4];       % subset of paper's [2 4 6]
    num_trials    = 20;           % paper uses 1000
    run_ssp       = true;
else
    fprintf('=== FULL MODE: paper-scale run (SLOW, see README.md) ===\n');
    Gamma_dB_list = params.Gamma_dB_sweep_fig;  % 10:1:18
    K_list        = params.K_list;               % [2 4 6]
    num_trials    = params.MC_trials_design;      % 1000
    run_ssp       = true;
end

% ---------------------------------------------------------------------
% 2. Design-stage figures (Figs. 3, 5, 6, 8, 9)
% ---------------------------------------------------------------------
fprintf('\n--- Step 1: single-realization beam pattern (Figs. 3-4) ---\n');
plot_beam_patterns(K_list(1), Gamma_dB_list(round(end/2)), params, run_ssp);
plot_beam_patterns(K_list(2), Gamma_dB_list(round(end/2)), params, run_ssp);

fprintf('\n--- Step 2: Monte Carlo design sweep (feeds Figs. 5,6,8,9) ---\n');
results = monte_carlo_driver(params, Gamma_dB_list, K_list, num_trials, run_ssp, true);
save(fullfile(this_dir, 'results', 'design_sweep_results.mat'), 'results', 'params');

fprintf('\n--- Step 3: plotting design-stage figures ---\n');
plot_mse_vs_gamma(results, K_list);
plot_sumrate_vs_gamma(results, K_list);
plot_feasibility_vs_gamma(results, K_list);
if run_ssp
    plot_ssp_comparison(results, K_list);
end

% ---------------------------------------------------------------------
% 3. Radar-receiver figures (Figs. 10, 11, 12) — optional, slower
% ---------------------------------------------------------------------
RUN_RECEIVER_FIGS = DEMO_MODE; % full-scale receiver sweeps are very slow;
                                 % see README.md before enabling for FULL_MODE

if RUN_RECEIVER_FIGS
    fprintf('\n--- Step 4: radar receiver processing (Fig. 10) ---\n');
    plot_range_angle(params);

    fprintf('\n--- Step 5: angle RMSE sweep (Fig. 11) ---\n');
    rmse_out_by_K = cell(1, numel(K_list));
    rmse_trials_demo = 10; % demo-scale; paper effectively averages over many more
    for ik = 1:numel(K_list)
        rmse_out_by_K{ik} = receiver_performance_sweep('rmse_vs_gamma', ...
            Gamma_dB_list, params, rmse_trials_demo, K_list(ik));
    end

    fprintf('\n--- Step 6: detection probability sweep (Fig. 12) ---\n');
    snr_db_sweep = -5:5:20;
    snr_linear_sweep = 10.^(snr_db_sweep/10);
    det_trials_demo = 20; % demo-scale; paper uses up to 1e6 total trials
    det_out = receiver_performance_sweep('detection_vs_snr', ...
        snr_linear_sweep, params, det_trials_demo);

    plot_rmse_and_detection(rmse_out_by_K, K_list, det_out);

    save(fullfile(this_dir, 'results', 'receiver_sweep_results.mat'), ...
        'rmse_out_by_K', 'det_out', 'params');
else
    fprintf('\n(Skipping receiver-stage figures. Set RUN_RECEIVER_FIGS=true or run FULL_MODE.)\n');
end

fprintf('\n=== Done. Results saved in results/. ===\n');
