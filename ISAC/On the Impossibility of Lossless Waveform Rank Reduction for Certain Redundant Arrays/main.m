% MAIN Entry point: reproduces Section III (theory) and Section IV
% (numerical validation, Fig. 1 & Fig. 2) of:
%   R. Rajamaki and P. Pal, "On the Impossibility of Lossless Waveform
%   Rank Reduction for Certain Redundant Arrays."
%
%   PURPOSE
%       Orchestrates the full reproduction pipeline:
%         PART A: Theory verification (NRS/RSC checks) for Arrays 1-4
%                 (cheap, runs first, matches Section III-B examples)
%         PART B: Numerical validation (Fig. 1: MSE vs K; Fig. 2: MSE
%                 vs SNR), via Monte Carlo simulation + atomic norm
%                 minimization (CVX) + root-MUSIC.
%
%   REQUIRES: CVX toolbox (confirmed available), an SDP-capable solver
%       (SDPT3/SeDuMi/Mosek).
%
%   RUNTIME WARNING (Phase 13 concern, surfaced here up front)
%       The FULL paper-scale simulation (1000 trials x 10 waveforms x
%       8 K-values x 1 array-pair-comparison, PLUS 1000 x 10 x 13
%       SNR-values x 2 waveform-types) involves on the order of
%       10^5-10^6 individual SDP solves. Even at ~0.05-0.2 sec/solve
%       (NSigma~30, small SDP), this is HOURS of runtime on a single
%       core. Set cfg.quick_mode = true below for a fast smoke-test
%       (drastically reduced trials/waveforms) before committing to a
%       full run. See Phase 13 for parallelization recommendations
%       (parfor over the trial loop) to reduce wall-clock time.
%
%   PARALLELIZATION (Phase 13 recommendation -- not applied by default)
%       If you have Parallel Computing Toolbox, the innermost `trial`
%       loops in both the Fig. 1 and Fig. 2 sections below are
%       embarrassingly parallel (each trial is independent) and can be
%       converted from `for trial = 1:cfg.nTrials` to
%       `parfor trial = 1:cfg.nTrials`, PROVIDED the accumulator
%       indexing is changed to use a per-trial cell array (parfor
%       cannot use the running-index n_accum_1 pattern used below,
%       since slicing rules require each iteration to write to a
%       DISTINCT, statically-determinable array location). A simple
%       conversion: collect a cell array `trial_results{trial} = ...`
%       inside the parfor, then flatten it with `cell2mat` after the
%       loop. This was NOT applied by default here to keep the
%       reference implementation simple and because CVX's thread-safety
%       under parfor depends on your solver backend (SDPT3/SeDuMi are
%       generally fine; verify with a small parfor test first).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

clear; clc; close all;

addpath('config');
addpath('algorithms');
addpath('simulation');
addpath('utilities');
addpath('postprocessing');
addpath('plots');

%% ------------------- Load configuration -------------------
cfg = parameters();
rng(cfg.seed);

% QUICK-TEST TOGGLE (OUR ADDITION -- set false for full paper-scale run)
quick_mode = true;
if quick_mode
    warning('main:quickMode', ...
        'quick_mode=true: using drastically reduced trials/waveforms for a fast smoke test. Set quick_mode=false for paper-scale results.');
    cfg.nTrials    = 20;
    cfg.nWaveforms = 2;
    cfg.K_sweep = [1 5 9 13];
    cfg.SNR_dB_sweep = [0 10 20 30];
end

arrays = array_geometry();

%% ==================== PART A: THEORY VERIFICATION ====================
fprintf('\n========== PART A: Theory verification (Section III) ==========\n');

theory_summary = struct('name', {}, 'NSigma', {}, 'is_contiguous', {}, ...
    'has_NRS', {}, 'NRS_set', {});

for i = 1:numel(arrays)
    Dt = arrays(i).Dt;
    Dr = arrays(i).Dr;

    [DSigma, NSigma, upsilon_mult, is_contig] = compute_sum_coarray(Dt, Dr);
    [has_NRS, NRS_set, NRS_Rx] = check_NRS(Dt, Dr, DSigma, upsilon_mult);

    fprintf('%-10s | NSigma=%2d | contiguous=%d | has_NRS=%d', ...
        arrays(i).name, NSigma, is_contig, has_NRS);
    if has_NRS
        fprintf(' | NRS=%s (via Rx sensor %d)', mat2str(NRS_set), NRS_Rx);
    end
    fprintf(' | expected(paper)=%d', arrays(i).has_NRS_expected);
    if has_NRS ~= arrays(i).has_NRS_expected
        fprintf('  *** MISMATCH ***\n');
    else
        fprintf('  [OK]\n');
    end

    theory_summary(i).name = arrays(i).name;
    theory_summary(i).NSigma = NSigma;
    theory_summary(i).is_contiguous = is_contig;
    theory_summary(i).has_NRS = has_NRS;
    theory_summary(i).NRS_set = NRS_set;

    % Store DSigma/Upsilon for Arrays 1 & 2 (needed in Part B)
    arrays(i).DSigma = DSigma;
    arrays(i).NSigma = NSigma;
    arrays(i).upsilon_mult = upsilon_mult;
    [arrays(i).Upsilon, ~] = compute_redundancy_pattern(Dt, Dr, DSigma);
end

if ~exist('results', 'dir'); mkdir('results'); end
save(fullfile('results', 'theory_summary.mat'), 'theory_summary');

%% --- Part A (continued): Section III-B's specific RSC-satisfying
%%     construction for Array 2 (drop Tx sensors {9,15}) ---
fprintf('\n--- Verifying Array 2''s specific RSC-satisfying construction (Sec. III-B) ---\n');
Dt2 = arrays(2).Dt;
idx_drop = find(Dt2==9 | Dt2==15);
idx_keep = setdiff(1:numel(Dt2), idx_drop);
Nt2 = numel(Dt2);
S2_construction = zeros(Nt2, Nt2);
S2_construction(idx_keep, idx_keep) = eye(numel(idx_keep));
[RSC_holds2, rank_W2] = check_RSC(S2_construction, arrays(2).Upsilon, cfg.Nr, cfg.rank_tol_scale);
fprintf('Array 2, dropping Tx sensors {9,15}: RSC_holds=%d, rank(W)=%d, NSigma=%d (paper claims RSC holds)\n', ...
    RSC_holds2, rank_W2, arrays(2).NSigma);
if ~RSC_holds2
    warning('main:rscMismatch', 'Expected RSC to hold for Array 2''s documented construction, but it did not.');
end

%% --- Part A (continued): Corollary 1 demonstration via the general GMA family ---
fprintf('\n--- Corollary 1 demonstration: sweeping GMA(Nt=7,Nr=6,Delta) ---\n');
for Delta_test = 1:cfg.Nr
    [Dt_g, Dr_g] = generalized_mimo_array(cfg.Nt, cfg.Nr, Delta_test);
    [DSigma_g, ~, upsilon_g] = compute_sum_coarray(Dt_g, Dr_g);
    [has_NRS_g, ~, ~] = check_NRS(Dt_g, Dr_g, DSigma_g, upsilon_g);
    in_range = (Delta_test > cfg.Nr/2) && (Delta_test < cfg.Nr);
    fprintf('  Delta=%d: in Corollary 1 range (Nr/2<Delta<Nr)=%d, has_NRS=%d\n', ...
        Delta_test, in_range, has_NRS_g);
    if in_range && ~has_NRS_g
        warning('main:corollary1Mismatch', 'Delta=%d is in Corollary 1''s range but no NRS was found.', Delta_test);
    end
end

%% ==================== PART B: NUMERICAL VALIDATION ====================
fprintf('\n========== PART B: Numerical validation (Section IV) ==========\n');

Array1 = arrays(1);
Array2 = arrays(2);
Nt = cfg.Nt; Nr = cfg.Nr; T_len = cfg.T_len;

%% --- Fig. 1: MSE vs K (low-rank waveforms, no noise) ---
fprintf('\n--- Fig. 1: MSE vs K sweep ---\n');

results_fig1 = struct();
results_fig1.K_sweep = cfg.K_sweep;
results_fig1.MSE_array1 = zeros(size(cfg.K_sweep));
results_fig1.MSE_array2 = zeros(size(cfg.K_sweep));

for kk = 1:numel(cfg.K_sweep)
    K = cfg.K_sweep(kk);
    fprintf('  K = %d ... ', K);

    % Pre-allocated accumulators (Phase 13 optimization: avoids O(n^2)
    % repeated-concatenation cost of growing arrays inside nested loops).
    % Each trial contributes a 1xK vector of per-target squared errors;
    % max possible entries = nWaveforms*nTrials*K.
    max_entries = cfg.nWaveforms * cfg.nTrials * K;
    mse_accum_1 = nan(1, max_entries);
    mse_accum_2 = nan(1, max_entries);
    n_accum_1 = 0;
    n_accum_2 = 0;

    for wf = 1:cfg.nWaveforms
        S1 = generate_waveform(T_len, Nt, 'low_rank_random', ...
            struct('rank_target', cfg.rank_low));
        S2 = generate_waveform(T_len, Nt, 'low_rank_random', ...
            struct('rank_target', cfg.rank_low));

        W1 = compute_W(S1, Array1.Upsilon, Nr);
        W2 = compute_W(S2, Array2.Upsilon, Nr);

        for trial = 1:cfg.nTrials
            [theta, x] = generate_targets(K);
            n_noise = generate_noise(Nr, T_len, 0); % Fig. 1 is noiseless

            y1 = generate_measurement(Array1.Dt, Array1.Dr, S1, theta, x, n_noise);
            y2 = generate_measurement(Array2.Dt, Array2.Dr, S2, theta, x, n_noise);

            [~, ~, ~, T_u1, ok1] = atomic_norm_recovery(y1, W1, 0);
            [~, ~, ~, T_u2, ok2] = atomic_norm_recovery(y2, W2, 0);

            if ok1 && K < Array1.NSigma
                theta_hat1 = root_music(T_u1, K);
                err1 = compute_mse(theta, theta_hat1);
                mse_accum_1(n_accum_1+1 : n_accum_1+K) = err1;
                n_accum_1 = n_accum_1 + K;
            end
            if ok2 && K < Array2.NSigma
                theta_hat2 = root_music(T_u2, K);
                err2 = compute_mse(theta, theta_hat2);
                mse_accum_2(n_accum_2+1 : n_accum_2+K) = err2;
                n_accum_2 = n_accum_2 + K;
            end
        end
    end

    mse_accum_1 = mse_accum_1(1:n_accum_1);
    mse_accum_2 = mse_accum_2(1:n_accum_2);

    results_fig1.MSE_array1(kk) = mean(mse_accum_1);
    results_fig1.MSE_array2(kk) = mean(mse_accum_2);
    fprintf('MSE1=%.3e, MSE2=%.3e\n', results_fig1.MSE_array1(kk), results_fig1.MSE_array2(kk));
end

%% --- Fig. 1(b): one sample realization at K=15 ---
fprintf('\n--- Fig. 1(b): sample realization, K=15 ---\n');
K_sample = 15;
S1s = generate_waveform(T_len, Nt, 'low_rank_random', struct('rank_target', cfg.rank_low));
S2s = generate_waveform(T_len, Nt, 'low_rank_random', struct('rank_target', cfg.rank_low));
W1s = compute_W(S1s, Array1.Upsilon, Nr);
W2s = compute_W(S2s, Array2.Upsilon, Nr);
[theta_s, x_s] = generate_targets(K_sample);
n_zero = generate_noise(Nr, T_len, 0);

y1s = generate_measurement(Array1.Dt, Array1.Dr, S1s, theta_s, x_s, n_zero);
y2s = generate_measurement(Array2.Dt, Array2.Dr, S2s, theta_s, x_s, n_zero);
[z1s, ~, ~, T_u1s, ok1s] = atomic_norm_recovery(y1s, W1s, 0);
[z2s, ~, ~, T_u2s, ok2s] = atomic_norm_recovery(y2s, W2s, 0);

if ok1s && K_sample < Array1.NSigma
    theta_hat1s = root_music(T_u1s, K_sample);
    x_hat1s = estimate_amplitudes(Array1.DSigma, theta_hat1s, z1s);
else
    theta_hat1s = nan(1, K_sample);
    x_hat1s = nan(K_sample, 1);
end
if ok2s && K_sample < Array2.NSigma
    theta_hat2s = root_music(T_u2s, K_sample);
    x_hat2s = estimate_amplitudes(Array2.DSigma, theta_hat2s, z2s);
else
    theta_hat2s = nan(1, K_sample);
    x_hat2s = nan(K_sample, 1);
end

results_fig1.sample_theta_true_1 = theta_s;
results_fig1.sample_theta_hat_1  = theta_hat1s;
results_fig1.sample_x_true_1     = abs(x_s)';
results_fig1.sample_x_hat_1      = abs(x_hat1s)';
results_fig1.sample_theta_true_2 = theta_s;
results_fig1.sample_theta_hat_2  = theta_hat2s;
results_fig1.sample_x_true_2     = abs(x_s)';
results_fig1.sample_x_hat_2      = abs(x_hat2s)';

save(fullfile('results', 'fig1_data.mat'), 'results_fig1');

%% --- Fig. 2: MSE vs SNR (K=15, low-rank AND full-rank waveforms) ---
fprintf('\n--- Fig. 2: MSE vs SNR sweep ---\n');

K2 = cfg.K_fixed_for_snr_sweep;
results_fig2 = struct();
results_fig2.SNR_dB_sweep = cfg.SNR_dB_sweep;
results_fig2.MSE_array1_lowrank  = zeros(size(cfg.SNR_dB_sweep));
results_fig2.MSE_array1_fullrank = zeros(size(cfg.SNR_dB_sweep));
results_fig2.MSE_array2_lowrank  = zeros(size(cfg.SNR_dB_sweep));
results_fig2.MSE_array2_fullrank = zeros(size(cfg.SNR_dB_sweep));

% Full-rank / designed waveforms (fixed, not re-drawn per trial; Section IV)
S1_full = generate_waveform(T_len, Nt, 'orthogonal_diag', struct('diag_cov', (1/7)*ones(1,7)));
diagcov2 = (1/5)*[1 1 0 1 0 1 1];
S2_full = generate_waveform(T_len, Nt, 'orthogonal_diag', struct('diag_cov', diagcov2));
W1_full = compute_W(S1_full, Array1.Upsilon, Nr);
W2_full = compute_W(S2_full, Array2.Upsilon, Nr);

for ss = 1:numel(cfg.SNR_dB_sweep)
    SNR_dB = cfg.SNR_dB_sweep(ss);
    sigma2 = 10^(-SNR_dB/10);
    sigma  = sqrt(sigma2);
    fprintf('  SNR = %g dB ... ', SNR_dB);

    % Pre-allocated accumulators (Phase 13 optimization; see Fig. 1 loop
    % for rationale). Each trial contributes K2 entries.
    max_entries2 = cfg.nWaveforms * cfg.nTrials * K2;
    mse_1_low  = nan(1, max_entries2); n1c = 0;
    mse_1_full = nan(1, max_entries2); n1fc = 0;
    mse_2_low  = nan(1, max_entries2); n2c = 0;
    mse_2_full = nan(1, max_entries2); n2fc = 0;

    for wf = 1:cfg.nWaveforms
        S1 = generate_waveform(T_len, Nt, 'low_rank_random', struct('rank_target', cfg.rank_low));
        S2 = generate_waveform(T_len, Nt, 'low_rank_random', struct('rank_target', cfg.rank_low));
        W1 = compute_W(S1, Array1.Upsilon, Nr);
        W2 = compute_W(S2, Array2.Upsilon, Nr);

        for trial = 1:cfg.nTrials
            [theta, x] = generate_targets(K2);

            n1 = generate_noise(Nr, T_len, sigma2);
            n2 = generate_noise(Nr, T_len, sigma2);
            n1f = generate_noise(Nr, T_len, sigma2);
            n2f = generate_noise(Nr, T_len, sigma2);

            y1  = generate_measurement(Array1.Dt, Array1.Dr, S1, theta, x, n1);
            y2  = generate_measurement(Array2.Dt, Array2.Dr, S2, theta, x, n2);
            y1f = generate_measurement(Array1.Dt, Array1.Dr, S1_full, theta, x, n1f);
            y2f = generate_measurement(Array2.Dt, Array2.Dr, S2_full, theta, x, n2f);

            [~,~,~,T_u1 , ok1 ] = atomic_norm_recovery(y1 , W1     , sigma);
            [~,~,~,T_u2 , ok2 ] = atomic_norm_recovery(y2 , W2     , sigma);
            [~,~,~,T_u1f, ok1f] = atomic_norm_recovery(y1f, W1_full, sigma);
            [~,~,~,T_u2f, ok2f] = atomic_norm_recovery(y2f, W2_full, sigma);

            if ok1 && K2 < Array1.NSigma
                mse_1_low(n1c+1:n1c+K2) = compute_mse(theta, root_music(T_u1, K2));
                n1c = n1c + K2;
            end
            if ok2 && K2 < Array2.NSigma
                mse_2_low(n2c+1:n2c+K2) = compute_mse(theta, root_music(T_u2, K2));
                n2c = n2c + K2;
            end
            if ok1f && K2 < Array1.NSigma
                mse_1_full(n1fc+1:n1fc+K2) = compute_mse(theta, root_music(T_u1f, K2));
                n1fc = n1fc + K2;
            end
            if ok2f && K2 < Array2.NSigma
                mse_2_full(n2fc+1:n2fc+K2) = compute_mse(theta, root_music(T_u2f, K2));
                n2fc = n2fc + K2;
            end
        end
    end

    mse_1_low  = mse_1_low(1:n1c);
    mse_1_full = mse_1_full(1:n1fc);
    mse_2_low  = mse_2_low(1:n2c);
    mse_2_full = mse_2_full(1:n2fc);

    results_fig2.MSE_array1_lowrank(ss)  = mean(mse_1_low);
    results_fig2.MSE_array1_fullrank(ss) = mean(mse_1_full);
    results_fig2.MSE_array2_lowrank(ss)  = mean(mse_2_low);
    results_fig2.MSE_array2_fullrank(ss) = mean(mse_2_full);
    fprintf('MSE1_low=%.3e MSE1_full=%.3e MSE2_low=%.3e MSE2_full=%.3e\n', ...
        results_fig2.MSE_array1_lowrank(ss), results_fig2.MSE_array1_fullrank(ss), ...
        results_fig2.MSE_array2_lowrank(ss), results_fig2.MSE_array2_fullrank(ss));
end

save(fullfile('results', 'fig2_data.mat'), 'results_fig2');

%% ==================== PLOTTING ====================
fprintf('\n========== Generating figures ==========\n');
plot_fig1(results_fig1);
plot_fig2(results_fig2);

fprintf('\nDone. Results saved to results/. Set quick_mode=false in main.m for a paper-scale run.\n');
