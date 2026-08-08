function mse = monte_carlo_mle(D_t, D_r, cfg)
%MONTE_CARLO_MLE Reproduces the Monte Carlo MSE-vs-SNR curve of Fig. 2
% for a single array geometry (D_t, D_r).
%
% Procedure (Section 4):
%   1. Fix ground truth omega=0, gamma=1 (cfg.omega_true, cfg.gamma_true).
%   2. Use the optimal (coherent beamforming) waveform, eq. (5), formed
%      at the TRUE angle (paper's simplifying assumption for the
%      numerical study -- in practice an initial angle estimate would
%      be required first, see [13] discussed in the paper).
%   3. For each SNR value (SNR_dB = 10*log10(|gamma|^2/sigma^2)), draw
%      cfg.n_trials realizations of i.i.d. circular Gaussian noise,
%      form y, run mle_beamformer.m, and compute squared error
%      (omega_hat - omega_true)^2, averaged over all trials -> MSE.
%
% Inputs:
%   D_t, D_r - Tx/Rx array geometries to test
%   cfg      - configuration struct from parameters.m (uses
%              cfg.T, cfg.u, cfg.omega_true, cfg.gamma_true,
%              cfg.SNR_dB_range, cfg.n_trials, cfg.omega_grid_N,
%              cfg.rng_seed)
%
% Outputs:
%   mse - 1x numel(cfg.SNR_dB_range) vector of Monte Carlo MSE values
%
% Numerical/implementation notes:
%   - rng seeded per-call (offset by geometry hash) for reproducibility
%     while keeping different geometries' noise draws independent;
%     see Phase 13 (Optimization) for parfor parallelization advice.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    rng(cfg.rng_seed);

    Nr = numel(D_r);
    a_t_true = steering_vector(cfg.omega_true, D_t);
    S = optimal_waveform_closedform(cfg.u, a_t_true);   % T x Nt

    omega_grid = linspace(-pi, pi, cfg.omega_grid_N + 1);
    omega_grid(end) = [];   % drop duplicate endpoint (-pi == pi wraparound)

    a_r_true = steering_vector(cfg.omega_true, D_r);
    Sat_true = S * a_t_true;
    h_true = kron(Sat_true, a_r_true);   % noiseless joint steering, (T*Nr)x1

    n_snr = numel(cfg.SNR_dB_range);
    mse = zeros(1, n_snr);

    for si = 1:n_snr
        snr_db = cfg.SNR_dB_range(si);
        sigma2 = abs(cfg.gamma_true)^2 / (10^(snr_db/10));
        sigma = sqrt(sigma2);
        %s=(si/n_snr)*100
        sq_err_sum = 0;
        for trial = 1:cfg.n_trials
            noise = (sigma/sqrt(2)) * (randn(cfg.T*Nr,1) + 1i*randn(cfg.T*Nr,1));
            y = cfg.gamma_true * h_true + noise;
            %p=((trial/cfg.n_trials)*100) 
            omega_hat = mle_beamformer(y, S, D_t, D_r, omega_grid);
            sq_err_sum = sq_err_sum + (omega_hat - cfg.omega_true)^2;
        end
        mse(si) = sq_err_sum / cfg.n_trials;
    end

end
