function generate_fig5()
%GENERATE_FIG5 Fig.5: CRB(theta) vs. SINR threshold, point target, K=14 and K=6.
%
%   Reproduces Fig. 5 of the CRB paper (Assumption A3, user-confirmed:
%   using the LEGEND values K=14 and K=6, not the body-text K=6/K=12).
%   SINR swept 6-20dB per Sec. V. All 3 methods (Proposed/Alg.B,
%   Design1, Design2) plotted for both K values -> 6 curves total.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    params = parameters();
    K_values = [14, 6];       % Assumption A3
    Gamma_dB_sweep = 6:2:20;
    Nsweep = numel(Gamma_dB_sweep);
    Nmethods = 3;
    NK = numel(K_values);
    Ntrials = params.Ntrials;

    [a_vec, ~]        = steering_vectors(params.theta_true_rad, params.Nt, params.d_spacing);
    [b_vec, bdot_vec] = steering_vectors(params.theta_true_rad, params.Nr, params.d_spacing);
    crb_extra = struct('a_vec',a_vec,'b_vec',b_vec,'bdot_vec',bdot_vec, ...
                        'alpha_true',params.alpha_true,'L',params.L,'sigmaR2',params.sigmaR2);

    % Phase 13 optimization: precompute once, reused across the entire
    % K x Gamma sweep (geometry never changes).
    grid_cache = struct( ...
        'A_grid', steering_vectors_grid(params.angle_grid_rad, params.Nt, params.d_spacing), ...
        'd_theta', double(abs(params.angle_grid_rad - params.theta_true_rad) <= params.mainlobe_width_rad/2).');

    CRB_deg = NaN(Nsweep, Nmethods, NK);
    feasfrac = NaN(Nsweep, Nmethods, NK);

    for kk = 1:NK
        K = K_values(kk);
        R2_cached = [];
        for s = 1:Nsweep
            Gamma = 10^(Gamma_dB_sweep(s)/10) * ones(K,1);
            trial_results = NaN(Ntrials, 1, Nmethods);
            feas = false(Ntrials, Nmethods);

            for tr = 1:Ntrials
                H = generate_channel(K, params.Nt);

                [WD, diagB] = pointtarget_multiuser_sdr(a_vec, H, Gamma, params.sigmaC2, params.PT);
                if strcmpi(diagB.cvx_status,'Solved') || strcmpi(diagB.cvx_status,'Inaccurate/Solved')
                    trial_results(tr,1,1) = rad2deg(sqrt(compute_crb(WD*WD', 'point', crb_extra)));
                    feas(tr,1) = true;
                end

                [RX_d1, diag1] = design1_sdr(H, Gamma, params.sigmaC2, params.PT, ...
                    params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, grid_cache);
                if strcmpi(diag1.cvx_status,'Solved') || strcmpi(diag1.cvx_status,'Inaccurate/Solved')
                    trial_results(tr,1,2) = rad2deg(sqrt(compute_crb(RX_d1, 'point', crb_extra)));
                    feas(tr,2) = true;
                end

                [RX_d2, R2_cached, diag2] = design2_sdr(H, Gamma, params.sigmaC2, params.PT, ...
                    params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, R2_cached, grid_cache);
                if strcmpi(diag2.cvx_status_stage2,'Solved') || strcmpi(diag2.cvx_status_stage2,'Inaccurate/Solved')
                    trial_results(tr,1,3) = rad2deg(sqrt(compute_crb(RX_d2, 'point', crb_extra)));
                    feas(tr,3) = true;
                end
            end

            [m, ~, ff] = aggregate_mc(trial_results, feas);
            CRB_deg(s,:,kk) = m;
            feasfrac(s,:,kk) = ff;
            fprintf('Fig5: K=%d, Gamma=%d dB done (feas=[%.2f %.2f %.2f])\n', K, Gamma_dB_sweep(s), ff(1), ff(2), ff(3));
        end
    end

    fig = figure('Position',[100 100 700 500]);
    colors = {'b','r','g'};
    styles = {'-o','-s'};
    labels = {'Proposed', 'Design 1 [10]', 'Design 2 [11]'};
    legend_entries = {};
    for kk = 1:NK
        for m = 1:Nmethods
            semilogy(Gamma_dB_sweep, CRB_deg(:,m,kk), [colors{m} styles{kk}], 'LineWidth', 1.5); hold on;
            legend_entries{end+1} = sprintf('%s, K=%d', labels{m}, K_values(kk)); %#ok<AGROW>
        end
    end
    xlabel('SINR threshold \Gamma (dB)'); ylabel('Root-CRB(\theta) (deg), log scale');
    legend(legend_entries, 'Location', 'best');
    title('Point target: CRB vs. SINR tradeoff'); xlim([6 20]);

    apply_paper_style(fig);
    export_figure(fig, results_dir(), 'fig5');
    save(fullfile(results_dir(),'fig5_data.mat'), 'Gamma_dB_sweep', 'K_values', 'CRB_deg', 'feasfrac');

    % Also save a copy into a plain output/ folder, as requested
    if ~exist('output','dir'); mkdir('output'); end
    saveas(fig, fullfile('output','fig5.png'));

    close(fig);
end
