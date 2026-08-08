function [chi_r_optimal, chi_r_best_found, D_r_best] = verify_theorem1_bruteforce(Nr, L)
%VERIFY_THEOREM1_BRUTEFORCE Verifies Theorem 1 by EXHAUSTIVE SEARCH over
% all Nr-element subsets of {0,...,L} that include both endpoints 0
% and L (i.e. all arrays with exactly aperture L), checking that none
% has a larger spatial variance chi_r than the closed-form clustered
% array of optimal_rx_array.m.
%
% Why brute force instead of CVX:
%   Choosing WHICH Nr integer positions (out of L+1 candidates) to
%   occupy is a combinatorial selection problem. The objective,
%   spatial variance chi(D), is a CONVEX function of the (indicator
%   variables of the) selected positions -- and MAXIMIZING a convex
%   function over a polytope is generally NP-hard / not solvable by
%   CVX (CVX solves convex minimization / concave maximization only).
%   A continuous relaxation would not certify combinatorial optimality.
%   For the small (Nr, L) used in this project, exhaustive search is
%   both correct and fast, and gives a genuine (not relaxed) proof.
%
% Inputs:
%   Nr - number of Rx sensors (even)
%   L  - aperture (must satisfy L >= Nr-1)
%
% Outputs:
%   chi_r_optimal    - chi(D_r) of the closed-form clustered array
%                      (optimal_rx_array.m)
%   chi_r_best_found - largest chi(D_r) found over ALL valid Nr-subsets
%                      of {0,...,L} containing both endpoints
%   D_r_best         - the array achieving chi_r_best_found
%
% Complexity: O( C(L-1, Nr-2) ), i.e. combinations of the L-1 interior
% candidate positions choose (Nr-2) additional interior sensors (since
% endpoints 0 and L are always included to realize aperture exactly L).
% Keep Nr, L small (as in the paper's Fig. 1 example) to keep this
% tractable -- for Nt=4,Nr=6,L=14 this is C(13,4) = 715 combinations,
% trivial to enumerate.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    if ~(isscalar(Nr) && Nr >= 2 && mod(Nr,2)==0)
        error('verify_theorem1_bruteforce:invalidNr', 'Nr must be an even integer >= 2.');
    end
    if ~(isscalar(L) && L >= Nr-1)
        error('verify_theorem1_bruteforce:invalidL', 'L must satisfy L >= Nr-1.');
    end

    D_r_closedform = optimal_rx_array(Nr, L);
    chi_r_optimal  = spatial_variance(D_r_closedform);

    interior = 1:(L-1);            % candidate interior positions
    n_interior_needed = Nr - 2;    % endpoints 0, L are fixed occupied

    if n_interior_needed == 0
        % Nr == 2: only choice is {0, L} itself
        chi_r_best_found = spatial_variance([0, L]);
        D_r_best = [0, L];
        return;
    end

    combos = nchoosek(interior, n_interior_needed);
    n_combos = size(combos,1);

    chi_r_best_found = -inf;
    D_r_best = [];

    for k = 1:n_combos
        D_candidate = sort([0, L, combos(k,:)]);
        chi_k = spatial_variance(D_candidate);
        if chi_k > chi_r_best_found
            chi_r_best_found = chi_k;
            D_r_best = D_candidate;
        end
    end

    fprintf('--- Brute-force verification of Theorem 1 (Nr=%d, L=%d) ---\n', Nr, L);
    fprintf('Closed-form clustered array chi_r : %.6f\n', chi_r_optimal);
    fprintf('Best found via exhaustive search   : %.6f\n', chi_r_best_found);
    fprintf('Match: %s\n', mat2str(abs(chi_r_optimal - chi_r_best_found) < 1e-9));

end
