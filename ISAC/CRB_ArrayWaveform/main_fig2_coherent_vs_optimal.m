%% MAIN_FIG2_COHERENT_VS_OPTIMAL.m
% Reproduces Fig. 2: distribution and correlation of the trace-CRB
% objective for the coherent waveform vs. the true optimal waveform (13),
% over 100 random Tx/Rx subset realizations, for linear and planar arrays.
%
% PAPER SETTINGS (Sec. III-A, Fig. 2 caption):
%   Linear:  Nt=Nr=15 randomly selected from ULA aperture L=49
%   Planar:  Nt=Nr=30 randomly selected from square UPA aperture L=9
%   Targets: theta=[0,10,-10,0] deg, phi=[90,80,70,60] deg, gamma=1_K
%   100 random array realizations
%
% REQUIRES CVX for the "optimal" branch (algorithms/optimal_waveform_cvx.m).
% If CVX is not installed, this script still produces the coherent-only
% distribution and prints instructions to enable the full comparison.
%
% Author: Ali Arabi Bavil
% Date: 2026-07

close all; clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

params = parameters_default();
lambda = params.lambda; sigma2 = params.sigma2; fType = params.fType;

nRealizations = 100;
K = 4; % use all 4 targets from the pool (Fig. 2 uses "multiple targets")
Omega_full = omega_from_angles(params.theta_deg_pool(1:K), params.phi_deg_pool(1:K), lambda, 3);
gamma = ones(K,1); % Fig. 2 caption: "gamma = 1_K"

hasCVX = (exist('cvx_begin', 'file') == 2);
if ~hasCVX
    warning(['CVX not found: only the coherent-beam distribution will be computed.\n' ...
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

    g_coh = nan(nRealizations,1);
    g_opt = nan(nRealizations,1);

    rng(2026); % ASSUMPTION (Phase 11): RNG seed not specified in paper; fixed here for reproducibility
    for r = 1:nRealizations
        idxT = randperm(Ncand, sc.N);
        idxR = randperm(Ncand, sc.N);
        Dt = C(idxT,:); Dr = C(idxR,:);

        g_coh(r) = objective_g(Dt, Dr, Omega_full, gamma, sigma2, sc.numDim, fType);

        if hasCVX
            try
                [~, g_opt(r)] = optimal_waveform_cvx(Dt, Dr, Omega_full, gamma, sigma2, sc.numDim, fType);
            catch ME
                warning('CVX solve failed at realization %d: %s', r, ME.message);
            end
        end
        if mod(r,20)==0, fprintf('  realization %d/%d done\n', r, nRealizations); end
    end

    results.(sc.name).g_coh = g_coh;
    results.(sc.name).g_opt = g_opt;
end

%% Plot Fig. 2a/2b style: distribution of the objective (in dB: 10log10(trace CRB))
figure('Name','Fig 2a/2b - distributions');
for s = 1:numel(scenarios)
    sc = scenarios(s);
    subplot(1,2,s); hold on; grid on;
    histogram(10*log10(results.(sc.name).g_coh), 'FaceAlpha',0.6, 'DisplayName','Coherent');
    if hasCVX
        histogram(10*log10(results.(sc.name).g_opt), 'FaceAlpha',0.6, 'DisplayName','Optimal');
    end
    xlabel('10log_{10}(trace CRBM)'); ylabel('Count');
    title(sprintf('%s arrays (N=%d, L=%d)', sc.name, sc.N, sc.L));
    legend show;
end

%% Plot Fig. 2c/2d style: correlation scatter (only if CVX available)
if hasCVX
    figure('Name','Fig 2c/2d - correlation');
    for s = 1:numel(scenarios)
        sc = scenarios(s);
        subplot(1,2,s); hold on; grid on; axis equal;
        x = 10*log10(results.(sc.name).g_opt);
        y = 10*log10(results.(sc.name).g_coh);
        scatter(x, y, 20, 'filled');
        lims = [min([x;y]), max([x;y])];
        plot(lims, lims, 'k--');
        xlabel('Optimal [dB]'); ylabel('Coherent [dB]');
        title(sprintf('%s arrays', sc.name));
    end
end

save(fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'fig2_results.mat'), 'results');
fprintf('\nSaved results to results/fig2_results.mat\n');
