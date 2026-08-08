function [D_t, L_opt] = optimal_tx_array(Nt, Nr)
%OPTIMAL_TX_ARRAY Constructs the Tx array of Corollary 1 (eq. 11), which,
% paired with optimal_rx_array.m, yields a jointly optimal (single-target
% CRB minimizing) AND contiguous-nonredundant-sum-co-array geometry.
%
% Theory (Corollary 1, eq. 11 in the paper):
%   Given Nt, Nr in N+, Nr even, and aperture
%       L = (Nt+1)*Nr/2 - 1                                    (*)
%   the Tx array
%       D_t* = (Nr/2) * U_Nt = (Nr/2) * {0, 1, ..., Nt-1}
%   is a solution to the joint CRB-minimizing design problem, and the
%   resulting sum co-array D_Sigma = D_t* (+) D_r* (Minkowski sum with
%   D_r* = optimal_rx_array(Nr, L)) is contiguous (covers 0..Nt*Nr-1)
%   and nonredundant (all Nt*Nr sums are distinct).
%
% Inputs:
%   Nt - number of Tx sensors
%   Nr - number of Rx sensors (must be even)
%
% Outputs:
%   D_t   - 1xNt vector of Tx sensor positions
%   L_opt - the aperture L satisfying (*), for which the contiguous/
%           nonredundant co-array property provably holds
%
% Equation reference: eq. (11), Corollary 1.
%
% Numerical implementation strategy:
%   Direct closed-form construction; no iteration needed.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    if ~(isscalar(Nt) && Nt > 0 && Nt == floor(Nt))
        error('optimal_tx_array:invalidNt', 'Nt must be a positive integer.');
    end
    if ~(isscalar(Nr) && Nr > 0 && mod(Nr,2) == 0 && Nr == floor(Nr))
        error('optimal_tx_array:invalidNr', 'Nr must be a positive even integer.');
    end

    U_Nt  = index_set(Nt);
    D_t   = (Nr/2) * U_Nt;
    L_opt = (Nt + 1) * Nr / 2 - 1;

end
