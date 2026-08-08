function mse = beam_pattern_mse(P_theta, P_theta_R0)
%BEAM_PATTERN_MSE  MSE between an obtained beam pattern and the radar-only
%                   optimal beam pattern, eq. (46).
%
%   mse = BEAM_PATTERN_MSE(P_theta, P_theta_R0)
%
%   Inputs:
%     P_theta    - 1xL beam pattern P(theta_l;R) of the design under test
%     P_theta_R0 - 1xL beam pattern P(theta_l;R0) of the radar-only optimum
%
%   Output:
%     mse - scalar, eq. (46): (1/L) * sum_l |P(theta_l;R0)-P(theta_l;R)|^2
%
%   Equation reference: (46).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

if isempty(P_theta)
    mse = NaN;
    return;
end
if numel(P_theta) ~= numel(P_theta_R0)
    error('beam_pattern_mse:dimMismatch', ...
        'P_theta and P_theta_R0 must have the same number of grid points.');
end

L = numel(P_theta_R0);
mse = sum(abs(P_theta_R0 - P_theta).^2) / L;

end