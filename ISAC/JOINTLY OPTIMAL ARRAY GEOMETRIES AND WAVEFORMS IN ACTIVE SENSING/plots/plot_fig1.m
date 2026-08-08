function plot_fig1(geoms, save_path)
%PLOT_FIG1 Reproduces Fig. 1 of the paper: four Tx/Rx array geometries
% and their sum co-arrays, plotted as stem/marker diagrams along a
% shared position axis 0..24 (matching the paper's figure axis).
%
% Inputs:
%   geoms     - struct array of length 4 with fields:
%                 .name  (string, panel title)
%                 .D_t   (Tx positions)
%                 .D_r   (Rx positions)
%   save_path - (optional) file path to save the figure (e.g. .png)
%
% Equation/figure reference: Fig. 1 ("Array geometries with Nt=4
% transmitter and Nr=6 receiver sensors...").
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    figure('Position', [100 100 800 900], 'Color', 'w');

    for k = 1:numel(geoms)
        subplot(numel(geoms), 1, k);
        D_t = geoms(k).D_t;
        D_r = geoms(k).D_r;
        [D_sigma, is_contig, is_nonred] = sum_coarray(D_t, D_r);

        hold on;
        plot(D_sigma, ones(size(D_sigma))*0.9, 'o', 'Color', 'k', ...
             'MarkerFaceColor', 'none', 'MarkerSize', 6, 'LineWidth', 1);
        plot(D_r, ones(size(D_r))*0.6, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7);
        plot(D_t, ones(size(D_t))*0.3, 'rs', 'MarkerFaceColor', 'r', 'MarkerSize', 7);

        ylim([0 1.1]);
        xlim([0 24]);
        set(gca, 'XTick', 0:2:24, 'YTick', []);
        grid on; box on;
        title(sprintf('%s  |  D_\\Sigma contiguous: %s, nonredundant: %s', ...
              geoms(k).name, mat2str(is_contig), mat2str(is_nonred)), ...
              'FontSize', 10);
        if k == numel(geoms)
            xlabel('Sensor position (half-wavelength units)');
        end
        if k == 1
            legend({'D_\Sigma (sum co-array)', 'D_r (Rx)', 'D_t (Tx)'}, ...
                   'Location', 'eastoutside');
        end
        hold off;
    end

    sgtitle('Fig. 1 reproduction: Array geometries (N_t=4, N_r=6)');

    if nargin >= 2 && ~isempty(save_path)
        save_dir = fileparts(save_path);
        if ~isempty(save_dir) && ~exist(save_dir, 'dir')
            mkdir(save_dir);
        end
        exportgraphics(gcf, save_path, 'Resolution', 150);
    end

    % Alternative for older MATLAB releases without exportgraphics
    % (pre-R2020a): saveas(gcf, save_path);

end
