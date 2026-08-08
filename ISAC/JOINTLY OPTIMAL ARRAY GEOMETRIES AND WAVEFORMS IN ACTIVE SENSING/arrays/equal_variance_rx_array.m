function D_r = equal_variance_rx_array()
%EQUAL_VARIANCE_RX_ARRAY Reconstructs the Fig. 1(b) comparison array:
% an Rx array with the SAME spatial variance chi_r as the optimal
% clustered array of Fig. 1(a) (Nt=4, Nr=6, L=14), but a LARGER
% aperture (L=20).
%
% Theory:
%   The paper points out this equality follows from the classical
%   "equal sums of squares" identity (paper refs [18],[19]):
%       5^2 + 6^2 + 7^2 = 1^2 + 3^2 + 10^2   (both equal 110)
%   Array (a) has centered positions +-{5,6,7} (i.e. D_r(a) =
%   {0,1,2,12,13,14}, centroid 7). Array (b) uses centered positions
%   +-{1,3,10} about a centroid of 10, giving:
%       D_r(b) = {0, 7, 9, 11, 13, 20}
%   which has identical chi_r to array (a) (since chi is the mean of
%   squared centered distances) but spans aperture L=20 instead of 14.
%
% Outputs:
%   D_r - 1x6 vector, the Fig. 1(b) Rx array {0,7,9,11,13,20}
%
% Equation/figure reference: Fig. 1(b) and the accompanying text
%   ("...by virtue of the following equal sums of squares: ...").
%
% Assumption: this array is a specific illustrative example tied to
% the Nt=4, Nr=6 case (it is NOT a general-Nr formula -- it exploits a
% particular numeric identity). It is hardcoded here rather than
% derived, as the paper does not give a general construction for it.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    centroid = 10;
    offsets  = [1, 3, 10];
    D_r = sort([centroid - offsets, centroid + offsets]);
    % D_r = [0 7 9 11 13 20]

end
