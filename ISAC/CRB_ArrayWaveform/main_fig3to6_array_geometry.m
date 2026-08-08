%% MAIN_FIG3TO6_ARRAY_GEOMETRY.m
% Reproduces Figs. 3-6: array geometries returned by Algorithm 1
% (sensor_relocation_algorithm.m) for linear, planar, and cubic arrays,
% K=2 and K=3 targets.
%
% PAPER SETTINGS:
%   Fig. 3 (linear,  K=2): Nt=Nr=18, L=50, omega1=0, varying omega2
%   Fig. 4 (planar,  K=2): Nt=Nr=30, L=9,  omega1=[0,0]', varying omega2
%   Fig. 5 (cubic,   K=2): Nt=Nr=50, L=4,  varying omega1, omega2
%   Fig. 6 (planar,  K=3): Nt=Nr=30, L=9,  omega1=[0,0]',
%                          omega2=2*pi*[1/3,0]/(lambda/2),
%                          omega3=2*pi*[0,1/4]/(lambda/2)
%
% Here we reproduce one representative configuration per figure (Fig. 3a,
% Fig. 4a, Fig. 6) plus a cubic example analogous to Fig. 5a. Target
% angles are specified directly as digital angular-frequency vectors
% (matching the paper's own omega-based figure captions), rather than via
% theta/phi, since the paper itself parametrizes Figs. 3-6 directly in
% omega units of 2*pi/(m*lambda/2) for integer m.
%
% ASSUMPTION (Phase 11): reflection coefficients for these geometry
% figures are not stated (unlike Fig. 2's caption); we use gamma = 1_K
% (unit, equal-strength targets), consistent with Fig. 2's convention and
% with the fact that geometry design in this simplified objective is
% independent of |gamma_k| scaling common to all targets (only relative
% magnitudes/phases matter, and the paper gives no reason to assume
% unequal targets here).
%
% Author: Ali Arabi Bavil
% Date: 2026-07

close all; clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

params = parameters_default();
lambda = params.lambda; sigma2 = params.sigma2; fType = params.fType;
halfLambda = lambda/2;

opts = struct('maxOuterIters', 30, 'rng_seed', 2026, 'verbose', true);

%% ---- Fig. 3a: linear array, K=2, Nt=Nr=18, L=50, omega2 = 2*pi/(6*halfLambda) ----
fprintf('\n=== Fig. 3a: linear array ===\n');
numDim = 1; L = 50; N = 18;
omega1 = 0;
omega2 = 2*pi/(6*halfLambda);
Omega = zeros(3,2); Omega(1,:) = [omega1, omega2]; % only dim-1 (linear array) active
gamma = ones(2,1);

Ct = candidate_positions(L, numDim, lambda);
Cr = Ct;
[Dt, Dr] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 3a - linear array geometry');
stem(Dt(:,1)/halfLambda, ones(size(Dt,1),1), 'filled', 'DisplayName','Dt'); hold on; grid on;
stem(Dr(:,1)/halfLambda, 2*ones(size(Dr,1),1), 'filled', 'DisplayName','Dr');
ylim([0 3]); yticks([1 2]); yticklabels({'Dt','Dr'});
xlabel('d_1 [\lambda/2]'); title('Fig. 3a reproduction: linear array, K=2');
legend show;

%% ---- Fig. 4a: planar array, K=2, Nt=Nr=30, L=9, omega2 = 2*pi[1/3,0]/halfLambda ----
fprintf('\n=== Fig. 4a: planar array ===\n');
numDim = 2; L = 9; N = 30;
omega1 = [0;0];
omega2 = 2*pi*[1/3; 0]/halfLambda;
Omega = zeros(3,2); Omega(1:2,:) = [omega1, omega2];
gamma = ones(2,1);

Ct = candidate_positions(L, numDim, lambda);
Cr = Ct;
[Dt, Dr] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 4a - planar array geometry');
subplot(1,2,1);
scatter(Dt(:,1)/halfLambda, Dt(:,2)/halfLambda, 50, 'filled'); grid on; axis equal;
xlabel('d_{t,1} [\lambda/2]'); ylabel('d_{t,2} [\lambda/2]'); title('Tx');
subplot(1,2,2);
scatter(Dr(:,1)/halfLambda, Dr(:,2)/halfLambda, 50, 'filled', 'MarkerFaceColor', [0.85 0.33 0.1]);
grid on; axis equal;
xlabel('d_{r,1} [\lambda/2]'); ylabel('d_{r,2} [\lambda/2]'); title('Rx');
sgtitle('Fig. 4a reproduction: planar array, K=2');

%% ---- Fig. 6: planar array, K=3, Nt=Nr=30, L=9 ----
fprintf('\n=== Fig. 6: planar array, K=3 ===\n');
numDim = 2; L = 9; N = 30;
omega1 = [0;0];
omega2 = 2*pi*[1/3; 0]/halfLambda;
omega3 = 2*pi*[0; 1/4]/halfLambda;
Omega = zeros(3,3); Omega(1:2,:) = [omega1, omega2, omega3];
gamma = ones(3,1);

[Dt, Dr] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 6 - planar array geometry, K=3');
subplot(1,2,1);
scatter(Dt(:,1)/halfLambda, Dt(:,2)/halfLambda, 50, 'filled'); grid on; axis equal;
xlabel('d_{t,1} [\lambda/2]'); ylabel('d_{t,2} [\lambda/2]'); title('Tx');
subplot(1,2,2);
scatter(Dr(:,1)/halfLambda, Dr(:,2)/halfLambda, 50, 'filled', 'MarkerFaceColor', [0.85 0.33 0.1]);
grid on; axis equal;
xlabel('d_{r,1} [\lambda/2]'); ylabel('d_{r,2} [\lambda/2]'); title('Rx');
sgtitle('Fig. 6 reproduction: planar array, K=3');

%% ---- Fig. 5-analogue: cubic array, K=2, Nt=Nr=50, L=4 ----
fprintf('\n=== Fig. 5-analogue: cubic array, K=2 ===\n');
numDim = 3; L = 4; N = 50;
omega1 = 2*pi/halfLambda * [-1/6; 0; sqrt(2)/3];
omega2 = 2*pi/halfLambda * [ 1/6; 0; sqrt(2)/3];
Omega = [omega1, omega2];
gamma = ones(2,1);

Ct = candidate_positions(L, numDim, lambda);
Cr = Ct;
opts.maxOuterIters = 15; % cubic candidate set is large; cap for runtime
[Dt, Dr] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 5-analogue - cubic array geometry');
subplot(1,2,1);
scatter3(Dt(:,1)/halfLambda, Dt(:,2)/halfLambda, Dt(:,3)/halfLambda, 50, 'filled');
grid on; xlabel('d_{t,1}'); ylabel('d_{t,2}'); zlabel('d_{t,3}'); title('Tx');
subplot(1,2,2);
scatter3(Dr(:,1)/halfLambda, Dr(:,2)/halfLambda, Dr(:,3)/halfLambda, 50, 'filled', ...
    'MarkerFaceColor',[0.85 0.33 0.1]);
grid on; xlabel('d_{r,1}'); ylabel('d_{r,2}'); zlabel('d_{r,3}'); title('Rx');
sgtitle('Fig. 5-analogue reproduction: cubic array, K=2');

fprintf('\nAll geometry figures generated.\n');
