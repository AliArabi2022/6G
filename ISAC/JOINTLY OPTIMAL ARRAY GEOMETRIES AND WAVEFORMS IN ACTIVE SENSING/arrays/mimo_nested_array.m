function [D_t, D_r] = mimo_nested_array(Nt, Nr)
%MIMO_NESTED_ARRAY Constructs the Fig. 1(d) comparison geometry: the
% "canonical MIMO (radar) array with a nested structure" referenced in
% the paper -- a widely-used sparse MIMO virtual-array design (e.g.
% Li/Stoica-type nested MIMO radar arrays).
%
% Theory:
%   D_t = Nr * {0, 1, ..., Nt-1}      (Tx: ULA with spacing Nr)
%   D_r = {0, 1, ..., Nr-1}           (Rx: unit-spacing ULA)
%
%   This gives a Tx aperture of (Nt-1)*Nr and Rx aperture Nr-1, total
%   physical aperture (Nt-1)*Nr + (Nr-1). For Nt=4, Nr=6 this equals
%   15 + 5 = 20, matching the paper's statement that this array has
%   "a larger Rx aperture (L=20)" than the optimal clustered design.
%   Its virtual (sum) co-array is nonredundant but has "holes" (unlike
%   the fully contiguous co-array of Corollary 1), causing spatial
%   aliasing in the MLE, as discussed in Section 4.
%
% Inputs:
%   Nt - number of Tx sensors
%   Nr - number of Rx sensors
%
% Outputs:
%   D_t - 1xNt vector, Tx positions
%   D_r - 1xNr vector, Rx positions
%
% Assumption: exact position set not given verbatim in the visible
% text; reconstructed as the standard nested-MIMO baseline, consistent
% with the paper's stated aperture L=20 for this configuration.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    if ~(isscalar(Nt) && Nt > 0 && Nt == floor(Nt))
        error('mimo_nested_array:invalidNt', 'Nt must be a positive integer.');
    end
    if ~(isscalar(Nr) && Nr > 0 && Nr == floor(Nr))
        error('mimo_nested_array:invalidNr', 'Nr must be a positive integer.');
    end

    D_t = index_set(Nt);
    D_r = Nt * index_set(Nr);

end
