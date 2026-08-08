function A = steering_vector(theta_deg, M, d_over_lambda)
%STEERING_VECTOR  ULA steering vector(s), eq. (8)-(11) of the paper.
%
%   A = STEERING_VECTOR(theta_deg, M, d_over_lambda)
%
%   Inputs:
%     theta_deg      - 1xL (or scalar) vector of angles in DEGREES
%     M              - number of antenna elements (scalar)
%     d_over_lambda  - element spacing in wavelengths (default 0.5, i.e.
%                      half-wavelength spacing as stated in Section V)
%
%   Output:
%     A - MxL complex matrix, column l is a(theta_l) as in eq. (8):
%         a(theta) = [1, exp(j*2*pi*d/lambda*sin(theta)), ...,
%                        exp(j*2*pi*d/lambda*(M-1)*sin(theta))]^T
%
%   Equation reference: (8)-(11). For d/lambda = 0.5 this reduces to the
%   standard a(theta) = exp(j*pi*(0:M-1)'*sin(theta)).
%
%   Error checking: validates M is a positive integer and theta is real.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

if nargin < 3 || isempty(d_over_lambda)
    d_over_lambda = 0.5; % half-wavelength ULA, Section V
end

if ~isscalar(M) || M < 1 || mod(M,1) ~= 0
    error('steering_vector:invalidM', 'M must be a positive integer scalar.');
end
if ~isreal(theta_deg)
    error('steering_vector:invalidTheta', 'theta_deg must be real-valued (degrees).');
end

theta_rad = theta_deg(:).' * pi / 180;   % 1xL row vector, radians
m_idx     = (0:M-1).';                    % Mx1 column vector

% a(theta) = exp(j * 2*pi * (d/lambda) * m * sin(theta)),  eq. (8)
A = exp(1j * 2 * pi * d_over_lambda * (m_idx * sin(theta_rad)));

end
