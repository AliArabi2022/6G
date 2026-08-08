function dB = to_dB_safe(x)
%TO_DB_SAFE  10*log10(x), but NEVER returns a complex number.
%
% PURPOSE: trace(CRBM) is mathematically guaranteed >= 0 (it's the trace
% of a principal submatrix of F^{-1}, and F is PSD, so F^{-1} is PSD, and
% every principal submatrix of a PSD matrix is PSD). In floating-point
% arithmetic, however, a near-singular/ill-conditioned random array
% geometry can produce a value that is numerically Inf, NaN, or a tiny
% NEGATIVE number (cancellation error) despite the mathematical
% guarantee. 10*log10() of a negative number returns a FINITE COMPLEX
% number in MATLAB (not an error, not caught by isfinite()!), which then
% silently corrupts any downstream code that assumes real data (sorting,
% percentile computation, boxplot whiskers, comparisons) -- this is
% exactly what caused the "Arrays have incompatible sizes" crash in
% simple_boxplot.m: a complex value survived an isfinite() filter,
% desynchronized array sizes a few lines later.
%
% FIX: convert to dB only where x is a genuine positive finite real
% number; everywhere else, return NaN (a real, well-behaved "missing
% value" marker that every downstream function -- isfinite, sort,
% boxplot, scatter -- already knows how to skip).
%
% INPUT
%   x  - real array (any size), typically a trace(CRBM) value or array
%        of such values. Must already be real (this function does NOT
%        silently drop an imaginary part -- if x itself is complex, that
%        is a bug further upstream and this function will flag it via
%        the ~isreal check below rather than mask it).
%
% OUTPUT
%   dB - same size as x; 10*log10(x) where x is real, finite, and > 0;
%        NaN elsewhere.
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    if ~isreal(x)
        warning('to_dB_safe:complexInput', ...
            ['Input to to_dB_safe was already complex -- this means a complex \n' ...
             'value was produced BEFORE this function was called (upstream bug). \n' ...
             'Treating those entries as invalid (NaN).']);
        x(imag(x) ~= 0) = NaN;
        x = real(x);
    end

    good = isfinite(x) & (x > 0);
    dB = nan(size(x));
    dB(good) = 10*log10(x(good));
end
