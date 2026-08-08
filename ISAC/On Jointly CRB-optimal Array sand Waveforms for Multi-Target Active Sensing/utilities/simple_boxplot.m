function simple_boxplot(ax, dataCell, xPositions, boxWidth, faceColor)
%SIMPLE_BOXPLOT  Draw one box-and-whisker at each xPosition, no toolbox.
%
% PURPOSE: MATLAB's built-in boxplot() requires the Statistics and
% Machine Learning Toolbox, which is not guaranteed to be present. This
% draws the same visual (median line, IQR box, 1.5*IQR whiskers, outlier
% points) using only base-MATLAB graphics primitives (patch, line, plot),
% keeping this reproduction toolbox-free except for CVX (which is
% inherently required for the optimal-waveform branch).
%
% INPUTS
%   ax         - axes handle to draw into (use gca if unsure)
%   dataCell   - cell array of numeric vectors, one per box
%   xPositions - x-coordinate for each box (same length as dataCell)
%   boxWidth   - width of each box (default 0.35)
%   faceColor  - RGB triplet or cell array of RGB triplets, one per box
%
% Author: (auto-generated MATLAB reproduction)
% Date: 2026-07-07

    if nargin < 4 || isempty(boxWidth); boxWidth = 0.35; end
    if nargin < 5 || isempty(faceColor); faceColor = [0.30 0.55 0.85]; end

    axes(ax); hold(ax, 'on'); %#ok<LAXES>

    for i = 1:numel(dataCell)
        d = dataCell{i}(:);
        if ~isreal(d)
            warning('simple_boxplot:complexData', ...
                'Box %d contains complex values (upstream should use to_dB_safe to prevent this); dropping them.', i);
            d = d(imag(d) == 0);
            d = real(d);
        end
        d = d(isfinite(d)); % drops NaN AND +-Inf; near-singular random draws can produce
                             % Inf-magnitude trace(CRBM), which otherwise breaks the
                             % percentile/whisker comparisons below (comparisons against
                             % Inf/NaN can select zero elements, making min([])=[] and
                             % crashing the next comparison with a size-mismatch error)
        if isempty(d); continue; end

        if iscell(faceColor)
            fc = faceColor{i};
        else
            fc = faceColor;
        end

        q1 = prctile_local(d, 25);
        q2 = prctile_local(d, 50);
        q3 = prctile_local(d, 75);
        iqr = q3 - q1;
        loWhisker = min(d(d >= q1 - 1.5*iqr));
        hiWhisker = max(d(d <= q3 + 1.5*iqr));
        outliers = d(d < loWhisker | d > hiWhisker);

        x0 = xPositions(i) - boxWidth/2;
        x1 = xPositions(i) + boxWidth/2;

        % Box (IQR)
        patch(ax, [x0 x1 x1 x0], [q1 q1 q3 q3], fc, 'FaceAlpha', 0.5, 'EdgeColor', 'k');
        % Median line
        plot(ax, [x0 x1], [q2 q2], 'k-', 'LineWidth', 1.5);
        % Whiskers
        plot(ax, [xPositions(i) xPositions(i)], [q3 hiWhisker], 'k-');
        plot(ax, [xPositions(i) xPositions(i)], [q1 loWhisker], 'k-');
        plot(ax, [x0+boxWidth*0.25 x1-boxWidth*0.25], [hiWhisker hiWhisker], 'k-');
        plot(ax, [x0+boxWidth*0.25 x1-boxWidth*0.25], [loWhisker loWhisker], 'k-');
        % Outliers
        if ~isempty(outliers)
            plot(ax, xPositions(i)*ones(size(outliers)), outliers, 'r+', 'MarkerSize', 5);
        end
    end
end

function p = prctile_local(d, pct)
%PRCTILE_LOCAL  Linear-interpolation percentile, no toolbox required.
    d = sort(d(:));
    n = numel(d);
    if n == 1; p = d(1); return; end
    pos = (pct/100)*(n-1) + 1;
    lo = floor(pos); hi = ceil(pos);
    frac = pos - lo;
    p = d(lo) + frac*(d(hi)-d(lo));
end
