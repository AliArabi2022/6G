function [z, u, t, T_u, cvx_ok] = atomic_norm_recovery(y, W, sigma, tau_override)
%ATOMIC_NORM_RECOVERY Recover co-array measurement via atomic norm minimization.
%
%   [z, u, t, T_u, cvx_ok] = ATOMIC_NORM_RECOVERY(y, W, sigma, tau_override)
%
%   PURPOSE
%       Solves the SDP from Section IV to recover the co-array
%       measurement z and Hermitian Toeplitz matrix T(u) from the raw
%       measurement y:
%
%           minimize_{z,u in C^NSigma; t>=0}
%               ||y - W*z||_2^2 + (t + u(1)) * tau
%           subject to:
%               [T(u), z; z', t] >= 0   (PSD)
%
%       where tau = sigma (assumed known noise std), per the paper's
%       stated choice.
%
%   SIGMA = 0 SPECIAL CASE (paper footnote 3, handled as an EXPLICIT
%   BRANCH, not a limit tau->0 of the general formula -- see Phase 3/6
%   design notes)
%       "When sigma = 0, we constrain W*z = y and set tau = 1."
%       This changes the problem from a penalized least-squares SDP to
%       a hard-constrained feasibility-style SDP:
%
%           minimize_{z,u in C^NSigma; t>=0}  (t + u(1))
%           subject to:
%               W*z == y
%               [T(u), z; z', t] >= 0
%
%   INPUTS
%       y            - (Nr*T_len) x 1 measurement vector
%       W            - (Nr*T_len) x NSigma effective sensing matrix (Eq. 3)
%       sigma        - noise standard deviation (sigma >= 0). If
%                      sigma==0, the hard-constrained branch is used.
%       tau_override - (optional) override for tau; if empty/omitted,
%                      tau = sigma (sigma>0) or tau = 1 (sigma==0), per
%                      the paper's stated choice (footnote 3).
%
%   OUTPUTS
%       z      - NSigma x 1 recovered co-array measurement
%       u      - NSigma x 1 Toeplitz-generating vector
%       t      - scalar SDP slack variable
%       T_u    - NSigma x NSigma Hermitian Toeplitz matrix built from u
%                (materialized numerically, for direct use by
%                root_music.m)
%       cvx_ok - logical, true if cvx_status is 'Solved' (or 'Inaccurate/Solved'),
%                false otherwise. CALLERS MUST CHECK THIS -- see
%                Phase 12 (Debugging): silently trusting a failed/
%                infeasible solve would corrupt downstream MSE results.
%
%   REQUIRED EQUATIONS
%       Section IV atomic norm minimization SDP; footnote 3.
%
%   ERROR CHECKING
%       Validates y, W dimensions are compatible. Does NOT throw on
%       solver failure (returns cvx_ok=false instead), since solver
%       failures can occur transiently during a long Monte Carlo sweep
%       and the caller (main.m) should decide how to handle them
%       (e.g. skip trial, log warning) rather than have the whole
%       sweep crash.
%
%   REQUIRES: CVX (http://cvxr.com/cvx/), with an SDP-capable solver
%       (SDPT3, SeDuMi, or Mosek). Assumes CVX is already set up on the
%       MATLAB path (cvx_setup already run once by the user).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    [M, NSigma] = size(W);
    if numel(y) ~= M
        error('atomic_norm_recovery:dimMismatch', ...
            'numel(y)=%d must equal size(W,1)=%d.', numel(y), M);
    end
    validateattributes(sigma, {'numeric'}, {'scalar','nonnegative'}, ...
        mfilename, 'sigma');

    y = y(:);

    if nargin < 4 || isempty(tau_override)
        if sigma == 0
            tau = 1;   % footnote 3
        else
            tau = sigma; % "tau is set to the standard deviation of the
                         %  noise, tau = sigma (assumed known)"
        end
    else
        tau = tau_override;
    end

    cvx_ok = false;

    if sigma == 0
        % --- Hard-constrained branch (footnote 3) ---
        cvx_clear;   %     defensively reset CVX's internal
                     %     state before each solve, guarding against
                     %     leftover state from an interrupted prior
                     %     cvx_begin/cvx_end pair elsewhere in the
                     %     session (a well-documented CVX gotcha).
        cvx_begin sdp quiet
            variable z(NSigma,1) complex
            variable u1
            variable u_tail(NSigma-1,1) complex
            variable t nonnegative
            u = [u1; u_tail];
            minimize( t + u1 )
            subject to
                W*z == y;
                [ toeplitz_herm(u), z; z', t ] == hermitian_semidefinite(NSigma+1);
        cvx_end
    else
        % --- General penalized branch ---
        cvx_clear;
        cvx_begin sdp quiet
            variable z(NSigma,1) complex
            variable u1                    % real by default -- no keyword needed
            variable u_tail(NSigma-1,1) complex
            variable t nonnegative
            u = [u1; u_tail];
            minimize( square_pos(norm(y - W*z, 2)) + (t + u1)*tau )
            subject to
                [ toeplitz_herm(u), z; z', t ] == hermitian_semidefinite(NSigma+1);
        cvx_end
    end

    if strcmpi(cvx_status, 'Solved') || strcmpi(cvx_status, 'Inaccurate/Solved')
        cvx_ok = true;
    else
        warning('atomic_norm_recovery:solverFailed', ...
            'CVX did not solve to optimality (cvx_status=''%s''). Returned values may be unreliable.', ...
            cvx_status);
    end

    % Materialize T(u) numerically for root_music.m (u is now numeric,
    % post-solve; toeplitz_herm.m works on plain numeric vectors too).
    T_u = toeplitz_herm(u);

end
