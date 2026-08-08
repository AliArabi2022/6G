function [Atr, Adot_tr, At, Ar] = compute_atr_and_derivative(Dt, Dr, Omega, numDim)
%COMPUTE_ATR_AND_DERIVATIVE  Build Atr (eq. 3) and its angle-derivative
%   Adot_tr (eq. 8), restricted to the `numDim` estimable direction-cosine
%   components per Remark 1.
%
% THEORY
%   at(omega_k)  = exp(1j * Dt * omega_k)                      (Nt x 1)
%   ar(omega_k)  = exp(1j * Dr * omega_k)                      (Nr x 1)
%   atr(omega_k) = at(omega_k) ⊗ ar(omega_k)                   (NtNr x 1)   (3)
%
%   d/d(omega_k,i) atr(omega_k)
%      = [d/d(omega_k,i) at(omega_k)] ⊗ ar(omega_k)
%        + at(omega_k) ⊗ [d/d(omega_k,i) ar(omega_k)]
%   with d/d(omega_k,i) at(omega_k) = 1j * Dt(:,i) .* at(omega_k)          (8)
%   (elementwise, since at_n(omega_k)=exp(1j*Dt(n,:)*omega_k) is a scalar
%    exponential of a linear form in omega_k).
%
% INPUTS
%   Dt, Dr  - (Nt x 3), (Nr x 3) sensor positions
%   Omega   - (3 x K) full 3D target angular frequencies
%   numDim  - 1/2/3 estimable direction-cosine components (Remark 1)
%
% OUTPUTS
%   Atr      - (NtNr x K)
%   Adot_tr  - (NtNr x numDim*K)   columns ordered target-major:
%              [ dAtr/domega_{1,1} ... dAtr/domega_{1,numDim}, dAtr/domega_{2,1}, ... ]
%   At, Ar   - (Nt x K), (Nr x K) steering matrices (returned for reuse,
%              e.g. eq. 14-16 optimal-waveform decomposition)
%
% Author: (auto-generated MATLAB reproduction)
% Date: 2026-07-07

    K  = size(Omega, 2);
    Nt = size(Dt, 1);
    Nr = size(Dr, 1);

    At = array_manifold(Dt, Omega); % (Nt x K)
    Ar = array_manifold(Dr, Omega); % (Nr x K)
    Atr = khatri_rao(At, Ar);       % (NtNr x K)   eq. (3)

    Adot_tr = zeros(Nt*Nr, numDim*K);
    col = 0;
    for k = 1:K
        at_k = At(:,k); ar_k = Ar(:,k);
        for i = 1:numDim
            dat_k = 1i * Dt(:,i) .* at_k; % d/d(omega_i) at(omega_k)
            dar_k = 1i * Dr(:,i) .* ar_k; % d/d(omega_i) ar(omega_k)
            col = col + 1;
            Adot_tr(:,col) = kron(dat_k, ar_k) + kron(at_k, dar_k); % eq. (8) term
        end
    end
end
