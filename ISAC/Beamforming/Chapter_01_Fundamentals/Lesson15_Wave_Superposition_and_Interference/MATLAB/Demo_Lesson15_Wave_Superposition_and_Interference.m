%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 Fundamentals of Waves
%
% Lesson 15
%
% File:
% Demo_Lesson15_Wave_Superposition_and_Interference.m
%
% Description:
% Educational demonstration for Lesson 15.
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

initializeProjectPaths();

disp("==================================================")
disp("Lesson 15")
disp("Wave Superposition")
disp("==================================================")
disp(" ")

%% Experiment 1

disp("Experiment 1")
disp("Equal Amplitude Waves")
disp(" ")
disp("Observe that the two waves overlap.")
disp("During the overlap, their amplitudes are added.")
disp("Press ENTER to start.")
pause

experiment.name = "Experiment 1 : Equal Amplitudes";

experiment.wave1 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Right");

experiment.wave2 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Left");

runExperiment(experiment);

disp("Did the waves disappear?")
disp("No.")
disp("They continued propagating.")
disp(" ")
disp("Press ENTER to continue.")
pause

%% Experiment 2

disp("Experiment 2")
disp("Different Amplitudes")
disp(" ")
disp("Only the amplitudes changed.")
disp("The superposition principle is still valid.")
disp("Press ENTER to start.")
pause

experiment.name = "Experiment 2 : Different Amplitudes";

experiment.wave1 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Right");

experiment.wave2 = createWave( ...
    "Amplitude",0.5,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Left");

runExperiment(experiment);

disp("Press ENTER to continue.")
pause

%% Experiment 3

disp("Experiment 3")
disp("Different Frequencies")
disp(" ")
disp("Notice that different frequencies")
disp("also satisfy the superposition principle.")
disp("Press ENTER to start.")
pause

experiment.name = "Experiment 3 : Different Frequencies";

experiment.wave1 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Right");

experiment.wave2 = createWave( ...
    "Amplitude",1,...
    "Frequency",1.5,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Left");

runExperiment(experiment);

disp("Press ENTER to continue.")
pause

%% Experiment 4

disp("Experiment 4")
disp("Different Phases")
disp(" ")
disp("Changing the phase changes")
disp("the resultant waveform.")
disp("Press ENTER to start.")
pause

experiment.name = "Experiment 4 : Different Phases";

experiment.wave1 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Right");

experiment.wave2 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",pi/3,...
    "Velocity",1,...
    "Direction","Left");

runExperiment(experiment);

disp("Press ENTER to continue.")
pause

%% Experiment 5

disp("Experiment 5")
disp("Same Direction")
disp(" ")
disp("Superposition does not depend")
disp("on propagation direction.")
disp("Press ENTER to start.")
pause

experiment.name = "Experiment 5 : Same Direction";

experiment.wave1 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Right");

experiment.wave2 = createWave( ...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",pi/4,...
    "Velocity",1,...
    "Direction","Right");

runExperiment(experiment);

disp("Press ENTER to continue.")
pause

%% Experiment 6

disp("Experiment 6")
disp("Gaussian Wave Packets")
disp(" ")
disp("Observe carefully.")
disp("The wave packets overlap")
disp("and then continue without")
disp("changing their identity.")
disp("Press ENTER to start.")
pause

experiment.name = "Experiment 6 : Gaussian Wave Packets";

experiment.simulationTime = 16;

experiment.wave1 = createWave( ...
    "Type","Gaussian",...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Right");

experiment.wave2 = createWave( ...
    "Type","Gaussian",...
    "Amplitude",1,...
    "Frequency",1,...
    "Phase",0,...
    "Velocity",1,...
    "Direction","Left");

runExperiment(experiment);

%% Lesson Summary

disp(" ")
disp("==================================================")
disp("Lesson Summary")
disp("==================================================")
disp(" ")

disp("1. Waves can occupy the same space.")
disp("2. Their amplitudes add point by point.")
disp("3. After the overlap, each wave continues")
disp("   with its original shape and direction.")
disp("4. This is the Principle of Superposition.")

disp(" ")

displaySummary();