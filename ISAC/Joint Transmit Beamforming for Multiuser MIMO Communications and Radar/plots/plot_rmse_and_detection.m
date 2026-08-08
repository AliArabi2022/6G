function [fig_rmse, fig_det] = plot_rmse_and_detection(rmse_out_by_K, K_list, det_out)
%PLOT_RMSE_AND_DETECTION  Reproduces Figs. 11 (RMSE vs Gamma) and 12
%                           (detection probability vs SNR).
%
%   [fig_rmse, fig_det] = PLOT_RMSE_AND_DETECTION(rmse_out_by_K, K_list, det_out)
%
%   rmse_out_by_K - cell array, one receiver_performance_sweep('rmse_vs_gamma',...)
%                   output struct per K in K_list
%   det_out       - single receiver_performance_sweep('detection_vs_snr',...) output
%
%   Author: Ali Arabi Bavil
%   Date:   2026

fig_rmse = figure('Name', 'Fig. 11: Angle RMSE vs Gamma');
hold on; grid on;
colors = lines(numel(K_list));
for ik = 1:numel(K_list)
    o = rmse_out_by_K{ik};
    plot(o.sweep_values, o.metric_mean, '-o', 'Color', colors(ik,:), ...
        'DisplayName', sprintf('SDR, K=%d', K_list(ik)));
end
xlabel('SINR threshold \Gamma (dB)');
ylabel('Angle estimation RMSE (degrees)');
title('Angle estimation RMSE vs. SINR threshold (Fig. 11)');
legend('Location', 'best');

fig_det = figure('Name', 'Fig. 12: Detection Probability vs SNR');
plot(10*log10(det_out.sweep_values), det_out.metric_mean, '-o', 'LineWidth', 1.5);
grid on;
xlabel('Transmit SNR (dB)');
ylabel('Detection probability');
ylim([0 1]);
title(sprintf('Detection probability vs. SNR, \\Gamma=%gdB, P_{fa}=%.0e (Fig. 12)', ...
    det_out.Gamma_dB, det_out.Pfa));
saveas (fig_rmse,'RMSE for angle estimation.jpg')
saveas (fig_det,'Detection probability versus transmit SNR.jpg')
end