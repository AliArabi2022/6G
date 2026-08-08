function [D_sigma, is_contiguous, is_nonredundant] = sum_coarray(D_t, D_r)
%SUM_COARRAY Computes the sum co-array D_Sigma = D_t (+) D_r (Minkowski
% sum of the Tx and Rx position sets) and checks whether it is
% contiguous and nonredundant, as claimed for the geometry of
% Corollary 1.
%
% Theory:
%   D_Sigma = { d_t + d_r : d_t in D_t, d_r in D_r }   (as a SET, i.e.
%   duplicate sums collapse -- this is what "nonredundant" checks: that
%   no collapsing actually occurs, i.e. all Nt*Nr sums are pairwise
%   distinct).
%   "Contiguous" means D_Sigma (as a set) equals the full run of
%   consecutive integers from min(D_Sigma) to max(D_Sigma).
%
% Inputs:
%   D_t - 1xNt vector, Tx sensor positions
%   D_r - 1xNr vector, Rx sensor positions
%
% Outputs:
%   D_sigma         - sorted unique vector of all pairwise sums
%   is_contiguous   - true if D_sigma covers every integer in its range
%   is_nonredundant - true if all Nt*Nr pairwise sums were distinct
%                     (i.e. numel(unique sums) == Nt*Nr)
%
% Equation reference: discussion following eq. (11), Corollary 1.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    all_sums = D_t(:) + D_r(:)';   % Nt x Nr matrix of all pairwise sums
    all_sums = all_sums(:);
    n_total  = numel(all_sums);

    D_sigma = unique(all_sums);
    D_sigma = sort(D_sigma(:))';

    is_nonredundant = (numel(D_sigma) == n_total);
    is_contiguous   = isequal(D_sigma, min(D_sigma):max(D_sigma));

end
