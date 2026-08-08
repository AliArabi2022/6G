function S = optimal_waveform_closedform(u, a_t_omega)
%OPTIMAL_WAVEFORM_CLOSEDFORM Constructs the CRB-optimal Tx waveform
% matrix, eq. (5) in the paper: coherent transmit beamforming toward
% the (assumed known / estimated) target angle.
%
% Theory:
%   S = u * a_t(omega)^T
%   where u in C^T is a unit-norm (or fixed-power) temporal weighting
%   vector (paper's numerical example: u = (1/sqrt(T)) * ones(T,1),
%   with T = Nt), and a_t(omega) is the Tx steering vector toward the
%   (assumed) target direction. This makes every Tx element transmit
%   the same waveform (up to steering-vector phase), i.e. Tx
%   beamforming -- shown to maximize the effective SNR / minimize the
%   CRB among all waveforms of fixed total transmit power.
%
% Inputs:
%   u          - Tx1 column vector, temporal weighting (power-normalized)
%   a_t_omega  - Ntx1 column vector, Tx steering vector at the
%                (assumed/estimated) target angle
%
% Outputs:
%   S - TxNt waveform matrix, S = u * a_t_omega.'
%
% Equation reference: eq. (5).
%
% Practical note: since S is only a function of the assumed angle, an
% initial coarse angle estimate is needed in practice before this
% closed-form beamforming waveform can be formed (see paper's remark
% referencing [13]); this project uses the known ground-truth angle
% for the Monte Carlo study, matching the paper's simplified numerical
% setup (Section 4).
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    u = u(:);
    a_t_omega = a_t_omega(:);
    S = u * a_t_omega.';

end
