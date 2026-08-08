function plot_fig1(results_fig1)
%PLOT_FIG1 Reproduce Fig. 1 (a,b) of the paper.
%
%   PLOT_FIG1(results_fig1)
%
%   PURPOSE
%       Reproduces:
%         (a) "Average performance": MSE vs. # targets K, for Array 1
%             (with NRS) and Array 2 (no NRS), low-rank waveforms.
%         (b) "Sample realization (K=15)": stem-style comparison of
%             ground-truth vs. estimated scattering magnitude vs. angle,
%             for both arrays, at K=15.
%
%   INPUTS
%       results_fig1 - struct with fields:
%           .K_sweep         - 1xNk vector of K values (x-axis for (a))
%           .MSE_array1      - 1xNk vector, Array 1 MSE per K
%           .MSE_array2      - 1xNk vector, Array 2 MSE per K
%           .sample_theta_true_1  - 1x15 ground-truth angles, Array 1, K=15
%           .sample_theta_hat_1   - 1x15 estimated angles, Array 1, K=15
%           .sample_x_true_1      - 1x15 ground-truth |x_k|, Array 1
%           .sample_x_hat_1       - 1x15 recovered magnitude, Array 1
%           .sample_theta_true_2, .sample_theta_hat_2,
%           .sample_x_true_2, .sample_x_hat_2  - same, for Array 2
%
%   OUTPUTS
%       None (renders a figure with 3 subplots: 1 for (a), 2 stacked for (b),
%       and saves fig1.png / fig1.fig to results/).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    fig = figure('Name', 'Fig. 1 reproduction', 'Position', [100 100 900 400]);

    % --- Panel (a): Average performance ---
    subplot(1,2,1);
    semilogy(results_fig1.K_sweep, results_fig1.MSE_array1, '-o', ...
        'Color', [0.85 0.1 0.1], 'LineWidth', 1.2, 'MarkerSize', 6);
    hold on;
    semilogy(results_fig1.K_sweep, results_fig1.MSE_array2, '-+', ...
        'Color', [0.1 0.1 0.1], 'LineWidth', 1.2, 'MarkerSize', 6);
    hold off;
    xlabel('# of targets, K');
    ylabel('MSE');
    title('(a) Average performance');
    legend('Array 1 (with NRS)', 'Array 2 (no NRS)', 'Location', 'northwest');
    grid on;
    ylim([1e-8, 1]);
    xticks(results_fig1.K_sweep);

    % --- Panel (b): Sample realization (K=15) ---
    subplot(2,2,2);
    stem(results_fig1.sample_theta_true_1, results_fig1.sample_x_true_1, ...
        's', 'Color', [0.3 0.3 0.3], 'MarkerFaceColor', 'none', 'LineStyle', 'none');
    hold on;
    stem(results_fig1.sample_theta_hat_1, results_fig1.sample_x_hat_1, ...
        'o', 'Color', [0.85 0.1 0.1], 'MarkerFaceColor', [0.85 0.1 0.1], 'LineStyle', '-');
    hold off;
    xlim([-pi/2, pi/2]);
    title('Array 1 (with NRS)');
    ylabel('Magnitude');
    legend('Ground truth', 'Estimate', 'Location', 'northeast', 'FontSize', 7);
    grid on;

    subplot(2,2,4);
    stem(results_fig1.sample_theta_true_2, results_fig1.sample_x_true_2, ...
        's', 'Color', [0.3 0.3 0.3], 'MarkerFaceColor', 'none', 'LineStyle', 'none');
    hold on;
    stem(results_fig1.sample_theta_hat_2, results_fig1.sample_x_hat_2, ...
        'o', 'Color', [0.1 0.1 0.7], 'MarkerFaceColor', [0.1 0.1 0.7], 'LineStyle', '-');
    hold off;
    xlim([-pi/2, pi/2]);
    title('Array 2 (no NRS)');
    xlabel('Angle, \theta');
    ylabel('Magnitude');
    grid on;

    if exist('sgtitle', 'file') == 2 || exist('sgtitle', 'builtin')
        sgtitle('Fig. 1: DoA estimation using low-rank waveforms (no noise)');
    else
        % Fallback for MATLAB releases older than R2018b (no sgtitle)
        warning('plot_fig1:noSgtitle', ...
            'sgtitle() not available in this release; skipping overall figure title.');
    end

    if ~exist('results', 'dir')
        mkdir('results');
    end
    saveas(fig, fullfile('results', 'fig1.png'));
    savefig(fig, fullfile('results', 'fig1.fig'));

end
