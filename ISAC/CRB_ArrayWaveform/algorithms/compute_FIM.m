function F = compute_FIM(Atr, Adot_tr, Rs, Nr, gamma, sigma2, numDim, K)
%COMPUTE_FIM  Assemble the Fisher Information Matrix F, eq. (4)-(8).
%
% EQUATIONS
%   R = Rs ⊗ I_Nr                                        (defined after eq. 8)
%   F_{Omega,Omega} = Adot_tr' * R * Adot_tr .* (gamma* gamma' ⊗ 1_d 1_d')     (5)
%   F_{gamma,gamma} = Atr' * R * Atr                                          (6)
%   F_{Omega,gamma} = Adot_tr' * R * Atr .* (gamma* 1_K' ⊗ 1_d)               (7)
%
%   F = (2/sigma2) * [ Re{F_OO}          Re{F_Og}        -Im{F_Og}  ;
%                      Re{F_Og}^H        Re{F_gg}        -Im{F_gg}  ;
%                     -Im{F_Og}^T       -Im{F_gg}^T        Re{F_gg} ]           (4)
%
% IMPORTANT IDENTITY used below: for any complex matrix X,
%   Im(X^H) = Im(conj(X)^T) = (-Im(X))^T = -imag(X)'   (since imag(X) is
%   real, its conjugate-transpose ' equals its plain transpose).
% The bottom-left blocks of (4) are Im{F_Og}^H and Im{F_gg}^H, which by
% this identity equal -imag(F_Og)' and -imag(F_gg)' respectively -- NOT
% +imag(F_Og)'/+imag(F_gg)' as a naive transcription would suggest. This
% sign is what guarantees F is exactly (not just numerically-forced)
% symmetric, hence a valid PSD Fisher Information Matrix.
%
% NOTE on dimension d: in the paper d = 3 (full 3D angle). Here d = numDim
% (Remark 1 reduction: 1 for linear, 2 for planar, 3 for cubic arrays),
% and 1_d is a d x 1 all-ones vector (so 1_d 1_d' is d x d all-ones).
%
% INPUTS
%   Atr, Adot_tr - from compute_atr_and_derivative (already restricted to numDim)
%   Rs           - (Nt x Nt) transmit waveform covariance, tr(Rs) <= 1
%   Nr           - number of Rx sensors (for building R = Rs ⊗ I_Nr)
%   gamma        - (K x 1) complex reflection coefficients
%   sigma2       - noise variance
%   numDim       - d, estimable angle dimensions per target (Remark 1)
%   K            - number of targets
%
% OUTPUT
%   F - ((numDim+2)*K x (numDim+2)*K) real Fisher Information Matrix
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    R = kron(Rs, eye(Nr)); % (Nt*Nr x Nt*Nr), matches Atr's [Tx-slow, Rx-fast] ordering

    gamma = gamma(:);
    onesD = ones(numDim, 1);

    % Hadamard mask: gamma* * gamma' ⊗ 1_d 1_d'  (KxK) ⊗ (dxd) -> (Kd x Kd)
    mask_OO = kron(conj(gamma) * gamma.', onesD * onesD');
    F_OO = (Adot_tr' * R * Adot_tr) .* mask_OO;                     % eq. (5)

    F_gg = Atr' * R * Atr;                                          % eq. (6)

    mask_Og = kron(conj(gamma) * ones(1,K), onesD);                 % gamma* 1_K' ⊗ 1_d  -> (Kd x K)
    F_Og = (Adot_tr' * R * Atr) .* mask_Og;                         % eq. (7)

    top    = [real(F_OO),   real(F_Og),  -imag(F_Og)];
    middle = [real(F_Og)',  real(F_gg),  -imag(F_gg)];
    bottom = [-imag(F_Og)', -imag(F_gg)',  real(F_gg)];

    F = (2/sigma2) * [top; middle; bottom];                         % eq. (4)
    F = (F + F')/2; % enforce exact symmetry (numerical hygiene)
end
