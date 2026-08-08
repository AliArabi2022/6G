function W = compute_W(S, Upsilon, Nr)
%COMPUTE_W Compute the effective waveform-redundancy matrix W.
%
%   W = COMPUTE_W(S, Upsilon, Nr) implements Eq. (3):
%       W = (S kron I_Nr) * Upsilon
%
%   PURPOSE
%       W is the key quantity whose rank determines whether the
%       redundancy subspace condition (RSC, Eq. 6) holds for a given
%       waveform matrix S (Lemma 1).
%
%   INPUTS
%       S       - T_len x Nt waveform matrix
%       Upsilon - (Nt*Nr) x NSigma redundancy pattern matrix (sparse,
%                 from compute_redundancy_pattern.m)
%       Nr      - scalar, number of Rx sensors (needed to build I_Nr)
%
%   OUTPUTS
%       W - (T_len*Nr) x NSigma matrix (Eq. 3)
%
%   REQUIRED EQUATIONS
%       Eq. (3)
%
%   ERROR CHECKING
%       Validates that size(S,2)*Nr == size(Upsilon,1), i.e. that S and
%       Upsilon have compatible Kronecker dimensions (Nt must match).
%
%   MATLAB IMPLEMENTATION STRATEGY (Phase 13 optimization note — RESOLVED)
%       This uses speye(Nr) (SPARSE identity), not eye(Nr) (dense). This
%       is deliberate and already resolves the memory-efficiency concern
%       flagged earlier in the design process (Phases 3/5): MATLAB's
%       kron() automatically returns a SPARSE result whenever at least
%       one input is sparse, so kron(S, speye(Nr)) has only
%       T_len*Nt*Nr nonzero entries rather than materializing the full
%       (T_len*Nr) x (Nt*Nr) DENSE matrix. This was verified empirically
%       (Phase 13): for T_len=Nt=7, Nr=6, the sparse result has 294
%       nonzeros vs. 1764 entries for the dense equivalent -- a 6x
%       reduction that scales with Nr. No further optimization of this
%       line is needed at this problem's scale.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    [~, Nt] = size(S);
    NtNr = size(Upsilon, 1);

    if Nt * Nr ~= NtNr
        error('compute_W:dimensionMismatch', ...
            ['Incompatible dimensions: size(S,2)*Nr = %d*%d = %d, but ' ...
             'size(Upsilon,1) = %d. S and Upsilon must correspond to ' ...
             'the same Nt, Nr.'], Nt, Nr, Nt*Nr, NtNr);
    end

    W = kron(S, speye(Nr)) * Upsilon;

end
