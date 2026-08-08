function runExperiment(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% runExperiment
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Executes a single experiment.
%
% Inputs:
%   scene       Scene configuration structure.
%   experiment  Experiment structure.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Display Experiment Information

fprintf('\n');
fprintf('=========================================================\n');
fprintf('Experiment %d\n', experiment.id);
fprintf('%s\n', experiment.title);
fprintf('=========================================================\n');

%% Execute Experiment

switch lower(experiment.type)

    case "superposition"

        renderSuperposition(scene, experiment);

    case "phase"

        renderPhaseInterference(scene, experiment);

    case "amplitudegraph"

        renderAmplitudePhase(scene, experiment);

    case "pathdifference"

        renderPathDifference(scene, experiment);

    case "spatialpattern"

        renderSpatialPattern(scene, experiment);

    case "coherence"

        renderCoherence(scene, experiment);

    case "energy"

        renderEnergyRedistribution(scene, experiment);

    otherwise

        error("Unknown experiment type.");

end

%% Pause Before Next Experiment

if experiment.id ~= 9

    fprintf('\nPress any key to continue...\n');
    pause;

end

end