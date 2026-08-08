function results = monte_carlo_driver(params, Gamma_dB_list, K_list, num_trials, run_ssp, verbose)
%MONTE_CARLO_DRIVER  Orchestrates the full (Gamma,K) sweep of Section V.
%
%   results = MONTE_CARLO_DRIVER(params, Gamma_dB_list, K_list, num_trials, run_ssp, verbose)
%
%   For every (Gamma, K) pair, draws num_trials independent Rayleigh
%   channel realizations (preprocessing/generate_channel.m) and solves:
%     - SDR beamforming (Algorithm 1)
%     - ZF beamforming (Algorithm 2)
%     - SSP baseline of [42] (if run_ssp is true)
%   then evaluates each with postprocessing/evaluate_design.m and
%   postprocessing/beam_pattern_mse.m, aggregating means over FEASIBLE
%   trials only, plus a feasibility probability (Fig. 8 quantity).
%
%   Inputs:
%     params         - struct from config/parameters.m
%     Gamma_dB_list  - vector of SINR thresholds to sweep, in dB
%     K_list         - vector of user counts to sweep
%     num_trials     - number of Monte Carlo trials per (Gamma,K) pair
%                       (paper uses 1000; pass a smaller number for a
%                       quick demo run -- see README.md)
%     run_ssp        - logical, whether to also run the (slower)
%                       SSP baseline of [42]
%     verbose         - logical, print progress
%
%   Output: results struct array, size numel(K_list) x numel(Gamma_dB_list),
%   each entry with fields:
%     K, Gamma_dB, Gamma_linear,
%     sdr_mse_mean, sdr_sumrate_mean, sdr_fairness_mean, sdr_feas_prob,
%     zf_mse_mean,  zf_sumrate_mean,  zf_fairness_mean,  zf_feas_prob,
%     ssp_mse_mean, ssp_sumrate_mean, ssp_fairness_mean (if run_ssp)
%     P_theta_R0 (beam pattern of the radar-only baseline, for plotting)
%
%   Author: Ali Arabi Bavil
%   Date:   2026

if nargin < 6 || isempty(verbose)
    verbose = true;
end
if nargin < 5 || isempty(run_ssp)
    run_ssp = true;
end

% --- Radar-only baseline (computed once, reused for every trial) ---
if verbose
    fprintf('Solving radar-only baseline design (eq. 15)...\n');
end
[R0, ~, status0] = radar_only_design(params);
if ~strcmpi(status0, 'Solved')
    error('monte_carlo_driver:radarOnlyFailed', ...
        'Radar-only baseline design did not solve (status: %s).', status0);
end
theta_grid = params.angle_grid_deg;
A_grid = steering_vector(theta_grid, params.M);
P_theta_R0 = real(sum(conj(A_grid) .* (R0 * A_grid), 1));

nK = numel(K_list);
nG = numel(Gamma_dB_list);
% results(nK, nG) = struct(); % preallocate struct array

for ik = 1:nK
    K = K_list(ik);
    for ig = 1:nG
        Gamma_dB = Gamma_dB_list(ig);
        Gamma_linear = 10^(Gamma_dB/10);

        if verbose
            fprintf('K=%d, Gamma=%g dB: running %d trials...\n', K, Gamma_dB, num_trials);
        end

        sdr_mse = []; sdr_rate = []; sdr_fair = []; sdr_feas_count = 0;
        zf_mse  = []; zf_rate  = []; zf_fair  = []; zf_feas_count  = 0;
        ssp_mse = []; ssp_rate = []; ssp_fair = [];

        for trial = 1:num_trials
            H = generate_channel(K, params.M);

            % --- SDR (Algorithm 1) ---
            [W_sdr, R_sdr, status_sdr] = sdr_beamforming(H, Gamma_linear, params);
            if strcmpi(status_sdr, 'Solved') && ~isempty(W_sdr)
                sdr_feas_count = sdr_feas_count + 1;
                ev = evaluate_design(W_sdr, R_sdr, H, params);
                sdr_mse(end+1)  = beam_pattern_mse(ev.P_theta, P_theta_R0); %#ok<AGROW>
                sdr_rate(end+1) = ev.sum_rate; %#ok<AGROW>
                sdr_fair(end+1) = ev.fairness_sinr; %#ok<AGROW>
            end

            % --- ZF (Algorithm 2) ---
            [W_zf, R_zf, status_zf] = zf_beamforming(H, Gamma_linear, params);
            if strcmpi(status_zf, 'Solved') && ~isempty(W_zf)
                zf_feas_count = zf_feas_count + 1;
                ev = evaluate_design(W_zf, R_zf, H, params);
                zf_mse(end+1)  = beam_pattern_mse(ev.P_theta, P_theta_R0); %#ok<AGROW>
                zf_rate(end+1) = ev.sum_rate; %#ok<AGROW>
                zf_fair(end+1) = ev.fairness_sinr; %#ok<AGROW>
            end

            % --- SSP baseline of [42] (always "feasible": unconstrained penalty) ---
            if run_ssp
                [W_ssp, R_ssp, ~] = ssp_baseline(H, Gamma_linear, R0, params);
                ev = evaluate_design(W_ssp, R_ssp, H, params);
                ssp_mse(end+1)  = beam_pattern_mse(ev.P_theta, P_theta_R0); %#ok<AGROW>
                ssp_rate(end+1) = ev.sum_rate; %#ok<AGROW>
                ssp_fair(end+1) = ev.fairness_sinr; %#ok<AGROW>
            end
        end

        r = struct();
        r.K = K; r.Gamma_dB = Gamma_dB; r.Gamma_linear = Gamma_linear;
        r.P_theta_R0 = P_theta_R0;

        r.sdr_mse_mean      = mean_safe(sdr_mse);
        r.sdr_sumrate_mean  = mean_safe(sdr_rate);
        r.sdr_fairness_mean = mean_safe(sdr_fair);
        r.sdr_feas_prob     = sdr_feas_count / num_trials;

        r.zf_mse_mean      = mean_safe(zf_mse);
        r.zf_sumrate_mean  = mean_safe(zf_rate);
        r.zf_fairness_mean = mean_safe(zf_fair);
        r.zf_feas_prob     = zf_feas_count / num_trials;

        if run_ssp
            r.ssp_mse_mean      = mean_safe(ssp_mse);
            r.ssp_sumrate_mean  = mean_safe(ssp_rate);
            r.ssp_fairness_mean = mean_safe(ssp_fair);
        else
            r.ssp_mse_mean = NaN; r.ssp_sumrate_mean = NaN; r.ssp_fairness_mean = NaN;
        end

        results(ik, ig) = r;
    end
end

end

function m = mean_safe(v)
if isempty(v)
    m = NaN;
else
    m = mean(v);
end
end