function [g, Rs] = objective_g(Dt, Dr, Omega, gamma, sigma2, numDim, fType)
%OBJECTIVE_G  g(Dt,Dr) = f(CRBM_Omega(Rs_coh, Dt, Dr))  [Sec. III-B, second
%   (simplified) objective form]:
%       g(Dt,Dr) = f( CRBM_Omega( Rs_coh, Dt, Dr ) )
%   "As it only requires evaluating the CRBM (without solving a
%    semidefinite program) it significantly reduces computational
%    complexity. Therefore, this simplified objective is adopted in the
%    numerical experiments presented in the next section."
%   This is exactly the objective used to produce Figs. 3-7.
%
% INPUTS/OUTPUTS as in compute_CRBM.m; also returns the coherent-beam Rs
% used, for reuse/inspection.
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    if nargin < 7 || isempty(fType); fType = 'trace'; end
    At = array_manifold(Dt, Omega);
    Rs = coherent_waveform(At);
    [~, g] = compute_CRBM(Dt, Dr, Omega, gamma, Rs, sigma2, numDim, fType);
end
