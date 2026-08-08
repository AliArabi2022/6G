function generate_fig4()
%GENERATE_FIG4 Fig.4: RMSE (MLE) vs. CRB, point target, vs. Radar SNR.
%
%   Reproduces Fig. 4 of the CRB paper: K=4, Gamma_k=15dB fixed, radar
%   SNR = |alpha|^2*L*PT/sigmaR2 swept from -20 to 0 dB by scaling
%   alpha_true's magnitude (PT, L, sigmaR2 held fixed per Sec. V).
%   For each of the 3 methods (Proposed/Alg.B, Design1, Design2),
%   plots BOTH the theoretical Root-CRB(theta) and the empirical RMSE
%   of the exhaustive-grid MLE (mle_angle_search.m) -- 6 curves total,
%   log-scale y-axis.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    params = parameters();
    K = 4;
    Gamma_dB = 15;
    Gamma = 10^(Gamma_dB/10) * ones(K,1);
    Ntrials = params.Ntrials;

    radarSNR_dB_sweep = -20:4:0;
    Nsweep = numel(radarSNR_dB_sweep);
    Nmethods = 3;

    [a_vec, ~]         = steering_vectors(params.theta_true_rad, params.Nt, params.d_spacing);
    [b_vec, bdot_vec]  = steering_vectors(params.theta_true_rad, params.Nr, params.d_spacing);

    % Phase 13 optimization: precompute once, reused by both benchmarks
    % across every sweep point x trial x method (geometry never changes).
    grid_cache = struct( ...
        'A_grid', steering_vectors_grid(params.angle_grid_rad, params.Nt, params.d_spacing), ...
        'd_theta', double(abs(params.angle_grid_rad - params.theta_true_rad) <= params.mainlobe_width_rad/2).');

    CRB_deg  = NaN(Nsweep, Nmethods);
    RMSE_deg = NaN(Nsweep, Nmethods);
    R2_cached = [];

    for s = 1:Nsweep
        % |alpha|^2 = radarSNR_lin * sigmaR2 / (L*PT)
        radarSNR_lin = 10^(radarSNR_dB_sweep(s)/10);
        alpha_mag = sqrt(radarSNR_lin * params.sigmaR2 / (params.L * params.PT));
        alpha_true = alpha_mag * exp(1i*angle(params.alpha_true));

        crb_trials  = NaN(Ntrials, 1, Nmethods);
        rmse_trials = NaN(Ntrials, 1, Nmethods);
        feas = false(Ntrials, Nmethods);

        for tr = 1:Ntrials
            H = generate_channel(K, params.Nt);

            for m = 1:Nmethods
                switch m
                    case 1
                        [WD, diagm] = pointtarget_multiuser_sdr(a_vec, H, Gamma, params.sigmaC2, params.PT);
                        ok = strcmpi(diagm.cvx_status,'Solved') || strcmpi(diagm.cvx_status,'Inaccurate/Solved');
                        RX = WD*WD';
                    case 2
                        [RX, diagm] = design1_sdr(H, Gamma, params.sigmaC2, params.PT, ...
                            params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, grid_cache);
                        ok = strcmpi(diagm.cvx_status,'Solved') || strcmpi(diagm.cvx_status,'Inaccurate/Solved');
                    case 3
                        [RX, R2_cached, diagm] = design2_sdr(H, Gamma, params.sigmaC2, params.PT, ...
                            params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, R2_cached, grid_cache);
                        ok = strcmpi(diagm.cvx_status_stage2,'Solved') || strcmpi(diagm.cvx_status_stage2,'Inaccurate/Solved');
                end

                if ~ok, continue; end

                crb_params = struct('a_vec',a_vec,'b_vec',b_vec,'bdot_vec',bdot_vec, ...
                                     'alpha_true',alpha_true,'L',params.L,'sigmaR2',params.sigmaR2);
                crb_val = compute_crb(RX, 'point', crb_params);
                crb_trials(tr,1,m) = rad2deg(sqrt(crb_val));

                % Synthesize one noisy echo realization and run MLE.
                % Generate raw i.i.d. Gaussian columns, then WHITEN and
                % RE-COLOR so the sample covariance (1/L)*Xtrial*Xtrial'
                % equals RX exactly (up to the whitening step itself
                % being exact by construction, not just in expectation):
                Xraw = (randn(params.Nt, params.L) + 1i*randn(params.Nt, params.L))/sqrt(2);
                Rraw = (Xraw*Xraw')/params.L;
                Rraw = (Rraw+Rraw')/2;
                [Uraw, Sraw] = eig(Rraw);
                Sraw = max(real(diag(Sraw)), 1e-12);
                whitening = Uraw * diag(Sraw.^(-1/2)) * Uraw';   % Rraw^(-1/2)
                Xwhite = whitening * Xraw;                        % (1/L)*Xwhite*Xwhite' = I exactly
                RXsqrt = sqrtm(RX);
                Xtrial = RXsqrt * Xwhite;                         % (1/L)*Xtrial*Xtrial' = RX exactly

                Gtrue = alpha_true * (b_vec * a_vec');   % reuses b_vec hoisted at top of function (Phase 13 fix: was recomputing steering_vectors() here on every trial)
                noise = sqrt(params.sigmaR2/2)*(randn(params.Nr,params.L)+1i*randn(params.Nr,params.L));
                YR = Gtrue*Xtrial + noise;

                theta_hat = mle_angle_search(YR, Xtrial, params.angle_grid_rad, params.Nr, params.Nt, params.d_spacing);
                rmse_trials(tr,1,m) = rad2deg(abs(theta_hat - params.theta_true_rad));
                feas(tr,m) = true;
            end
        end

        [m_crb, ~, ~]  = aggregate_mc(crb_trials, feas);
        [m_rmse_sq, ~, ~] = aggregate_mc(rmse_trials.^2, feas);   % average squared error -> sqrt for RMSE
        CRB_deg(s,:)  = m_crb;
        RMSE_deg(s,:) = sqrt(m_rmse_sq);

        fprintf('Fig4: radarSNR=%d dB done\n', radarSNR_dB_sweep(s));
    end

    fig = figure('Position',[100 100 700 500]);
    colors = {'b','r','g'};
    labels = {'Proposed', 'Design 1 [10]', 'Design 2 [11]'};
    for m = 1:Nmethods
        semilogy(radarSNR_dB_sweep, CRB_deg(:,m), [colors{m} '-o'], 'LineWidth', 1.5); hold on;
        semilogy(radarSNR_dB_sweep, RMSE_deg(:,m), [colors{m} '--x'], 'LineWidth', 1.5);
    end
    xlabel('Radar SNR (dB)'); ylabel('RMSE / Root-CRB (deg), log scale');
    legend([strcat(labels,' CRB'), strcat(labels,' MLE RMSE')], 'Location', 'best');
    title(sprintf('K=%d, \\Gamma=%d dB', K, Gamma_dB));
    xlim([-20 0]);

    apply_paper_style(fig);
    export_figure(fig, results_dir(), 'fig4');
    save(fullfile(results_dir(),'fig4_data.mat'), 'radarSNR_dB_sweep', 'CRB_deg', 'RMSE_deg');

    % Also save a copy into a plain output/ folder, as requested
    if ~exist('output','dir'); mkdir('output'); end
    saveas(fig, fullfile('output','fig4.png'));

    close(fig);
end
