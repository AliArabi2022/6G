function [theta_true, alpha_true, G] = generate_target(target_type, Nt, Nr, theta_true, alpha_true)
%GENERATE_TARGET Generate a point-target or extended-target realization.
%
%   [theta_true, alpha_true, G] = GENERATE_TARGET(target_type, Nt, Nr, theta_true, alpha_true)
%
%   POINT TARGET (target_type='point'), Eq. (2):
%       G = alpha_true * b(theta_true) * a(theta_true)'
%       theta_true, alpha_true are PASSED THROUGH from the caller
%       (Sec. V fixes theta_true = 0 deg; alpha_true per Assumption A4).
%       G is also returned (rank-1) for callers that need the actual
%       echo-generating matrix (e.g. Fig.4's MLE benchmark, which
%       needs to synthesize a noisy YR = G*X + ZR realization).
%
%   EXTENDED TARGET (target_type='extended'), Sec. V reproduction
%   variant of Eq. (3): G is generated directly as an Nr x Nt matrix
%   with i.i.d. CN(0,1) entries (the paper's stated simulation setup,
%   representing a dense/distributed scatterer field via the central-
%   limit argument -- see Phase 3 Sec 3.1 note on Eq. 3). In this case
%   theta_true/alpha_true are returned empty (not meaningful for a
%   distributed target).
%
%   Inputs:
%       target_type : 'point' | 'extended'
%       Nt, Nr       : scalars, array sizes
%       theta_true   : (point only) scalar, true angle in RADIANS.
%                      Ignored for 'extended'; pass [] if unused.
%       alpha_true   : (point only) scalar complex reflectivity.
%                      Ignored for 'extended'; pass [] if unused.
%
%   Outputs:
%       theta_true : passthrough (point) or [] (extended)
%       alpha_true : passthrough (point) or [] (extended)
%       G          : Nr x Nt complex target response matrix
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    switch target_type
        case 'point'
            validateattributes(theta_true, {'numeric'}, {'scalar','real'});
            validateattributes(alpha_true, {'numeric'}, {'scalar'});

            [a_vec, ~] = steering_vectors(theta_true, Nt, 0.5);
            [b_vec, ~] = steering_vectors(theta_true, Nr, 0.5);
            G = alpha_true * (b_vec * a_vec');   % Eq. (2), rank-1 by construction

        case 'extended'
            theta_true = [];
            alpha_true = [];
            G = (randn(Nr, Nt) + 1i*randn(Nr, Nt)) / sqrt(2);   % Sec. V Gaussian variant of Eq. (3)

        otherwise
            error('generate_target:badTargetType', 'target_type must be ''point'' or ''extended'', got ''%s''.', target_type);
    end
end
