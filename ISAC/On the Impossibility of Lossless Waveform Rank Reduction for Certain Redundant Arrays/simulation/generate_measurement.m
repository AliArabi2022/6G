function [y, B_theta, ADt, ADr] = generate_measurement(Dt, Dr, S, theta, x, n_noise, varargin)
%GENERATE_MEASUREMENT Generate the received signal y via the forward model.
%
%   [y, B_theta, ADt, ADr] = GENERATE_MEASUREMENT(Dt, Dr, S, theta, x, n_noise)
%   [y, B_theta, ADt, ADr] = GENERATE_MEASUREMENT(..., Upsilon, DSigma)
%
%   PURPOSE
%       Implements Eq. (1) directly:
%           B(theta) = (S * A_Dt(theta)) khatri-rao A_Dr(theta)
%           y = B(theta) * x + n
%       This is the PRIMARY (Eq. 1-based) computation path. If Upsilon
%       and DSigma are additionally supplied, this function ALSO
%       computes y via the equivalent Eq. (3)-based path
%       (y = W * A_DSigma(theta) * x + n, with W = compute_W(S,Upsilon,Nr))
%       and asserts the two agree to numerical precision -- a built-in
%       consistency check between Eq. (1) and Eq. (3), since Eq. (3) is
%       an algebraic identity that MUST hold if all other modules
%       (array_manifold.m, compute_redundancy_pattern.m, compute_W.m,
%       khatri_rao.m) are implemented correctly and consistently
%       (see Phase 11).
%
%   INPUTS
%       Dt      - 1xNt Tx sensor positions
%       Dr      - 1xNr Rx sensor positions
%       S       - T_len x Nt waveform matrix
%       theta   - 1xK target DoAs (radians)
%       x       - Kx1 scattering coefficients
%       n_noise - (Nr*T_len)x1 noise vector (from generate_noise.m)
%       Upsilon - (optional) (Nt*Nr) x NSigma redundancy pattern matrix,
%                 triggers the Eq. (3) cross-check
%       DSigma  - (optional, required if Upsilon given) 1xNSigma sum
%                 co-array vector
%
%   OUTPUTS
%       y       - (Nr*T_len) x 1 received signal (Eq. 1)
%       B_theta - (Nr*T_len) x K sensing matrix (Eq. 1), returned for
%                 diagnostic/reuse purposes
%       ADt     - Nt x K Tx array manifold (Eq. 2), returned for reuse
%       ADr     - Nr x K Rx array manifold (Eq. 2), returned for reuse
%
%   REQUIRED EQUATIONS
%       Eq. (1), Eq. (2); optionally Eq. (3) as a consistency check.
%
%   ERROR CHECKING
%       Validates dimensional compatibility of all inputs. If the
%       optional Eq. (3) cross-check is requested and the two
%       computations of y disagree beyond numerical tolerance, this
%       function throws an error (this would indicate a bug in one of
%       the dependent modules, not a modeling choice).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    Nt = numel(Dt);
    Nr = numel(Dr);
    K = numel(theta);
    T_len = size(S, 1);

    if size(S,2) ~= Nt
        error('generate_measurement:dimMismatch', ...
            'size(S,2)=%d must equal Nt=%d (numel(Dt)).', size(S,2), Nt);
    end
    if numel(x) ~= K
        error('generate_measurement:dimMismatch', ...
            'numel(x)=%d must equal numel(theta)=%d.', numel(x), K);
    end
    if numel(n_noise) ~= Nr*T_len
        error('generate_measurement:dimMismatch', ...
            'numel(n_noise)=%d must equal Nr*T_len=%d.', numel(n_noise), Nr*T_len);
    end

    ADt = array_manifold(Dt, theta); % Nt x K   (Eq. 2)
    ADr = array_manifold(Dr, theta); % Nr x K   (Eq. 2)

    B_theta = khatri_rao(S*ADt, ADr); % (Nr*T_len) x K   (Eq. 1)
    x = x(:);
    y = B_theta * x + n_noise(:);      % Eq. (1)

    % --- Optional Eq. (3) cross-check ---
    if numel(varargin) >= 2
        Upsilon = varargin{1};
        DSigma  = varargin{2};

        % Partial consistency guard (Phase 12): cannot fully verify
        % Upsilon/DSigma "belong to" this Dt/Dr without recomputing
        % them, but we CAN catch the common mistake of passing
        % mismatched objects from a DIFFERENT array configuration.
        if size(Upsilon,1) ~= Nt*Nr
            error('generate_measurement:upsilonSizeMismatch', ...
                ['size(Upsilon,1)=%d does not match Nt*Nr=%d for the ' ...
                 'supplied Dt, Dr. Upsilon was likely built for a ' ...
                 'different array configuration.'], size(Upsilon,1), Nt*Nr);
        end
        if size(Upsilon,2) ~= numel(DSigma)
            error('generate_measurement:upsilonDSigmaMismatch', ...
                'size(Upsilon,2)=%d does not match numel(DSigma)=%d.', ...
                size(Upsilon,2), numel(DSigma));
        end

        W = compute_W(S, Upsilon, Nr);           % Eq. (3)
        ADSigma = array_manifold(DSigma, theta);  % Eq. (2), on DSigma
        y_alt = W * ADSigma * x + n_noise(:);      % Eq. (3)-based y

        max_diff = max(abs(y - y_alt));
        tol = 1e-8 * max(1, max(abs(y)));
        if max_diff > tol
            error('generate_measurement:eq1eq3Inconsistent', ...
                ['Eq. (1)-based y and Eq. (3)-based y disagree by %.3e ' ...
                 '(tolerance %.3e). This indicates a bug in one of: ' ...
                 'array_manifold.m, khatri_rao.m, compute_redundancy_pattern.m, ' ...
                 'or compute_W.m.'], max_diff, tol);
        end
    elseif numel(varargin) == 1
        error('generate_measurement:incompleteOptionalArgs', ...
            'If Upsilon is provided for the Eq. (3) cross-check, DSigma must also be provided.');
    end

end
