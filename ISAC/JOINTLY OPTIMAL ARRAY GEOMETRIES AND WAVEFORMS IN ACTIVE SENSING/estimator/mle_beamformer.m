function [omega_hat, obj_vals] = mle_beamformer(y, S, D_t, D_r, omega_grid)
%MLE_BEAMFORMER Computes the maximum likelihood estimate (MLE) of the
% target angle omega via the joint Tx-Rx beamformer, as derived in the
% paper (Section 4):
%
%   omega_hat = argmax_{omega_bar}
%       | y^H (S*a_t(omega_bar) (kron) a_r(omega_bar)) |^2
%       / || S*a_t(omega_bar) ||^2
%
% Theory:
%   Given the signal model (eq. 1), for a FIXED waveform matrix S, the
%   MLE of omega reduces to this normalized matched-filter / beamformer
%   search over candidate angles -- a standard result for a single
%   complex sinusoid amplitude with unknown (nonlinear) frequency
%   parameter omega, linear (given omega) in gamma.
%
% Inputs:
%   y          - (T*Nr) x 1 received data vector, eq. (1)
%   S          - T x Nt waveform matrix used for transmission
%   D_t        - 1xNt Tx sensor positions
%   D_r        - 1xNr Rx sensor positions
%   omega_grid - 1xM vector of candidate angles in [-pi, pi) to search
%                over (grid search; paper does not specify a refinement
%                step, so this implementation uses grid search only --
%                see Phase 12 debugging notes for a suggested
%                refinement to reduce grid quantization error)
%
% Outputs:
%   omega_hat - scalar, the grid point achieving the maximum objective
%   obj_vals  - 1xM vector, objective value at each grid point (useful
%               for diagnostic plotting of the beampattern)
%
% Equation reference: Section 4, joint Tx-Rx beamformer MLE expression.
%
% Numerical implementation strategy: vectorized across the angle grid
% for efficiency, since this is called once per Monte Carlo trial.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    T  = size(S,1);
    Nt = size(S,2);
    Nr = numel(D_r);
    M  = numel(omega_grid);

    A_t = steering_vector(omega_grid, D_t);   % Nt x M
    A_r = steering_vector(omega_grid, D_r);   % Nr x M

    obj_vals = zeros(1, M);

    for m = 1:M
        Sat = S * A_t(:,m);              % T x 1
        h   = kron(Sat, A_r(:,m));       % (T*Nr) x 1, joint steering
        num = abs(y' * h)^2;
        den = norm(Sat)^2;               % ||S*a_t||^2 (norm(a_r)=... handled via kron scaling below)
        % Note: kron(Sat, A_r(:,m)) has norm^2 = norm(Sat)^2 * norm(A_r(:,m))^2.
        % The paper's normalization is by ||S*a_t(omega)||^2 only (a_r has
        % unit-modulus entries so norm(a_r)^2 = Nr, a constant that does not
        % affect the argmax location; included here for a numerically
        % well-scaled objective, but does not change omega_hat).
        obj_vals(m) = num / den;
    end

    [~, idx] = max(obj_vals);
    omega_hat = omega_grid(idx);

end
