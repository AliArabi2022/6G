function plot_fig2(SNR_dB_range, crb_curves, mse_curves, names, save_path)
%PLOT_FIG2 Reproduces Fig. 2: single-target CRB (solid) and empirical
% MLE MSE (markers) vs SNR, for the four array geometries of Fig. 1,
% on a semilog-y axis matching the paper's plot style.
%
% Inputs:
%   SNR_dB_range - 1xN vector of SNR values (dB), x-axis
%   crb_curves   - 4xN matrix, analytical CRB per geometry (rows)
%   mse_curves   - 4xN matrix, Monte Carlo MSE per geometry (rows)
%   names        - 1x4 cell array of geometry names, for the legend
%   save_path    - (optional) file path to save the figure
%
% Equation/figure reference: Fig. 2 ("Single-target CRB and MLE
% performance of array geometries in Fig. 1...").
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    figure('Position', [100 100 700 500], 'Color', 'w');
    colors = lines(size(crb_curves,1));

    hold on;
    for k = 1:size(crb_curves,1)
        semilogy(SNR_dB_range, crb_curves(k,:), '-', 'Color', colors(k,:), ...
                 'LineWidth', 1.8, 'DisplayName', sprintf('CRB: %s', names{k}));
    end
    for k = 1:size(mse_curves,1)
        semilogy(SNR_dB_range, mse_curves(k,:), 'o--', 'Color', colors(k,:), ...
                 'MarkerFaceColor', colors(k,:), 'MarkerSize', 5, ...
                 'DisplayName', sprintf('MLE: %s', names{k}));
    end
    hold off;

    grid on; box on;
    xlabel('SNR (dB)');
    ylabel('MSE');
    title('Fig. 2 reproduction: CRB and MLE performance vs SNR');
    legend('Location', 'southwest', 'FontSize', 8);
    set(gca, 'YScale', 'log');

    if nargin >= 5 && ~isempty(save_path)
        save_dir = fileparts(save_path);
        if ~isempty(save_dir) && ~exist(save_dir, 'dir')
            mkdir(save_dir);
        end
        exportgraphics(gcf, save_path, 'Resolution', 150);
    end

    % Alternative for older MATLAB releases without exportgraphics
    % (pre-R2020a): saveas(gcf, save_path);

end
