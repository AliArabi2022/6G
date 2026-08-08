function fig = plot_beam_patterns(K, Gamma_dB, params, run_ssp)
%PLOT_BEAM_PATTERNS  Reproduces Figs. 3-4: transmit beam pattern P(theta;R)
%                      for radar-only, SDR, ZF and (optionally) SSP [42].
%
%   fig = PLOT_BEAM_PATTERNS(K, Gamma_dB, params, run_ssp)
%
%   Solves ONE representative channel realization (not Monte-Carlo
%   averaged -- the paper's Figs. 3-4 show single-trial beam patterns)
%   for the requested K and Gamma_dB, then plots all methods together in
%   dB scale, matching the paper's y-axis convention (10*log10(P)).
%
%   Author: Ali Aravi Bavil
%   Date:   2026

if nargin < 4 || isempty(run_ssp)
    run_ssp = true;
end

Gamma_linear = 10^(Gamma_dB/10);
theta_grid = params.angle_grid_deg;
A_grid = steering_vector(theta_grid, params.M);

[R0, ~, status0] = radar_only_design(params);
if ~strcmpi(status0, 'Solved')
    error('plot_beam_patterns:radarOnlyFailed', 'Radar-only design failed.');
end
P_R0 = 10*log10(real(sum(conj(A_grid) .* (R0*A_grid), 1)));

H = generate_channel(K, params.M);

[~, R_sdr] = sdr_beamforming(H, Gamma_linear, params);
[~, R_zf]  = zf_beamforming(H, Gamma_linear, params);

P_sdr = 10*log10(real(sum(conj(A_grid) .* (R_sdr*A_grid), 1)));
P_zf  = 10*log10(real(sum(conj(A_grid) .* (R_zf*A_grid), 1)));

fig = figure('Name', sprintf('Beam Pattern, K=%d, Gamma=%gdB', K, Gamma_dB));
hold on; grid on;
plot(theta_grid, P_R0, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Radar-only optimum');
plot(theta_grid, P_sdr, 'b--', 'LineWidth', 1.5, 'DisplayName', 'SDR beamforming');
plot(theta_grid, P_zf, 'r-.', 'LineWidth', 1.5, 'DisplayName', 'ZF beamforming');

if run_ssp
    [~, R_ssp] = ssp_baseline(H, Gamma_linear, R0, params);
    P_ssp = 10*log10(real(sum(conj(A_grid) .* (R_ssp*A_grid), 1)));
    plot(theta_grid, P_ssp, 'g:', 'LineWidth', 1.5, 'DisplayName', 'SSP method of [42]');
end

xlabel('Angle (degree)');
ylabel('Beam pattern (dB)');
title(sprintf('Transmit beam pattern, K=%d, \\Gamma=%g dB', K, Gamma_dB));
legend('Location', 'best');
xlim([-90 90]);
saveas (fig,'beam_pattern.jpg')

end