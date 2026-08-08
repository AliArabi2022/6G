function [CRBM_OO, obj] = compute_CRBM(Dt, Dr, Omega, gamma, Rs, sigma2, numDim, fType)
%COMPUTE_CRBM  End-to-end: geometry + waveform -> CRBM_Omega,Omega and f(.)
%
% EQUATION (9): CRBM_{Omega,Omega} = J' * F^{-1} * J,  J = [I_{dK}, 0_{dK,2K}]'
%   i.e., simply the top-left (numDim*K)x(numDim*K) block of F^{-1}.
%
% INPUTS
%   Dt,Dr   - (Nt x 3),(Nr x 3) sensor position sets
%   Omega   - (3 x K) full target angular frequencies
%   gamma   - (K x 1) reflection coefficients
%   Rs      - (Nt x Nt) transmit covariance (tr(Rs)<=1)
%   sigma2  - noise variance
%   numDim  - 1/2/3 (Remark 1)
%   fType   - 'trace' | 'logdet' | 'maxeig'  (eq. 10: f is any convex
%             function of CRBM; the paper's numerical experiments use the
%             trace, Sec. IV-B: "the resulting trace of the CRB")
%
% OUTPUTS
%   CRBM_OO - (numDim*K x numDim*K) CRB matrix on target angles
%   obj     - scalar f(CRBM_OO)
%
% ASSUMPTION (Phase 11): a small diagonal loading (1e-10) is added to F
% before inversion purely for numerical robustness against rank
% deficiency (e.g., very small/degenerate candidate geometries); it has
% negligible effect on well-posed configurations and is standard practice
% not specific to this paper.
%
% Author: (auto-generated MATLAB reproduction)
% Date: 2026-07-07

    if nargin < 8 || isempty(fType)
        fType = 'trace';
    end
    K = size(Omega, 2);
    Nr = size(Dr, 1);

    [Atr, Adot_tr] = compute_atr_and_derivative(Dt, Dr, Omega, numDim);
    F = compute_FIM(Atr, Adot_tr, Rs, Nr, gamma, sigma2, numDim, K);

    epsLoad = 1e-10 * trace(F)/size(F,1);
    Finv = inv(F + epsLoad*eye(size(F))); %#ok<MINV>

    dK = numDim*K;
    CRBM_OO = Finv(1:dK, 1:dK); % eq. (9)
    CRBM_OO = (CRBM_OO + CRBM_OO')/2;

    switch lower(fType)
        case 'trace'
            obj = real(trace(CRBM_OO));
        case 'logdet'
            obj = real(log(det(CRBM_OO)));
        case 'maxeig'
            obj = max(real(eig(CRBM_OO)));
        otherwise
            error('compute_CRBM:badFType', 'Unknown fType: %s', fType);
    end
end
