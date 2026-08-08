function n_noise = generate_noise(Nr, T_len, sigma2)
%GENERATE_NOISE Generate the additive complex Gaussian noise vector.
%
%   n_noise = GENERATE_NOISE(Nr, T_len, sigma2)
%
%   PURPOSE
%       Implements the noise model in Eq. (1)/Section IV: "Noise is
%       circularly symmetric Gaussian, n ~ CN(0, sigma^2 * I)".
%
%   IMPORTANT NOTE -- PAPER TEXT AMBIGUITY (flagged explicitly, not
%   silently resolved)
%       The paper states y = B(theta)*x + n is an NrT x 1 vector
%       (Section II, following Eq. 1), but separately describes n as
%       "n in C^{Nr}" (Section IV). These two statements are
%       dimensionally inconsistent as literally written: for
%       y = B(theta)*x + n to type-check, n must have the SAME
%       dimension as y, i.e. NrT x 1, not Nr x 1. We treat "n in C^Nr"
%       as an apparent shorthand/typo in the paper text and implement
%       n as an NrT x 1 vector (matching y's actual dimension), which
%       is the only choice consistent with Eq. (1) as an equation.
%       This is OUR EXPLICIT RESOLUTION of an ambiguity, not an
%       invented assumption about the underlying model.
%
%   INPUTS
%       Nr     - number of Rx sensors
%       T_len  - waveform temporal length
%       sigma2 - noise variance (per-entry), sigma2 >= 0
%
%   OUTPUTS
%       n_noise - (Nr*T_len) x 1 complex vector, CN(0, sigma2*I)
%
%   ERROR CHECKING
%       Validates sigma2 >= 0. If sigma2 == 0, returns an exact zero
%       vector (noiseless case), consistent with footnote 3's handling
%       of sigma=0 in the atomic norm recovery step.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    validateattributes(Nr, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'Nr');
    validateattributes(T_len, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'T_len');
    validateattributes(sigma2, {'numeric'}, {'scalar','nonnegative'}, ...
        mfilename, 'sigma2');

    N = Nr * T_len;

    if sigma2 == 0
        n_noise = zeros(N, 1);
        return;
    end

    % Circularly symmetric complex Gaussian: real and imaginary parts
    % each N(0, sigma2/2), so that E|n_i|^2 = sigma2.
    n_noise = sqrt(sigma2/2) * (randn(N,1) + 1i*randn(N,1));

end
