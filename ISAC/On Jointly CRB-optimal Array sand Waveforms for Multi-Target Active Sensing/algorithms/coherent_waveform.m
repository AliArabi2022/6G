function Rs = coherent_waveform(At, targetSet)
%COHERENT_WAVEFORM  Multi-target coherent-beam transmit covariance.
%
% SINGLE-TARGET EQUATION (15):
%   S_coh = (1/||at(w1)||^2) * u * at(w1)^H,  ||u||_2 = 1
%   => Rs_coh = S_coh^H S_coh = (1/||at(w1)||^4) * at(w1) at(w1)^H  (rank 1)
%   (u is an arbitrary unit-norm temporal waveform; per Remark 2 the CRBM
%    only depends on Rs = S^H S, so u cancels and Rs_coh is unique.)
%
% MULTI-TARGET EXTENSION (not a numbered equation in the paper; the paper
% only defines "coherent beamforming" qualitatively in Sec. III-A as
% "sending energy coherently toward the target directions." We adopt the
% standard multi-target coherent-beamforming covariance, i.e., an equal
% superposition of per-target coherent beams, normalized to satisfy the
% power constraint tr(Rs)<=1. This is the natural K-target generalization
% of (15) and is consistent with the paper's Fig. 2 experiments, which
% compare "coherent" vs. "optimal" waveforms for K > 1 targets.)
%
% ASSUMPTION (Phase 11 - explicitly flagged): the exact multi-target
% coherent-beam definition is not spelled out in the 5-page paper; the
% equal-superposition form below is the standard choice in the cited
% prior work [14],[15],[16] for the single-target case and its most
% direct multi-target generalization.
%
% INPUTS
%   At        - (Nt x K) Tx steering matrix for ALL K targets
%   targetSet - (optional) subset of target indices to beam towards
%               (default: all targets 1:K)
%
% OUTPUT
%   Rs - (Nt x Nt) transmit covariance, tr(Rs) = 1
%
% Author: (auto-generated MATLAB reproduction)
% Date: 2026-07-07

    [Nt, K] = size(At);
    if nargin < 2 || isempty(targetSet)
        targetSet = 1:K;
    end

    Rs = zeros(Nt, Nt);
    for k = targetSet
        ak = At(:,k);
        nrm2 = norm(ak)^2;
        Rs = Rs + (ak*ak') / nrm2^2; % eq. (15) rank-1 contribution per target
    end
    Rs = Rs / trace(Rs); % normalize to satisfy tr(Rs) <= 1 (eq. 11) with equality
end
