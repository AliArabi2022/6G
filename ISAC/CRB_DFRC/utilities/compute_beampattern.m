function beampattern_dBi = compute_beampattern(RX, angle_grid_rad, d_spacing)
%COMPUTE_BEAMPATTERN Transmit beampattern P(theta;RX) over an angle grid.
%
%   beampattern_dBi = COMPUTE_BEAMPATTERN(RX, angle_grid_rad, d_spacing)
%   evaluates P(theta;R) = a'(theta) * R * a(theta) (Eq. 10 of ref [10],
%   reused here purely as an EVALUATION metric for Fig. 3, not as an
%   optimization objective for the proposed CRB-optimal method).
%
%   Fully vectorized (Phase 5 Module 15 requirement): builds the full
%   steering-vector grid once and evaluates all angles via a single
%   matrix expression, avoiding an explicit loop over ~1801 grid points
%   x thousands of Monte Carlo trials.
%
%   Inputs:
%       RX             : Nt x Nt, Hermitian PSD transmit covariance
%       angle_grid_rad : 1 x Ngrid, angles in RADIANS
%       d_spacing      : scalar, ULA element spacing in wavelengths
%
%   Outputs:
%       beampattern_dBi : Ngrid x 1, beampattern gain in dBi
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    Nt = size(RX,1);
    RX = (RX + RX')/2;

    A_grid = steering_vectors_grid(angle_grid_rad, Nt, d_spacing);   % Nt x Ngrid

    % P(theta_l) = a_l' * RX * a_l  for every column a_l of A_grid,
    % vectorized as: diag(A_grid' * RX * A_grid) without forming the
    % full Ngrid x Ngrid matrix -- use the equivalent
    % sum((RX*A_grid) .* conj(A_grid), 1) trick, O(Nt^2*Ngrid) instead
    % of O(Nt*Ngrid^2).
    P_lin = real(sum((RX*A_grid) .* conj(A_grid), 1)).';    % Ngrid x 1

    P_lin = max(P_lin, eps);     % epsilon floor before log10 (Phase 5 Module 15 pitfall)
    beampattern_dBi = 10*log10(P_lin);
end
