function theta_hat = mle_angle_search(YR, X, angle_grid_rad, Nr, Nt, d_spacing)
%MLE_ANGLE_SEARCH Exhaustive-grid maximum-likelihood point-target angle estimator.
%
%   theta_hat = MLE_ANGLE_SEARCH(YR, X, angle_grid_rad, Nr, Nt, d_spacing)
%
%   Implements the "Numerical Solution" / MLE benchmark referenced in
%   Figs. 2 and 4 captions (not separately numbered in the paper, but
%   implied by the point-target likelihood under the model (1)-(2)).
%
%   THEORY: for the point-target model YR = alpha*b(theta)*a'(theta)*X + ZR
%   with ZR white Gaussian, the ML estimator of theta (concentrating
%   out the unknown complex alpha in closed form) reduces to a
%   matched-filter / correlator search:
%
%       theta_hat = argmax_theta | b'(theta) * YR * X' * a(theta) |^2
%                                 -----------------------------------
%                                    ||b(theta)||^2 * ||X' a(theta)||^2
%
%   which is the standard "compressed" log-likelihood for a rank-1
%   bilinear signal in noise (concentrated MLE after profiling out
%   the nuisance amplitude alpha).
%
%   Inputs:
%       YR             : Nr x L, noisy radar echo (one MC realization)
%       X              : Nt x L, known transmitted signal
%       angle_grid_rad : 1 x Ngrid, search grid in RADIANS (Sec. V: 0.1 deg res)
%       Nr, Nt         : scalars, array sizes
%       d_spacing      : scalar, ULA spacing in wavelengths
%
%   Outputs:
%       theta_hat : scalar, ML angle estimate in RADIANS
%
%   Author: Ali Arabi Bavil
%   Date:   2026
%
%   PITFALL (Phase 5 Module 16): the 0.1 deg grid resolution imposes a
%   quantization floor on achievable RMSE. At high radar SNR, RMSE will
%   plateau near this floor rather than continuing to track CRB -- this
%   is an EXPECTED reproduction artifact of the paper's own stated grid
%   resolution, not a bug (documented again in Phase 11).

    [A_grid, ~] = steering_vectors_grid(angle_grid_rad, Nt, d_spacing);   % Nt x Ngrid
    [B_grid, ~] = steering_vectors_grid(angle_grid_rad, Nr, d_spacing);   % Nr x Ngrid

    XtA = X' * A_grid;                 % L x Ngrid, = X' * a(theta_l) per column
    aX_energy = sum(abs(XtA).^2, 1);   % 1 x Ngrid, = ||X' a(theta_l)||^2

    % Numerator: |b(theta_l)' * YR * X' * a(theta_l)|^2 for every l.
    % Compute Y_R * X' once (Nr x Nt is too specific since X' a depends
    % on theta_l too) -- instead compute per-column efficiently:
    %   b_l' * (YR * (X' a_l))  =  b_l' * YR * XtA(:,l)
    YR_XtA = YR * XtA;                  % Nr x Ngrid  (YR * (X'*a_l) for every l)
    numer = abs(sum(conj(B_grid) .* YR_XtA, 1)).^2;   % 1 x Ngrid

    b_energy = sum(abs(B_grid).^2, 1);  % 1 x Ngrid, = ||b(theta_l)||^2

    denom = b_energy .* aX_energy;
    denom = max(denom, eps);

    likelihood = numer ./ denom;        % 1 x Ngrid

    [~, idx] = max(likelihood);
    theta_hat = angle_grid_rad(idx);
end
