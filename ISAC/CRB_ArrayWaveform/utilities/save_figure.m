function save_figure(figHandle, name)
%SAVE_FIGURE  Save a figure to <project_root>/plots/ as both .png and .fig.
%
% PURPOSE: centralizes figure-saving so every main_*.m script writes its
% output figures to the same place automatically, without each script
% needing its own path-building/mkdir boilerplate.
%
% INPUTS
%   figHandle - figure handle (e.g. gcf, or the handle returned by figure())
%   name      - base filename (no extension, no spaces/special chars),
%               e.g. 'fig2a_linear_boxplots'
%
% OUTPUT: none. Writes <project_root>/plots/<name>.png (300 DPI) and
% <project_root>/plots/<name>.fig (re-openable/editable in MATLAB via
% openfig) with the timestamp preserved in the .fig file itself.
%
% NOTE ON project_root: found via this file's own location
% (utilities/save_figure.m -> project_root is one level up), NOT via
% mfilename('fullpath') of the calling script -- this makes the function
% self-contained and correct regardless of which script calls it.
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    thisFileDir = fileparts(mfilename('fullpath')); % .../CRB_ArrayWaveform/utilities
    projectRoot = fileparts(thisFileDir);            % .../CRB_ArrayWaveform
    plotsDir = fullfile(projectRoot, 'plots');
    if ~exist(plotsDir, 'dir')
        mkdir(plotsDir);
    end

    pngPath = fullfile(plotsDir, [name '.png']);
    figPath = fullfile(plotsDir, [name '.fig']);

    try
        exportgraphics(figHandle, pngPath, 'Resolution', 300); % modern, crisp, handles subplots/tiledlayout well
    catch
        % Fallback for older MATLAB versions without exportgraphics
        saveas(figHandle, pngPath);
    end
    savefig(figHandle, figPath);

    fprintf('    Saved plot -> %s (.png, .fig)\n', pngPath);
end
