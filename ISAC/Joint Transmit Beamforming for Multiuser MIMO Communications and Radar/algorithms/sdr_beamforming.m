function [W_tilde, R_tilde, cvx_status_out] = sdr_beamforming(H, Gamma_linear, params)
%SDR_BEAMFORMING  Algorithm 1: Joint transmit beamforming via SDR.
%
%   [W_tilde, R_tilde, cvx_status_out] = SDR_BEAMFORMING(H, Gamma_linear, params)
%
%   Implements Section IV-B, solving the convex QSDP (32):
%       min_{R,R1,...,RK,alpha_var}  Lr(R,alpha_var)                        (32a)
%       s.t. R in S_M^+,  R - sum_k Rk in S_M^+                     (32b)
%            [R]_{m,m} = Pt/M                                        (32c)
%            Rk in S_M^+                                              (32d)
%            (1+1/Gamma) hk^H Rk hk >= hk^H R hk + sigma^2            (32e)
%   then recovering the precoding matrix via eq. (33)-(34) (Algorithm 1,
%   steps 2-4).
%
%   Inputs:
%     H            - K x M downlink channel matrix
%     Gamma_linear - scalar SINR threshold, LINEAR (not dB)
%     params       - struct from config/parameters.m
%
%   Outputs:
%     W_tilde        - M x (M+K) precoding matrix [Wc, Wr], or [] if
%                       infeasible
%     R_tilde        - M x M recovered covariance matrix, or [] if
%                       infeasible
%     cvx_status_out - CVX solver status string
%
%   Equation reference: (26)-(34), Algorithm 1.
%   MATLAB functions used: cvx_begin/cvx_end (CVX/SDPT3), psd_clip (for
%   numerical robustness before Cholesky), chol.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

M   = params.M;
Pt  = params.Pt;
wc  = params.wc;
sigma2 = params.sigma2;
K = size(H,1);

if size(H,2) ~= M
    error('sdr_beamforming:dimMismatch', 'H must be K x M with M = params.M.');
end

theta_grid  = params.angle_grid_deg;
target_dirs = params.target_dirs_deg;
L = numel(theta_grid);
P = numel(target_dirs);

A_grid    = steering_vector(theta_grid, M);
A_targets = steering_vector(target_dirs, M);
d_vec     = desired_beam_pattern(theta_grid, target_dirs, params.beamwidth_deg);

if P >= 2
    pair_idx = nchoosek(1:P, 2);
else
    pair_idx = zeros(0,2);
end
num_pairs  = size(pair_idx, 1);
cross_norm = 2 / (P^2 - P);

cvx_begin sdp quiet
    variable R(M,M) hermitian
    variable Rk(M,M,K) hermitian
    variable alpha_var nonnegative

    % See radar_only_design.m for why we avoid forming the LxL matrix.
    RA = R * A_grid;                               % M x L, affine in R
    P_theta = real( sum( conj(A_grid) .* RA, 1 ) ); % eq. (10)
    Lr1 = sum_square_abs( alpha_var * d_vec - P_theta ) / L; % eq. (12)

    if num_pairs > 0
        Pc_vec = cvx( zeros(1, num_pairs) );
        for pp = 1:num_pairs
            th_p = pair_idx(pp,1);
            th_q = pair_idx(pp,2);
            Pc_vec(pp) = A_targets(:,th_q)' * R * A_targets(:,th_p); % eq. (11)
        end
        Lr2 = cross_norm * sum_square_abs( Pc_vec ); % eq. (13)
    else
        Lr2 = 0;
    end

    Lr_total = Lr1 + wc * Lr2; % eq. (14)

    % Sum of the K lifted matrices, needed for constraint (32b)
    Rsum = cvx( zeros(M,M) );
    for k = 1:K
        Rsum = Rsum + Rk(:,:,k);
    end

    minimize( Lr_total )
    subject to
        R == hermitian_semidefinite(M);              % eq. (32b), part 1
        (R - Rsum) == hermitian_semidefinite(M);      % eq. (32b), part 2
        diag(R) == (Pt/M) * ones(M,1);                % eq. (32c)
        for k = 1:K
            Rk(:,:,k) == hermitian_semidefinite(M);   % eq. (32d)
            hk = H(k,:).';
            (1 + 1/Gamma_linear) * real( hk' * Rk(:,:,k) * hk ) >= ...
                real( hk' * R * hk ) + sigma2;        % eq. (32e)
        end
cvx_end

cvx_status_out = cvx_status;

if ~strcmpi(cvx_status, 'Solved')
    % Infeasible or numerically failed trial: report and return empty.
    W_tilde = [];
    R_tilde = [];
    return;
end

R_hat  = full(R);
Rk_hat = full(Rk);

% --- Recovery, eq. (33): w_tilde_k for k=1..K ---
Wc_tilde = zeros(M, K);
for k = 1:K
    hk = H(k,:).';
    Rk_k = psd_clip(Rk_hat(:,:,k));
    denom = real(hk' * Rk_k * hk);
    if denom <= 0
        denom = eps; % numerical guard: theoretically > 0 at optimum (Thm 1)
    end
    Wc_tilde(:,k) = (denom)^(-1/2) * (Rk_k * hk);
end

% --- Recovery, eq. (34): Cholesky-type factorization for radar part ---
R_hat_clipped = psd_clip(R_hat);
Residual = R_hat_clipped - (Wc_tilde * Wc_tilde');
Residual = psd_clip(Residual); % guard tiny negative eigenvalues from round-off

Wr_tilde = chol(Residual, 'lower');   % M x M lower-triangular, eq. (34)

W_tilde = [Wc_tilde, Wr_tilde]; % M x (K+M), eq. Algorithm 1 step 4
R_tilde = R_hat_clipped;

end