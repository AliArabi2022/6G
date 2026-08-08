%MAIN Reproduces the key theoretical results, Fig. 1, and Fig. 2 of:
% "Jointly Optimal Array Geometries and Waveforms in Active Sensing:
%  New Insights into Array Design via the Cramer-Rao Bound"
%
% Execution order (see README.md for full project structure):
%   1. Load configuration (config/parameters.m)
%   2. Construct the four Fig. 1 array geometries
%   3. Validate Corollary 1 (contiguous / nonredundant sum co-array)
%   4. Verify Theorem 1 by brute-force combinatorial search
%   5. Verify the optimal waveform (eq. 5) via a CVX-based SDP
%   6. Reproduce Fig. 1 (array geometry diagrams)
%   7. Compute analytical CRB curves for all 4 geometries (Fig. 2, solid)
%   8. Run Monte Carlo MLE simulation for all 4 geometries (Fig. 2, markers)
%   9. Reproduce Fig. 2
%
% Requirements: MATLAB (R2020a+ recommended), CVX toolbox (for step 5
% only -- comment out that block if CVX is not installed; nothing else
% in this project depends on it).
%
% Expected runtime: steps 1-7 are near-instant. Step 8 (Monte Carlo,
% cfg.n_trials=1e4 x numel(SNR_dB_range) x 4 geometries) is the
% bottleneck -- expect several minutes on a typical laptop; reduce
% cfg.n_trials in config/parameters.m for a quick smoke test.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
clear; clc; close all;

% --- Setup paths ---
project_root = fileparts(mfilename('fullpath'));
addpath(genpath(project_root));

% --- Ensure output directory exists (zip archives can drop empty folders) ---
results_dir = fullfile(project_root, 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% --- Step 1: Configuration ---
cfg = parameters();
fprintf('Config: Nt=%d, Nr=%d, L_opt=%d\n', cfg.Nt, cfg.Nr, cfg.L_opt);

% --- Step 2: Construct the four Fig. 1 geometries ---
[D_t_opt, L_opt] = optimal_tx_array(cfg.Nt, cfg.Nr);
D_r_opt = optimal_rx_array(cfg.Nr, L_opt);

D_r_eqvar = equal_variance_rx_array();          % Fig. 1(b), L=20
D_t_eqvar = index_set(cfg.Nt);                   % plain unit-ULA Tx array,
                                                  % NOT the same as (a)'s optimal
                                                  % Tx array -- verified against
                                                  % the paper's own figure pixels

[D_t_ula, D_r_ula] = ula_array(cfg.Nt, cfg.Nr);          % Fig. 1(c)
[D_t_mimo, D_r_mimo] = mimo_nested_array(cfg.Nt, cfg.Nr); % Fig. 1(d)

geoms(1) = struct('name', '(a) Clustered array (optimal)', 'D_t', D_t_opt,   'D_r', D_r_opt);
geoms(2) = struct('name', '(b) Same chi_r, larger aperture', 'D_t', D_t_eqvar, 'D_r', D_r_eqvar);
geoms(3) = struct('name', '(c) ULA', 'D_t', D_t_ula,  'D_r', D_r_ula);
geoms(4) = struct('name', '(d) Canonical MIMO (nested)', 'D_t', D_t_mimo, 'D_r', D_r_mimo);

% --- Step 3: Validate Corollary 1 for the optimal geometry ---
[D_sigma, is_contig, is_nonred] = sum_coarray(D_t_opt, D_r_opt);
fprintf('\nCorollary 1 check (optimal array): contiguous=%s, nonredundant=%s, |D_Sigma|=%d (expect %d)\n', ...
        mat2str(is_contig), mat2str(is_nonred), numel(D_sigma), cfg.Nt*cfg.Nr);

% --- Step 4: Brute-force verification of Theorem 1 (Rx array optimality) ---
verify_theorem1_bruteforce(cfg.Nr, L_opt);

% --- Step 5: CVX verification of the optimal waveform (eq. 5) ---
% Comment out this block if CVX is not installed.
try
    cvx_verify_optimal_waveform(D_t_opt, cfg.omega_true, 1.0);
catch ME
    warning('CVX verification skipped/failed: %s', ME,message);
end

% --- Step 6: Reproduce Fig. 1 ---
plot_fig1(geoms, fullfile(project_root, 'results', 'fig1_reproduction.png'));

% --- Step 7: Analytical CRB curves (Fig. 2, solid lines) ---
n_geoms = numel(geoms);
n_snr = numel(cfg.SNR_dB_range);
crb_curves = zeros(n_geoms, n_snr);

for k = 1:n_geoms
    sigma2_vec = abs(cfg.gamma_true)^2 ./ (10.^(cfg.SNR_dB_range/10));
    crb_curves(k,:) = compute_crb(geoms(k).D_t, geoms(k).D_r, ...
                                   cfg.gamma_true, sigma2_vec, cfg.kappa);
end

% --- Step 8: Monte Carlo MLE simulation (Fig. 2, markers) ---
% NOTE: this is the slow step; see README.md for runtime expectations
% and how to reduce cfg.n_trials for a quick check.
mse_curves = zeros(n_geoms, n_snr);
for k = 1:n_geoms
    fprintf('\nRunning Monte Carlo MLE for geometry %d/%d: %s ...\n', k, n_geoms, geoms(k).name);
    mse_curves(k,:) = monte_carlo_mle(geoms(k).D_t, geoms(k).D_r, cfg);
end

% --- Step 9: Reproduce Fig. 2 ---
names = {geoms.name};
plot_fig2(cfg.SNR_dB_range, crb_curves, mse_curves, names, ...
          fullfile(project_root, 'results', 'fig2_reproduction.png'));

% --- Save numerical results ---
save(fullfile(project_root, 'results', 'reproduction_results.mat'), ...
     'cfg', 'geoms', 'crb_curves', 'mse_curves');

fprintf('\nDone. Figures and results saved to %s\n', fullfile(project_root, 'results'));
