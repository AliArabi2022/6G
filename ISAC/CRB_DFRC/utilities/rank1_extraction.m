function [wk, Wk_tilde, rank1_gap] = rank1_extraction(Wk_hat, hk)
%RANK1_EXTRACTION Extract a rank-1 beamforming vector from an SDR solution.
%
%   [wk, Wk_tilde, rank1_gap] = RANK1_EXTRACTION(Wk_hat, hk)
%   implements the shared "dominant-direction-along-h_k" construction
%   used by BOTH:
%     - Theorem 2 (point-target multi-user, Eq. 33 of ref [10]-style
%       construction / the CRB paper's own analogous Eq. numbering)
%     - Theorem 4 (extended-target multi-user, Eq. 45 of the CRB paper)
%
%   Given an optimal (possibly non-rank-1) SDR solution Wk_hat for
%   user k, this returns the rank-1 matrix Wk_tilde = wk*wk' that:
%     (a) satisfies the SINR constraint for user k with EQUALITY
%         (i.e. uses the minimum necessary "signal power" -- any more
%         would be wasted power that could instead go to radar/other
%         users), and
%     (b) is guaranteed (by Theorem 2's or Theorem 4's proof) to
%         remain feasible and optimal for the original rank-1-
%         constrained problem.
%
%   Formula (Eq. 45):
%       wk       = (hk' * Wk_hat * hk)^(-1/2) * Wk_hat * hk
%       Wk_tilde = wk * wk'
%
%   Inputs:
%       Wk_hat : Nt x Nt, Hermitian PSD (SDR solution for user k)
%       hk     : Nt x 1, complex channel vector for user k
%
%   Outputs:
%       wk        : Nt x 1, extracted rank-1 beamforming vector
%       Wk_tilde  : Nt x Nt, wk*wk' (exactly rank-1 by construction)
%       rank1_gap : scalar, ratio lambda2/lambda1 of Wk_hat's
%                   eigenvalues -- a DIAGNOSTIC confirming how close
%                   the raw SDR solution already was to rank-1
%                   (expected ~0 per Theorem 2's tightness guarantee
%                   for the point-target case; can be non-negligible
%                   for the extended-target case, where Theorem 4's
%                   guarantee is about the EXTRACTED solution's
%                   optimality, not about Wk_hat itself being rank-1)
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    Nt = size(Wk_hat, 1);
    validateattributes(Wk_hat, {'numeric'}, {'size', [Nt Nt]});
    validateattributes(hk, {'numeric'}, {'size', [Nt 1]});

    % Defensive Hermitian symmetrization (Phase 5 Module 10 pitfall:
    % float error from the SDP solver can leave Wk_hat numerically
    % non-Hermitian, corrupting eig()).
    Wk_hat = (Wk_hat + Wk_hat')/2;

    % --- Diagnostic: rank-1 gap of the raw SDR solution ---
    eigvals = sort(eig(Wk_hat), 'descend');
    eigvals = max(real(eigvals), 0);   % clip negligible negative float noise
    if eigvals(1) > 0
        rank1_gap = eigvals(2) / eigvals(1);
    else
        rank1_gap = 0;   % degenerate all-zero solution
    end

    % --- Extraction (Eq. 45) ---
    denom = real(hk' * Wk_hat * hk);
    if denom <= 0
        error('rank1_extraction:nonPositiveDenominator', ...
            'hk''*Wk_hat*hk = %.3e <= 0; SDR solution does not deliver signal power to user (check SINR constraint / solver status).', denom);
    end
    wk = (denom)^(-1/2) * (Wk_hat * hk);
    Wk_tilde = wk * wk';
end
