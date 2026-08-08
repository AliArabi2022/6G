function [RX_d2, R2_target, diagnostics] = design2_sdr(H, Gamma, sigmaC2, PT, theta_target_rad, mainlobe_width_rad, angle_grid_rad, d_spacing, R2_cached, grid_cache)
%DESIGN2_SDR Benchmark "Beampattern Approx. Design 2" (ref [11]), total-power adapted.
%
%   [RX_d2, R2_target, diagnostics] = DESIGN2_SDR(H, Gamma, sigmaC2, PT, theta_target_rad, mainlobe_width_rad, angle_grid_rad, d_spacing, R2_cached, grid_cache)
%
%   Reproduces the "shared deployment" of
%   F. Liu, C. Masouros, A. Li, H. Sun, L. Hanzo, "MU-MIMO
%   Communications with MIMO Radar: From Co-existence to Joint
%   Transmission," arXiv:1707.00519 -- their Eq. (9) [radar-only
%   target covariance] and Eq. (20) [comm-only beampattern matching],
%   TOTAL-POWER adapted (Assumption A2, user-confirmed) in place of
%   the original per-antenna equality constraint.
%
%   KEY STRUCTURAL DIFFERENCE from Design 1: here ONLY communication
%   symbols are precoded (no dedicated radar waveform), so the
%   achievable covariance has DoF <= K < Nt -- this is precisely the
%   "decreased MIMO radar DoF" effect the CRB paper's own narrative
%   attributes to methods that don't jointly precode radar+comm
%   streams (see Phase 0 Sec 0.2, "existing DFRC beamforming designs").
%
%   TWO-STAGE SOLVE:
%     Stage 1 (ref[11] Eq. 9 analog): solve for the unconstrained
%       radar-only target covariance R2 matching the desired
%       beampattern d(theta), subject ONLY to tr(R2)<=PT. This does
%       NOT depend on K, Gamma, or H -- cache and reuse across an
%       entire figure's sweep (Phase 5 Module 12 caching note,
%       Phase 6 Sec.6.2 R2_cached argument).
%     Stage 2 (ref[11] Eq. 20 analog): solve for K rank-1-relaxed
%       comm.-only precoders {Ti} minimizing ||sum_i Ti - R2||_F^2
%       subject to individual SINR constraints and tr(sum Ti)<=PT.
%
%   Inputs:
%       H, Gamma, sigmaC2, PT, theta_target_rad, mainlobe_width_rad,
%       angle_grid_rad, d_spacing : as in design1_sdr.m
%       R2_cached : [] to force Stage 1 recompute, or a previously
%                   returned R2_target (Nt x Nt) to reuse (pass [] on
%                   the first call of a sweep, then the returned
%                   R2_target on all subsequent calls with the SAME
%                   theta_target/mainlobe_width/PT).
%       grid_cache : PHASE 13 OPTIMIZATION (backward compatible,
%                   optional, defaults to recompute if omitted/[]).
%                   Struct with fields .A_grid, .d_theta precomputed
%                   exactly as this function would internally --
%                   skips the Nt x Ngrid steering-vector-grid
%                   recomputation on every Monte Carlo trial, since
%                   it depends only on fixed geometry, never on H,
%                   K, or Gamma.
%
%   Outputs:
%       RX_d2       : Nt x Nt, Hermitian PSD, Stage-2 achieved covariance
%       R2_target   : Nt x Nt, Stage-1 target covariance (return so
%                     caller can cache it for the next sweep point)
%       diagnostics : struct with .cvx_status_stage1, .cvx_status_stage2
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    K = size(H,1);
    Nt = size(H,2);
    Gamma = Gamma(:);

    if nargin >= 10 && ~isempty(grid_cache)
        A_grid = grid_cache.A_grid;
        d_theta = grid_cache.d_theta;
    else
        A_grid = steering_vectors_grid(angle_grid_rad, Nt, d_spacing);
        d_theta = double(abs(angle_grid_rad - theta_target_rad) <= mainlobe_width_rad/2).';
    end

    diagnostics = struct('cvx_status_stage1', '', 'cvx_status_stage2', '');

    % Phase 12 hardening: a stale R2_cached from a different Nt would
    % otherwise silently corrupt the Stage-2 objective ||RXi-R2_target||
    % (implicit singleton/broadcast expansion or a dimension-mismatch
    % error deep inside CVX, far from the actual root cause). Fail
    % loudly and immediately instead.
    if ~isempty(R2_cached)
        assert(isequal(size(R2_cached), [Nt Nt]), ...
            'design2_sdr:cacheDimMismatch', ...
            'R2_cached is %dx%d but expected %dx%d (Nt=%d); stale cache from a different array size?', ...
            size(R2_cached,1), size(R2_cached,2), Nt, Nt, Nt);
    end

    % ---------------- Stage 1: radar-only target covariance ----------------
    if isempty(R2_cached)
        try
            cvx_begin sdp quiet
                variable R2(Nt,Nt) hermitian semidefinite
                variable alpha2

                % BUGFIX (real-CVX run, see conversation log): avoid
                % forming the full Ngrid x Ngrid affine matrix (was
                % real(diag(A_grid' * R2 * A_grid)) -- requested a
                % 461056x1801 = Nt^2*Ngrid x Ngrid array). Compute
                % R2*A_grid first (Nt x Ngrid), then a columnwise
                % weighted sum -- stays a size-Ngrid vector of affine
                % scalars, matching compute_beampattern.m's numeric
                % approach.
                bp_response = real(sum(conj(A_grid) .* (R2*A_grid), 1)).';
                minimize( sum_square_abs(alpha2*d_theta - bp_response) )
                subject to
                    real(trace(R2)) <= PT;
                    alpha2 >= 0;
            cvx_end
        catch ME
            if exist('cvx_clear','file'); cvx_clear; end
            rethrow(ME);
        end
        diagnostics.cvx_status_stage1 = cvx_status;
        if strcmpi(cvx_status,'Solved') || strcmpi(cvx_status,'Inaccurate/Solved')
            R2_target = (R2 + R2')/2;
        else
            R2_target = NaN(Nt,Nt);
            warning('design2_sdr:stage1NotSolved', 'CVX status = %s for Design 2 Stage 1 (radar-only target).', cvx_status);
        end
    else
        R2_target = R2_cached;
        diagnostics.cvx_status_stage1 = 'cached';
    end

    % ---------------- Stage 2: comm-only beampattern matching ----------------
    hk = cell(K,1);
    Qk = cell(K,1);
    for k = 1:K
        hk{k} = H(k,:)';
        Qk{k} = hk{k}*hk{k}';
    end

    try
        cvx_begin sdp quiet
            % BUGFIX (real-CVX run, see conversation log -- TWO
            % consecutive attempts at an N-D "stacked" declaration
            % both failed against real CVX; see
            % pointtarget_multiuser_sdr.m's BUGFIX HISTORY note for
            % full detail). FINAL FIX: K independent, dynamically-NAMED
            % 2D Hermitian PSD variables via eval().
            for k = 1:K
                eval(sprintf('variable Ti_%d(Nt,Nt) hermitian semidefinite', k));
            end
            Ti = cell(K,1);
            RXi = 0;
            for k = 1:K
                Ti{k} = eval(sprintf('Ti_%d', k));
                RXi = RXi + Ti{k};
            end

            minimize( square_pos(norm(RXi - R2_target, 'fro')) )
            subject to
                real(trace(RXi)) <= PT;    % adaptation (i): total power

                for k = 1:K
                    interf = 0;
                    for i = 1:K
                        if i ~= k
                            interf = interf + real(trace(Qk{k}*Ti{i}));
                        end
                    end
                    real(trace(Qk{k}*Ti{k})) - Gamma(k)*interf >= Gamma(k)*sigmaC2;
                end
        cvx_end

        % RXi was built as sum(Ti{k}) DURING model construction, using
        % the live symbolic cvx objects -- it is NOT itself a
        % "variable"-declared identifier, so cvx_end's substitution
        % does not automatically refresh it. Re-fetch each Ti_k
        % (now numeric, post-solve) and recompute RXi's numeric value.
        RXi = zeros(Nt,Nt);
        for k = 1:K
            Ti{k} = eval(sprintf('Ti_%d', k));
            RXi = RXi + Ti{k};
        end
    catch ME
        if exist('cvx_clear','file'); cvx_clear; end
        rethrow(ME);
    end

    diagnostics.cvx_status_stage2 = cvx_status;
    if strcmpi(cvx_status,'Solved') || strcmpi(cvx_status,'Inaccurate/Solved')
        RX_d2 = (RXi + RXi')/2;
    else
        RX_d2 = NaN(Nt,Nt);
        warning('design2_sdr:stage2NotSolved', 'CVX status = %s for Design 2 Stage 2 (comm-only matching).', cvx_status);
    end
end
