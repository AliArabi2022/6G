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
% All panels shown on the paper's page 5 are reproduced here with EXACT
% omega values read off the figure captions (confirmed by direct
% inspection of the page image, not guessed): Fig. 3a/3b, Fig. 4a/4b/4c,
% Fig. 5a/5b, and Fig. 6. Target angles are specified directly as digital
% angular-frequency (omega) vectors, matching the paper's own omega-based
% figure captions, rather than via theta/phi.
%
% ASSUMPTION (Phase 11): reflection coefficients for these geometry
% figures are not stated (unlike Fig. 2's caption); we use gamma = 1_K
% (unit, equal-strength targets), consistent with Fig. 2's convention and
% with the fact that geometry design in this simplified objective is
% independent of |gamma_k| scaling common to all targets (only relative
% magnitudes/phases matter, and the paper gives no reason to assume
% unequal targets here).
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

close all; clear; clc;
addpath(genpath(fileparts(mfilename('fullpath')))); % project root (this script's own folder), NOT its parent

params = parameters_default();
lambda = params.lambda; sigma2 = params.sigma2; fType = params.fType;
halfLambda = lambda/2;

opts = struct('maxOuterIters', 30, 'rng_seed', 2026, 'verbose', true);

% Color/marker convention matching the paper's actual figures (confirmed
% by direct visual inspection of page 5): Dt = red filled squares,
% Dr = blue filled circles, consistently across all panels.
DT_COLOR = [0.80 0.10 0.10];
DR_COLOR = [0.10 0.30 0.80];

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

plot(Dt(:,1)/halfLambda, 2*ones(size(Dt,1),1), ...
    's', ...
    'LineStyle','none', ...
    'Color',DT_COLOR, ...
    'MarkerFaceColor',DT_COLOR, ...
    'MarkerSize',8, ...
    'DisplayName','Dt');

hold on;
grid on;

plot(Dr(:,1)/halfLambda, ones(size(Dr,1),1), ...
    'o', ...
    'LineStyle','none', ...
    'Color',DR_COLOR, ...
    'MarkerFaceColor',DR_COLOR, ...
    'MarkerSize',8, ...
    'DisplayName','Dr');
hold on;
grid on;


% stem(Dt(:,1)/halfLambda, 2*ones(size(Dt,1),1), 's', 'filled', 'Color', DT_COLOR, ...
%     'MarkerFaceColor', DT_COLOR, 'DisplayName','Dt'); hold on; grid on;
% stem(Dr(:,1)/halfLambda, ones(size(Dr,1),1), 'o', 'filled', 'Color', DR_COLOR, ...
%     'MarkerFaceColor', DR_COLOR, 'DisplayName','Dr');
ylim([0 3]); yticks([1 2]); yticklabels({'Dr','Dt'});
xlabel('d_1 [\lambda/2]'); title('Fig. 3a reproduction: linear array, K=2');
legend show;
save_figure(gcf, 'fig3a_linear_array');

%% ---- Fig. 3b: linear array, K=2, same setup, omega2 = 2*pi/(9*halfLambda) ----
fprintf('\n=== Fig. 3b: linear array ===\n');
omega2b = 2*pi/(9*halfLambda);
Omega_3b = zeros(3,2); Omega_3b(1,:) = [0, omega2b];
[Dt_3b, Dr_3b] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega_3b, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 3b - linear array geometry');
% stem(Dt_3b(:,1)/halfLambda, 2*ones(size(Dt_3b,1),1), 's', 'filled', 'Color', DT_COLOR, ...
%     'MarkerFaceColor', DT_COLOR, 'DisplayName','Dt'); hold on; grid on;
plot(Dt_3b(:,1)/halfLambda, 2*ones(size(Dt_3b,1),1), ...
    's', ...
    'LineStyle','none', ...
    'Color',DT_COLOR, ...
    'MarkerFaceColor',DT_COLOR, ...
    'MarkerSize',8, ...
    'DisplayName','Dt');
hold on;
grid on;

% stem(Dr_3b(:,1)/halfLambda, ones(size(Dr_3b,1),1), 'o', 'filled', 'Color', DR_COLOR, ...
%     'MarkerFaceColor', DR_COLOR, 'DisplayName','Dr');
plot(Dr_3b(:,1)/halfLambda, ones(size(Dr_3b,1),1), ...
    'o', ...
    'LineStyle','none', ...
    'Color',DR_COLOR, ...
    'MarkerFaceColor',DR_COLOR, ...
    'MarkerSize',8, ...
    'DisplayName','Dr');
hold on;
grid on;
ylim([0 3]); yticks([1 2]); yticklabels({'Dr','Dt'});
xlabel('d_1 [\lambda/2]'); title('Fig. 3b reproduction: linear array, K=2 (\omega_2=2\pi/(9\lambda/2))');
legend show;
save_figure(gcf, 'fig3b_linear_array');

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
scatter(Dt(:,1)/halfLambda, Dt(:,2)/halfLambda, 50, 's', 'filled', 'MarkerFaceColor', DT_COLOR); grid on; axis equal;
plot(Dt_3b(:,1)/halfLambda, 2*ones(size(Dt_3b,1),1), ...
    's', ...
    'LineStyle','none', ...
    'Color',DT_COLOR, ...
    'MarkerFaceColor',DT_COLOR, ...
    'MarkerSize',8, ...
    'DisplayName','Dt');
hold on;
grid on;
xlabel('d_{t,1} [\lambda/2]'); ylabel('d_{t,2} [\lambda/2]'); title('Tx');
subplot(1,2,2);
scatter(Dr(:,1)/halfLambda, Dr(:,2)/halfLambda, 50, 'o', 'filled', 'MarkerFaceColor', DR_COLOR);
plot(Dr_3b(:,1)/halfLambda, ones(size(Dr_3b,1),1), ...
    'o', ...
    'LineStyle','none', ...
    'Color',DR_COLOR, ...
    'MarkerFaceColor',DR_COLOR, ...
    'MarkerSize',8, ...
    'DisplayName','Dr');
hold on;
grid on;
grid on; axis equal;
xlabel('d_{r,1} [\lambda/2]'); ylabel('d_{r,2} [\lambda/2]'); title('Rx');
sgtitle('Fig. 4a reproduction: planar array, K=2');
save_figure(gcf, 'fig4a_planar_array');

%% ---- Fig. 4b: planar array, K=2, omega2 = 2*pi[0, 1/(4*halfLambda)]^T ----
fprintf('\n=== Fig. 4b: planar array ===\n');
omega2_4b = 2*pi*[0; 1/4]/halfLambda;
Omega_4b = zeros(3,2); Omega_4b(1:2,:) = [omega1, omega2_4b];
[Dt_4b, Dr_4b] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega_4b, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 4b - planar array geometry');
subplot(1,2,1);
scatter(Dt_4b(:,1)/halfLambda, Dt_4b(:,2)/halfLambda, 50, 's', 'filled', 'MarkerFaceColor', DT_COLOR); grid on; axis equal;
xlabel('d_{t,1} [\lambda/2]'); ylabel('d_{t,2} [\lambda/2]'); title('Tx');
subplot(1,2,2);
scatter(Dr_4b(:,1)/halfLambda, Dr_4b(:,2)/halfLambda, 50, 'o', 'filled', 'MarkerFaceColor', DR_COLOR);
grid on; axis equal;
xlabel('d_{r,1} [\lambda/2]'); ylabel('d_{r,2} [\lambda/2]'); title('Rx');
sgtitle('Fig. 4b reproduction: planar array, K=2 (\omega_2=2\pi[0,1/4]/(\lambda/2))');
save_figure(gcf, 'fig4b_planar_array');

%% ---- Fig. 4c: planar array, K=2, omega2 = 2*pi[1/3, -1/4]/halfLambda ----
fprintf('\n=== Fig. 4c: planar array ===\n');
omega2_4c = 2*pi*[1/3; -1/4]/halfLambda;
Omega_4c = zeros(3,2); Omega_4c(1:2,:) = [omega1, omega2_4c];
[Dt_4c, Dr_4c] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega_4c, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 4c - planar array geometry');
subplot(1,2,1);
scatter(Dt_4c(:,1)/halfLambda, Dt_4c(:,2)/halfLambda, 50, 's', 'filled', 'MarkerFaceColor', DT_COLOR); grid on; axis equal;
xlabel('d_{t,1} [\lambda/2]'); ylabel('d_{t,2} [\lambda/2]'); title('Tx');
subplot(1,2,2);
scatter(Dr_4c(:,1)/halfLambda, Dr_4c(:,2)/halfLambda, 50, 'o', 'filled', 'MarkerFaceColor', DR_COLOR);
grid on; axis equal;
xlabel('d_{r,1} [\lambda/2]'); ylabel('d_{r,2} [\lambda/2]'); title('Rx');
sgtitle('Fig. 4c reproduction: planar array, K=2 (\omega_2=2\pi[1/3,-1/4]/(\lambda/2))');
save_figure(gcf, 'fig4c_planar_array');

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
scatter(Dt(:,1)/halfLambda, Dt(:,2)/halfLambda, 50, 's', 'filled', 'MarkerFaceColor', DT_COLOR); grid on; axis equal;
xlabel('d_{t,1} [\lambda/2]'); ylabel('d_{t,2} [\lambda/2]'); title('Tx');
subplot(1,2,2);
scatter(Dr(:,1)/halfLambda, Dr(:,2)/halfLambda, 50, 'o', 'filled', 'MarkerFaceColor', DR_COLOR);
grid on; axis equal;
xlabel('d_{r,1} [\lambda/2]'); ylabel('d_{r,2} [\lambda/2]'); title('Rx');
sgtitle('Fig. 6 reproduction: planar array, K=3');
save_figure(gcf, 'fig6_planar_array_K3');

%% ---- Fig. 5a: cubic array, K=2, Nt=Nr=50, L=4 (values confirmed exact from paper p.5) ----
fprintf('\n=== Fig. 5a: cubic array, K=2 ===\n');
numDim = 3; L = 4; N = 50;
omega1 = 2*pi/halfLambda * [-1/6; 0; sqrt(2)/3];
omega2 = 2*pi/halfLambda * [ 1/6; 0; sqrt(2)/3];
Omega = [omega1, omega2];
gamma = ones(2,1);

Ct = candidate_positions(L, numDim, lambda);
Cr = Ct;
opts.maxOuterIters = 15; % cubic candidate set is large; cap for runtime
[Dt, Dr] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 5a - cubic array geometry');
subplot(1,2,1);
scatter3(Dt(:,1)/halfLambda, Dt(:,2)/halfLambda, Dt(:,3)/halfLambda, 50, 's', 'filled', 'MarkerFaceColor', DT_COLOR);
grid on; xlabel('d_{t,1}'); ylabel('d_{t,2}'); zlabel('d_{t,3}'); title('Tx');
subplot(1,2,2);
scatter3(Dr(:,1)/halfLambda, Dr(:,2)/halfLambda, Dr(:,3)/halfLambda, 50, 'o', 'filled', ...
    'MarkerFaceColor', DR_COLOR);
grid on; xlabel('d_{r,1}'); ylabel('d_{r,2}'); zlabel('d_{r,3}'); title('Rx');
sgtitle('Fig. 5a reproduction: cubic array, K=2');
save_figure(gcf, 'fig5a_cubic_array');

%% ---- Fig. 5b: cubic array, K=2, same Nt=Nr=50, L=4, different omega1/omega2 ----
fprintf('\n=== Fig. 5b: cubic array, K=2 ===\n');
omega1_5b = 2*pi/halfLambda * [0; 0; 1/2];
omega2_5b = 2*pi/halfLambda * [1/3; 0; sqrt(5)/6];
Omega_5b = [omega1_5b, omega2_5b];
[Dt_5b, Dr_5b] = sensor_relocation_algorithm(Ct, Cr, N, N, Omega_5b, gamma, sigma2, numDim, fType, opts);

figure('Name','Fig 5b - cubic array geometry');
subplot(1,2,1);
scatter3(Dt_5b(:,1)/halfLambda, Dt_5b(:,2)/halfLambda, Dt_5b(:,3)/halfLambda, 50, 's', 'filled', 'MarkerFaceColor', DT_COLOR);
grid on; xlabel('d_{t,1}'); ylabel('d_{t,2}'); zlabel('d_{t,3}'); title('Tx');
subplot(1,2,2);
scatter3(Dr_5b(:,1)/halfLambda, Dr_5b(:,2)/halfLambda, Dr_5b(:,3)/halfLambda, 50, 'o', 'filled', ...
    'MarkerFaceColor', DR_COLOR);
grid on; xlabel('d_{r,1}'); ylabel('d_{r,2}'); zlabel('d_{r,3}'); title('Rx');
sgtitle('Fig. 5b reproduction: cubic array, K=2 (alt. angles)');
save_figure(gcf, 'fig5b_cubic_array');

fprintf('\nAll geometry figures generated.\n');
