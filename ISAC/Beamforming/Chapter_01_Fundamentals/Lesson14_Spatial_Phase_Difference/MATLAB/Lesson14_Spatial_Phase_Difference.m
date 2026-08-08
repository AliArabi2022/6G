%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
% Lesson  : 14 - Spatial Phase Difference
%
% Main Simulation
%
% Version : 2.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

initializeProjectPaths();

%% Parameters

c = 3e8;
f = 1e9;

lambda = c/f;

d = lambda/2;

arrivalAngle = 40;

%% Create Array

antennaPosition = createTwoElementArray(d);

%% Scene 1
showPlaneWaveOnly(arrivalAngle);

%% Scene 2
showPropagationDirection(arrivalAngle);

%% Scene 3
showArrayWithWave(arrivalAngle,antennaPosition);

%% Scene 4

[pathDifference,timeDelay] = ...
    calculateSpatialDelay(...
    d,...
    arrivalAngle,...
    c);

phaseDifference = ...
    calculateSpatialPhaseDifference(...
    pathDifference,...
    lambda);

%% Scene 5

animateWaveArrival(...
    antennaPosition,...
    arrivalAngle,...
    pathDifference,...
    timeDelay,...
    phaseDifference);

%% Scene 6

plotReceivedSinusoids(...
    f,...
    timeDelay);

%% Scene 7

plotPhasorDiagram(...
    phaseDifference);

%% Results

displaySimulationResults(...
    arrivalAngle,...
    d,...
    pathDifference,...
    timeDelay,...
    phaseDifference);