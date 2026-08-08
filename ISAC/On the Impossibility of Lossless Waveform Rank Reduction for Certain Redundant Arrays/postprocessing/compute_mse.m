function sq_err = compute_mse(theta_true, theta_hat)
%COMPUTE_MSE Compute per-target squared error via optimal DoA matching.
%
%   sq_err = COMPUTE_MSE(theta_true, theta_hat)
%
%   PURPOSE
%       root_music.m returns K estimated angles with NO correspondence
%       to the K ground-truth angles (eigen-based methods do not
%       preserve target ordering). Before computing squared error, the
%       estimates must be optimally paired with the ground truth.
%
%   NOTE ON THIS BEING A NECESSARY BUT UNSTATED DETAIL (Phase 5 flag)
%       The paper does not discuss this matching step explicitly (MSE
%       is simply stated as an "empirical mean squared error"). Using a
%       suboptimal (e.g. naive index-order) matching would artificially
%       inflate MSE and bias the Array 1 vs Array 2 comparison. We use
%       OPTIMAL linear assignment (via MATLAB's built-in matchpairs,
%       no toolbox required since R2019a) to avoid this bias -- this is
%       OUR EXPLICIT, DOCUMENTED CHOICE, not an invented physical
%       assumption.
%
%   INPUTS
%       theta_true - 1xK ground-truth DoAs (radians)
%       theta_hat  - 1xK estimated DoAs (radians), UNORDERED
%
%   OUTPUTS
%       sq_err - 1xK vector, squared error for each optimally-matched
%                pair (theta_true(i) matched to its assigned theta_hat(j))
%
%   ERROR CHECKING
%       Validates theta_true and theta_hat have the same length K.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    theta_true = theta_true(:);
    theta_hat  = theta_hat(:);
    K = numel(theta_true);

    if numel(theta_hat) ~= K
        error('compute_mse:sizeMismatch', ...
            'theta_true (K=%d) and theta_hat (K=%d) must have the same length.', ...
            K, numel(theta_hat));
    end

    % Cost matrix: squared difference between every true/estimated pair
    cost = (theta_true - theta_hat').^2; % K x K

    % Optimal one-to-one assignment (Hungarian-style linear assignment).
    % matchpairs minimizes total cost; unassignedCost set very large so
    % all K pairs are always matched (square cost matrix, K==K).
    unassignedCost = 1e6 * max(1, max(cost(:)));
    M = matchpairs(cost, unassignedCost);

    % M is a Kx2 matrix of [row, col] index pairs; extract in row order.
    sq_err = zeros(K,1);
    for r = 1:size(M,1)
        i = M(r,1);
        j = M(r,2);
        sq_err(i) = cost(i,j);
    end

    if size(M,1) ~= K
        error('compute_mse:incompleteMatching', ...
            'matchpairs returned only %d of %d required assignments; check unassignedCost.', ...
            size(M,1), K);
    end

    sq_err = sq_err';

end
