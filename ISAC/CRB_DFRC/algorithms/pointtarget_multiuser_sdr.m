function [WD, diagnostics] = pointtarget_multiuser_sdr(a_vec, H, Gamma, sigmaC2, PT)
%POINTTARGET_MULTIUSER_SDR SDR-based CRB(theta)-optimal beamformer, K>=2 point target.
%
%   [WD, diagnostics] = POINTTARGET_MULTIUSER_SDR(a_vec, H, Gamma, sigmaC2, PT)
%
%   Implements Proposition 1's LMI reformulation (Eq. 29), the
%   linearized SINR constraint (Eq. 31), and the SDR-relaxed SDP
%   (Eq. 32), solved via CVX/SDPT3. Theorem 2 guarantees a rank-1
%   global optimum EXISTS for this relaxation; rank1_extraction.m
%   (Eq. 45-style construction) is applied to every solver output as
%   a safety net, since a generic SDP solver need not return an
%   exactly rank-1 numerical solution even when one is guaranteed to
%   exist among the optimal set (paper's own Remark after Theorem 2).
%
%   SDP (Eq. 32), epigraph/Schur-complement form of CRB(theta) (Eq. 29):
%       minimize_{t, RX, {Wk}}  t
%       s.t.  RX = sum_k Wk,           Wk PSD (Nt x Nt) for k=1..K
%             tr(RX) <= PT
%             [t, 1; 1, real(a'*RX*a)] is PSD             (Eq. 29)
%             tr(Qk*Wk) - Gamma_k*sum_{i~=k} tr(Qk*Wi) >= Gamma_k*sigmaC2   (Eq. 31)
%
%   Inputs:
%       a_vec   : Nt x 1, Tx steering vector at target angle
%       H       : K x Nt, channel matrix
%       Gamma   : K x 1, per-user SINR thresholds (linear)
%       sigmaC2 : scalar, comm. noise variance [W]
%       PT      : scalar, total power budget [W]
%
%   Outputs:
%       WD          : Nt x K, extracted rank-1 beamforming matrix [w_1,...,w_K]
%       diagnostics : struct with fields:
%                       .cvx_status   (string, e.g. 'Solved'/'Infeasible')
%                       .cvx_optval   (optimal t, i.e. 1/(a'*RX*a) bound)
%                       .rank1_gap    (K x 1, lambda2/lambda1 per user's raw Wk)
%
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
%
%   PITFALL (Phase 5 Module 7): CVX requires STATIC variable
%   declarations -- a native K x K x Nt x Nt 4D "hermitian
%   semidefinite" array is not directly supported. We declare K
%   separate Nt x Nt Hermitian-PSD variables via a loop over a cell
%   array constructed through repeated cvx variable statements using
%   MATLAB's dynamic `eval`-free approach: CVX's `variable` keyword
%   inside a for-loop with distinct variable NAMES is the officially
%   supported pattern (each iteration creates Wk_1, Wk_2, ... as
%   genuinely distinct CVX variables); we then collect them into a
%   cell array for use in the constraint-building loops below.

    Nt = numel(a_vec);
    K = size(H,1);
    a_vec = a_vec(:);
    Gamma = Gamma(:);
    validateattributes(H, {'numeric'}, {'size', [K Nt]});
    validateattributes(Gamma, {'numeric'}, {'numel', K});

    Qk = cell(K,1);
    hk = cell(K,1);
    for k = 1:K
        hk{k} = H(k,:)';
        Qk{k} = hk{k}*hk{k}';
    end

    try
        cvx_begin sdp quiet
            variable RX(Nt,Nt) hermitian semidefinite
            variable t

            % Declare K independent Hermitian PSD variables with
            % genuinely distinct names (Wk1_1 ... Wk1_K), using ONLY
            % the plain 2D declaration syntax already proven to work.
            for k = 1:K
                eval(sprintf('variable Wk1_%d(Nt,Nt) hermitian semidefinite', k));
            end

            % Collect into a cell array of LIVE cvx objects for
            % constraint-building below (valid only DURING model
            % construction, before cvx_end -- see semantics note above).
            Wk1 = cell(K,1);
            RXsum = 0;
            for k = 1:K
                Wk1{k} = eval(sprintf('Wk1_%d', k));
                RXsum = RXsum + Wk1{k};
            end

            minimize(t)
            subject to
                RX == RXsum;
                real(trace(RX)) <= PT;
                [t, 1; 1, real(a_vec'*RX*a_vec)] == semidefinite(2);   % Eq. (29) LMI

                for k = 1:K
                    interf = 0;
                    for i = 1:K
                        if i ~= k
                            interf = interf + real(trace(Qk{k}*Wk1{i}));
                        end
                    end
                    real(trace(Qk{k}*Wk1{k})) - Gamma(k)*interf >= Gamma(k)*sigmaC2;   % Eq. (31)
                end
        cvx_end

        % Re-fetch each Wk1_k identifier NOW that cvx_end has
        % overwritten it with its solved numeric value (see semantics
        % note above -- the Wk1 cell array built above is stale).
        for k = 1:K
            Wk1{k} = eval(sprintf('Wk1_%d', k));
        end
    catch ME
        % Defensive: an error INSIDE cvx_begin...cvx_end leaves
        % cvx_end never reached, corrupting CVX's internal problem
        % stack for every SUBSEQUENT call in the session (this is
        % exactly what produced the cascading "A non-empty cvx
        % problem already exists" warnings across later figures in
        % the log). Clearing here prevents that cascade.
        if exist('cvx_clear','file'); cvx_clear; end
        rethrow(ME);
    end

    diagnostics = struct('cvx_status', cvx_status, 'cvx_optval', cvx_optval, ...
                          'rank1_gap', zeros(K,1));

    WD = NaN(Nt, K);
    if strcmpi(cvx_status, 'Solved') || strcmpi(cvx_status, 'Inaccurate/Solved')
        for k = 1:K
            [wk, ~, gap] = rank1_extraction(Wk1{k}, hk{k});
            WD(:,k) = wk;
            diagnostics.rank1_gap(k) = gap;
        end
    else
        warning('pointtarget_multiuser_sdr:notSolved', ...
            'CVX status = %s; SDP likely infeasible at this (K,Gamma) operating point. Returning NaN beamformer.', cvx_status);
    end
end
