function A = array_manifold(D, Omega)
%ARRAY_MANIFOLD  Steering matrix for a sensor set and set of target angles.
%
% EQUATION (Sec. II-A):
%   a(omega_k) = [exp(1j*d[1]'*omega_k), ..., exp(1j*d[N]'*omega_k)]'  in C^N
%   A(Omega)   = [a(omega_1), ..., a(omega_K)]                        in C^{N x K}
%
% NOTE: The paper indexes sensors d[0]..d[Nt] (eq. after (3)); we use the
% equivalent 1-based MATLAB indexing d[1]..d[N] with no loss of generality
% (only relative phase differences matter for the CRB / FIM, and a common
% phase reference cancels in Re/Im{.} products used throughout).
%
% INPUTS
%   D     - (N x 3) Cartesian sensor positions (rows = sensors)
%   Omega - (3 x K) target spatial-frequency vectors
%
% OUTPUT
%   A     - (N x K) steering matrix, A(n,k) = exp(1j * D(n,:) * Omega(:,k))
%
% Author: (auto-generated MATLAB reproduction)
% Date: 2026-07-07

    if isempty(D)
        A = zeros(0, size(Omega,2));
        return;
    end
    A = exp(1i * (D * Omega)); % (N x 3)*(3 x K) = (N x K)
end
