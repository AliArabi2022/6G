%% MAIN_FIG7_PERFORMANCE_COMPARISON.m
% Reproduces Fig. 7: trace-CRB vs. target angle separation, comparing
%   (a) the proposed sensor-relocation algorithm (Algorithm 1),
%   (b) random array selection (mean and best over 100 realizations),
%   (c) the canonical MIMO configuration (ULA Tx, dilated-ULA Rx).
%
% PAPER SETTINGS (Fig. 7 caption, page 5):
%   Linear array, aperture L=30, Nt=Nr=6, K=2 targets, lambda=2.
%   x-axis ticks read directly off the figure: 0.2 to 2.0 (12 ticks).
%   y-axis ticks: -36 to -26 dB.
%   Random selection: 100 realizations per point.
%
% ASSUMPTION (Phase 11, explicitly flagged):
%   1) x-axis units: the paper's own axis-label glyph did not extract
%      cleanly as text. However, cross-checking against Figs. 3-4 (which
%      DO give exact omega2 values in the same paper): Fig. 3's
%      omega2 = 2*pi/(6*halfLambda) = 1.047 rad and Fig. 4's
%      omega2 = 2*pi/(3*halfLambda) = 2.094 rad (component magnitude)
%      both fall inside Fig. 7's plotted range of [0.2, 2.0]. This is
%      strong internal evidence that Fig. 7's x-axis is simply
%      deltaOmega = omega2 (with omega1=0 fixed) in radians -- i.e. the
%      SAME quantity used to parametrize Figs. 3-4 -- rather than some
%      separately-normalized separation measure. We adopt that reading.
%   2) "Dilated-ULA" (canonical Rx design) is implemented as the standard
%      MIMO virtual-array-filling design: Tx = ULA with unit half-
%      wavelength spacing, Rx = ULA with spacing Nt half-wavelengths
%      (i.e., Rx candidate indices are multiples of Nt), which is the
%      classical construction for filling the difference co-array in
%      colocated MIMO radar. The paper cites this as "canonical MIMO
%      configuration" without a formula, so this is our best-practice
%      reconstruction.
%   3) Target 1 is fixed at broadside (omega1 = 0); target 2's separation
%      is swept. gamma = 1_2 (unit reflection coefficients, consistent
%      with Fig. 2's convention).
%
% Author: Ali Arabi Bavil
% Date: 2026-07

close all; clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

params = parameters_default();
lambda = params.lambda; sigma2 = params.sigma2; fType = params.fType;
halfLambda = lambda/2;

numDim = 1; L = 30; Nt = 6; Nr = 6; K = 2;
gamma = ones(K,1);
Ct = candidate_positions(L, numDim, lambda);
Cr = Ct;
Ncand = size(Ct,1);

sepUnits = linspace(0.2, 2.0, 12); % x-axis reading off the figure (see ASSUMPTION #1 above)
deltaOmega = sepUnits; % ASSUMPTION: x-axis IS deltaOmega (=omega2, rad), not a derived quantity

nRandom = 100;
opts = struct('maxOuterIters', 30, 'rng_seed', 2026, 'verbose', false);

g_proposed = nan(size(sepUnits));
g_random_mean = nan(size(sepUnits));
g_random_best = nan(size(sepUnits));
g_canonical = nan(size(sepUnits));

rng(2026); % ASSUMPTION: fixed seed for reproducibility (not specified in paper)

for i = 1:numel(sepUnits)
    Omega = zeros(3,2);
    Omega(1,:) = [0, deltaOmega(i)];

    fprintf('\n--- Separation index %d/%d (deltaOmega=%.4f) ---\n', i, numel(sepUnits), deltaOmega(i));

    % (a) Proposed algorithm
    [Dt_p, Dr_p] = sensor_relocation_algorithm(Ct, Cr, Nt, Nr, Omega, gamma, sigma2, numDim, fType, opts);
    g_proposed(i) = objective_g(Dt_p, Dr_p, Omega, gamma, sigma2, numDim, fType);

    % (b) Random selection over nRandom realizations
    g_rand = nan(nRandom,1);
    for r = 1:nRandom
        idxT = randperm(Ncand, Nt); idxR = randperm(Ncand, Nr);
        Dt_r = Ct(idxT,:); Dr_r = Cr(idxR,:);
        g_rand(r) = objective_g(Dt_r, Dr_r, Omega, gamma, sigma2, numDim, fType);
    end
    g_random_mean(i) = mean(g_rand);
    g_random_best(i) = min(g_rand);

    % (c) Canonical: Tx = ULA (contiguous, first Nt candidates), Rx = dilated-ULA
    idxT_canon = 1:Nt; % contiguous ULA starting at 0
    idxR_canon = 1 + (0:Nr-1)*Nt; % spacing = Nt half-wavelengths
    idxR_canon = idxR_canon(idxR_canon <= Ncand);
    if numel(idxR_canon) < Nr
        idxR_canon = round(linspace(1, Ncand, Nr)); % fallback if aperture too small
    end
    Dt_c = Ct(idxT_canon,:); Dr_c = Cr(idxR_canon,:);
    g_canonical(i) = objective_g(Dt_c, Dr_c, Omega, gamma, sigma2, numDim, fType);
end

%% Plot Fig. 7 style
figure('Name','Fig 7 - performance comparison');
plot(sepUnits, 10*log10(g_proposed), '-o', 'DisplayName','Proposed (Algorithm 1)'); hold on; grid on;
plot(sepUnits, 10*log10(g_random_mean), '-s', 'DisplayName','Random (mean)');
plot(sepUnits, 10*log10(g_random_best), '-^', 'DisplayName','Random (best)');
plot(sepUnits, 10*log10(g_canonical), '-d', 'DisplayName','Canonical (ULA/dilated-ULA)');
xlabel('\Delta\omega = \omega_2 [rad]  (\omega_1 = 0)'); ylabel('10log_{10}(trace CRBM) [dB]');
title('Fig. 7 reproduction: performance comparison, K=2, linear array');
legend show;

save(fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'fig7_results.mat'), ...
    'sepUnits','g_proposed','g_random_mean','g_random_best','g_canonical');
fprintf('\nSaved results to results/fig7_results.mat\n');
