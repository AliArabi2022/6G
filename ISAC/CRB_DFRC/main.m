%MAIN Top-level orchestrator for the CRB-Optimal DFRC Beamforming reproduction.
%
%   Reproduces Figures 2-7 of:
%       F. Liu, Y.-F. Liu, A. Li, C. Masouros, Y. C. Eldar,
%       "Cramer-Rao Bound Optimization for Joint Radar-Communication
%       Design," arXiv:2101.12530v1.
%
%   Requires: MATLAB, CVX (with SDPT3 or SeDuMi backend) on the path.
%
%   Execution order (Phase 6 Sec.6.4): Fig.2 runs first as a fast-fail
%   self-consistency gate (closed-form vs. CVX for the SAME proposed
%   method, no benchmarks involved) -- if this fails, Figs. 3-7's
%   benchmark comparisons are not meaningful.
%
%   Checkpointing (Phase 6 Sec.6.5): each figure's underlying data is
%   saved to results/figN_data.mat; if that file already exists, the
%   figure is SKIPPED (delete the .mat to force a rerun). A failure in
%   one figure does not abort the run.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

clear; close all; clc;

% --- Reproducibility (Assumption A8) ---
rng(42);

% --- Path setup ---
proj_root = fileparts(mfilename('fullpath'));
addpath(genpath(proj_root));

% --- CVX availability check (fail early with a clear message) ---
if ~exist('cvx_begin', 'file')
    error('main:cvxNotFound', ...
        ['CVX not found on the MATLAB path. This reproduction requires ' ...
         'CVX (with SDPT3 or SeDuMi) for all SDR-based modules ' ...
         '(Algorithms B/D, Design 1/2 benchmarks). Install CVX and run ' ...
         'cvx_setup, then re-run main.m.']);
end

if ~exist(fullfile(proj_root,'results'), 'dir')
    mkdir(fullfile(proj_root,'results'));
end
results_path = results_dir();   % single source of truth, shared with every generate_figN.m
assert(strcmp(results_path, fullfile(proj_root,'results')), ...
    'main:resultsPathMismatch', 'results_dir() disagrees with proj_root-derived path -- investigate before proceeding.');

% --- Figure list, in
%  the fixed execution order (Phase 6 Sec.6.4) ---
fig_list = {@generate_fig2, @generate_fig3, @generate_fig4, ...
            @generate_fig5, @generate_fig6, @generate_fig7};
fig_names = {'fig2','fig3','fig4','fig5','fig6','fig7'};

summary = struct('name', {}, 'status', {}, 'elapsed_sec', {});

for i = 1:numel(fig_list)
    data_file = fullfile(results_path, [fig_names{i} '_data.mat']);

    if exist(data_file, 'file')
        fprintf('[main] %s already completed (%s exists) -- skipping. Delete the .mat to force a rerun.\n', ...
            fig_names{i}, data_file);
        summary(end+1) = struct('name', fig_names{i}, 'status', 'skipped (cached)', 'elapsed_sec', 0); %#ok<SAGROW>
        continue;
    end

    fprintf('[main] Starting %s ...\n', fig_names{i});
    tic;
    try
        fig_list{i}();
        elapsed = toc;
        fprintf('[main] %s completed in %.1f s.\n', fig_names{i}, elapsed);
        summary(end+1) = struct('name', fig_names{i}, 'status', 'ok', 'elapsed_sec', elapsed); %#ok<SAGROW>
    catch ME
        elapsed = toc;
        warning('main:figureFailed', '[main] %s FAILED after %.1f s: %s\n%s', ...
            fig_names{i}, elapsed, ME.message, getReport(ME, 'basic'));
        summary(end+1) = struct('name', fig_names{i}, 'status', sprintf('FAILED: %s', ME.message), 'elapsed_sec', elapsed); %#ok<SAGROW>
    end

    if exist('cvx_clear', 'file')
        cvx_clear;
    end
end

% --- Final summary ---
fprintf('\n================ RUN SUMMARY ================\n');
for i = 1:numel(summary)
    fprintf('  %-6s : %-30s (%.1f s)\n', summary(i).name, summary(i).status, summary(i).elapsed_sec);
end
fprintf('===============================================\n');
fprintf('Outputs written to: %s\n', results_path);
