function fig = plot_ssp_comparison(results, K_list)
%PLOT_SSP_COMPARISON  Reproduces Fig. 9: beam pattern MSE tradeoff of SDR
%                       beamforming vs. the SSP method of [42].
%
%   fig = PLOT_SSP_COMPARISON(results, K_list)
%
%   Requires results computed with run_ssp = true in
%   algorithms/monte_carlo_driver.m.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

fig = figure('Name', 'SDR vs SSP MSE Comparison');
hold on; grid on; set(gca, 'YScale', 'log');

colors = lines(numel(K_list));
for ik = 1:numel(K_list)
    Gamma_dB_list = [results(ik,:).Gamma_dB];
    sdr_mse = [results(ik,:).sdr_mse_mean];
    ssp_mse = [results(ik,:).ssp_mse_mean];

    plot(Gamma_dB_list, sdr_mse, '-o', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('SDR, K=%d', K_list(ik)));
    plot(Gamma_dB_list, ssp_mse, ':^', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('SSP [42], K=%d', K_list(ik)));
end

xlabel('SINR threshold \Gamma (dB)');
ylabel('Beam pattern MSE');
title('SDR beamforming vs. SSP method of [42] (Fig. 9)');
legend('Location', 'best');
saveas (fig,'SSP_COMPARISON.jpg')
end