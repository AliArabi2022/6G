function rdir = results_dir()
%RESULTS_DIR Absolute path to the project's results/ directory.
%
%   rdir = RESULTS_DIR() returns fullfile(project_root, 'results'),
%   where project_root is resolved from THIS FILE's own location
%   (utilities/results_dir.m -> project_root/utilities -> project_root),
%   NOT from MATLAB's current working directory.
%
%   BUG THIS FIXES (found in Phase 12 debugging sweep): every
%   generate_figN.m previously called mkdir('results') /
%   fullfile('results',...) using a path RELATIVE to whatever
%   directory MATLAB's pwd happened to be when the function was
%   called. main.m, meanwhile, checks for checkpoint files using an
%   ABSOLUTE path derived from its own mfilename location. If a user
%   runs main() (or any generate_figN() directly) from a working
%   directory other than the project root -- entirely possible once
%   the project is on the MATLAB path via addpath -- the two path
%   resolutions silently diverge: checkpointing breaks (main.m looks
%   in the wrong place and reruns already-completed figures), and a
%   stray results/ folder gets created wherever pwd happened to be.
%
%   Using this single function everywhere (main.m and all 6
%   generate_figN.m) guarantees both always agree on the same
%   absolute location, regardless of the caller's current directory.
%
%   Outputs:
%       rdir : absolute path string to <project_root>/results
%              (created if it does not already exist)
%
%   Author: Ali Arabi Bavil
%   Date:   2026-07-03

    this_file_dir = fileparts(mfilename('fullpath'));   % .../CRB_DFRC_Reproduction/utilities
    project_root = fileparts(this_file_dir);             % .../CRB_DFRC_Reproduction
    rdir = fullfile(project_root, 'results');

    if ~exist(rdir, 'dir')
        mkdir(rdir);
    end
end