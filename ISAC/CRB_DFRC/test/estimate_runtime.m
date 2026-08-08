function estimate_runtime()
%ESTIMATE_RUNTIME Timed pilot run to extrapolate full-reproduction runtime.
%
%   Runs a SMALL number of trials (Npilot=5) of the single most
%   expensive operation in each figure family -- a single CVX solve of
%   pointtarget_multiuser_sdr (point-target proxy) and
%   extended_multiuser_sdr (extended-target proxy) at representative
%   problem sizes -- and extrapolates the full run's expected wall-clock
%   time using each figure's actual (sweep points x trials x methods)
%   count from Phase 6's execution plan.
%
%   This is deliberately NOT a claim of exact runtime (that depends on
%   your CPU, CVX version, and solver choice) -- it is a measurement
%   TOOL so you can get a real number for YOUR environment before
%   committing to a multi-hour run.
%
%   Requires CVX (this script does touch cvx_begin, unlike the
%   Phase 11/12 test suites which deliberately avoided it).
%
%   Run: estimate_runtime()
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    proj_root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(proj_root));

    if ~exist('cvx_begin', 'file')
        error('estimate_runtime:cvxNotFound', ...
            'This script needs CVX to produce a real timing estimate. Install CVX and run cvx_setup first.');
    end

    params = parameters();
    Npilot = 5;

    fprintf('=== Runtime Pilot (Npilot=%d trials per representative solve) ===\n\n', Npilot);

    % --- Representative point-target multiuser solve (K=6, mid-range) ---
    [a_vec, ~] = steering_vectors(params.theta_true_rad, params.Nt, params.d_spacing);
    K = 6;
    Gamma = 10^(15/10)*ones(K,1);
    tic;
    for i = 1:Npilot
        H = generate_channel(K, params.Nt);
        pointtarget_multiuser_sdr(a_vec, H, Gamma, params.sigmaC2, params.PT);
    end
    t_point_multiuser = toc / Npilot;
    fprintf('pointtarget_multiuser_sdr (K=%d):  %.3f s/solve\n', K, t_point_multiuser);

    % --- Representative extended-target multiuser solve (K=6) ---
    tic;
    for i = 1:Npilot
        H = generate_channel(K, params.Nt);
        extended_multiuser_sdr(H, Gamma, params.sigmaC2, params.PT, params.Nt);
    end
    t_ext_multiuser = toc / Npilot;
    fprintf('extended_multiuser_sdr (K=%d):     %.3f s/solve\n', K, t_ext_multiuser);

    % --- Representative Design 1 / Design 2 solves ---
    tic;
    for i = 1:Npilot
        H = generate_channel(K, params.Nt);
        design1_sdr(H, Gamma, params.sigmaC2, params.PT, params.theta_true_rad, ...
            params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing);
    end
    t_design1 = toc / Npilot;
    fprintf('design1_sdr (K=%d):                %.3f s/solve\n', K, t_design1);

    tic;
    R2c = [];
    for i = 1:Npilot
        H = generate_channel(K, params.Nt);
        [~, R2c] = design2_sdr(H, Gamma, params.sigmaC2, params.PT, params.theta_true_rad, ...
            params.mainlobe_width_rad, params.angle_grid_rad, params.d_spacing, R2c); %#ok<NASGU>
    end
    t_design2 = toc / Npilot;
    fprintf('design2_sdr (K=%d, Stage1 cached after 1st): %.3f s/solve (amortized)\n\n', K, t_design2);

    % --- Extrapolate per figure using Phase 6/7's actual sweep counts ---
    Ntrials = params.Ntrials;
    t_avg_point = mean([t_point_multiuser, t_design1, t_design2]);
    t_avg_ext   = mean([t_ext_multiuser,  t_design1, t_design2]);

    fig_estimates = struct( ...
        'fig2', 11*Ntrials*2*mean([t_point_multiuser, t_ext_multiuser]), ...  % 11 Gamma points x 2 (point+ext CVX check)
        'fig3', 1*Ntrials*3*t_avg_point, ...
        'fig4', 6*Ntrials*3*t_avg_point, ...
        'fig5', (8*Ntrials*3*t_avg_point) * 2, ...   % two K values, roughly similar cost order
        'fig6', (9*Ntrials*3*t_avg_ext) * 2, ...
        'fig7', (12*Ntrials*3*t_avg_ext) * 2);

    fnames = fieldnames(fig_estimates);
    total_sec = 0;
    fprintf('%-8s %12s\n', 'Figure', 'Est. time');
    for i = 1:numel(fnames)
        sec = fig_estimates.(fnames{i});
        total_sec = total_sec + sec;
        fprintf('%-8s %10.1f min\n', fnames{i}, sec/60);
    end
    fprintf('--------------------------------\n');
    fprintf('%-8s %10.1f min (%.1f hours)\n', 'TOTAL', total_sec/60, total_sec/3600);
    fprintf('\nNOTE: this is a ROUGH extrapolation from %d-trial pilots at ONE representative\n', Npilot);
    fprintf('(K,Gamma) operating point per method -- actual per-sweep-point cost varies with\n');
    fprintf('problem size (K, Nt+K) and solver behavior near feasibility boundaries. Treat this\n');
    fprintf('as an order-of-magnitude planning number, not a guarantee.\n');
end
