function generate_fig6()
%GENERATE_FIG6 Fig.6: MSE(G) vs. SINR threshold, extended target, K=6 and K=12.
%
%   Reproduces Fig. 6 of the CRB paper: SINR swept 2-20dB (Sec. V),
%   K in {6,12} per body text (this figure's K values were NOT part
%   of the Fig.5 legend/text ambiguity -- Assumption A3 applies only
%   to Fig.5). All 3 methods (Proposed/Alg.D, Design1, Design2)
%   evaluated via CRB(G) (Eq.16) on their respective achieved RX.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    params = parameters();
    K_values = [6, 12];
    Gamma_dB_sweep = 2:2:20;
    Nsweep = numel(Gamma_dB_sweep);
    Nmethods = 3;
    NK = numel(K_values);
    Ntrials = params.Ntrials;

    crb_extra = struct('Nr',params.Nr,'L',params.L,'sigmaR2',params.sigmaR2);

    % Phase 13 optimization: precompute once, reused across the entire
    % K x Gamma sweep (geometry never changes).
    grid_cache = struct( ...
        'A_grid', steering_vectors_grid(params.angle_grid_rad, params.Nt, params.d_spacing), ...
        'd_theta', double(abs(params.angle_grid_rad - params.theta_true_rad) <= params.mainlobe_width_rad/2).');

    MSE_dB = NaN(Nsweep, Nmethods, NK);
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

                [WC, WA, diagD] = extended_multiuser_sdr(H, Gamma, params.sigmaC2, params.PT, params.Nt);
                if strcmpi(diagD.cvx_status,'Solved') || strcmpi(diagD.cvx_status,'Inaccurate/Solved')
                    RX_prop = WC*WC' + WA*WA';
                    trial_results(tr,1,1) = 10*log10(compute_crb(RX_prop, 'extended', crb_extra));
                    feas(tr,1) = true;
                end

                [RX_d1, diag1] = design1_sdr(H, Gamma, params.sigmaC2, params.PT, ...
                    params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, grid_cache);
                if strcmpi(diag1.cvx_status,'Solved') || strcmpi(diag1.cvx_status,'Inaccurate/Solved')
                    trial_results(tr,1,2) = 10*log10(compute_crb(RX_d1, 'extended', crb_extra));
                    feas(tr,2) = true;
                end

                [RX_d2, R2_cached, diag2] = design2_sdr(H, Gamma, params.sigmaC2, params.PT, ...
                    params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, R2_cached, grid_cache);
                if strcmpi(diag2.cvx_status_stage2,'Solved') || strcmpi(diag2.cvx_status_stage2,'Inaccurate/Solved')
                    trial_results(tr,1,3) = 10*log10(compute_crb(RX_d2, 'extended', crb_extra));
                    feas(tr,3) = true;
                end
            end

            [m, ~, ff] = aggregate_mc(trial_results, feas);
            MSE_dB(s,:,kk) = m;
            feasfrac(s,:,kk) = ff;
            fprintf('Fig6: K=%d, Gamma=%d dB done (feas=[%.2f %.2f %.2f])\n', K, Gamma_dB_sweep(s), ff(1), ff(2), ff(3));
        end
    end

    fig = figure('Position',[100 100 700 500]);
    colors = {'b','r','g'};
    styles = {'-o','-s'};
    labels = {'Proposed', 'Design 1 [10]', 'Design 2 [11]'};
    legend_entries = {};
    for kk = 1:NK
        for m = 1:Nmethods
            plot(Gamma_dB_sweep, MSE_dB(:,m,kk), [colors{m} styles{kk}], 'LineWidth', 1.5); hold on;
            legend_entries{end+1} = sprintf('%s, K=%d', labels{m}, K_values(kk)); %#ok<AGROW>
        end
    end
    xlabel('SINR threshold \Gamma (dB)'); ylabel('MSE(G) (dB)');
    legend(legend_entries, 'Location', 'best');
    title('Extended target: MSE vs. SINR tradeoff'); xlim([2 20]);

    apply_paper_style(fig);
    export_figure(fig, results_dir(), 'fig6');
    save(fullfile(results_dir(),'fig6_data.mat'), 'Gamma_dB_sweep', 'K_values', 'MSE_dB', 'feasfrac');

    % Also save a copy into a plain output/ folder, as requested
    if ~exist('output','dir'); mkdir('output'); end
    saveas(fig, fullfile('output','fig6.png'));

    close(fig);
end
