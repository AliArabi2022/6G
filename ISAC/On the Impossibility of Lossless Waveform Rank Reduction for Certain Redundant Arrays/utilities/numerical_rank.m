function [r, tol_used, sv] = numerical_rank(M, tol_scale)
%NUMERICAL_RANK Compute numerical rank of a matrix with an explicit tolerance.
%
%   [r, tol_used, sv] = NUMERICAL_RANK(M, tol_scale) wraps MATLAB's
%   built-in RANK() but makes the tolerance explicit and returns the
%   singular values used, so that borderline cases (e.g. checking the
%   redundancy subspace condition, Eq. 6) can be inspected rather than
%   trusted blindly.
%
%   PURPOSE
%       Lemma 1 / Eq. (6) require checking whether rank((S kron I) Upsilon)
%       equals NSigma EXACTLY. Floating point SVD-based rank computation
%       is tolerance-sensitive; this function documents and exposes that
%       tolerance rather than hiding it inside a bare rank() call.
%
%   INPUTS
%       M         - matrix whose numerical rank is sought
%       tol_scale - (optional) positive scalar multiplier applied to the
%                   default MATLAB tolerance
%                   tol_default = max(size(M)) * eps(norm(M))
%                   Default: 1 (i.e., use MATLAB's standard tolerance).
%
%   OUTPUTS
%       r        - estimated numerical rank (integer)
%       tol_used - the actual singular-value threshold applied
%       sv       - full vector of singular values of M (for diagnostics)
%
%   EXPECTED NUMERICAL BEHAVIOR
%       For well-conditioned matrices with a clear gap between "large"
%       and "numerically zero" singular values, the result is robust to
%       moderate changes in tol_scale. For near-degenerate matrices
%       (e.g., S close to but not exactly rank-deficient), results can
%       be sensitive -- callers should inspect `sv` directly in such
%       cases (see Phase 12, Debugging).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    if nargin < 2 || isempty(tol_scale)
        tol_scale = 1;
    end
    validateattributes(tol_scale, {'numeric'}, {'scalar','positive'}, ...
        mfilename, 'tol_scale');

    if isempty(M)
        error('numerical_rank:emptyInput', 'Input matrix M is empty.');
    end

    % MATLAB's svd() does NOT support sparse input (errors outright;
    % use svds() for that case, which computes only a subset of
    % singular values -- not what we want here, since we need the
    % FULL singular value spectrum to assess rank against NSigma).
    % compute_W.m deliberately produces a SPARSE W for memory
    % efficiency during the Kronecker-product step (Phase 13), but W
    % itself is small at this problem's scale (NSigma ~ 30), so
    % converting to full here is cheap and necessary for svd() to work
    % at all under real MATLAB (this discrepancy did not surface during
    % Octave-based validation, since Octave's svd() tolerates sparse
    % input -- flagged here as a MATLAB/Octave behavioral difference
    % caught during real-MATLAB testing).
    if issparse(M)
        M = full(M);
    end

    sv = svd(M);
    tol_default = max(size(M)) * eps(max(sv));
    tol_used = tol_scale * tol_default;

    r = sum(sv > tol_used);

end
