function [W_ssp, R_ssp, converged] = ssp_baseline(H, Gamma_linear, R0, params)
%SSP_BASELINE  Sum-square-penalty DFRC baseline of reference [42].
%
%   [W_ssp, R_ssp, converged] = SSP_BASELINE(H, Gamma_linear, R0, params)
%
%   CORRECTED per the actual reference: F. Liu, C. Masouros, A. Li,
%   H. Sun, L. Hanzo, "MU-MIMO Communications with MIMO Radar: From
%   Co-existence to Joint Transmission," arXiv:1707.00519 -- this is the
%   "[42]" cited by the target paper (arXiv:1912.03420) for the SSP
%   baseline. Section III-D / IV-C of that reference gives the exact
%   penalty structure, which we reproduce here (adapted to our K x M
%   channel convention H, where their y=h^T*t model becomes our
%   y=H*x+n, i.e. their h_i^T*t_i becomes our [H*Wc]_{k,k}):
%
%   Sum-square SINR penalty (their eq. 21-24): define, per user k,
%       alpha_k(Wc) = |F(k,k)|^2 - Gamma * sum_{j~=k} |F(k,j)|^2,
%       F = H*Wc                                              (K x K)
%   Then the penalty term is
%       lambda(alpha) = sum_k ( alpha_k - Gamma*sigma^2 )^2
%   which is ZERO exactly when gamma_k = Gamma for every k (their
%   Section VI-A: "the given SINR at each user is equal to the SINR
%   threshold Gamma" -- confirming a TWO-SIDED equality-seeking penalty,
%   not a one-sided gamma_k>=Gamma hinge as an earlier version of this
%   file incorrectly used). Crucially, alpha_k is a purely QUADRATIC
%   (polynomial) function of Wc -- no division by a SINR denominator --
%   which is both faithful to the reference and numerically better
%   conditioned than a ratio-based penalty.
%
%   Full objective (their eq. 56, oblique/per-antenna-constraint case):
%       f(Wc) = rho1*||Wc*Wc^H - R0||_F^2 + rho2*lambda(alpha)
%       s.t.   [Wc*Wc^H]_{m,m} = Pt/M  for all m
%   with Wr == 0 (only communication symbols are precoded, matching the
%   paper's description of [42] as precoding only Wc).
%
%   REMAINING SIMPLIFICATION (documented, not from the paper): the
%   reference solves this via a full Riemannian conjugate-gradient (RCG)
%   optimizer on the oblique manifold (their Algorithm 3, eq. 58-65),
%   with Armijo-rule step sizes and vector transport between tangent
%   spaces. We solve the same objective with a simpler projected
%   gradient descent + backtracking line search instead of full RCG --
%   this reaches the same fixed points (the objective and per-antenna
%   manifold are identical) but may converge slower / less smoothly than
%   their conjugate-gradient scheme. See params.ssp_max_iter,
%   params.ssp_tol, params.ssp_step0 in config/parameters.m.
%
%   Inputs:
%     H            - K x M downlink channel matrix
%     Gamma_linear - scalar SINR threshold, LINEAR (not dB)
%     R0           - M x M radar-only optimal covariance (from eq. 15)
%     params       - struct from config/parameters.m
%
%   Outputs:
%     W_ssp     - M x (M+K) precoder [Wc, 0_{MxM}] (radar part is zero)
%     R_ssp     - M x M covariance Wc*Wc^H
%     converged - logical, true if stopping tolerance was reached before
%                 hitting the iteration cap
%
%   Author: Ali ArabiBavil
%   Date:   2026

M   = params.M;
Pt  = params.Pt;
sigma2 = params.sigma2;
rho1 = params.ssp_rho1;
rho2 = params.ssp_rho2;
max_iter = params.ssp_max_iter;
tol      = params.ssp_tol;
step     = params.ssp_step0;
K = size(H,1);

% --- Initialization: random Wc satisfying the per-antenna constraint ---
Wc = (randn(M,K) + 1j*randn(M,K)) / sqrt(2);
Wc = project_per_antenna(Wc, Pt, M);

f_prev = ssp_objective(Wc, H, R0, sigma2, Gamma_linear, rho1, rho2);
converged = false;

for iter = 1:max_iter
    Grad = ssp_gradient(Wc, H, R0, sigma2, Gamma_linear, rho1, rho2);
    gnorm = norm(Grad, 'fro');
    if gnorm < tol
        converged = true;
        break;
    end

    % Backtracking line search (simple halving rule; our choice, in
    % place of the reference's Armijo-rule Riemannian line search)
    step_try = step;
    for bt = 1:20
        Wc_new = project_per_antenna(Wc - step_try * Grad, Pt, M);
        f_new = ssp_objective(Wc_new, H, R0, sigma2, Gamma_linear, rho1, rho2);
        if f_new <= f_prev
            break;
        end
        step_try = step_try / 2;
    end

    if abs(f_prev - f_new) < tol * max(1, abs(f_prev))
        Wc = Wc_new;
        converged = true;
        break;
    end

    Wc = Wc_new;
    f_prev = f_new;
end

R_ssp = Wc * Wc';
W_ssp = [Wc, zeros(M,M)]; % Wr = 0, matching [42]'s comm-only precoding

end

% =========================================================================
function f = ssp_objective(Wc, H, R0, sigma2, Gamma, rho1, rho2)
%SSP_OBJECTIVE  f(Wc) = rho1*||WcWc^H-R0||_F^2 + rho2*sum_k (alpha_k-Gamma*sigma2)^2
%   alpha_k = |F(k,k)|^2 - Gamma*sum_{j~=k}|F(k,j)|^2, F = H*Wc.
%   See file header for the derivation matching reference [42], eq.(24).
R = Wc * Wc';
term1 = rho1 * norm(R - R0, 'fro')^2;

F = H * Wc; % K x K
K_ = size(F,1);
target = Gamma * sigma2;
term2 = 0;
for k = 1:K_
    idx_off = [1:k-1, k+1:K_];
    alpha_k = abs(F(k,k))^2 - Gamma * sum(abs(F(k, idx_off)).^2);
    term2 = term2 + (alpha_k - target)^2;
end
f = term1 + rho2 * term2;
end

% =========================================================================
function Grad = ssp_gradient(Wc, H, R0, sigma2, Gamma, rho1, rho2)
%SSP_GRADIENT  Analytic Wirtinger-calculus gradient of ssp_objective wrt Wc*.
%
%   Term 1: d/dWc* rho1*||WcWc^H-R0||_F^2 = 2*rho1*(WcWc^H-R0)*Wc
%
%   Term 2: for e_k := alpha_k - Gamma*sigma2,
%       d(e_k^2)/dF(k,k)*  =  2*e_k*F(k,k)                  (since
%           d|F(k,k)|^2/dF(k,k)* = F(k,k))
%       d(e_k^2)/dF(k,j)*  = -2*Gamma*e_k*F(k,j), j~=k       (since
%           d(-Gamma|F(k,j)|^2)/dF(k,j)* = -Gamma*F(k,j))
%   then propagated to Wc via the linear chain rule for F=H*Wc:
%       dh/dWc* = H^H * (dh/dF*).
R = Wc * Wc';
Grad1 = 2 * rho1 * (R - R0) * Wc;

F = H * Wc; % K x K
K_ = size(F,1);
target = Gamma * sigma2;
Grad_F = zeros(K_, K_);

for k = 1:K_
    idx_off = [1:k-1, k+1:K_];
    alpha_k = abs(F(k,k))^2 - Gamma * sum(abs(F(k, idx_off)).^2);
    e_k = alpha_k - target;

    Grad_F(k,k)       = 2 * e_k * F(k,k);
    Grad_F(k, idx_off) = -2 * Gamma * e_k * F(k, idx_off);
end

Grad2 = H' * Grad_F; % M x K, chain rule through linear map F = H*Wc

Grad = Grad1 + rho2 * Grad2;
end

% =========================================================================
function Wc_proj = project_per_antenna(Wc, Pt, M)
%PROJECT_PER_ANTENNA  Row-wise rescaling to enforce [WcWc^H]_{m,m}=Pt/M.
%
%   This is an exact projection onto the oblique manifold M defined in
%   reference [42] eq.(55): since each row's power depends only on that
%   row, scaling row m by a positive real factor exactly fixes that
%   row's power without affecting other rows.
Wc_proj = Wc;
target = Pt / M;
for m = 1:M
    row_power = sum(abs(Wc(m,:)).^2);
    if row_power > 0
        Wc_proj(m,:) = Wc(m,:) * sqrt(target / row_power);
    else
        % Degenerate all-zero row: seed with a small random vector
        v = (randn(1,size(Wc,2)) + 1j*randn(1,size(Wc,2)));
        Wc_proj(m,:) = v * sqrt(target / sum(abs(v).^2));
    end
end
end