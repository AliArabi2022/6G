function D_r = optimal_rx_array(Nr, L)
%OPTIMAL_RX_ARRAY Constructs the CRB-optimal ("clustered") Rx array.
%
% Theory (Theorem 1, eq. 10 in the paper):
%   For a fixed number of Rx sensors Nr and fixed aperture L, the array
%   maximizing the spatial variance chi(D_r) (and hence minimizing the
%   single-target CRB, given optimal coherent Tx waveform) places
%   Nr/2 contiguous sensors at each edge of the aperture [0, L]:
%
%       D_r* = {0, 1, ..., Nr/2 - 1}  U  {L - Nr/2 + 1, ..., L}
%
%   Intuition: for points confined to an interval, variance is maximized
%   by pushing mass to the extremes (a discrete analogue of the
%   continuous two-point-mass variance-maximizing distribution).
%
% Inputs:
%   Nr - number of Rx sensors (must be even, per the paper's construction)
%   L  - physical aperture (max sensor position, min is fixed at 0)
%
% Outputs:
%   D_r - 1xNr vector of Rx sensor positions, sorted ascending
%
% Equation reference: eq. (10), Theorem 1.
%
% Assumption: the paper denotes this array "K_L". Its exact index-set
% definition was not fully legible via OCR; the contiguous-edge-cluster
% construction below was reverse-engineered from, and exactly matches,
% the paper's own worked numerical example (Nt=4, Nr=6, L=14 => the
% resulting sum co-array is contiguous & nonredundant, as required by
% Corollary 1 -- see verify/verify_corollary1.m for the check).
%
% Error checking:
%   - Nr must be a positive even integer
%   - L must satisfy L >= Nr - 1 (else Nr distinct integer positions
%     cannot fit within [0, L])
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    if ~(isscalar(Nr) && Nr > 0 && mod(Nr,2) == 0 && Nr == floor(Nr))
        error('optimal_rx_array:invalidNr', 'Nr must be a positive even integer.');
    end
    if ~(isscalar(L) && L == floor(L) && L >= Nr - 1)
        error('optimal_rx_array:invalidL', 'L must be an integer >= Nr-1.');
    end

    half = Nr / 2;
    D_r = [0:(half-1), (L-half+1):L];
    D_r = sort(D_r);

end
