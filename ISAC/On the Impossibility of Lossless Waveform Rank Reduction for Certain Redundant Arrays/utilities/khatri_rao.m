function C = khatri_rao(A, B)
%KHATRI_RAO Columnwise Kronecker (Khatri-Rao) product of two matrices.
%
%   C = KHATRI_RAO(A, B) computes the Khatri-Rao product of A and B,
%   used in Eq. (1) of the paper:
%       B(theta) = (S*A_Dt(theta)) (khatri-rao) A_Dr(theta)
%
%   PURPOSE
%       MATLAB has no built-in Khatri-Rao product. This function
%       implements it directly from its definition: the k-th column of
%       C is the Kronecker product of the k-th columns of A and B.
%
%   INPUTS
%       A - (p x k) matrix
%       B - (q x k) matrix (A and B must have the SAME number of columns)
%
%   OUTPUTS
%       C - (p*q x k) matrix, where C(:,j) = kron(A(:,j), B(:,j))
%
%   ERROR CHECKING
%       Validates that A and B have matching column counts, and that
%       both are 2-D numeric (or complex) matrices.
%
%   EXPECTED NUMERICAL BEHAVIOR
%       Purely algebraic (no iterative computation); output magnitude
%       is the product of input magnitudes columnwise.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    if ~ismatrix(A) || ~ismatrix(B)
        error('khatri_rao:invalidInput', 'A and B must be 2-D matrices.');
    end

    [p, kA] = size(A);
    [q, kB] = size(B);

    if kA ~= kB
        error('khatri_rao:sizeMismatch', ...
            'A and B must have the same number of columns (got %d and %d).', ...
            kA, kB);
    end

    k = kA;
    C = zeros(p*q, k, 'like', A(1)*B(1)); % preserve complex/real class

    for j = 1:k
        C(:, j) = kron(A(:, j), B(:, j));
    end

end
