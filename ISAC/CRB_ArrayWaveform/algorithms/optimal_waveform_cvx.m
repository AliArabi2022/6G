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
% F^{-1}, and F is affine in Rs, hence affine in Lambda via (14).
%
%   fType='trace': trace(CRBM_Omega,Omega) = sum_i e_i' F^{-1} e_i, each
%   term encoded via CVX's matrix_frac(e_i,F) atom (Schur-complement LMI
%   internally). No hand-rolled LMI blocks needed.
%
%   fType='logdet': minimizing log det(CRBM_Omega,Omega) is NOT the same
%   as minimizing log det(F) or any simple atom of F directly, because
%   CRBM_OO is the INVERSE of a SCHUR COMPLEMENT of F, not of F itself.
%   Using the block-matrix inversion identity, with F partitioned as
%   F = [F11 F12; F21 F22] (F11 = Omega-block, F22 = gamma-block):
%       (F^{-1})_{Omega,Omega} = S^{-1},   S = F11 - F12*F22^{-1}*F21
%   so log det(CRBM_OO) = -log det(S). Minimizing this = maximizing
%   log det(S). Although log det(S) is a concave function of F (a
%   classical result -- log-det of a Schur complement is concave), CVX's
%   DCP ruleset cannot verify this directly from "log_det(F)-log_det(F22)"
%   (difference of two concave terms is not DCP-recognizable as concave).
%   The DCP-safe encoding introduces an auxiliary real symmetric variable
%   Daux (dK x dK) with the LMI
%       [F11 - Daux,  F12 ;  F21,  F22] >= 0
%   which (by the Schur complement lemma, given F22 > 0) is equivalent to
%   Daux <= S in the PSD order. Since log_det is monotone increasing in
%   the PSD order, maximizing log_det(Daux) subject to this LMI drives
%   Daux -> S at the optimum, giving max log_det(Daux) = log det(S) =
%   -log det(CRBM_OO), i.e. exactly the desired minimization.
%
% REQUIRES: CVX (http://cvxr.com/cvx/) on the MATLAB path (>> cvx_setup once).
%
% INPUTS/OUTPUTS: same convention as compute_CRBM.m. fType: 'trace' (default)
% or 'logdet'.
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    if nargin < 7 || isempty(fType); fType = 'trace'; end
    if ~any(strcmpi(fType, {'trace','logdet'}))
        error('optimal_waveform_cvx:unsupported', ...
            'fType must be ''trace'' or ''logdet''.');
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

        switch lower(fType)
            case 'trace'
                expression obj
                obj = 0;
                for i = 1:dK
                    ei = zeros(Ntot,1); ei(i) = 1;
                    obj = obj + matrix_frac(ei, F);   % e_i' * F^{-1} * e_i
                end
                minimize( obj )
                subject to
                    trace(Rs) <= 1;                                    % eq. (11)

            case 'logdet'
                variable Daux(dK,dK) symmetric
                F11 = F(1:dK, 1:dK);
                F12 = F(1:dK, dK+1:end);
                F22 = F(dK+1:end, dK+1:end);
                maximize( log_det(Daux) )
                subject to
                    trace(Rs) <= 1;                                    % eq. (11)
                    [F11 - Daux, F12; F12', F22] >= 0;                  % Schur-complement LMI
        end
    cvx_end

    Rs_opt = M * Lambda * M';
    Rs_opt = (Rs_opt + Rs_opt')/2;
    [~, obj_opt] = compute_CRBM(Dt, Dr, Omega, gamma, Rs_opt, sigma2, numDim, fType);
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
    bottom = [-imag(F_Og)', -imag(F_gg)', real(F_gg)]; % see compute_FIM.m for the Im(X^H)=-imag(X)' derivation

    F = (2/sigma2) * [top; middle; bottom];
end
