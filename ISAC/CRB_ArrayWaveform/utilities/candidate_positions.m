function D = candidate_positions(L, numDim, lambda)
%CANDIDATE_POSITIONS  Build the candidate sensor-position set C (Ct or Cr).
%
% PURPOSE
%   Paper (Sec. IV-A): "The candidate Tx and Rx sets, Ct and Cr, are taken
%   as uniform arrays with aperture L." We realize this as a uniform grid
%   of integer half-wavelength positions from 0 to L along each active
%   spatial dimension, matching the axis labels used in Figs. 3-6
%   ("d [lambda/2]").
%
% ASSUMPTION (not stated explicitly in the paper, Phase 11):
%   The candidate grid step is exactly lambda/2 (i.e., integer indices),
%   consistent with the figures' axis ticks (integers 0..L). The paper
%   does not state the grid resolution explicitly; this is the natural
%   choice matching classical sparse-array literature (Nested/MRA, etc.)
%   and the paper's own figures.
%
% INPUTS
%   L       - aperture (candidate grid spans [0, L] along each active dim)
%   numDim  - 1 (linear), 2 (planar), or 3 (cubic) array
%   lambda  - wavelength (default 2, so that 1 unit = lambda/2, matching
%             the paper's "d [lambda/2]" axis convention and Fig. 7 which
%             explicitly uses lambda = 2)
%
% OUTPUT
%   D       - (Ncand x 3) matrix of physical Cartesian candidate positions.
%             Columns beyond numDim are zero (Remark 1: planar array =
%             z-coordinate 0; linear array = y,z coordinates 0).
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    if nargin < 3 || isempty(lambda)
        lambda = 2; % matches Fig. 7 caption: "lambda = 2"
    end

    if numDim < 1 || numDim > 3 || mod(numDim,1) ~= 0
        error('candidate_positions:badDim', 'numDim must be 1, 2, or 3.');
    end

    idx = 0:L; % integer half-wavelength indices, aperture L (Ncand = L+1 per dim)

    switch numDim
        case 1
            grids = {idx};
        case 2
            [X, Y] = ndgrid(idx, idx);
            grids = {X(:), Y(:)};
        case 3
            [X, Y, Z] = ndgrid(idx, idx, idx);
            grids = {X(:), Y(:), Z(:)};
    end

    Ncand = numel(grids{1});
    D = zeros(Ncand, 3);
    for i = 1:numDim
        D(:, i) = grids{i}(:) * (lambda/2);
    end
end
