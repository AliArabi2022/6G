function [WC, WA, diagnostics] = extended_singleuser(h1, Gamma1, sigmaC2, PT, Nt)
%EXTENDED_SINGLEUSER Closed-form CRB(G)-optimal beamformer, K=1 extended target.
%
%   [WC, WA, diagnostics] = EXTENDED_SINGLEUSER(h1, Gamma1, sigmaC2, PT, Nt)
%
%   Implements Lemma 2 (Eqs. 37-39) and Theorem 3 (Eqs. 40-42):
%   the optimal RX shares eigenvectors with Q1 = h1*h1' (rank-1), and
%   the optimal eigenvalues follow a water-filling-like allocation:
%
%   FEASIBILITY: minimum power needed to meet the SINR floor,
%   Gamma1*sigmaC2/||h1||^2, must not exceed PT.
%
%   REGIME 1 (SINR inactive), Gamma1 < PT*||h1||^2/(Nt*sigmaC2), Eq.(40):
%       uniform allocation: lambda_ii = PT/Nt for all i=1..Nt
%
%   REGIME 2 (SINR active), Eqs.(41)-(42):
%       lambda_11 = Gamma1*sigmaC2/||h1||^2          (minimum along u1=h1/||h1||)
%       lambda_ii = (PT - lambda_11)/(Nt-1), i=2..Nt  (uniform over the rest)
%
%   The orthonormal eigenbasis Q is built via QR with the first column
%   forced to u1 = h1/||h1|| exactly (Lemma 2). Q(:,2:Nt) spans h1's
%   orthogonal complement; ANY unitary rotation of these columns gives
%   an equally optimal RX (non-uniqueness noted in diagnostics).
%
%   Inputs:
%       h1      : Nt x 1, user 1's channel vector
%       Gamma1  : scalar, SINR threshold (linear)
%       sigmaC2 : scalar, comm. noise variance [W]
%       PT      : scalar, total power budget [W]
%       Nt      : scalar, number of Tx antennas
%
%   Outputs:
%       WC : Nt x 1, communication beamformer (=w1)
%       WA : Nt x (Nt-1), auxiliary probing beamformer (sqrt-factor of
%            the leftover PSD covariance along h1's orthogonal complement)
%       diagnostics : struct with fields .feasible, .regime_used
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    validateattributes(h1, {'numeric'}, {'vector','numel',Nt});
    h1 = h1(:);

    diagnostics = struct('feasible', true, 'regime_used', '');

    lambda1_min = Gamma1*sigmaC2 / norm(h1)^2;
    if lambda1_min > PT
        diagnostics.feasible = false;
        WC = NaN(Nt,1);
        WA = NaN(Nt, Nt-1);
        warning('extended_singleuser:infeasible', ...
            'Infeasible: minimum power to meet SINR (%.3g) exceeds total power budget PT=%.3g.', lambda1_min, PT);
        return;
    end

    u1 = h1 / norm(h1);

    % Build an orthonormal basis with the first column EXACTLY u1
    % (Lemma 2 requirement), remaining columns an arbitrary orthonormal
    % complement obtained via QR of a random augmented matrix.
    [Qfull, ~] = qr([u1, randn(Nt, Nt-1) + 1i*randn(Nt, Nt-1)]);
    Qfull(:,1) = u1;
    % Re-orthogonalize columns 2:Nt against the (now fixed) column 1
    % using modified Gram-Schmidt, then re-QR to restore orthonormality:
    Vrest = Qfull(:,2:end) - u1*(u1'*Qfull(:,2:end));
    [Qrest, ~] = qr(Vrest, 0);
    Q = [u1, Qrest];

    threshold = PT * norm(h1)^2 / (Nt * sigmaC2);
    if Gamma1 < threshold
        diagnostics.regime_used = 'inactive';
        lambda = (PT/Nt) * ones(Nt,1);
    else
        diagnostics.regime_used = 'active';
        lambda1 = lambda1_min;
        lambda_rest = (PT - lambda1) / (Nt-1);
        lambda = [lambda1; lambda_rest*ones(Nt-1,1)];
    end

    % Phase-align w1 so that h1'*w1 is real & positive (arbitrary but
    % consistent convention; SINR/CRB are phase-invariant -- Assumption
    % A6-style non-uniqueness note, documented here for WC/WA too).
    w1 = sqrt(lambda(1)) * Q(:,1);
    phase_fix = exp(-1i*angle(h1'*w1));
    w1 = w1 * phase_fix;

    WC = w1;
    WA = Q(:,2:end) * diag(sqrt(lambda(2:end)));
end
