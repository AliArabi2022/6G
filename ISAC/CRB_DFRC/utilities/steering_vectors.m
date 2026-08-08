function [a_vec, adot_vec] = steering_vectors(theta_rad, N_elements, d_spacing)
%STEERING_VECTORS ULA steering vector and its derivative w.r.t. angle.
%
%   [a_vec, adot_vec] = STEERING_VECTORS(theta_rad, N_elements, d_spacing)
%   implements Eqs. (19)-(20) of the CRB paper for a uniform linear
%   array (ULA):
%
%       a(theta)    = [1, e^{j*2*pi*d*sin(theta)}, ..., e^{j*2*pi*d*(N-1)*sin(theta)}]^T
%       adot(theta) = d/dtheta a(theta)
%                   = j*2*pi*d*cos(theta) .* [0,1,...,N-1]' .* a(theta)
%
%   With d_spacing = 0.5 (half-wavelength, Sec. V), the phase
%   increment per element is pi*sin(theta), matching Eq. (19).
%
%   This SAME function is called for both the Tx array (N_elements=Nt,
%   producing a(theta)/adot(theta)) and the Rx array
%   (N_elements=Nr, producing b(theta)/bdot(theta)) -- using one
%   function for both guarantees an identical sign/phase convention,
%   which is required for the orthogonality identity
%   Re{a^H adot} = 0 (Eq. 21, see Phase 3 Sec 3.2 clarification) to
%   hold for BOTH arrays consistently.
%
%   Inputs:
%       theta_rad  : scalar, angle in RADIANS
%       N_elements : scalar, number of array elements (Nt or Nr)
%       d_spacing  : scalar, element spacing in wavelengths (0.5 nominal)
%
%   Outputs:
%       a_vec    : N_elements x 1 complex, steering vector
%       adot_vec : N_elements x 1 complex, d(a_vec)/d(theta)
%
%   Author: Ali Arabi Bavil
%   Date:   2026-07-03

    validateattributes(theta_rad, {'numeric'}, {'scalar','real'});
    validateattributes(N_elements, {'numeric'}, {'scalar','positive','integer'});
    validateattributes(d_spacing, {'numeric'}, {'scalar','positive'});

    n = (0:N_elements-1).';                        % element index, Nx1
    phase = 2*pi*d_spacing*n*sin(theta_rad);        % Nx1
    a_vec = exp(1i*phase);                          % Eq. (19)

    if nargout > 1
        adot_vec = 1i*2*pi*d_spacing*cos(theta_rad) .* n .* a_vec;  % Eq. (20)
    end
end
