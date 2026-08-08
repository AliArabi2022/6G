function generate_fig7()
%GENERATE_FIG7 Fig.7: MSE(G) vs. number of users K, extended target.
%
%   Reproduces Fig. 7 of the CRB paper: K swept 1-12 (Sec. V), for two
%   fixed SINR thresholds Gamma=10dB and Gamma=20dB. All 3 methods
%   plotted -> 6 curves total.
%
%   NOTE: at K=1 the proposed method routes through Algorithm C
%   (closed form) via extended_multiuser_sdr's own K=1 case would
%   still work numerically (the SDR/extraction machinery degenerates
%   gracefully to a single-user problem), so for consistency with the
%   OTHER sweep points in this figure (which must go through the SDR
%   path since K>1), we deliberately call extended_multiuser_sdr
%   directly at K=1 too, rather than dispatch_beamformer -- ensuring
%   every point in this figure comes from the SAME algorithmic path.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    params = parameters();
    K_sweep = 1:12;
    Gamma_dB_values = [10, 20];
    Nsweep = numel(K_sweep);
    NG = numel(Gamma_dB_values);
    Nmethods = 3;
    Ntrials = params.Ntrials;

    crb_extra = struct('Nr',params.Nr,'L',params.L,'sigmaR2',params.sigmaR2);

    % Phase 13 optimization: precompute once, reused across the entire
    % Gamma x K sweep (geometry never changes, even as K itself is
    % swept -- the ANGLE grid and desired pattern don't depend on K).
    grid_cache = struct( ...
        'A_grid', steering_vectors_grid(params.angle_grid_rad, params.Nt, params.d_spacing), ...
        'd_theta', double(abs(params.angle_grid_rad - params.theta_true_rad) <= params.mainlobe_width_rad/2).');

    MSE_dB = NaN(Nsweep, Nmethods, NG);
    feasfrac = NaN(Nsweep, Nmethods, NG);

    for gg = 1:NG
        Gamma_dB = Gamma_dB_values(gg);
        R2_cached = [];
        for s = 1:Nsweep
            K = K_sweep(s);
            Gamma = 10^(Gamma_dB/10) * ones(K,1);
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
            MSE_dB(s,:,gg) = m;
            feasfrac(s,:,gg) = ff;
            fprintf('Fig7: Gamma=%d dB, K=%d done (feas=[%.2f %.2f %.2f])\n', Gamma_dB, K, ff(1), ff(2), ff(3));
        end
    end

    fig = figure('Position',[100 100 700 500]);
    colors = {'b','r','g'};
    styles = {'-o','-s'};
    labels = {'Proposed', 'Design 1 [10]', 'Design 2 [11]'};
    legend_entries = {};
    for gg = 1:NG
        for m = 1:Nmethods
            plot(K_sweep, MSE_dB(:,m,gg), [colors{m} styles{gg}], 'LineWidth', 1.5); hold on;
            legend_entries{end+1} = sprintf('%s, \\Gamma=%ddB', labels{m}, Gamma_dB_values(gg)); %#ok<AGROW>
        end
    end
    xlabel('Number of users K'); ylabel('MSE(G) (dB)');
    legend(legend_entries, 'Location', 'best');
    title('Extended target: MSE vs. number of users');
    xlim([1 12]); xticks(1:12);

    apply_paper_style(fig);
    export_figure(fig, results_dir(), 'fig7');
    save(fullfile(results_dir(),'fig7_data.mat'), 'K_sweep', 'Gamma_dB_values', 'MSE_dB', 'feasfrac');

    % Also save a copy into a plain output/ folder, as requested
    if ~exist('output','dir'); mkdir('output'); end
    saveas(fig, fullfile('output','fig7.png'));

    close(fig);
end
