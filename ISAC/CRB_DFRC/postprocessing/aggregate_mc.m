function [sweep_mean, sweep_std, feasible_fraction] = aggregate_mc(trial_results, feasibility_mask)
%AGGREGATE_MC Average per-trial metrics over Monte Carlo trials, per method.
%
%   [sweep_mean, sweep_std, feasible_fraction] = AGGREGATE_MC(trial_results, feasibility_mask)
%
%   Averages trial_results over trials, EXCLUDING infeasible trials,
%   with feasibility tracked INDEPENDENTLY per method (Phase 5 Module
%   17 pitfall): the proposed method, Design 1, and Design 2 can each
%   be infeasible on a given random channel/SINR combination
%   independently of one another. Averaging every method over its OWN
%   valid-trial subset (rather than a single shared mask) avoids
%   silently biasing comparisons when feasible-trial counts differ.
%
%   Inputs:
%       trial_results     : Ntrials x Nmetrics x Nmethods
%       feasibility_mask  : Ntrials x Nmethods (logical; true = feasible)
%
%   Outputs:
%       sweep_mean         : Nmetrics x Nmethods, mean over each
%                             method's own feasible trials
%       sweep_std          : Nmetrics x Nmethods, std over same
%       feasible_fraction  : 1 x Nmethods, fraction of trials that
%                             were feasible for each method
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    [Ntrials, Nmetrics, Nmethods] = size(trial_results);
    validateattributes(feasibility_mask, {'logical','numeric'}, {'size', [Ntrials Nmethods]});

    sweep_mean = NaN(Nmetrics, Nmethods);
    sweep_std  = NaN(Nmetrics, Nmethods);
    feasible_fraction = zeros(1, Nmethods);

    for m = 1:Nmethods
        valid_idx = logical(feasibility_mask(:,m));
        feasible_fraction(m) = sum(valid_idx) / Ntrials;

        if any(valid_idx)
            data_m = squeeze(trial_results(valid_idx, :, m));   % Nvalid x Nmetrics
            if size(data_m,1) == 1
                data_m = reshape(data_m, 1, Nmetrics);
            end
            sweep_mean(:,m) = mean(data_m, 1).';
            sweep_std(:,m)  = std(data_m, 0, 1).';
        else
            warning('aggregate_mc:noFeasibleTrials', ...
                'Method %d had zero feasible trials at this sweep point; returning NaN.', m);
        end
    end
end
