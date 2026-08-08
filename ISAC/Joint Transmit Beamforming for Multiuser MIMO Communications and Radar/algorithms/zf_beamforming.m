function [W_tilde, R_tilde, cvx_status_out] = zf_beamforming(H, Gamma_linear, params)
%ZF_BEAMFORMING  Algorithm 2: Joint transmit beamforming via Zero-Forcing.
%
%   [W_tilde, R_tilde, cvx_status_out] = ZF_BEAMFORMING(H, Gamma_linear, params)
%
%   Implements Section IV-C, solving the convex QSDP (40):
%       min_{R,alpha_var}  Lr(R,alpha_var)                                  (40a)
%       s.t. R in S_M^+,  H*R*H^H = diag(p)                          (40b)
%            [R]_{m,m} = Pt/M                                         (40c)
%            (1/Gamma) p_k >= sigma^2, k=1..K                         (40d)
%   then recovering the precoding matrix via eq. (41)-(42) (Algorithm 2).
%
%   IMPLEMENTATION NOTE (recovery derivation, documented explicitly since
%   the OCR'd paper equations (41)-(42) reference a Q_f matrix computed
%   from F via row-QR that this derivation shows is redundant):
%
%   Because the SDP constraint (40b) enforces H*R_tilde*H^H = diag(p)
%   EXACTLY, and diag(p) is already diagonal with positive entries, its
%   unique lower-triangular-positive-diagonal Cholesky factor is
%   diag(sqrt(p)) itself. Applying row-QR (eq. 59) to H*Lr, where
%   R_tilde = Lr*Lr^H (eq. 58), gives H*Lr = [Lh, 0_{KxM-K}]*Qh with
%   Lh*Lh^H = H*R_tilde*H^H = diag(p) (eq. 60) -- so Lh = diag(sqrt(p))
%   automatically (up to our row_qr.m's positive-diagonal sign
%   convention), and no separate decomposition of F is required. Setting
%   V = Lr*Qh^H (M x M) gives V*V^H = R_tilde and H*V = [diag(sqrt(p)),
%   0_{Kx(M-K)}]. The first K columns of V are the interference-free
%   communication precoder (Wc_tilde); the remaining M-K columns of V,
%   together with an appended all-zero M x K block, form the radar
%   precoder (Wr_tilde), which by construction satisfies H*Wr_tilde = 0
%   (i.e. Fr = 0, eq. 35). This reproduces eq. (42), W_tilde =
%   [Lr*Qh^H, 0_{MxK}], while making explicit which columns serve
%   communications vs. radar.
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
%   Equation reference: (35)-(42), Algorithm 2, Theorem 2 (Appendix B).
%   MATLAB functions used: cvx_begin/cvx_end (CVX/SDPT3), psd_clip, chol,
%   row_qr (custom helper implementing eq. 54-56).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

M   = params.M;
Pt  = params.Pt;
wc  = params.wc;
sigma2 = params.sigma2;
K = size(H,1);

if size(H,2) ~= M
    error('zf_beamforming:dimMismatch', 'H must be K x M with M = params.M.');
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
    variable p(K,1) nonnegative
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

    minimize( Lr_total )
    subject to
        R == hermitian_semidefinite(M);         % eq. (40b), part 1
        H * R * H' == diag(p);                  % eq. (40b), part 2 / eq. (39)
        diag(R) == (Pt/M) * ones(M,1);           % eq. (40c)
        (1/Gamma_linear) * p >= sigma2 * ones(K,1); % eq. (40d)
cvx_end

cvx_status_out = cvx_status;

if ~strcmpi(cvx_status, 'Solved')
    W_tilde = [];
    R_tilde = [];
    return;
end

R_hat = psd_clip(full(R));

% --- Recovery, eq. (41)-(42) via the simplified derivation above ---
Lr_chol = chol(R_hat, 'lower');      % eq. (58): R_tilde = Lr*Lr^H
[~, Qh] = row_qr(H * Lr_chol);       % eq. (59): H*Lr = [Lh, 0]*Qh, Qh is MxM unitary

V = Lr_chol * Qh';                   % M x M, satisfies V*V^H = R_hat

Wc_tilde = V(:, 1:K);                % first K columns: interference-free comm precoder
Wr_tilde = [V(:, K+1:end), zeros(M,K)]; % remaining columns + zero-pad: radar precoder

W_tilde = [Wc_tilde, Wr_tilde];      % M x (K+M), eq. (42)
R_tilde = R_hat;

end