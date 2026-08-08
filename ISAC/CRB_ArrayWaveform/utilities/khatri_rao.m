function C = khatri_rao(A, B)
%KHATRI_RAO  Column-wise Kronecker (Khatri-Rao) product, A ⊙ B.
%
% EQUATION (3): Atr = [at(w1) ⊗ ar(w1), ..., at(wK) ⊗ ar(wK)] = At ⊙ Ar
%
% INPUTS
%   A - (Nt x K)
%   B - (Nr x K)
% OUTPUT
%   C - (Nt*Nr x K), C(:,k) = kron(A(:,k), B(:,k))
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    [Nt, K]  = size(A);
    [Nr, K2] = size(B);
    if K ~= K2
        error('khatri_rao:dimMismatch', 'A and B must have the same number of columns (targets).');
    end
    C = zeros(Nt*Nr, K);
    for k = 1:K
        C(:,k) = kron(A(:,k), B(:,k));
    end
end
