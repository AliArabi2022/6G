function generate_fig3()
%GENERATE_FIG3 Fig.3: beampattern comparison, point target, K=4, Gamma=15dB.
%
%   Reproduces Fig. 3 of the CRB paper: transmit beampattern P(theta;RX)
%   over -90:0.1:90 deg, comparing the proposed method (Algorithm B)
%   against Design 1 (ref [10]) and Design 2 (ref [11]) benchmarks, at
%   a fixed operating point K=4, Gamma_k=15 dB for all k.
%
%   Beampatterns are averaged (in linear power, then converted to dB)
%   over Ntrials random channel realizations, per Sec. V's Monte Carlo
%   convention.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    params = parameters();
    K = 4;
    Gamma_dB = 15;
    Gamma = 10^(Gamma_dB/10) * ones(K,1);
    Ntrials = params.Ntrials;

    [a_vec, ~] = steering_vectors(params.theta_true_rad, params.Nt, params.d_spacing);
    Ngrid = numel(params.angle_grid_rad);
    Nmethods = 3;   % 1=Proposed, 2=Design1, 3=Design2

    % Phase 13 optimization: precompute the benchmark steering-vector
    % grid ONCE (geometry is fixed for the whole figure), instead of
    % letting design1_sdr/design2_sdr recompute it on every trial.
    grid_cache = struct( ...
        'A_grid', steering_vectors_grid(params.angle_grid_rad, params.Nt, params.d_spacing), ...
        'd_theta', double(abs(params.angle_grid_rad - params.theta_true_rad) <= params.mainlobe_width_rad/2).');

    bp_accum_lin = zeros(Ngrid, Nmethods);
    feas_count   = zeros(1, Nmethods);
    R2_cached = [];

    for tr = 1:Ntrials
        H = generate_channel(K, params.Nt);

        % Proposed (Algorithm B)
        [WD, diagB] = pointtarget_multiuser_sdr(a_vec, H, Gamma, params.sigmaC2, params.PT);
        if strcmpi(diagB.cvx_status,'Solved') || strcmpi(diagB.cvx_status,'Inaccurate/Solved')
            RX_prop = WD*WD';
            bp_accum_lin(:,1) = bp_accum_lin(:,1) + 10.^(compute_beampattern(RX_prop, params.angle_grid_rad, params.d_spacing)/10);
            feas_count(1) = feas_count(1) + 1;
        end

        % Design 1
        [RX_d1, diag1] = design1_sdr(H, Gamma, params.sigmaC2, params.PT, ...
            params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, grid_cache);
        if strcmpi(diag1.cvx_status,'Solved') || strcmpi(diag1.cvx_status,'Inaccurate/Solved')
            bp_accum_lin(:,2) = bp_accum_lin(:,2) + 10.^(compute_beampattern(RX_d1, params.angle_grid_rad, params.d_spacing)/10);
            feas_count(2) = feas_count(2) + 1;
        end

        % Design 2 (cache Stage-1 R2 across trials: same theta/PT every trial)
        [RX_d2, R2_cached, diag2] = design2_sdr(H, Gamma, params.sigmaC2, params.PT, ...
            params.theta_true_rad, params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, R2_cached, grid_cache);
        if strcmpi(diag2.cvx_status_stage2,'Solved') || strcmpi(diag2.cvx_status_stage2,'Inaccurate/Solved')
            bp_accum_lin(:,3) = bp_accum_lin(:,3) + 10.^(compute_beampattern(RX_d2, params.angle_grid_rad, params.d_spacing)/10);
            feas_count(3) = feas_count(3) + 1;
        end

        if mod(tr,50)==0
            fprintf('Fig3: trial %d/%d done\n', tr, Ntrials);
        end
    end

    bp_avg_dBi = NaN(Ngrid, Nmethods);
    for m = 1:Nmethods
        if feas_count(m) > 0
            bp_avg_dBi(:,m) = 10*log10(bp_accum_lin(:,m)/feas_count(m));
        end
    end

    fig = figure('Position',[100 100 700 500]);
    plot(rad2deg(params.angle_grid_rad), bp_avg_dBi(:,1), 'b-', 'LineWidth', 1.5); hold on;
    plot(rad2deg(params.angle_grid_rad), bp_avg_dBi(:,2), 'r--', 'LineWidth', 1.5);
    plot(rad2deg(params.angle_grid_rad), bp_avg_dBi(:,3), 'g-.', 'LineWidth', 1.5);
    xlabel('Direction (degree)'); ylabel('Beampattern (dBi)');
    legend('Proposed (Alg. B)', 'Design 1 [10]', 'Design 2 [11]', 'Location', 'best');
    title(sprintf('Beampattern comparison, K=%d, \\Gamma=%d dB', K, Gamma_dB));
    xlim([-90 90]);

    apply_paper_style(fig);
    export_figure(fig, results_dir(), 'fig3');
    save(fullfile(results_dir(),'fig3_data.mat'), 'bp_avg_dBi', 'feas_count', 'params', 'K', 'Gamma_dB');

    % Also save a copy into a plain output/ folder, as requested
    if ~exist('output','dir'); mkdir('output'); end
    saveas(fig, fullfile('output','fig3.png'));

    close(fig);
end
