function U = index_set(N)
%INDEX_SET Implements U_N = {0, 1, ..., N-1}, the basic index set notation
% used throughout the paper (e.g. eq. (11): D_t* = (Nr/2) * U_Nt).
%
% Inputs:
%   N - positive integer, cardinality of the set
%
% Outputs:
%   U - 1xN row vector [0 1 ... N-1]
%
% Equation reference: notation U_N, used in eq. (11) and Corollary 1.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    if ~(isscalar(N) && N == floor(N) && N > 0)
        error('index_set:invalidInput', 'N must be a positive integer scalar.');
    end
    U = 0:(N-1);

end
