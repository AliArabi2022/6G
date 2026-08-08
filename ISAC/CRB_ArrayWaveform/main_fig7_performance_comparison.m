%% MAIN_FIG7_PERFORMANCE_COMPARISON.m
% Reproduces Fig. 7: trace-CRB vs. target angle separation, comparing
%   (a) the proposed sensor-relocation algorithm (Algorithm 1),
%   (b) random array selection (mean and best over 100 realizations),
%   (c) the "Nested array" design -- paper's Sec. IV-B text: "the
%       canonical MIMO configuration (ULA as Tx array, dilated-ULA as
%       Rx array)"; Fig. 7's own legend labels this curve "Nested array".
%
% PAPER SETTINGS (Fig. 7 caption, exact, confirmed from full paper text):
%   "Performance comparison for a linear array with aperture L=30, for
%    K=2 targets using Nt=Nr=6 sensors and lambda=2. The random selection
%    is performed over 100 iterations."
%   x-axis: 0.2 to 2.0 in steps of 0.2 (10 major ticks).
%   y-axis: tr(CRBM(Delta omega)) [dB], -36 to -26.
%
% CONFIRMED (no longer an assumption): Sec. IV-A states explicitly
%   "for an angle separation Delta*omega = omega2 - omega1 = 2*pi/Delta*d
%    [footnote: the inverse of Delta*d is elementwise], the Tx sensors
%    form clusters spaced by Delta*d"
% and Fig. 7's x-axis is exactly this Delta*omega, in radians, with
% omega1=0 fixed and omega2 swept -- matching what this script computes.
%
% ASSUMPTION (Phase 11, one remaining item):
%   1) "Nested array" / "dilated-ULA" exact spacing multiplier: the paper
%      names the design (ULA Tx + dilated-ULA Rx / "Nested array") but
%      does not give the exact dilation factor formula in text. We use
%      the standard nested-array construction: Tx = contiguous ULA
%      (dense subarray), Rx spacing = Nt half-wavelengths (sparse
%      subarray scaled by the dense subarray's element count) -- the
%      textbook definition (Pal & Vaidyanathan-style nesting) that fills
%      the sum/difference co-array without holes, consistent with the
%      paper's own "canonical MIMO configuration" framing.
%   2) Target 1 is fixed at broadside (omega1 = 0); target 2's separation
%      is swept. gamma = 1_2 (unit reflection coefficients, consistent
%      with Fig. 2's convention; not restated in the Fig. 7 caption).
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

close all; clear; clc;
addpath(genpath(fileparts(mfilename('fullpath')))); % project root (this script's own folder), NOT its parent

params = parameters_default();
lambda = params.lambda; sigma2 = params.sigma2; fType = params.fType;
halfLambda = lambda/2;

numDim = 1; L = 30; Nt = 6; Nr = 6; K = 2;
gamma = ones(K,1);
Ct = candidate_positions(L, numDim, lambda);
Cr = Ct;
Ncand = size(Ct,1);

sepUnits = 0.2:0.05:2.0; % x-axis, exact tick values from Fig. 7
deltaOmega = sepUnits; % CONFIRMED: x-axis IS Delta*omega = omega2-omega1 (rad), per Sec. IV-A

nRandom = 1000;
opts = struct('maxOuterIters', 30, 'rng_seed', 42, 'verbose', false);

g_proposed = nan(size(sepUnits));
g_random_mean = nan(size(sepUnits));
g_random_best = nan(size(sepUnits));
g_canonical = nan(size(sepUnits));

rng(42); % ASSUMPTION: fixed seed for reproducibility (not specified in paper)

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
plot(sepUnits, to_dB_safe(g_proposed), '-o', 'DisplayName','Proposed (Algorithm 1)'); hold on; grid on;
plot(sepUnits, to_dB_safe(g_random_mean), '-s', 'DisplayName','Random (mean)');
plot(sepUnits, to_dB_safe(g_random_best), '-^', 'DisplayName','Random (best)');
plot(sepUnits, to_dB_safe(g_canonical), '-d', 'DisplayName','Nested array'); % matches Fig. 7's own legend label
xlabel('\Delta\omega = \omega_2 [rad]  (\omega_1 = 0)'); ylabel('10log_{10}(trace CRBM) [dB]');
title('Fig. 7 reproduction: performance comparison, K=2, linear array');
legend show;
save_figure(gcf, 'fig7_performance_comparison');

resultsDir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(resultsDir, 'dir'); mkdir(resultsDir); end
save(fullfile(resultsDir, 'fig7_results.mat'), ...
    'sepUnits','g_proposed','g_random_mean','g_random_best','g_canonical');
fprintf('\nSaved results to results/fig7_results.mat\n');
