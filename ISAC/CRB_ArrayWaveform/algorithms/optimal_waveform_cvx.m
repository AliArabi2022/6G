function [Rs_opt, obj_opt] = optimal_waveform_cvx(Dt, Dr, Omega, gamma, sigma2, numDim, fType)
%OPTIMAL_WAVEFORM_CVX  Solve (13) for the CRB-optimal Rs given a geometry.
%
% EQUATIONS
%   (13):  min_Rs f(CRBM_Omega,Omega(Rs))  s.t. tr(Rs) <= 1
%   (14):  Rs = [At, Adot_t] * Lambda * [At, Adot_t]^H,  Lambda in S_+^{4K}
%          ("4K" generalizes to (1+numDim)*K under the Remark-1 reduction
%          used throughout this codebase)
%
% CONVEXITY (Sec. II-D): f is convex in the CRBM = (top-left block of)
% F^{-1}, and F is affine in Rs, hence affine in Lambda via (14). For
% f = trace (the metric used in the paper's Fig. 2 and Fig. 7, "the
% trace of the CRB"), we use the identity
%     trace(CRBM_Omega,Omega) = trace(J' F^{-1} J) = sum_i e_i' F^{-1} e_i
% where e_i are the standard basis vectors of the Omega-block. Each term
% e_i' F^{-1} e_i is exactly CVX's built-in convex atom matrix_frac(e_i,F),
% which internally represents e_i' F^{-1} e_i via a Schur-complement LMI.
% This is the standard, numerically robust way to encode trace-of-inverse
% objectives as an SDP — no hand-rolled LMI blocks needed.
%
% REQUIRES: CVX (http://cvxr.com/cvx/) on the MATLAB path (>> cvx_setup once).
%
% ASSUMPTION (Phase 11): only fType='trace' is implemented (matches the
% paper's reported metric). 'logdet' is also SDP-representable via CVX's
% -log_det() atom applied to the Omega-block of F^{-1} (requires a
% slightly different Schur-complement construction) and is left as a
% documented extension point since it is not needed to reproduce the
% paper's figures.
%
% INPUTS/OUTPUTS: same convention as compute_CRBM.m
%
% Author:Ali Arabi Bavil
% Date: 2026-07

    if nargin < 7 || isempty(fType); fType = 'trace'; end
    if ~strcmpi(fType, 'trace')
        error('optimal_waveform_cvx:unsupported', ...
            'Only fType=''trace'' is implemented (see header for why).');
    end
    if exist('cvx_begin', 'file') ~= 2
        error('optimal_waveform_cvx:noCVX', ...
            ['CVX not found on path. Install from http://cvxr.com/cvx/ and run cvx_setup.\n' ...
             'As a fallback for quick checks, use coherent_waveform.m (near-optimal per Fig. 2).']);
    end

    K  = size(Omega, 2);
    Nt = size(Dt, 1);
    Nr = size(Dr, 1);

    [Atr_full, Adot_tr_full, At, ~] = compute_atr_and_derivative(Dt, Dr, Omega, numDim); %#ok<ASGLU>

    % Tx-only derivative Adot_t, needed for the (14) decomposition:
    %   d/d(omega_i) at(omega_k) = 1j * Dt(:,i) .* at(omega_k)
    Adot_t = zeros(Nt, numDim*K);
    col = 0;
    for k = 1:K
        ak = At(:,k);
        for i = 1:numDim
            col = col + 1;
            Adot_t(:,col) = 1i * Dt(:,i) .* ak;
        end
    end

    M  = [At, Adot_t];         % (Nt x (1+numDim)K), basis of eq. (14)
    P  = size(M, 2);
    dK = numDim*K;
    Ntot = dK + 2*K;           % full FIM size, eq. (4)

    cvx_begin sdp quiet
        variable Lambda(P,P) hermitian semidefinite
        Rs = M * Lambda * M';                                          % eq. (14)
        F  = build_FIM_cvx(Rs, Nr, gamma, sigma2, numDim, K, Atr_full, Adot_tr_full);
        F  = (F + F')/2; % keep symmetric as a CVX affine expression

        expression obj
        obj = 0;
        for i = 1:dK
            ei = zeros(Ntot,1); ei(i) = 1;
            obj = obj + matrix_frac(ei, F);   % e_i' * F^{-1} * e_i
        end

        minimize( obj )
        subject to
            trace(Rs) <= 1;                                            % eq. (11)
    cvx_end

    Rs_opt = M * Lambda * M';
    Rs_opt = (Rs_opt + Rs_opt')/2;
    [~, obj_opt] = compute_CRBM(Dt, Dr, Omega, gamma, Rs_opt, sigma2, numDim, 'trace');
end

% -------------------------------------------------------------------
function F = build_FIM_cvx(Rs, Nr, gamma, sigma2, numDim, K, Atr, Adot_tr)
%BUILD_FIM_CVX  CVX-affine reconstruction of F(Rs), eq. (4)-(8).
% Rs is a CVX affine expression here (not numeric); the construction
% mirrors compute_FIM.m exactly but avoids any operation that assumes a
% numeric input (no eig()/inv()/etc — those only ever act on constants
% Atr, Adot_tr, gamma, never on the CVX variable Rs itself).
    R = kron(Rs, eye(Nr));
    onesD = ones(numDim,1);
    mask_OO = kron(conj(gamma(:))*gamma(:).', onesD*onesD');
    mask_Og = kron(conj(gamma(:))*ones(1,K), onesD);

    F_OO = (Adot_tr' * R * Adot_tr) .* mask_OO;
    F_gg = Atr' * R * Atr;
    F_Og = (Adot_tr' * R * Atr) .* mask_Og;

    top    = [real(F_OO),  real(F_Og), -imag(F_Og)];
    middle = [real(F_Og)', real(F_gg), -imag(F_gg)];
    bottom = [imag(F_Og)', imag(F_gg)', real(F_gg)];

    F = (2/sigma2) * [top; middle; bottom];
end
