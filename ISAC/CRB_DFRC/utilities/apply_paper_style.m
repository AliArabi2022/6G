function apply_paper_style(fig_handle)
%APPLY_PAPER_STYLE Apply a consistent publication-style look to a figure.
%
%   APPLY_PAPER_STYLE(fig_handle) applies, to every axes in fig_handle:
%     - box on (closed axes border, matching IEEE-style plots)
%     - grid on with light gridlines
%     - consistent font size (11pt) and font name
%     - consistent line/marker sizing already set by the caller's plot()
%       calls is left untouched; this function only touches
%       axes-level cosmetic properties, not data
%
%   This is called once per figure, at the end of each generate_figN.m,
%   right before export_figure.m -- factored out so all 6 figures share
%   IDENTICAL cosmetic conventions rather than each re-specifying its
%   own font/box/grid settings (Phase 10 requirement: match the paper's
%   look as closely as MATLAB's default renderer allows, consistently).
%
%   Inputs:
%       fig_handle : handle returned by figure()
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    all_axes = findall(fig_handle, 'Type', 'axes');
    for i = 1:numel(all_axes)
        ax = all_axes(i);
        box(ax, 'on');
        grid(ax, 'on');
        ax.GridAlpha = 0.25;
        ax.FontName = 'Helvetica';
        ax.FontSize = 11;
        ax.LineWidth = 0.75;   % axes border weight
    end

    set(fig_handle, 'Color', 'w');   % white background (not MATLAB's gray default in some versions)
end
