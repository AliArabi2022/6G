function [w1, diagnostics] = pointtarget_singleuser(a_vec, h1, Gamma1, sigmaC2, PT)
%POINTTARGET_SINGLEUSER Closed-form CRB(theta)-optimal beamformer, K=1 point target.
%
%   [w1, diagnostics] = POINTTARGET_SINGLEUSER(a_vec, h1, Gamma1, sigmaC2, PT)
%
%   Implements Theorem 1 (Eqs. 26-28) via the reduced problem (24) and
%   Lemma 1's 2-D solution-subspace result (Eq. 25, Appendix A):
%   the optimal w1 always lies in span{a, h1}.
%
%   FEASIBILITY (Appendix B): problem (24) is feasible iff there is
%   enough power to meet the SINR floor using pure h1-direction
%   steering:  PT*||h1||^2 >= Gamma1*sigmaC2.
%
%   CASE 1 -- SINR constraint INACTIVE (Eq. 26):
%     Condition: PT*|h1'*a|^2 > Nt*Gamma1*sigmaC2
%     (enough "natural" alignment between a and h1 that the power-
%      maximizing-toward-target solution already satisfies SINR)
%       w1 = sqrt(PT) * a / ||a||
%
%   CASE 2 -- SINR constraint ACTIVE (Eqs. 27-28, Appendix B):
%     w1 = x1*u1 + x2*au   where
%       u1 = h1/||h1||                          (unit vector along h1)
%       au = (a - (u1'*a)*u1) / ||a - (u1'*a)*u1||   (Gram-Schmidt of a against u1)
%       x1 = sqrt(Gamma1*sigmaC2)/||h1|| * exp(1i*angle(h1'*a))   (meets SINR with equality)
%       x2 = sqrt(PT - |x1|^2) * exp(1i*angle(au'*a))             (remaining power toward a)
%
%   Inputs:
%       a_vec   : Nt x 1, Tx steering vector at the target angle
%       h1      : Nt x 1, user 1's channel vector
%       Gamma1  : scalar, SINR threshold (linear)
%       sigmaC2 : scalar, comm. noise variance [W]
%       PT      : scalar, total power budget [W]
%
%   Outputs:
%       w1          : Nt x 1, optimal beamforming vector
%       diagnostics : struct with fields:
%                       .feasible   (logical)
%                       .case_used  ('inactive' | 'active')
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
%
%   ASSUMPTION A6: the phase convention for x2 (which orthonormal
%   direction's phase reference to align to) is not explicitly stated
%   in the paper beyond the power split |x1|^2+|x2|^2<=PT; the choice
%   here (align x2 to maximize the REAL part of a'*w1, i.e. phase-lock
%   to au'*a) maximizes |a'*w1|^2 for the given magnitudes and is
%   validated numerically against the CVX single-user SDP solution in
%   Phase 11 (only the beamformer's overall phase reference is
%   non-unique; all physical metrics -- CRB, SINR, beampattern -- are
%   phase-invariant and therefore unaffected either way).

    Nt = numel(a_vec);
    validateattributes(a_vec, {'numeric'}, {'vector','numel',Nt});
    validateattributes(h1, {'numeric'}, {'vector','numel',Nt});
    a_vec = a_vec(:);
    h1 = h1(:);

    diagnostics = struct('feasible', true, 'case_used', '');

    % --- Feasibility pre-check (Appendix B) ---
    if PT*norm(h1)^2 < Gamma1*sigmaC2
        diagnostics.feasible = false;
        w1 = NaN(Nt,1);
        warning('pointtarget_singleuser:infeasible', ...
            'Infeasible: SINR threshold Gamma1=%.3g exceeds available power*channel-gain (PT*||h1||^2=%.3g).', Gamma1, PT*norm(h1)^2);
        return;
    end

    % --- Case dispatch (Eq. 26 condition) ---
    if PT * abs(h1'*a_vec)^2 > Nt * Gamma1 * sigmaC2
        % CASE 1: SINR inactive
        diagnostics.case_used = 'inactive';
        w1 = sqrt(PT) * a_vec / norm(a_vec);
    else
        % CASE 2: SINR active
        diagnostics.case_used = 'active';
        u1 = h1 / norm(h1);

        a_perp = a_vec - (u1'*a_vec)*u1;
        a_perp_norm = norm(a_perp);
        if a_perp_norm < 1e-10
            % Degenerate geometry: a is (numerically) parallel to h1.
            % Fall back to any unit vector orthogonal to u1 (Phase 3
            % Sec 3.5 numerical-issues note). The choice is arbitrary
            % since a's component along au is then zero regardless.
            tmp = null(u1');
            au = tmp(:,1);
        else
            au = a_perp / a_perp_norm;
        end

        x1 = sqrt(Gamma1*sigmaC2) / norm(h1) * exp(1i*angle(h1'*a_vec));
        remaining_power = max(PT - abs(x1)^2, 0);
        x2 = sqrt(remaining_power) * exp(1i*angle(au'*a_vec));

        w1 = x1*u1 + x2*au;
    end
end
