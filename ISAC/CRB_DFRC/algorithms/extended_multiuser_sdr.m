function [WC, WA, diagnostics] = extended_multiuser_sdr(H, Gamma, sigmaC2, PT, Nt)
%   EXTENDED_MULTIUSER_SDR SDR-based CRB(G)-optimal beamformer, K>=2 extended target.
%
%   [WC, WA, diagnostics] = EXTENDED_MULTIUSER_SDR(H, Gamma, sigmaC2, PT, Nt)
%
%   Implements the SDR-relaxed extended-target SDP (Eq. 35, in the
%   simplified inequality form of Eq. 43: RX >= sum_k Wk, PSD), solved
%   via CVX's native trace_inv() convex atom, followed by Theorem 4's
%   CONSTRUCTIVE rank-1 extraction (Eqs. 44-46) -- which, unlike
%   Theorem 2 for the point-target case, does not claim the raw SDR
%   solution Wk_hat is already rank-1; instead it gives an explicit
%   post-processing recipe that is PROVEN to preserve optimality.
%
%   SDP:
%       minimize_{RX,{Wk}}  trace_inv(RX)
%       s.t.  RX - sum_k Wk  is PSD          (Eq. 43)
%             tr(RX) <= PT
%             SINR constraint (Eq. 17, linearized like Eq. 31 but with
%             the extra "leftover" interference folded into RX itself)
%
%   Inputs:
%       H       : K x Nt, channel matrix
%       Gamma   : K x 1, per-user SINR thresholds (linear)
%       sigmaC2 : scalar, comm. noise variance [W]
%       PT      : scalar, total power budget [W]
%       Nt      : scalar, number of Tx antennas
%
%   Outputs:
%       WC : Nt x K, extracted rank-1 communication beamformers
%       WA : Nt x Nt, extracted auxiliary probing beamformer (Eq. 46)
%       diagnostics : struct with fields:
%                       .cvx_status
%                       .cvx_optval
%                       .psd_clip_flag (K+1 x 1 logical: true if a
%                        "negative PSD eigenvalue" beyond float-noise
%                        tolerance was clipped during extraction --
%                        would indicate a real upstream bug, not
%                        expected in normal operation)
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    K = size(H,1);
    validateattributes(H, {'numeric'}, {'size', [K Nt]});
    Gamma = Gamma(:);

    hk = cell(K,1);
    Qk = cell(K,1);
    for k = 1:K
        hk{k} = H(k,:)';
        Qk{k} = hk{k}*hk{k}';
    end

    try
        cvx_begin sdp quiet
            variable RX(Nt,Nt) hermitian semidefinite

            % Declare K independent Hermitian PSD variables with
            % genuinely distinct names (Wk1_1 ... Wk1_K) -- see
            % pointtarget_multiuser_sdr.m's BUGFIX HISTORY note.
            for k = 1:K
                eval(sprintf('variable Wk1_%d(Nt,Nt) hermitian semidefinite', k));
            end

            Wk1 = cell(K,1);
            Wk1sum = 0;
            for k = 1:K
                Wk1{k} = eval(sprintf('Wk1_%d', k));
                Wk1sum = Wk1sum + Wk1{k};
            end

            minimize( trace_inv(RX) )
            subject to
                (RX - Wk1sum) == semidefinite(Nt);     % Eq. (43): RX >= sum_k Wk
                real(trace(RX)) <= PT;

                for k = 1:K
                    interf = 0;
                    for i = 1:K
                        if i ~= k
                            interf = interf + real(trace(Qk{k}*Wk1{i}));
                        end
                    end
                    % Extended-target SINR (Eq. 17) linearized: the
                    % "radar-probing interference" ||h_k' WA||^2 term is
                    % exactly RX's leftover power along h_k once all Wk
                    % are subtracted, i.e. tr(Qk*(RX-sum_i Wk_i)), which is
                    % already >= 0 by the PSD constraint above and is
                    % folded directly into the SINR constraint below:
                    radar_interf = real(trace(Qk{k}*RX)) - real(trace(Qk{k}*Wk1{k})) - interf;
                    real(trace(Qk{k}*Wk1{k})) - Gamma(k)*(interf + radar_interf) >= Gamma(k)*sigmaC2;
                end
        cvx_end

        % Re-fetch each Wk1_k identifier now that cvx_end has
        % overwritten it with its solved numeric value (see
        % pointtarget_multiuser_sdr.m's semantics note).
        for k = 1:K
            Wk1{k} = eval(sprintf('Wk1_%d', k));
        end
    catch ME
        if exist('cvx_clear','file'); cvx_clear; end
        rethrow(ME);
    end

    diagnostics = struct('cvx_status', cvx_status, 'cvx_optval', cvx_optval, ...
                          'psd_clip_flag', false(K+1,1));

    WC = NaN(Nt,K);
    WA = NaN(Nt,Nt);
    if strcmpi(cvx_status,'Solved') || strcmpi(cvx_status,'Inaccurate/Solved')
        Wk_tilde_sum = zeros(Nt,Nt);
        for k = 1:K
            % Eq. (44)-(45) constructive extraction
            Wk_hat = (Wk1{k} + Wk1{k}')/2;
            denom = real(trace(Qk{k}*Wk_hat));
            if denom <= 1e-12
                warning('extended_multiuser_sdr:zeroTraceQW', ...
                    'tr(Qk*Wk_hat) ~ 0 for user %d; SDR solution allocates no power to this user.', k);
                Wk_tilde = zeros(Nt,Nt);
                wk = zeros(Nt,1);
            else
                Wk_tilde = (Wk_hat*Qk{k}*Wk_hat') / denom;    % Eq. (44)
                wk = (hk{k}'*Wk_hat*hk{k})^(-1/2) * Wk_hat*hk{k};  % Eq. (45)
            end
            WC(:,k) = wk;
            Wk_tilde_sum = Wk_tilde_sum + Wk_tilde;
        end

        % Eq. (46): WA*WA' = RX_hat - sum_k Wk_tilde
        RX_hat = (RX + RX')/2;
        Rleft = RX_hat - Wk_tilde_sum;
        Rleft = (Rleft + Rleft')/2;
        [V, D] = eig(Rleft);
        d = real(diag(D));

        clip_tol = 1e-6;
        neg_mask = d < 0;
        if any(d(neg_mask) < -clip_tol)
            diagnostics.psd_clip_flag(K+1) = true;
            warning('extended_multiuser_sdr:negativeEigenvalue', ...
                'Rleft has an eigenvalue of %.3e (< -%.1e tolerance) after Theorem-4 extraction; this suggests numerical trouble upstream, not just float noise.', min(d), clip_tol);
        end
        d = max(d, 0);
        WA = V * diag(sqrt(d));
    else
        warning('extended_multiuser_sdr:notSolved', ...
            'CVX status = %s; SDP likely infeasible at this (K,Gamma) operating point.', cvx_status);
    end
end
