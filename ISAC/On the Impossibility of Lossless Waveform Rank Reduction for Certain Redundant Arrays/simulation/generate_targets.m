function [theta, x] = generate_targets(K)
%GENERATE_TARGETS Generate ground-truth target DoAs and scattering coefficients.
%
%   [theta, x] = GENERATE_TARGETS(K)
%
%   PURPOSE
%       Implements the ground-truth DoA generation formula and
%       scattering coefficient model described in Section IV:
%           omega_k = sin(theta_k) = -1 + (2k-1)/K + eps_k
%           eps_k ~ i.i.d. Uniform[-1/(10K), 1/(10K)]
%           x_k on the complex unit circle, |x_k| = 1/sqrt(K)
%
%   INPUTS
%       K - number of targets (positive integer)
%
%   OUTPUTS
%       theta - 1xK vector of DoAs in RADIANS, theta in [-pi/2, pi/2)
%       x     - Kx1 complex vector, scattering coefficients,
%               |x_k| = 1/sqrt(K), uniform random phase
%
%   REQUIRED EQUATIONS
%       Section IV ground-truth DoA formula (unnumbered); SNR/power
%       normalization implies E||x||_2^2 = 1, achieved exactly here
%       since sum_k |x_k|^2 = K*(1/sqrt(K))^2 = 1.
%
%   ERROR CHECKING
%       Validates K is a positive integer. Clips omega to [-1,1] before
%       asin() as a numerical safety net (see Phase 3 analysis: the
%       nominal grid plus perturbation should theoretically stay within
%       range, but floating-point edge cases are guarded against).
%
%   EXPECTED NUMERICAL BEHAVIOR
%       theta values are spread roughly evenly across the visible angle
%       range with small random jitter; x has unit total power.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    validateattributes(K, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'K');

    k = (1:K)';
    omega_nominal = -1 + (2*k - 1)/K;
    eps_k = (rand(K,1) - 0.5) * (2/(10*K)); % Uniform[-1/(10K), 1/(10K)]
    omega = omega_nominal + eps_k;

    % Defensive clip (Phase 3 numerical-issue note)
    omega = min(max(omega, -1), 1);

    theta = asin(omega)'; % 1xK, radians

    % Scattering coefficients: unit modulus scaled by 1/sqrt(K), random phase
    phase = 2*pi*rand(K,1);
    x = (1/sqrt(K)) * exp(1i*phase);

end
