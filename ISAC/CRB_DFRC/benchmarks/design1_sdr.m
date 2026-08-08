function [RX_d1, diagnostics] = design1_sdr(H, Gamma, sigmaC2, PT, theta_target_rad, mainlobe_width_rad, angle_grid_rad, d_spacing, grid_cache)
%DESIGN1_SDR Benchmark "Beampattern Approx. Design 1" (ref [10]), total-power adapted.
%
%   [RX_d1, diagnostics] = DESIGN1_SDR(H, Gamma, sigmaC2, PT, theta_target_rad, mainlobe_width_rad, angle_grid_rad, d_spacing, grid_cache)
%
%   PHASE 13 OPTIMIZATION (backward compatible): the optional 9th
%   argument grid_cache, if supplied as a struct with fields
%   .A_grid and .d_theta (both precomputed exactly as this function
%   would compute them internally), skips the Nt x Ngrid steering-
%   vector-grid recomputation that would otherwise happen on EVERY
%   Monte Carlo trial despite depending only on fixed geometry
%   (Nt, angle_grid_rad, d_spacing, theta_target_rad,
%   mainlobe_width_rad -- none of which vary across trials or even
%   across an entire figure's sweep). Omit grid_cache (or pass [])
%   to fall back to the original per-call computation -- fully
%   backward compatible with the Phase 6 frozen signature.
%
%   Reproduces the joint radar+communication SDR beamforming of
%   X. Liu, T. Huang, N. Shlezinger, Y. Liu, J. Zhou, Y. C. Eldar,
%   "Joint Transmit Beamforming for Multiuser MIMO Communications and
%   Radar," arXiv:1912.03420 -- their Eqs. (12)-(14) [radar loss] and
%   (26)-(32) [SDR beamforming problem], with TWO adaptations agreed
%   for fair comparison against the CRB paper's own problem setup
%   (locked assumptions A2/A3, confirmed by user):
%     (i)  TOTAL power constraint tr(RX)<=PT, replacing the original
%          per-antenna equality [R]_mm = Pt/M.
%     (ii) Desired beampattern is a SINGLE mainlobe at theta_target
%          with 3dB width mainlobe_width_rad (CRB paper Sec. V setup),
%          so the cross-correlation loss L_{r,2} (their Eq. 13) is
%          IDENTICALLY ZERO (Assumption A7: no direction PAIRS exist
%          with only one target direction of interest) and is omitted
%          from the objective entirely.
%
%   This benchmark jointly designs a FULL-RANK-CAPABLE radar precoder
%   Wr (Nt x Nt) together with the K comm. precoder columns Wc -- i.e.
%   DoF = Nt, matching the CRB paper's own extended-target augmented
%   structure in spirit (though this is the POINT-target comparison
%   figure family; see CRB paper Figs. 3-7).
%
%   SDP (lifted, adapted from ref [10] Eqs. 30-32):
%       minimize_{RX,{Ri},alpha}  (1/Ngrid) * sum_l |alpha*d(theta_l) - a(theta_l)'*RX*a(theta_l)|^2
%       s.t.  RX = sum_i Ri  (i=1..Nt+K),   Ri PSD
%             tr(RX) <= PT                                    [adaptation (i)]
%             SINR constraints (ref[10] Eq. 30e, individual Gamma_k form)
%
%   Only RX (not individual rank-1 beamformers) is needed downstream,
%   since this benchmark is evaluated purely on ITS COVARIANCE's
%   CRB/beampattern/SINR -- no rank-1 extraction is performed here
%   (Phase 5 Module 11 pitfall note: Design 1 has no Theorem-2-style
%   rank-1 tightness guarantee, so attempting extraction would be a
%   category error; we evaluate metrics directly on RX_d1).
%
%   Inputs:
%       H                   : K x Nt, channel matrix
%       Gamma               : K x 1, per-user SINR thresholds (linear)
%       sigmaC2             : scalar, comm. noise variance [W]
%       PT                  : scalar, total power budget [W]
%       theta_target_rad    : scalar, mainlobe center [rad]
%       mainlobe_width_rad  : scalar, 3dB mainlobe width [rad]
%       angle_grid_rad      : 1 x Ngrid, beampattern evaluation grid [rad]
%       d_spacing           : scalar, ULA spacing [wavelengths]
%
%   Outputs:
%       RX_d1       : Nt x Nt, Hermitian PSD transmit covariance
%       diagnostics : struct with field .cvx_status
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    K = size(H,1);
    Nt = size(H,2);
    Gamma = Gamma(:);

    if nargin >= 9 && ~isempty(grid_cache)
        A_grid = grid_cache.A_grid;
        d_theta = grid_cache.d_theta;
    else
        A_grid = steering_vectors_grid(angle_grid_rad, Nt, d_spacing);   % Nt x Ngrid
        d_theta = double(abs(angle_grid_rad - theta_target_rad) <= mainlobe_width_rad/2).';  % Ngrid x 1
    end

    hk = cell(K,1);
    Qk = cell(K,1);
    for k = 1:K
        hk{k} = H(k,:)';
        Qk{k} = hk{k}*hk{k}';
    end

    try
        cvx_begin sdp quiet
            variable RX(Nt,Nt) hermitian semidefinite
            variable Wr(Nt,Nt) hermitian semidefinite      % dedicated radar-only precoder lift
            variable alpha_scale

            % BUGFIX (real-CVX run, see conversation log -- TWO
            % consecutive attempts at an N-D "stacked" declaration
            % both failed against real CVX: neither
            % "Wc1(Nt,Nt,K) hermitian semidefinite" nor
            % "Wc1(Nt,Nt,K) hermitian" + per-slice semidefinite()
            % constraints worked; CVX's N-D structure keywords are not
            % reliably supported here). FINAL FIX: declare K
            % independent, dynamically-NAMED 2D Hermitian PSD
            % variables via eval(), using only the plain single-2D
            % declaration style already proven to work for RX/Wr.
            for k = 1:K
                eval(sprintf('variable Wc1_%d(Nt,Nt) hermitian semidefinite', k));
            end
            Wc1 = cell(K,1);
            Wc1sum = 0;
            for k = 1:K
                Wc1{k} = eval(sprintf('Wc1_%d', k));
                Wc1sum = Wc1sum + Wc1{k};
            end

            % BUGFIX (real-CVX run): the previous
            % real(diag(A_grid' * RX * A_grid)) forms the FULL
            % Ngrid x Ngrid CVX affine expression matrix before taking
            % its diagonal -- since RX is a live optimization variable,
            % CVX must symbolically track every one of the Ngrid^2
            % entries as an affine function of RX's Nt^2 coefficients,
            % requiring an internal (Nt^2*Ngrid) x Ngrid representation
            % (exactly the 461056 x 1801 = 16^2*1801 x 1801 array MATLAB
            % refused to allocate). The fix mirrors compute_beampattern.m's
            % already-correct numeric approach: compute RX*A_grid first
            % (Nt x Ngrid, cheap), then a columnwise weighted sum -- this
            % stays a size-Ngrid VECTOR of affine scalars, never forming
            % the outer Ngrid x Ngrid matrix.
            bp_response = real(sum(conj(A_grid) .* (RX*A_grid), 1)).';   % Ngrid x 1

            minimize( sum_square_abs(alpha_scale*d_theta - bp_response) )
            subject to
                RX == Wr + Wc1sum;
                real(trace(RX)) <= PT;     % adaptation (i): total power
                alpha_scale >= 0;

                for k = 1:K
                    interf = 0;
                    for i = 1:K
                        if i ~= k
                            interf = interf + real(trace(Qk{k}*Wc1{i}));
                        end
                    end
                    real(trace(Qk{k}*Wc1{k})) - Gamma(k)*interf >= Gamma(k)*sigmaC2;
                end
        cvx_end
    catch ME
        % Defensive: an error INSIDE cvx_begin...cvx_end (as happened
        % above) leaves cvx_end never reached, corrupting CVX's
        % internal problem stack for every SUBSEQUENT call in this
        % MATLAB session (visible in the log as repeated "A non-empty
        % cvx problem already exists" warnings cascading through every
        % later figure). Clearing explicitly here prevents that
        % cascade even if some other unexpected error occurs.
        if exist('cvx_clear','file'); cvx_clear; end
        rethrow(ME);
    end

    diagnostics = struct('cvx_status', cvx_status, 'cvx_optval', cvx_optval);

    if strcmpi(cvx_status,'Solved') || strcmpi(cvx_status,'Inaccurate/Solved')
        RX_d1 = (RX + RX')/2;
    else
        RX_d1 = NaN(Nt,Nt);
        warning('design1_sdr:notSolved', 'CVX status = %s for Design 1 benchmark.', cvx_status);
    end
end
