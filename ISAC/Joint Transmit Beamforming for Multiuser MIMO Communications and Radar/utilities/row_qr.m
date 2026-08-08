function [La, Qa] = row_qr(A)
%ROW_QR  Row-QR decomposition as defined in the paper's Appendix B,
%         eq. (54)-(56).
%
%   [La, Qa] = ROW_QR(A)
%
%   For an m x n matrix A with m <= n, this returns:
%       A = [La, 0_{m x (n-m)}] * Qa
%   where:
%       La - m x m LOWER triangular matrix, with (by convention, eq. 63)
%            real, positive diagonal entries.
%       Qa - n x n unitary matrix, i.e. Qa*Qa' = Qa'*Qa = I_n, eq. (56).
%
%   Derivation strategy (documented, not merged with other steps):
%     The paper defines row-QR of A (m x n, m<=n) via the (standard)
%     column-QR of B = A^T (n x m, n>=m):
%         B = Pa * Ua = Pa * [Ua_reduced; 0]   (eq. 54)
%     with Ua_reduced upper triangular (m x m) and Pa unitary (n x n).
%     Then:
%         La = Ua_reduced^T   (lower triangular, eq. 55)
%         Qa = Pa^T
%     MATLAB's built-in qr() returns a full (non-economy) decomposition
%     when called as qr(B) with two outputs, which is exactly the form
%     needed here (Pa is n x n unitary, not just n x m).
%
%   Inputs:
%     A - m x n complex matrix, m <= n, full row rank (K x M or similar)
%
%   Outputs:
%     La - m x m lower triangular, real positive diagonal
%     Qa - n x n unitary
%
%   Equation reference: (54)-(59), Appendix B.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

[m, n] = size(A);
if m > n
    error('row_qr:invalidShape', 'row_qr requires m <= n (A must be wide or square).');
end

B = A';                       % n x m
[Pa, Ua_full] = qr(B);        % Pa: n x n unitary, Ua_full: n x m

Ua_reduced = Ua_full(1:m, :); % m x m upper triangular

% --- Enforce positive real diagonal convention (paper eq. 63) ---
d = diag(Ua_reduced);
% Avoid division by (near-)zero for a rank-deficient row; guard with eps.
phase = d ./ max(abs(d), eps);
D_fix = diag(conj(phase));    % unitary diagonal correction

Ua_reduced = D_fix * Ua_reduced;         % now has non-negative real diagonal
Pa(:, 1:m) = Pa(:, 1:m) * D_fix';        % compensate so B = Pa*Ua_full unchanged

La = Ua_reduced.';             % lower triangular, eq. (55): La = Ua^T
Qa = Pa.';                     % Qa = Pa^T, unitary n x n

end