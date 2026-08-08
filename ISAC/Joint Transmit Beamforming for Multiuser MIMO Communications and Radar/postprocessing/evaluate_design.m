function results = evaluate_design(W, R, H, params)
%EVALUATE_DESIGN  Compute all reporting metrics for a recovered precoder.
%
%   results = EVALUATE_DESIGN(W, R, H, params)
%
%   Inputs:
%     W      - M x (M+K) precoder [Wc, Wr] (Wc = W(:,1:K), Wr = W(:,K+1:end))
%     R      - M x M covariance (should equal W*W^H)
%     H      - K x M channel matrix
%     params - struct from config/parameters.m
%
%   Output: results struct with fields
%     P_theta      - 1xL beam pattern P(theta_l;R), eq. (10)
%     gamma        - Kx1 per-user SINR, eq. (21)
%     sum_rate     - scalar, eq. (22)
%     fairness_sinr- scalar, eq. (23)
%
%   Equation reference: (10),(17)-(23).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

M = params.M;
K = size(H,1);

if isempty(W) || isempty(R)
    results = struct('P_theta', [], 'gamma', [], 'sum_rate', NaN, ...
        'fairness_sinr', NaN, 'feasible', false);
    return;
end

Wc = W(:, 1:K);
Wr = W(:, K+1:end);

theta_grid = params.angle_grid_deg;
A_grid = steering_vector(theta_grid, M);
P_theta = real(sum(conj(A_grid) .* (R * A_grid), 1)); % eq. (10), vectorized

Fc = H * Wc; % eq. (17b)
Fr = H * Wr; % eq. (17a)
sigma2 = params.sigma2;

gamma = zeros(K,1);
for k = 1:K
    sig_power = abs(Fc(k,k))^2;                                   % eq. (18)
    interuser = sum(abs(Fc(k, [1:k-1, k+1:end])).^2);              % eq. (19)
    radar_int = sum(abs(Fr(k,:)).^2);                              % eq. (20)
    gamma(k) = sig_power / (interuser + radar_int + sigma2);       % eq. (21)
end

sum_rate      = sum(log2(1 + gamma));  % eq. (22)
fairness_sinr = min(gamma);            % eq. (23)

results = struct( ...
    'P_theta', P_theta, ...
    'gamma', gamma, ...
    'sum_rate', sum_rate, ...
    'fairness_sinr', fairness_sinr, ...
    'feasible', true);

end