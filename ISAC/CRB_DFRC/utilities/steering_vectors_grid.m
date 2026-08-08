function [A_grid, Adot_grid] = steering_vectors_grid(angle_grid_rad, N_elements, d_spacing)
%STEERING_VECTORS_GRID Vectorized ULA steering vectors over an angle grid.
%
%   [A_grid, Adot_grid] = STEERING_VECTORS_GRID(angle_grid_rad, N_elements, d_spacing)
%   evaluates Eqs. (19)-(20) at every angle in angle_grid_rad
%   simultaneously (fully vectorized -- no loop over grid points),
%   required for efficient beampattern (Module 15) and MLE grid
%   search (Module 16) evaluation, since those are called O(Ntrials)
%   times per figure with grids of ~1801 points (Sec. V: -90:0.1:90 deg).
%
%   Inputs:
%       angle_grid_rad : 1 x Ngrid (or Ngrid x 1), angles in RADIANS
%       N_elements     : scalar, number of array elements
%       d_spacing      : scalar, element spacing in wavelengths
%
%   Outputs:
%       A_grid    : N_elements x Ngrid complex
%       Adot_grid : N_elements x Ngrid complex (derivative w.r.t. theta)
%
%   Author: Ali Arabi Bavil
%   Date:   2026-07-03

    validateattributes(angle_grid_rad, {'numeric'}, {'vector','real'});
    validateattributes(N_elements, {'numeric'}, {'scalar','positive','integer'});

    angle_grid_rad = angle_grid_rad(:).';           % force row, 1 x Ngrid
    n = (0:N_elements-1).';                          % N x 1

    phase  = 2*pi*d_spacing * (n * sin(angle_grid_rad));   % N x Ngrid (outer product)
    A_grid = exp(1i*phase);

    if nargout > 1
        cos_row   = cos(angle_grid_rad);              % 1 x Ngrid
        Adot_grid = (1i*2*pi*d_spacing * (n .* A_grid)) .* cos_row;
    end
end
