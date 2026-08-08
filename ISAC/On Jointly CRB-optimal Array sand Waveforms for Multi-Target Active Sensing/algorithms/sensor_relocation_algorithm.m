function [Dt, Dr, idxT, idxR, history] = sensor_relocation_algorithm(Ct, Cr, Nt, Nr, ...
    Omega, gamma, sigma2, numDim, fType, opts)
%SENSOR_RELOCATION_ALGORITHM  Algorithm 1 (paper, p.4): iterative
%   coordinate-descent-style sensor relocation minimizing g(Dt,Dr).
%
% ALGORITHM 1 (verbatim structure):
%   1: Initialize Dt in Ct, Dr in Cr
%   2: while Dt and Dr change do
%   3:   for n = 1:Nt                      % Update Tx array
%   4:     Dt_tilde = Dt \ d_n
%   5:     d_opt = argmin_{d in C\Dt_tilde} g(d U Dt_tilde, Dr)
%   6:     Dt = d_opt U Dt_tilde
%   7:   end for
%   8:   for n = 1:Nr                      % Update Rx array
%   9:     Dr_tilde = Dr \ d_n
%  10:     d_opt = argmin_{d in C\Dr_tilde} g(Dt, d U Dr_tilde)
%  11:     Dr = d_opt U Dr_tilde
%  12:   end for
%  13: end while
%
% Converges when a full Tx+Rx sweep produces no change (no relocation
% strictly decreases g, matching the paper's local-optimality guarantee:
% "no single sensor can be reassigned without increasing the objective").
%
% INPUTS
%   Ct, Cr    - (Ncand_t x 3), (Ncand_r x 3) candidate position sets
%   Nt, Nr    - number of Tx/Rx sensors to place
%   Omega     - (3 x K) target angular frequencies
%   gamma     - (K x 1) reflection coefficients
%   sigma2    - noise variance
%   numDim    - 1/2/3 (Remark 1)
%   fType     - objective type, default 'trace'
%   opts      - struct with optional fields:
%                 .maxOuterIters (default 50)
%                 .rng_seed      (default [] = no reseed)
%                 .verbose       (default true)
%
% OUTPUTS
%   Dt, Dr        - final (Nt x 3), (Nr x 3) sensor positions
%   idxT, idxR    - indices into Ct, Cr of the selected sensors
%   history       - struct array logging g after each Tx/Rx sub-sweep
%
% ASSUMPTION (Phase 11): the paper does not state (i) the initialization
% distribution (we use uniform-random sampling without replacement from
% Ct/Cr, matching "Starting from an initial (random) configuration",
% Sec. III-B), (ii) a maximum outer-iteration cap for safety against
% pathological non-termination (we cap at 50 outer while-loop iterations
% and warn if reached; in practice this greedy coordinate descent on a
% finite candidate set converges in a handful of iterations), or (iii)
% tie-breaking when multiple candidates achieve the same minimal g (we
% keep the first one found, i.e., MATLAB's default min() behavior).
%
% Author: (auto-generated MATLAB reproduction)
% Date: 2026-07-07

    if nargin < 9 || isempty(fType); fType = 'trace'; end
    if nargin < 10; opts = struct(); end
    if ~isfield(opts, 'maxOuterIters'); opts.maxOuterIters = 50; end
    if ~isfield(opts, 'verbose'); opts.verbose = true; end
    if isfield(opts, 'rng_seed') && ~isempty(opts.rng_seed)
        rng(opts.rng_seed);
    end

    NcandT = size(Ct, 1);
    NcandR = size(Cr, 1);
    if Nt > NcandT || Nr > NcandR
        error('sensor_relocation_algorithm:tooFewCandidates', ...
            'Nt/Nr exceeds the number of candidate positions.');
    end

    % --- Line 1: random initialization without replacement ---
    permT = randperm(NcandT); idxT = sort(permT(1:Nt));
    permR = randperm(NcandR); idxR = sort(permR(1:Nr));
    Dt = Ct(idxT, :);
    Dr = Cr(idxR, :);

    history = struct('outerIter', {}, 'phase', {}, 'g', {});
    changed = true;
    outerIter = 0;

    gCurrent = objective_g(Dt, Dr, Omega, gamma, sigma2, numDim, fType);

    while changed && outerIter < opts.maxOuterIters
        outerIter = outerIter + 1;
        changed = false;

        % ---- Line 3-7: update Tx array, one sensor at a time ----
        for n = 1:Nt
            freeMaskT = true(NcandT, 1); freeMaskT(idxT) = false;
            freeMaskT(idxT(n)) = true; % candidate n's own slot is also eligible
            candIdx = find(freeMaskT);

            bestG = inf; bestCand = idxT(n);
            for c = candIdx'
                trialIdxT = idxT; trialIdxT(n) = c;
                trialDt = Ct(trialIdxT, :);
                g_try = objective_g(trialDt, Dr, Omega, gamma, sigma2, numDim, fType);
                if g_try < bestG
                    bestG = g_try; bestCand = c;
                end
            end

            if bestCand ~= idxT(n) && bestG < gCurrent - 1e-12
                idxT(n) = bestCand;
                Dt = Ct(idxT, :);
                gCurrent = bestG;
                changed = true;
            end
        end
        history(end+1) = struct('outerIter', outerIter, 'phase', 'Tx', 'g', gCurrent); %#ok<AGROW>
        if opts.verbose
            fprintf('[Algorithm 1] outer=%d  Tx sweep done, g=%.6f\n', outerIter, gCurrent);
        end

        % ---- Line 8-12: update Rx array, one sensor at a time ----
        for n = 1:Nr
            freeMaskR = true(NcandR, 1); freeMaskR(idxR) = false;
            freeMaskR(idxR(n)) = true;
            candIdx = find(freeMaskR);

            bestG = inf; bestCand = idxR(n);
            for c = candIdx'
                trialIdxR = idxR; trialIdxR(n) = c;
                trialDr = Cr(trialIdxR, :);
                g_try = objective_g(Dt, trialDr, Omega, gamma, sigma2, numDim, fType);
                if g_try < bestG
                    bestG = g_try; bestCand = c;
                end
            end

            if bestCand ~= idxR(n) && bestG < gCurrent - 1e-12
                idxR(n) = bestCand;
                Dr = Cr(idxR, :);
                gCurrent = bestG;
                changed = true;
            end
        end
        history(end+1) = struct('outerIter', outerIter, 'phase', 'Rx', 'g', gCurrent); %#ok<AGROW>
        if opts.verbose
            fprintf('[Algorithm 1] outer=%d  Rx sweep done, g=%.6f\n', outerIter, gCurrent);
        end
    end

    if outerIter >= opts.maxOuterIters && changed
        warning('sensor_relocation_algorithm:maxIter', ...
            'Reached maxOuterIters (%d) without full convergence.', opts.maxOuterIters);
    end
end
