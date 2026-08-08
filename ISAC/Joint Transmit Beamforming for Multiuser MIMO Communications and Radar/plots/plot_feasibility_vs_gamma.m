function fig = plot_feasibility_vs_gamma(results, K_list)
%PLOT_FEASIBILITY_VS_GAMMA  Reproduces Fig. 8: feasibility probability of
%                             the SDR (32) and ZF (40) problems vs Gamma.
%
%   fig = PLOT_FEASIBILITY_VS_GAMMA(results, K_list)
%
%   Author: Ali Arabi Bavil
%   Date:   2026

fig = figure('Name', 'Feasibility Probability vs Gamma');
hold on; grid on;

colors = lines(numel(K_list));
for ik = 1:numel(K_list)
    Gamma_dB_list = [results(ik,:).Gamma_dB];
    sdr_feas = [results(ik,:).sdr_feas_prob];
    zf_feas  = [results(ik,:).zf_feas_prob];

    plot(Gamma_dB_list, sdr_feas, '-o', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('SDR, K=%d', K_list(ik)));
    plot(Gamma_dB_list, zf_feas, '--s', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('ZF, K=%d', K_list(ik)));
end

xlabel('SINR threshold \Gamma (dB)');
ylabel('Feasibility probability');
ylim([0 1]);
title('Feasibility probability vs. SINR threshold (Fig. 8)');
legend('Location', 'best');
saveas (fig,'FEASIBILITY_VS_GAMMA.jpg')
end