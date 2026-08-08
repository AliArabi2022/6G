function fig = plot_mse_vs_gamma(results, K_list)
%PLOT_MSE_VS_GAMMA  Reproduces Fig. 5: beam pattern MSE (eq.46) vs SINR
%                     threshold Gamma, for SDR and ZF, one curve per K.
%
%   fig = PLOT_MSE_VS_GAMMA(results, K_list)
%
%   results - output of algorithms/monte_carlo_driver.m
%             (size numel(K_list) x numel(Gamma_dB_list))
%
%   Author: Ali Arabi Bavil
%   Date:   2026

fig = figure('Name', 'Beam Pattern MSE vs Gamma');
hold on; grid on; set(gca, 'YScale', 'log');

colors = lines(numel(K_list));
for ik = 1:numel(K_list)
    Gamma_dB_list = [results(ik,:).Gamma_dB];
    sdr_mse = [results(ik,:).sdr_mse_mean];
    zf_mse  = [results(ik,:).zf_mse_mean];

    plot(Gamma_dB_list, sdr_mse, '-o', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('SDR, K=%d', K_list(ik)));
    plot(Gamma_dB_list, zf_mse, '--s', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('ZF, K=%d', K_list(ik)));
end

xlabel('SINR threshold \Gamma (dB)');
ylabel('Beam pattern MSE');
title('Beam pattern MSE vs. SINR threshold (Fig. 5)');
legend('Location', 'best');
saveas (fig,'MSE_VS_GAMMA.jpg')
end