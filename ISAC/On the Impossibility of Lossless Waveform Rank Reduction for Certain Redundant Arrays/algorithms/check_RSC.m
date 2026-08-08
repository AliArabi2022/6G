function [RSC_holds, rank_W, NSigma, sv] = check_RSC(S, Upsilon, Nr, tol_scale)
%CHECK_RSC Check the Redundancy Subspace Condition (RSC), Lemma 1, Eq. (6).
%
%   [RSC_holds, rank_W, NSigma, sv] = CHECK_RSC(S, Upsilon, Nr, tol_scale)
%
%   PURPOSE
%       Determines whether a GIVEN waveform matrix S satisfies the
%       redundancy subspace condition:
%           rank((S kron I_Nr) * Upsilon) == NSigma
%       equivalently, dim(N(S kron I) intersect R(Upsilon)) == 0.
%       If RSC_holds is true, this specific S achieves maximum
%       identifiability (rank(B(theta)) = NSigma for all theta), even
%       if rank(S) < Nt (Lemma 1).
%
%   INPUTS
%       S         - T_len x Nt waveform matrix to test
%       Upsilon   - (Nt*Nr) x NSigma redundancy pattern matrix
%       Nr        - scalar, number of Rx sensors
%       tol_scale - (optional) passed through to numerical_rank.m;
%                   default 1
%
%   OUTPUTS
%       RSC_holds - logical, true if RSC (Eq. 6) is satisfied
%       rank_W    - the computed numerical rank of W = (S kron I)*Upsilon
%       NSigma    - number of columns of Upsilon (target rank)
%       sv        - singular values of W (diagnostic; see
%                   utilities/numerical_rank.m)
%
%   REQUIRED EQUATIONS
%       Eq. (3) [via compute_W.m], Eq. (6), Lemma 1
%
%   ERROR CHECKING
%       Delegated to compute_W.m (dimension check) and
%       numerical_rank.m (tolerance validation).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    if nargin < 4 || isempty(tol_scale)
        tol_scale = 1;
    end

    NSigma = size(Upsilon, 2);

    W = compute_W(S, Upsilon, Nr);
    [rank_W, ~, sv] = numerical_rank(W, tol_scale);

    RSC_holds = (rank_W == NSigma);

end
