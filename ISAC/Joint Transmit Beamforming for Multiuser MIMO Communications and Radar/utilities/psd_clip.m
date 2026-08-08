function R_clipped = psd_clip(R, tol)
%PSD_CLIP  Repair a Hermitian matrix that should be PSD but has tiny
%           negative eigenvalues due to solver numerical tolerance.
%
%   R_clipped = PSD_CLIP(R, tol)
%
%   This is NOT part of the paper's math -- it is a numerical-robustness
%   utility required before any Cholesky decomposition of a CVX-returned
%   covariance matrix (e.g. eq. 34, eq. 41 recovery steps), because
%   interior-point solvers return R that is PSD only up to solver
%   tolerance, and a strict Cholesky factorization can fail on matrices
%   with eigenvalues of order -1e-10.
%
%   Inputs:
%     R   - MxM matrix, should be Hermitian PSD
%     tol - eigenvalues below tol are clipped to tol (default 1e-10)
%
%   Output:
%     R_clipped - MxM Hermitian PSD matrix (nearest, via eigenvalue clip)
%
%   Potential numerical issues addressed: negative eigenvalues from
%   floating point/solver tolerance breaking chol(); asymmetry from
%   floating point round-off (fixed via Hermitian symmetrization first).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

if nargin < 2 || isempty(tol)
    tol = 1e-10;
end

if size(R,1) ~= size(R,2)
    error('psd_clip:notSquare', 'R must be a square matrix.');
end

% Force exact Hermitian symmetry (removes round-off asymmetry)
R_herm = (R + R') / 2;

[V, D] = eig(R_herm);
d = real(diag(D));
d(d < tol) = tol;

R_clipped = V * diag(d) * V';
R_clipped = (R_clipped + R_clipped') / 2; % re-symmetrize after reconstruction

end