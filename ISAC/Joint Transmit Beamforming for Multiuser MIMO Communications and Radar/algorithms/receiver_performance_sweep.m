function out = receiver_performance_sweep(sweep_type, sweep_values, params, num_trials, K)
%RECEIVER_PERFORMANCE_SWEEP  Drives Figs. 11 (RMSE vs Gamma) and 12
%                              (detection probability vs SNR).
%
%   out = RECEIVER_PERFORMANCE_SWEEP(sweep_type, sweep_values, params, num_trials, K)
%
%   sweep_type = 'rmse_vs_gamma':
%       sweep_values are Gamma_dB values (Fig. 11). For each Gamma, a
%       fresh SDR design is solved per Monte Carlo trial (a new channel
%       H each time) and radar_receiver_sim is run in 'rmse_detection'
%       mode using params.exp2_target_angles_deg; RMSE (eq. 47) is
%       averaged over trials.
%
%   sweep_type = 'detection_vs_snr':
%       sweep_values are transmit SNR values Pt*N/sigma_r^2 (linear)
%       (Fig. 12). Gamma is fixed at params.Gamma_dB_for_receiver_demo.
%       For each SNR point, params.sigma_r2 is rescaled to hit the
%       requested SNR (Pt and N held fixed, per the paper's definition
%       "transmit SNR given by Pt*N/sigma_r^2", Sec. V-C), and detection
%       probability is estimated over num_trials Monte Carlo trials.
%
%   COMPUTE COST WARNING: the paper uses up to 10^6 total trials for the
%   detection-probability curve. That is NOT run by default here -- pass
%   a smaller num_trials (e.g. 50-200) for a demonstration-scale run; see
%   README.md for guidance on scaling this up.
%
%   Inputs:
%     sweep_type   - 'rmse_vs_gamma' or 'detection_vs_snr'
%     sweep_values - vector of Gamma_dB (first mode) or SNR values (second)
%     params       - struct from config/parameters.m
%     num_trials   - Monte Carlo trials PER sweep point
%     K            - number of users (design-side), used only for
%                     'rmse_vs_gamma' (Fig. 11 sweeps over K=2,4,6)
%
%   Output: out struct with fields:
%     sweep_values, metric_mean (RMSE or detection probability), metric_std
%
%   Author: Ali Arabi Bavil
%   Date:   2026

if nargin < 5
    K = params.K_for_receiver_demo;
end

targets = struct('range_bin', {20,20,20}, ...
    'angle_deg', num2cell(params.exp2_target_angles_deg), ...
    'amplitude', {params.exp2_target_amplitude, params.exp2_target_amplitude, params.exp2_target_amplitude});

n_pts = numel(sweep_values);
metric_mean = nan(1, n_pts);
metric_std  = nan(1, n_pts);

switch sweep_type
    case 'rmse_vs_gamma'
        for i = 1:n_pts
            Gamma_dB = sweep_values(i);
            Gamma_linear = 10^(Gamma_dB/10);
            rmse_trials = [];
            for t = 1:num_trials
                H = generate_channel(K, params.M);
                [W_sdr, ~, status] = sdr_beamforming(H, Gamma_linear, params);
                if ~strcmpi(status, 'Solved') || isempty(W_sdr)
                    continue;
                end
                r = radar_receiver_sim(W_sdr, targets, params, 'rmse_detection');
                if ~isnan(r.rmse)
                    rmse_trials(end+1) = r.rmse; %#ok<AGROW>
                end
            end
            if ~isempty(rmse_trials)
                metric_mean(i) = mean(rmse_trials);
                metric_std(i)  = std(rmse_trials);
            end
        end

    case 'detection_vs_snr'
        Gamma_dB = params.Gamma_dB_for_receiver_demo;
        Gamma_linear = 10^(Gamma_dB/10);
        for i = 1:n_pts
            snr_target = sweep_values(i); % Pt*N/sigma_r^2 (linear)
            params_i = params;
            params_i.sigma_r2 = (params.Pt * params.N_block) / snr_target;

            det_flags = false(1, num_trials);
            for t = 1:num_trials
                H = generate_channel(K, params.M);
                [W_sdr, ~, status] = sdr_beamforming(H, Gamma_linear, params_i);
                if ~strcmpi(status, 'Solved') || isempty(W_sdr)
                    continue;
                end
                r = radar_receiver_sim(W_sdr, targets, params_i, 'rmse_detection');
                det_flags(t) = r.detection_flag;
            end
            metric_mean(i) = mean(det_flags);
            metric_std(i)  = std(double(det_flags));
        end

    otherwise
        error('receiver_performance_sweep:badType', ...
            'sweep_type must be ''rmse_vs_gamma'' or ''detection_vs_snr''.');
end

out = struct('sweep_type', sweep_type, 'sweep_values', sweep_values, ...
    'metric_mean', metric_mean, 'metric_std', metric_std, 'K', K, ...
    'Gamma_dB', params.Gamma_dB_for_receiver_demo, 'Pfa', params.Pfa);

end