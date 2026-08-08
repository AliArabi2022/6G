function theta_hat = root_music(T_u, K)
%ROOT_MUSIC Estimate K target DoAs from a Hermitian Toeplitz matrix via root-MUSIC.
%
%   theta_hat = ROOT_MUSIC(T_u, K)
%
%   PURPOSE
%       Standard root-MUSIC [42], applied to the RECOVERED Toeplitz
%       matrix T(u) (from atomic_norm_recovery.m) rather than a sample
%       covariance matrix, per Section IV: "apply root-MUSIC to
%       Hermitian Toeplitz matrix T(u) ... (assuming K to be known)".
%
%   ALGORITHM
%       1. Eigendecompose T_u = V*Lambda*V' (Hermitian, so eigenvalues
%          are real; sort descending).
%       2. Signal subspace = top-K eigenvectors; noise subspace =
%          remaining (NSigma-K) eigenvectors.
%       3. Form the noise-subspace polynomial
%              D(z) = a(z)^H * En * En^H * a(z)
%          where a(z) = [1, z, z^2, ..., z^(NSigma-1)]^T (the steering
%          polynomial in the z-domain), En = noise-subspace eigenvectors.
%          Expand D(z) as a polynomial in z and find its roots.
%       4. Select the K roots INSIDE the unit circle that are closest
%          to it (these correspond to the true signal directions;
%          spurious roots are further from the unit circle).
%       5. Convert each selected root's angle to a DoA via
%              theta_hat = asin( angle(root) / pi )
%          (NOT /(2*pi) -- see IMPLEMENTATION NOTE below, consistent
%          with the paper's steering vector convention, Eq. 2:
%          exp(j*pi*d*sin(theta)), i.e. half-wavelength spacing.)
%
%   IMPLEMENTATION NOTE -- ANGLE CONVERSION FACTOR (flagged pitfall,
%   Phase 5/Phase 12)
%       Because Eq. (2) uses exp(j*pi*d*sin(theta)) (half-wavelength
%       normalized spacing, factor pi, not the more common 2*pi/lambda*d
%       with unit integer spacing), the root-to-angle conversion here
%       uses /pi, NOT the more commonly seen /(2*pi) found in root-MUSIC
%       tutorials that assume full-wavelength spacing conventions. Using
%       the wrong factor here would silently produce DoA estimates off
%       by a systematic scale factor -- this is explicitly tested in
%       Phase 11 against a noiseless, well-separated synthetic case.
%
%   INPUTS
%       T_u - NSigma x NSigma Hermitian Toeplitz matrix (recovered
%             co-array "covariance-like" matrix)
%       K   - number of targets to estimate (assumed known, per paper)
%
%   OUTPUTS
%       theta_hat - 1xK vector of estimated DoAs, radians, UNORDERED
%                   (no correspondence to any particular true target;
%                   pairing/matching is handled downstream by
%                   postprocessing/compute_mse.m)
%
%   ERROR CHECKING
%       Validates T_u is square and Hermitian (up to tolerance), and
%       that K < NSigma (root-MUSIC requires a nontrivial noise
%       subspace, i.e. at least one dimension left over after removing
%       the K-dimensional signal subspace).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    NSigma = size(T_u, 1);
    if size(T_u,2) ~= NSigma
        error('root_music:notSquare', 'T_u must be square.');
    end
    herm_err = max(max(abs(T_u - T_u')));
    if herm_err > 1e-6 * max(1, max(abs(T_u(:))))
        error('root_music:notHermitian', ...
            'T_u is not Hermitian within tolerance (max asymmetry = %.3e).', herm_err);
    end
    validateattributes(K, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'K');
    if K >= NSigma
        error('root_music:tooManyTargets', ...
            'K (%d) must be strictly less than NSigma (%d) for a nontrivial noise subspace.', ...
            K, NSigma);
    end

    % Step 1-2: eigendecomposition, sorted descending
    T_u = (T_u + T_u')/2; % force exact Hermitian symmetry (guard against roundoff)
    [V, D] = eig(T_u);
    [eigvals, idx] = sort(real(diag(D)), 'descend');
    V = V(:, idx);

    En = V(:, K+1:end); % noise subspace, NSigma x (NSigma-K)

    % Step 3: noise-subspace polynomial coefficients.
    % D(z) = sum_{i,j} conj(En(i,:)*En(j,:)') * z^{i-j}  (after expanding
    % a(z)^H * (En*En') * a(z) with a(z)_n = z^{n-1}).
    % Equivalent, numerically robust approach: build C = En*En', then
    % sum along anti-diagonals to get polynomial coefficients c_m for
    % power z^m, m = -(NSigma-1) .. (NSigma-1).
    C = En * En'; % NSigma x NSigma
    m_powers = -(NSigma-1):(NSigma-1);
    c = zeros(size(m_powers));
    for idxM = 1:numel(m_powers)
        m = m_powers(idxM);
        c(idxM) = sum(diag(C, m)); % sum of the m-th diagonal of C
    end
    % c is symmetric conjugate (c(-m) = conj(c(m))) since C is Hermitian;
    % polynomial coefficients ordered from highest power to lowest for
    % MATLAB's roots():
    poly_coeffs = fliplr(c); % now ordered z^{NSigma-1} down to z^{-(NSigma-1)}
    % roots() operates on a proper polynomial in descending powers of z
    % starting at z^0; shift by multiplying through by z^{NSigma-1}
    % (already implicit in our c indexing, so poly_coeffs as constructed
    % directly corresponds to a standard polynomial of degree 2*(NSigma-1)).

    rts = roots(poly_coeffs);

    % Step 4: discard roots essentially at infinity/zero or NaN (guard),
    % then select K roots strictly inside the unit circle closest to it.
    rts = rts(isfinite(rts));
    inside = rts(abs(rts) < 1);
    if numel(inside) < K
        error('root_music:tooFewRootsInside', ...
            ['Found only %d roots strictly inside the unit circle, need ' ...
             'K=%d. This may indicate T_u is ill-conditioned or the SDP ' ...
             'recovery failed (check cvx_ok from atomic_norm_recovery.m).'], ...
            numel(inside), K);
    end
    [~, order] = sort(abs(inside), 'descend'); % closest to unit circle first
    chosen = inside(order(1:K));

    % Step 5: angle-to-DoA conversion (see IMPLEMENTATION NOTE above)
    omega_hat = angle(chosen) / pi; % in [-1,1] range (approximately)
    omega_hat = min(max(omega_hat, -1), 1); % defensive clip
    theta_hat = asin(omega_hat)';

end
