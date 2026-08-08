%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Main Simulation
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% This script orchestrates all experiments for Lesson 16.
% It initializes the project, creates the experiments,
% executes them sequentially, and displays the final summary.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization

clear;
close all;
clc;

%% Initialize Project Paths

initializeProjectPaths();

%% Initialize Lesson

scene = initializeLesson16();

%% Create Experiments

experiments = createExperiments();

numberOfExperiments = numel(experiments);

%% Execute Experiments

for experimentIndex = 1:numberOfExperiments

    experiment = experiments(experimentIndex);

    fprintf('\n');
    fprintf('=====================================================\n');
    fprintf('Experiment %d of %d\n', ...
        experimentIndex, numberOfExperiments);
    fprintf('%s\n', experiment.title);
    fprintf('=====================================================\n\n');

    runExperiment(scene, experiment);

end

%% Display Summary

displaySummary();
