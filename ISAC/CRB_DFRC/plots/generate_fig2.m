 function generate_fig2()
%GENERATE_FIG2 Fig.2: closed-form vs. numerical (CVX) verification, K=1.
%
%   Reproduces Fig. 2 of the CRB paper: for a SINGLE user (K=1), sweep
%   the SINR threshold Gamma1 from 20 to 40 dB and compare:
%     (a) Point target:    Root-CRB(theta) [deg]  -- closed form
%         (Theorem 1, Algorithm A) vs. direct CVX solve of the
%         single-user SDP (Algorithm B's machinery called with K=1,
%         bypassing the dispatcher's closed-form branch on purpose --
%         this IS the self-consistency check).
%     (b) Extended target: MSE(G) [dB]            -- closed form
%         (Theorem 3, Algorithm C) vs. direct CVX solve (Algorithm D's
%         machinery called with K=1).
%
%   This figure is run FIRST in main.m as a fast-fail gate: if the
%   closed forms don't match their CVX counterparts here, no
%   downstream benchmark comparison (Figs 3-7) is meaningful.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    params = parameters();
    Gamma_dB_sweep = 20:2:40;
    Nsweep = numel(Gamma_dB_sweep);
    Ntrials = params.Ntrials;

    % Methods: 1 = closed-form, 2 = CVX (direct SDR solve, K=1)
    Nmethods = 2;
    CRB_point_deg  = NaN(Nsweep, Nmethods);
    MSE_ext_dB     = NaN(Nsweep, Nmethods);
    feasfrac_point = NaN(Nsweep, Nmethods);
    feasfrac_ext   = NaN(Nsweep, Nmethods);

    [a_vec, ~]   = steering_vectors(params.theta_true_rad, params.Nt, params.d_spacing);
    [b_vec, bdot_vec] = steering_vectors(params.theta_true_rad, params.Nr, params.d_spacing);

    for s = 1:Nsweep
        Gamma1 = 10^(Gamma_dB_sweep(s)/10);

        trial_results_pt = NaN(Ntrials, 1, Nmethods);
        trial_results_ex = NaN(Ntrials, 1, Nmethods);
        feas_pt = false(Ntrials, Nmethods);
        feas_ex = false(Ntrials, Nmethods);

        for tr = 1:Ntrials
            H = generate_channel(1, params.Nt);
            h1 = H(1,:)';

            % --- Point target ---
            [w1_cf, diag_cf] = pointtarget_singleuser(a_vec, h1, Gamma1, params.sigmaC2, params.PT);
            if diag_cf.feasible
                RX_cf = w1_cf*w1_cf';
                crb_params = struct('a_vec',a_vec,'b_vec',b_vec,'bdot_vec',bdot_vec, ...
                                     'alpha_true',params.alpha_true,'L',params.L,'sigmaR2',params.sigmaR2);
                trial_results_pt(tr,1,1) = rad2deg(sqrt(compute_crb(RX_cf, 'point', crb_params)));
                feas_pt(tr,1) = true;
            end

            [WD_cvx, diag_cvx] = pointtarget_multiuser_sdr(a_vec, H, Gamma1, params.sigmaC2, params.PT);
            if strcmpi(diag_cvx.cvx_status,'Solved') || strcmpi(diag_cvx.cvx_status,'Inaccurate/Solved')
                RX_cvx = WD_cvx*WD_cvx';
                crb_params = struct('a_vec',a_vec,'b_vec',b_vec,'bdot_vec',bdot_vec, ...
                                     'alpha_true',params.alpha_true,'L',params.L,'sigmaR2',params.sigmaR2);
                trial_results_pt(tr,1,2) = rad2deg(sqrt(compute_crb(RX_cvx, 'point', crb_params)));
                feas_pt(tr,2) = true;
            end

            % --- Extended target ---
            [WC_cf, WA_cf, diag_ecf] = extended_singleuser(h1, Gamma1, params.sigmaC2, params.PT, params.Nt);
            if diag_ecf.feasible
                RX_ecf = WC_cf*WC_cf' + WA_cf*WA_cf';
                crb_params_e = struct('Nr',params.Nr,'L',params.L,'sigmaR2',params.sigmaR2);
                mse_lin = compute_crb(RX_ecf, 'extended', crb_params_e);
                trial_results_ex(tr,1,1) = 10*log10(mse_lin);
                feas_ex(tr,1) = true;
            end

            [WC_cvx, WA_cvx, diag_ecvx] = extended_multiuser_sdr(H, Gamma1, params.sigmaC2, params.PT, params.Nt);
            if strcmpi(diag_ecvx.cvx_status,'Solved') || strcmpi(diag_ecvx.cvx_status,'Inaccurate/Solved')
                RX_ecvx = WC_cvx*WC_cvx' + WA_cvx*WA_cvx';
                crb_params_e = struct('Nr',params.Nr,'L',params.L,'sigmaR2',params.sigmaR2);
                mse_lin = compute_crb(RX_ecvx, 'extended', crb_params_e);
                trial_results_ex(tr,1,2) = 10*log10(mse_lin);
                feas_ex(tr,2) = true;
            end
        end

        [m_pt, ~, ff_pt] = aggregate_mc(trial_results_pt, feas_pt);
        [m_ex, ~, ff_ex] = aggregate_mc(trial_results_ex, feas_ex);
        CRB_point_deg(s,:) = m_pt;
        MSE_ext_dB(s,:)    = m_ex;
        feasfrac_point(s,:) = ff_pt;
        feasfrac_ext(s,:)   = ff_ex;

        fprintf('Fig2: Gamma=%d dB done (point feas=[%.2f %.2f], ext feas=[%.2f %.2f])\n', ...
            Gamma_dB_sweep(s), ff_pt(1), ff_pt(2), ff_ex(1), ff_ex(2));
    end

    fig = figure('Position',[100 100 1000 420]);
    subplot(1,2,1);
    plot(Gamma_dB_sweep, CRB_point_deg(:,1), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6); hold on;
    plot(Gamma_dB_sweep, CRB_point_deg(:,2), 'r--x', 'LineWidth', 1.5, 'MarkerSize', 8);
    xlabel('SINR threshold \Gamma_1 (dB)'); ylabel('Root-CRB(\theta) (deg)');
    legend('Closed form (Thm.1)', 'CVX (SDR, K=1)', 'Location', 'best');
    title('Point target'); xlim([20 40]);

    subplot(1,2,2);
    plot(Gamma_dB_sweep, MSE_ext_dB(:,1), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6); hold on;
    plot(Gamma_dB_sweep, MSE_ext_dB(:,2), 'r--x', 'LineWidth', 1.5, 'MarkerSize', 8);
    xlabel('SINR threshold \Gamma_1 (dB)'); ylabel('MSE(G) (dB)');
    legend('Closed form (Thm.3)', 'CVX (SDR, K=1)', 'Location', 'best');
    title('Extended target'); xlim([20 40]);

    apply_paper_style(fig);
    export_figure(fig, results_dir(), 'fig2');
    save(fullfile(results_dir(),'fig2_data.mat'), 'Gamma_dB_sweep', 'CRB_point_deg', 'MSE_ext_dB', ...
         'feasfrac_point', 'feasfrac_ext');

    % Also save a copy into a plain output/ folder, as requested
    if ~exist('output','dir'); mkdir('output'); end
    saveas(fig, fullfile('output','fig2.png'));

    close(fig);
end
