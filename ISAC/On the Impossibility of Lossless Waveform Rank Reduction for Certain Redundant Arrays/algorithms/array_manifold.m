function A = array_manifold(D, theta)
%ARRAY_MANIFOLD Compute the array manifold (steering) matrix for array D.
%
%   A = ARRAY_MANIFOLD(D, theta) implements Eq. (2):
%       [A_D(theta)]_{n,k} = exp(j*pi*D(n)*sin(theta(k)))
%
%   PURPOSE
%       General-purpose steering-vector computation, reused for the Tx
%       manifold A_Dt(theta), Rx manifold A_Dr(theta), and sum co-array
%       manifold A_DSigma(theta) alike (Eq. (3) requires all three).
%
%   INPUTS
%       D     - 1xN vector of sensor positions (half-wavelength units,
%               integers per the paper's convention, but this function
%               does not require integrality -- it works for any real
%               D, since Eq. (2) itself makes no integrality assumption)
%       theta - 1xK (or Kx1) vector of angles in RADIANS, theta in
%               [-pi/2, pi/2)
%
%   OUTPUTS
%       A - NxK complex matrix, the array manifold matrix (Eq. 2)
%
%   REQUIRED EQUATIONS
%       Eq. (2)
%
%   ERROR CHECKING
%       Validates D and theta are real numeric vectors.
%
%   EXPECTED NUMERICAL BEHAVIOR
%       All entries have unit modulus (pure phase terms); no overflow
%       or underflow risk for any finite D, theta.
%
%   MATLAB IMPLEMENTATION STRATEGY
%       Fully vectorized outer product: no loops needed.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    validateattributes(D, {'numeric'}, {'vector','real'}, mfilename, 'D');
    validateattributes(theta, {'numeric'}, {'vector','real'}, mfilename, 'theta');

    D = D(:);       % N x 1
    theta = theta(:)'; % 1 x K

    A = exp(1i * pi * (D * sin(theta))); % N x K, vectorized outer product

end
