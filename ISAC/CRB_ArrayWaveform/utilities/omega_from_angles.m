function Omega = omega_from_angles(theta_deg, phi_deg, lambda, numDim)
%OMEGA_FROM_ANGLES  Compute target spatial-frequency vectors omega_k.
%
% EQUATION (Sec. II-A, unnumbered display equation after "The k'th target..."):
%   omega_k = (2*pi/lambda) * [cos(theta_k)cos(phi_k); sin(theta_k)cos(phi_k); sin(phi_k)]
%
% INPUTS
%   theta_deg - (1xK) azimuth angles in degrees
%   phi_deg   - (1xK) elevation angles in degrees
%   lambda    - wavelength
%   numDim    - 1, 2, or 3: number of ESTIMABLE direction-cosine
%               components to retain (Remark 1). For a linear array only
%               the first component (cos(theta)cos(phi), the azimuth
%               direction cosine along the array axis) is identifiable;
%               for a planar array the first two; for a cubic (3D) array
%               all three.
%
% ASSUMPTION (Phase 11): Remark 1 states that for linear/planar arrays,
% "the corresponding rows and columns of the FIM and CRBM are removed."
% We implement this by only keeping/estimating the first `numDim`
% direction-cosine components per target; the remaining components are
% treated as fixed, known (not estimated) nuisance angles used only to
% generate a physically valid 3D target position for numerical realism.
%
% OUTPUT
%   Omega - (3 x K) full 3D omega vectors (for array-manifold evaluation)
%           Use omega_active_dims to get the (numDim x K) estimable slice.
%
% Author: Ali Arabi Bavil
% Date: 2026-07
    if nargin < 3 || isempty(lambda)
        lambda = 2;
    end
    if nargin < 4
        numDim = 3;
    end

    theta = deg2rad(theta_deg(:)');
    phi   = deg2rad(phi_deg(:)');

    K = numel(theta);
    Omega = zeros(3, K);
    Omega(1,:) = cos(theta) .* cos(phi);
    Omega(2,:) = sin(theta) .* cos(phi);
    Omega(3,:) = sin(phi);
    Omega = (2*pi/lambda) * Omega;

    %#ok<*NASGU> (numDim kept for interface symmetry with omega_active_dims)
end
