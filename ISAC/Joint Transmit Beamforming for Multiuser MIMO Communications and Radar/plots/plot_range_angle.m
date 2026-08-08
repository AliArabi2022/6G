function fig = plot_range_angle(params)
%PLOT_RANGE_ANGLE  Reproduces Fig. 10: range profile (direction 0 deg) and
%                    Capon spatial spectrum (20th range bin), comparing
%                    radar-only, SSP [42] and SDR beamforming.
%
%   fig = PLOT_RANGE_ANGLE(params)
%
%   Uses params.exp1_targets, params.K_for_receiver_demo,
%   params.Gamma_dB_for_receiver_demo (Section V-C settings: K=2, Gamma=12dB).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

K = params.K_for_receiver_demo;
Gamma_dB = params.Gamma_dB_for_receiver_demo;
Gamma_linear = 10^(Gamma_dB/10);

[R0, ~, status0] = radar_only_design(params);
if ~strcmpi(status0, 'Solved')
    error('plot_range_angle:radarOnlyFailed', 'Radar-only design failed.');
end
W0 = [zeros(params.M, K), chol(psd_clip(R0), 'lower')]; % Wc=0, Wr=chol(R0)

H = generate_channel(K, params.M);
[W_sdr, ~] = sdr_beamforming(H, Gamma_linear, params);
[W_ssp, ~] = ssp_baseline(H, Gamma_linear, R0, params);

targets = params.exp1_targets;

out_radar_only = radar_receiver_sim(W0, targets, params, 'range_angle');
out_ssp        = radar_receiver_sim(W_ssp, targets, params, 'range_angle');
out_sdr        = radar_receiver_sim(W_sdr, targets, params, 'range_angle');

fig = figure('Name', 'Fig. 10: Range/Angle Profiles', 'Position', [100 100 900 600]);

subplot(3,2,1); plot(out_radar_only.range_bins, out_radar_only.range_profile, 'k-'); grid on;
xlabel('Range resolution bin index'); ylabel('Range profile'); title('(a) Radar-only');

subplot(3,2,2); plot(out_radar_only.theta_grid, out_radar_only.capon_spectrum, 'k-'); grid on;
xlabel('Angle (degree)'); ylabel('Capon spectrum'); title('(b) Radar-only');

subplot(3,2,3); plot(out_ssp.range_bins, out_ssp.range_profile, 'r-'); grid on;
xlabel('Range resolution bin index'); ylabel('Range profile'); title('(c) SSP [42]');

subplot(3,2,4); plot(out_ssp.theta_grid, out_ssp.capon_spectrum, 'r-'); grid on;
xlabel('Angle (degree)'); ylabel('Capon spectrum'); title('(d) SSP [42]');

subplot(3,2,5); plot(out_sdr.range_bins, out_sdr.range_profile, 'b-'); grid on;
xlabel('Range resolution bin index'); ylabel('Range profile'); title('(e) SDR');

subplot(3,2,6); plot(out_sdr.theta_grid, out_sdr.capon_spectrum, 'b-'); grid on;
xlabel('Angle (degree)'); ylabel('Capon spectrum'); title('(f) SDR');

sgtitle(sprintf('Range profile / Capon spectrum, K=%d, \\Gamma=%gdB (Fig. 10)', K, Gamma_dB));
saveas (fig,'RANGE_ANGLE.jpg')
end