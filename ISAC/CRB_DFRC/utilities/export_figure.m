function export_figure(fig_handle, results_dir, base_name)
%EXPORT_FIGURE Export a figure as both a high-res PNG and a vector PDF.
%
%   EXPORT_FIGURE(fig_handle, results_dir, base_name)
%
%   Writes:
%       results_dir/base_name.png  (300 DPI raster, for quick viewing/
%                                    embedding in documents)
%       results_dir/base_name.pdf  (vector, for publication-quality
%                                    inclusion in a report/paper)
%
%   Uses exportgraphics (MATLAB R2020a+) in preference to the legacy
%   saveas/print commands, since exportgraphics respects the actual
%   rendered axes tightly (no excess whitespace) and supports a
%   Resolution option directly.
%
%   Inputs:
%       fig_handle  : handle returned by figure()
%       results_dir : output directory (created if it doesn't exist)
%       base_name   : file name WITHOUT extension, e.g. 'fig5'
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end

    png_path = fullfile(results_dir, [base_name '.png']);
    pdf_path = fullfile(results_dir, [base_name '.pdf']);

    if exist('exportgraphics', 'file')
        exportgraphics(fig_handle, png_path, 'Resolution', 300);
        exportgraphics(fig_handle, pdf_path, 'ContentType', 'vector');
    else
        % Fallback for MATLAB versions predating exportgraphics (<R2020a)
        warning('export_figure:noExportgraphics', ...
            'exportgraphics not available; falling back to saveas/print (lower quality, more whitespace).');
        saveas(fig_handle, png_path);
        print(fig_handle, pdf_path, '-dpdf', '-bestfit');
    end
end
