function x_hat = estimate_amplitudes(DSigma, theta_hat, z)
%ESTIMATE_AMPLITUDES Recover per-target scattering amplitudes via least squares.
%
%   x_hat = ESTIMATE_AMPLITUDES(DSigma, theta_hat, z)
%
%   PURPOSE
%       root_music.m recovers target ANGLES theta_hat but not
%       amplitudes. The paper's Fig. 1(b) plots both estimated angle
%       AND magnitude (as stem heights), which requires an amplitude
%       estimate. This is NOT detailed numerically anywhere in the
%       paper -- flagged here as an EXPLICIT, DOCUMENTED ADDITION,
%       not an invented physical assumption.
%
%       By Eq. (3), the recovered co-array measurement satisfies
%       (approximately, post SDP-denoising):
%           z ~= A_DSigma(theta) * x
%       Given theta_hat (from root-MUSIC), we recover x_hat via
%       ordinary least squares:
%           x_hat = pinv(A_DSigma(theta_hat)) * z
%
%   INPUTS
%       DSigma    - 1xNSigma sum co-array positions
%       theta_hat - 1xK estimated DoAs (radians), from root_music.m
%       z         - NSigma x 1 recovered co-array measurement, from
%                   atomic_norm_recovery.m
%
%   OUTPUTS
%       x_hat - Kx1 complex vector, estimated scattering amplitudes,
%               in the SAME (unmatched/unordered) order as theta_hat
%               (i.e. x_hat(k) corresponds to theta_hat(k))
%
%   ERROR CHECKING
%       Validates dimensional compatibility; warns (does not error) if
%       A_DSigma(theta_hat) is poorly conditioned (near-coincident
%       angle estimates), since this reflects genuine estimation
%       difficulty rather than a bug.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    K = numel(theta_hat);
    NSigma = numel(DSigma);

    if numel(z) ~= NSigma
        error('estimate_amplitudes:dimMismatch', ...
            'numel(z)=%d must equal numel(DSigma)=%d.', numel(z), NSigma);
    end

    A_hat = array_manifold(DSigma, theta_hat); % NSigma x K

    c = cond(A_hat);
    if c > 1e8
        warning('estimate_amplitudes:illConditioned', ...
            ['A_DSigma(theta_hat) is poorly conditioned (cond=%.2e), likely ' ...
             'due to closely-spaced angle estimates. Amplitude estimates ' ...
             'may be unreliable.'], c);
    end

    x_hat = pinv(A_hat) * z(:);

end
