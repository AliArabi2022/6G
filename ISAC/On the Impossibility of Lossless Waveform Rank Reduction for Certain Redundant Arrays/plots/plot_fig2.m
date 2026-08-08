function plot_fig2(results_fig2)
%PLOT_FIG2 Reproduce Fig. 2 of the paper.
%
%   PLOT_FIG2(results_fig2)
%
%   PURPOSE
%       Reproduces the MSE vs. SNR plot comparing Array 1 and Array 2,
%       each with both low-rank (random) and full-rank/designed
%       (orthogonal) waveforms -- four curves total, K=15 fixed.
%
%   INPUTS
%       results_fig2 - struct with fields:
%           .SNR_dB_sweep       - 1xNs vector of SNR values (dB), x-axis
%           .MSE_array1_lowrank - 1xNs
%           .MSE_array1_fullrank- 1xNs
%           .MSE_array2_lowrank - 1xNs
%           .MSE_array2_fullrank- 1xNs
%
%   OUTPUTS
%       None (renders and saves fig2.png / fig2.fig to results/).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    fig = figure('Name', 'Fig. 2 reproduction', 'Position', [100 100 600 450]);

    semilogy(results_fig2.SNR_dB_sweep, results_fig2.MSE_array1_lowrank, ...
        '-o', 'Color', [0.85 0.1 0.1], 'LineWidth', 1.2, 'MarkerFaceColor', 'none');
    hold on;
    semilogy(results_fig2.SNR_dB_sweep, results_fig2.MSE_array1_fullrank, ...
        '--o', 'Color', [0.85 0.1 0.1], 'LineWidth', 1.2, 'MarkerFaceColor', [0.85 0.1 0.1]);
    semilogy(results_fig2.SNR_dB_sweep, results_fig2.MSE_array2_lowrank, ...
        '-+', 'Color', [0.1 0.1 0.1], 'LineWidth', 1.2);
    semilogy(results_fig2.SNR_dB_sweep, results_fig2.MSE_array2_fullrank, ...
        '--^', 'Color', [0.1 0.1 0.1], 'LineWidth', 1.2, 'MarkerFaceColor', [0.1 0.1 0.1]);
    hold off;

    xlabel('SNR (dB)');
    ylabel('MSE');
    grid on;
    ylim([1e-4, 1e-1]);
    xlim([0, 30]);

    legend({'Array 1 (with NRS): low rank S', 'Array 1 (with NRS): full rank S', ...
             'Array 2 (no NRS): low rank S', 'Array 2 (no NRS): full rank S'}, ...
             'Location', 'southwest', 'FontSize', 8);

    title('Fig. 2: MSE vs. SNR using low-rank and full-rank waveforms (K=15)');

    if ~exist('results', 'dir')
        mkdir('results');
    end
    saveas(fig, fullfile('results', 'fig2.png'));
    savefig(fig, fullfile('results', 'fig2.fig'));

end
