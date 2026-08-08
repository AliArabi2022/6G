function fig = plot_sumrate_vs_gamma(results, K_list)
%PLOT_SUMRATE_VS_GAMMA  Reproduces Fig. 6: achievable sum rate (eq.22) vs
%                         SINR threshold Gamma, for SDR and ZF.
%
%   fig = PLOT_SUMRATE_VS_GAMMA(results, K_list)
%
%   Author: Ali Arabi Bavil
%   Date:   2026

fig = figure('Name', 'Sum Rate vs Gamma');
hold on; grid on;

colors = lines(numel(K_list));
for ik = 1:numel(K_list)
    Gamma_dB_list = [results(ik,:).Gamma_dB];
    sdr_rate = [results(ik,:).sdr_sumrate_mean];
    zf_rate  = [results(ik,:).zf_sumrate_mean];

    plot(Gamma_dB_list, sdr_rate, '-o', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('SDR, K=%d', K_list(ik)));
    plot(Gamma_dB_list, zf_rate, '--s', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('ZF, K=%d', K_list(ik)));
end

xlabel('SINR threshold \Gamma (dB)');
ylabel('Achievable sum rate (bits/s/Hz)');
title('Achievable sum rate vs. SINR threshold (Fig. 6)');
legend('Location', 'best');
saveas (fig,'SUMRATE_VS_GAMMA.jpg')
end