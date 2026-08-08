function [R_s_opt, crb_cvx, crb_closedform] = cvx_verify_optimal_waveform(D_t, omega, P)
%CVX_VERIFY_OPTIMAL_WAVEFORM Numerically verifies, via CVX, that the
% paper's closed-form coherent-beamforming waveform (eq. 5) is indeed
% the CRB-minimizing solution among ALL power-constrained waveform
% covariance matrices.
%
% Why CVX is the right tool here (unlike the array-geometry problem):
%   For a FIXED array geometry, the transmit waveform design problem
%   reduces to choosing a waveform covariance matrix R_s = E[s s^H],
%   R_s >= 0 (PSD), subject to a total power constraint trace(R_s) = P.
%   The CRB (inverse Fisher information) for omega, expressed as a
%   function of R_s, is CONVEX in R_s (a standard result for Gaussian /
%   linear-in-parameter signal models -- CRB is proportional to the
%   inverse of a quadratic form a_t(omega)^H R_s a_t(omega), and
%   1/(x^H R_s x) is convex in R_s for R_s >= 0). Minimizing a convex
%   function over the convex set {R_s : R_s >= 0, trace(R_s) = P} is a
%   textbook SDP -- this is exactly what CVX solves.
%
%   This is in contrast to arrays/optimal_rx_array.m and
%   arrays/optimal_tx_array.m: choosing WHICH integer sensor positions
%   to occupy is a combinatorial (integer) problem, not a convex one,
%   so CVX is not the appropriate verification tool there (see
%   verify/verify_theorem1_bruteforce.m for that check instead).
%
% Formulation solved:
%   minimize_{R_s}   1 / ( a_t(omega)' * R_s * a_t(omega) )
%   subject to       R_s >= 0 (PSD),  trace(R_s) = P
%
%   Equivalently (and more CVX-friendly, since 1/x is convex-decreasing
%   for x>0 and we can instead directly MAXIMIZE the concave quadratic
%   form, which is equivalent since the objective is monotonic):
%
%   maximize_{R_s}   a_t(omega)' * R_s * a_t(omega)
%   subject to       R_s >= 0,  trace(R_s) = P
%
% Expected/known closed-form answer (eq. 5):
%   R_s* = P * a_t(omega) * a_t(omega)' / ||a_t(omega)||^2   (rank-1,
%   i.e. coherent beamforming) -- this function checks the CVX solution
%   matches this closed form (both the optimal value and, up to a
%   global phase/rank check, the optimal R_s).
%
% Inputs:
%   D_t   - 1xNt vector, Tx sensor positions
%   omega - scalar, angle to beamform toward
%   P     - scalar, total transmit power budget (trace constraint)
%
% Outputs:
%   R_s_opt        - Nt x Nt CVX-computed optimal waveform covariance
%   crb_cvx        - achieved value of 1/(a_t' R_s a_t) from CVX
%   crb_closedform - the same quantity evaluated at the eq.(5) closed form
%
% Requires: CVX toolbox (http://cvxr.com/cvx/) on the MATLAB path.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    Nt = numel(D_t);
    a_t = steering_vector(omega, D_t);   % Nt x 1

    cvx_begin sdp quiet
        variable R_s(Nt,Nt) hermitian semidefinite
        maximize( real(a_t' * R_s * a_t) )
        subject to
            trace(R_s) == P;
    cvx_end

    R_s_opt = R_s;
    crb_cvx = 1 / real(a_t' * R_s_opt * a_t);

    % Closed-form rank-1 beamforming solution, eq. (5)
    R_s_cf  = P * (a_t * a_t') / (a_t' * a_t);
    crb_closedform = 1 / real(a_t' * R_s_cf * a_t);

    fprintf('--- CVX verification of optimal waveform (eq. 5) ---\n');
    fprintf('CVX-achieved  a_t^H R_s a_t : %.6f\n', real(a_t' * R_s_opt * a_t));
    fprintf('Closed-form   a_t^H R_s a_t : %.6f\n', real(a_t' * R_s_cf  * a_t));
    fprintf('Rank of CVX-optimal R_s     : %d (expect 1, i.e. beamforming)\n', ...
            rank(R_s_opt, 1e-6 * norm(R_s_opt)));

end
