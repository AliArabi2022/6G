function a = steering_vector(omega, D)
%STEERING_VECTOR Computes the array steering (manifold) vector for a
% given electrical angle omega and sensor position set D.
%
%   [a(omega)]_k = exp(1i * omega * D(k))
%
% This implements the Tx steering vector a_t(omega) (when D = D_t) and
% Rx steering vector a_r(omega) (when D = D_r) used in the signal model
% eq. (1): y = gamma * (S*a_t(omega) (kron) a_r(omega)) + n.
%
% Inputs:
%   omega - scalar (or vector) electrical angle(s) in [-pi, pi)
%   D     - 1xN vector of sensor positions (half-wavelength units)
%
% Outputs:
%   a - if omega is scalar: Nx1 steering vector
%       if omega is a 1xM vector: NxM matrix, one steering vector per column
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    D = D(:);          % Nx1
    omega = omega(:)'; % 1xM
    a = exp(1i * D * omega);  % Nx M

end
