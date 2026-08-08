%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 13 - Why Aren't All Antenna Outputs the Same?
%
% Description:
% This lesson explains why different antennas observe different
% versions of the same transmitted signal.
%
% Version : 2.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Common Folder

projectRoot = fileparts( ...
              fileparts( ...
              fileparts( ...
              fileparts(mfilename('fullpath')))));

addpath(genpath(fullfile(projectRoot,'Common')));
%% Initialization

clear
clc
close all

%% Lesson Title

disp("====================================================")
disp("Lesson 13")
disp("Why Aren't All Antenna Outputs the Same?")
disp("====================================================")

pause(2)

%% Question

disp("Question")
disp("--------")
disp("A transmitter sends ONE signal.")
disp(" ")
disp("Why don't all antennas")
disp("receive identical outputs?")

pause(4)

%% Simulation Parameters

numberOfAntennas = 8;

antennaSpacing = 0.5;

propagationSpeed = 3e8;

frequency = 1e9;

arrivalAngle = 35;

%% STEP 1

disp(" ")
disp("----------------------------------------------")
disp("STEP 1")
disp("Create a Uniform Linear Array")
disp("----------------------------------------------")

pause(2)

antennaPositions = createLinearArray( ...
                    numberOfAntennas,...
                    antennaSpacing);

pause(3)

%% STEP 2

disp(" ")
disp("----------------------------------------------")
disp("STEP 2")
disp("Observe an Incoming Plane Wave")
disp("----------------------------------------------")

pause(2)

animateIncomingWave( ...
    antennaPositions,...
    arrivalAngle);

pause(3)

%% STEP 3

disp(" ")
disp("----------------------------------------------")
disp("STEP 3")
disp("Calculate Arrival Time")
disp("----------------------------------------------")

pause(2)

arrivalTimes = calculateArrivalTimes( ...
                antennaPositions,...
                arrivalAngle,...
                propagationSpeed);

pause(3)

%% STEP 4

disp(" ")
disp("----------------------------------------------")
disp("STEP 4")
disp("Generate Received Signals")
disp("----------------------------------------------")

pause(2)

[time,receivedSignals] = ...
    generateReceivedSignals( ...
    arrivalTimes,...
    frequency);

pause(3)

%% STEP 5

disp(" ")
disp("----------------------------------------------")
disp("STEP 5")
disp("Compare Antenna Outputs")
disp("----------------------------------------------")

pause(2)

plotReceivedSignals( ...
    time,...
    receivedSignals);

pause(4)

%% STEP 6

disp(" ")
disp("----------------------------------------------")
disp("STEP 6")
disp("Calculate Phase Difference")
disp("----------------------------------------------")

pause(2)

phaseDifferences = ...
    calculatePhaseDifferences( ...
    arrivalTimes,...
    frequency);

pause(2)

%% STEP 7

disp(" ")
disp("----------------------------------------------")
disp("STEP 7")
disp("Visualize the Phases")
disp("----------------------------------------------")

pause(2)

animatePhasorDiagram( ...
    phaseDifferences,...
    frequency);

pause(2)

%% Final Message

disp(" ")
disp("====================================================")
disp("Lesson Summary")
disp("====================================================")

disp(" ")

disp("One transmitted signal")

pause(1)

disp("        ↓")

pause(1)

disp("Different propagation distances")

pause(1)

disp("        ↓")

pause(1)

disp("Different arrival times")

pause(1)

disp("        ↓")

pause(1)

disp("Different time delays")

pause(1)

disp("        ↓")

pause(1)

disp("Different phase shifts")

pause(1)

disp("        ↓")

pause(1)

disp("Different antenna outputs")

pause(1)

disp("        ↓")

pause(1)

disp("Beamforming")

disp(" ")

disp("Congratulations!")
disp("You have just discovered")
disp("the fundamental principle")
disp("behind every beamforming algorithm.")