function [R0, alpha0, cvx_status_out] = radar_only_design(params)
%RADAR_ONLY_DESIGN  Solve the radar-only transmit covariance design, eq. (15).
%
%   [R0, alpha0, cvx_status_out] = RADAR_ONLY_DESIGN(params)
%
%   Solves:
%       min_{R,alpha_var}  Lr(R,alpha_var)                      (15a)
%       s.t.           R in S_M^+                        (15b)
%                       [R]_{m,m} = Pt/M, m=1..M          (15c)
%
%   where Lr(R,alpha_var) = Lr,1(R,alpha_var) + wc*Lr,2(R), eq. (12)-(14).
%
%   Inputs:
%     params - struct from config/parameters.m (needs M, Pt, wc,
%              angle_grid_deg, target_dirs_deg, beamwidth_deg)
%
%   Outputs:
%     R0             - M x M optimal radar-only covariance matrix
%     alpha0         - optimal scaling factor alpha_var (eq. 12)
%     cvx_status_out - CVX solver status string ('Solved', etc.)
%
%   MATLAB function used: cvx_begin/cvx_end (CVX toolbox, SDPT3 solver as
%   used in the paper, Sec. V).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

M   = params.M;
Pt  = params.Pt;
wc  = params.wc;

theta_grid = params.angle_grid_deg;
target_dirs = params.target_dirs_deg;
L = numel(theta_grid);
P = numel(target_dirs);

% Precompute steering vectors (data, not optimization variables)
A_grid    = steering_vector(theta_grid, M);      % M x L
A_targets = steering_vector(target_dirs, M);     % M x P
d_vec     = desired_beam_pattern(theta_grid, target_dirs, params.beamwidth_deg); % 1xL

% Number of distinct target-direction pairs (p<q), eq. (13)
if P >= 2
    pair_idx = nchoosek(1:P, 2); % [P*(P-1)/2] x 2
else
    pair_idx = zeros(0,2);
end
num_pairs = size(pair_idx, 1);
cross_norm = 2 / (P^2 - P); % normalization constant in eq. (13); requires P>=2

cvx_begin sdp quiet
    variable R(M,M) hermitian
    variable alpha_var nonnegative

    % --- eq. (10): beam pattern at each grid angle, as affine CVX expr ---
    % IMPORTANT: do NOT form A_grid'*R*A_grid (an LxL matrix, L~1801) just
    % to extract its diagonal -- CVX would build ~L^2 symbolic affine
    % expressions and run out of memory. Instead compute only the L
    % diagonal entries directly: P_theta(l) = a_l' R a_l =
    % real(sum(conj(a_l) .* (R*a_l))), vectorized over l via elementwise
    % multiply + sum (R*A_grid is only MxL, not LxL).
    RA = R * A_grid;                              % M x L, affine in R
    P_theta = real( sum( conj(A_grid) .* RA, 1 ) ); % 1xL, real (Hermitian R)
 
    % --- eq. (12): beam pattern MSE term ---
    Lr1 = sum_square_abs( alpha_var * d_vec - P_theta ) / L;

    % --- eq. (13): cross-correlation term ---
    if num_pairs > 0
        Pc_vec = cvx( zeros(1, num_pairs) );
        for pp = 1:num_pairs
            th_p = pair_idx(pp,1);
            th_q = pair_idx(pp,2);
            Pc_vec(pp) = A_targets(:,th_q)' * R * A_targets(:,th_p); % eq. (11)
        end
        Lr2 = cross_norm * sum_square_abs( Pc_vec );
    else
        Lr2 = 0;
    end

    Lr_total = Lr1 + wc * Lr2; % eq. (14)

    minimize( Lr_total )
    subject to
        R == hermitian_semidefinite(M);      % eq. (15b)
        diag(R) == (Pt/M) * ones(M,1);       % eq. (15c)
cvx_end

cvx_status_out = cvx_status;

if ~strcmpi(cvx_status, 'Solved')
    warning('radar_only_design:notSolved', ...
        'CVX status for radar-only design: %s', cvx_status);
end

R0     = full(R);
alpha0 = full(alpha_var);

end