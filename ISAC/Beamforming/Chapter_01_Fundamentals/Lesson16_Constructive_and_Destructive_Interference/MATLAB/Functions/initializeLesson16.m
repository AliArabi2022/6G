function scene = initializeLesson16()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% initializeLesson16
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Initializes the lesson configuration and creates the scene structure
% used throughout all experiments.
%
% Inputs:
%   None
%
% Outputs:
%   scene    Structure containing lesson configuration.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Lesson Information

scene.lessonNumber = 16;
scene.lessonTitle  = "Constructive and Destructive Interference";

%% Animation Settings

scene.frameRate = 30;                 % Frames per second
scene.timeStep  = 1 / scene.frameRate;

%% Visualization Settings

scene.figurePosition = [100 100 1400 800];

scene.fontName  = "Arial";
scene.fontSize  = 13;
scene.titleSize = 16;
scene.lineWidth = 2.0;

%% Axes Limits

scene.xLimits = [-10 10];
scene.yLimits = [-2.5 2.5];

%% Grid

scene.grid = "on";

%% Animation Control

scene.pauseKey = "space";

%% Educational Text

scene.pauseMessage = ...
    "Press SPACE to Pause / Resume";

%% Default Colors

scene.colors.wave1 = [0.0000 0.4470 0.7410];
scene.colors.wave2 = [0.8500 0.3250 0.0980];
scene.colors.result = [0.4660 0.6740 0.1880];

%% Default Simulation Parameters

scene.defaultAmplitude = 1.0;
scene.defaultFrequency = 1.0;
scene.defaultVelocity  = 1.0;
scene.defaultPhase     = 0.0;

%% Interactive Demo Defaults

scene.slider.minimum = 0;
scene.slider.maximum = 360;
scene.slider.initial = 0;

scene.autoSweep.enabled = true;
scene.autoSweep.speed   = 1.0;    % degrees per frame

%% Flags

scene.enableAmplitudeGraph = true;
scene.enableInterferenceLabel = true;
scene.enablePathDifference = true;
scene.enableSpatialPattern = true;

end