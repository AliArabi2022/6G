%% MAIN_FIG2_COHERENT_VS_OPTIMAL.m
% Reproduces Fig. 2 (a)-(d): trace-CRB performance of the coherent vs.
% optimal waveform, over 100 random Tx/Rx subset realizations, for linear
% and planar arrays, swept over K=1,2,3,4 targets.
%
% PAPER SETTINGS (Sec. III-A, Fig. 2 caption -- confirmed from full text):
%   Linear:  Nt=Nr=15 randomly selected from ULA aperture L=49
%   Planar:  Nt=Nr=30 randomly selected from square UPA aperture L=9
%   Targets (fixed pool, first K used for each panel):
%     theta = [0,10,-10,0] deg, phi = [90,80,70,60] deg, gamma = 1_K
%   100 random array realizations per K.
%   Metric: trace of the CRBM, plotted in dB (10*log10(.)).
%
% FIGURE STRUCTURE (confirmed from the actual figure, not assumed):
%   Fig. 2a (linear) / Fig. 2b (planar): EACH has FOUR side-by-side
%     panels, one per K in {1,2,3,4}; each panel is a pair of boxplots
%     (coherent=orange, optimal=blue) showing the distribution of
%     tr(CRBM) in dB over the 100 realizations.
%   Fig. 2c (linear) / Fig. 2d (planar): ONE scatter plot per array type,
%     x=tr(CRBM) for optimal [dB], y=tr(CRBM) for coherent [dB], points
%     colored/marked by K in {1,2,3,4}, plus the y=x reference line.
%
% REQUIRES CVX for the "optimal" branch (algorithms/optimal_waveform_cvx.m).
% If CVX is not installed, this script still produces the coherent-only
% boxplots and prints instructions to enable the full comparison.
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

close all; clear; clc;
addpath(genpath(fileparts(mfilename('fullpath')))); % project root (this script's own folder), NOT its parent

params = parameters_default();
lambda = params.lambda; sigma2 = params.sigma2; fType = params.fType;

nRealizations = 100;
Kvals = 1:4;

hasCVX = (exist('cvx_begin', 'file') == 2);
if ~hasCVX
    warning(['CVX not found: only the coherent-beam boxplots will be computed.\n' ...
             'Install CVX (http://cvxr.com/cvx/) and run cvx_setup to reproduce the\n' ...
             'full optimal-vs-coherent comparison of Fig. 2.']);
end

scenarios = struct( ...
    'name',   {'linear', 'planar'}, ...
    'numDim', {1, 2}, ...
    'L',      {49, 9}, ...
    'N',      {15, 30} );

results = struct();

for s = 1:numel(scenarios)
    sc = scenarios(s);
    fprintf('\n=== Scenario: %s (L=%d, N=%d, numDim=%d) ===\n', sc.name, sc.L, sc.N, sc.numDim);

    C = candidate_positions(sc.L, sc.numDim, lambda);
    Ncand = size(C,1);

    g_coh = cell(numel(Kvals),1);
    g_opt = cell(numel(Kvals),1);

    for kk = 1:numel(Kvals)
        K = Kvals(kk);
        Omega_K = omega_from_angles(params.theta_deg_pool(1:K), params.phi_deg_pool(1:K), lambda, 3);
        gamma_K = ones(K,1); % Fig. 2 caption: "gamma = 1_K"

        gc = nan(nRealizations,1);
        go = nan(nRealizations,1);

        rng(2026 + K); % ASSUMPTION (Phase 11): RNG seed not specified in paper; fixed per-K for reproducibility
        for r = 1:nRealizations
            idxT = randperm(Ncand, sc.N);
            idxR = randperm(Ncand, sc.N);
            Dt = C(idxT,:); Dr = C(idxR,:);

            gc(r) = objective_g(Dt, Dr, Omega_K, gamma_K, sigma2, sc.numDim, fType);

            if r == 1
                At_diag = array_manifold(Dt, Omega_K);
                Rs_diag = coherent_waveform(At_diag);
                [Atr_diag, Adot_tr_diag] = compute_atr_and_derivative(Dt, Dr, Omega_K, sc.numDim);
                F_diag = compute_FIM(Atr_diag, Adot_tr_diag, Rs_diag, sc.N, gamma_K, sigma2, sc.numDim, K);
                fprintf('    [diag, %s, K=%d, realization 1] size(F)=%dx%d, cond(F)=%.3g, min(eig(F))=%.3g, trace(F)=%.3g, g_coh(1)=%.6g\n', ...
                    sc.name, K, size(F_diag,1), size(F_diag,2), cond(F_diag), min(eig(F_diag)), trace(F_diag), gc(1));
            end

            if hasCVX
                try
                    [~, go(r)] = optimal_waveform_cvx(Dt, Dr, Omega_K, gamma_K, sigma2, sc.numDim, fType);
                catch ME
                    warning('CVX solve failed at K=%d, realization %d: %s', K, r, ME.message);
                end
            end
        end
        g_coh{kk} = gc; g_opt{kk} = go;
        nBadCoh = sum(~isfinite(gc));
        nBadOpt = sum(hasCVX & ~isfinite(go));
        fprintf('  K=%d done', K);
        if nBadCoh > 0
            fprintf(' (%d/%d coherent realizations non-finite -- near-singular random geometry, excluded from plots)', ...
                nBadCoh, nRealizations);
        end
        if hasCVX && nBadOpt > 0
            fprintf(' (%d/%d optimal realizations non-finite)', nBadOpt, nRealizations);
        end
        fprintf('\n');
    end

    results.(sc.name).g_coh = g_coh;
    results.(sc.name).g_opt = g_opt;
end

%% Fig. 2a / 2b: four boxplot panels (one per K), coherent vs optimal
for s = 1:numel(scenarios)
    sc = scenarios(s);
    figure('Name', sprintf('Fig 2%s - %s arrays boxplots', char('a'+s-1), sc.name));
    for kk = 1:numel(Kvals)
        K = Kvals(kk);
        ax = subplot(1, numel(Kvals), kk);
        dataCell = {to_dB_safe(results.(sc.name).g_opt{kk}),to_dB_safe(results.(sc.name).g_coh{kk})};
        
        nValidOpt = sum(isfinite(dataCell{1}));
        nValidCoh = sum(isfinite(dataCell{2}));

        fprintf('    [%s, K=%d] valid points for plotting: optimal=%d/%d,coherent=%d/%d\n', ...
            sc.name, K, nValidOpt, nRealizations, nValidCoh, nRealizations);
        if nValidCoh == 0
            fprintf('    !! ALL coherent realizations invalid for K=%d -- this panel will be EMPTY.\n', K);
            fprintf('       min/max/median of raw g_coh (linear scale, pre-dB): %.6g / %.6g / %.6g\n', ...
                min(results.(sc.name).g_coh{kk}), max(results.(sc.name).g_coh{kk}), median(results.(sc.name).g_coh{kk}));
        end
        colors = {[0.20 0.45 0.80], [0.85 0.45 0.15]}; % blue=optimal, orange=coherent
        if ~hasCVX
            dataCell = dataCell(2); colors = colors(2); % coherent-only fallback
            xPos = 1; xlim(ax, [0.5 1.5]); xticks(ax, 1); xticklabels(ax, {'Coh'});
        else
            xPos = [1 2]; xlim(ax, [0.5 2.5]); xticks(ax, [1 2]); xticklabels(ax, {'Opt','Coh'});
        end
        nDrawn = simple_boxplot(ax, dataCell, xPos, 0.4, colors);
        nChildren = numel(get(ax, 'Children'));
        fprintf('    [%s, K=%d] simple_boxplot drew %d box(es); axes now has %d graphics object(s) (children)\n', ...
            sc.name, K, nDrawn, nChildren);
        grid(ax, 'on');
        title(ax, sprintf('K = %d', K));
        if kk == 1; ylabel(ax, 'tr(CRBM_{\Omega,\Omega}) [dB]'); end
    end
    sgtitle(sprintf('Fig. 2%s reproduction: %s arrays (N=%d, L=%d)', char('a'+s-1), sc.name, sc.N, sc.L));
    drawnow; % force render now, in case this session doesn't auto-refresh figures
    save_figure(gcf, sprintf('fig2%s_%s_boxplots', char('a'+s-1), sc.name));
end

%% Fig. 2c / 2d: correlation scatter, points colored/marked by K
if hasCVX
    markers = {'s','o','v','>'};
    colorsK = {[0.20 0.45 0.80], [0.85 0.15 0.15], [0.90 0.70 0.10], [0.55 0.25 0.75]};
    for s = 1:numel(scenarios)
        sc = scenarios(s);
        figure('Name', sprintf('Fig 2%s - %s correlation', char('c'+s-1), sc.name));
        hold on; grid on; axis equal;
        allX = []; allY = [];
        for kk = 1:numel(Kvals)
            x = to_dB_safe(results.(sc.name).g_opt{kk});
            y = to_dB_safe(results.(sc.name).g_coh{kk});
            valid = isfinite(x) & isfinite(y); % exclude near-singular-geometry draws (see K-loop report above)
            x = x(valid); y = y(valid);
            scatter(x, y, 30, colorsK{kk}, markers{kk}, 'filled', 'DisplayName', sprintf('K=%d', Kvals(kk)));
            allX = [allX; x]; allY = [allY; y]; %#ok<AGROW>
        end
        lims = [min([allX;allY]), max([allX;allY])];
        if isempty(lims) || any(~isfinite(lims))
            fprintf('    !! No valid (x,y) pairs at all for %s correlation plot -- skipping y=x line.\n', sc.name);
        else
            plot(lims, lims, 'k--', 'DisplayName', 'y=x');
        end
        xlabel('tr(CRBM_{\Omega}(S^{opt})) [dB]'); ylabel('tr(CRBM_{\Omega}(S^{coh})) [dB]');
        title(sprintf('Fig. 2%s reproduction: %s arrays correlation', char('c'+s-1), sc.name));
        legend('Location','best');
        drawnow;
        save_figure(gcf, sprintf('fig2%s_%s_correlation', char('c'+s-1), sc.name));
    end
end

resultsDir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(resultsDir, 'dir'); mkdir(resultsDir); end
save(fullfile(resultsDir, 'fig2_results.mat'), 'results');
fprintf('\nSaved results to results/fig2_results.mat\n');
