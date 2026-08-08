function T = toeplitz_herm(u)
%TOEPLITZ_HERM Build a Hermitian Toeplitz matrix from a generating vector.
%
%   T = TOEPLITZ_HERM(u) constructs the NSigma x NSigma Hermitian
%   Toeplitz matrix T(u) used in the atomic norm minimization SDP of
%   Section IV:
%       T(u)_{i,j} = u(i-j+1),        i >= j
%       T(u)_{i,j} = conj(u(j-i+1)),  i <  j
%
%   PURPOSE
%       T(u) parameterizes the recovered co-array autocorrelation-like
%       structure inside the SDP constraint
%           [T(u), z; z', t] >= 0 (PSD)
%
%   INPUTS
%       u - NSigma x 1 vector. u(1) MUST be real (it sits on the main
%           diagonal of a Hermitian matrix). If u is a CVX variable,
%           this function is written using only indexing/concatenation
%           operations so it remains compatible with CVX's overloaded
%           operators and can be called directly inside a cvx_begin /
%           cvx_end block.
%
%   OUTPUTS
%       T - NSigma x NSigma Hermitian Toeplitz matrix (or CVX affine
%           expression, if u is a CVX variable).
%
%   ERROR CHECKING
%       When u is plain numeric (not a CVX variable), this function
%       verifies that u(1) is (numerically) real, since a Hermitian
%       matrix's diagonal must be real. For CVX variables this check
%       is skipped (CVX affine expressions do not support isreal()
%       introspection in general), and it is the CALLER's
%       responsibility to declare u(1) as a real CVX variable (see
%       algorithms/atomic_norm_recovery.m).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    u = u(:); % ensure column vector

    if isnumeric(u)
        if abs(imag(u(1))) > 1e-10 * max(1, abs(u(1)))
            error('toeplitz_herm:nonRealDiagonal', ...
                'u(1) must be real (Hermitian matrix diagonal), got imag(u(1))=%g.', ...
                imag(u(1)));
        end
        u(1) = real(u(1)); % force exact real to avoid tiny imaginary residue
    end

    % toeplitz(c, r) requires c(1) == r(1); since u(1) is real,
    % conj(u(1)) == u(1), so this construction is self-consistent and
    % produces a Hermitian matrix by definition of the Toeplitz map.
    T = toeplitz(u, conj(u));

end
