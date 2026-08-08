%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 05 - What Is Initial Phase?
%
% File    : Lesson05_What_Is_Initial_Phase.m
%
% Description:
% Demonstrates how the initial phase affects a sinusoidal waveform while
% keeping amplitude and frequency unchanged.
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Common Functions to MATLAB Path

projectRoot = fileparts( ...
              fileparts( ...
              fileparts( ...
              fileparts(mfilename('fullpath')))));

addpath(genpath(fullfile(projectRoot,'Common')));

%% Initialization

clear;
clc;
close all;

%% Simulation Parameters

% Signal amplitude
amplitude = 1;

% Signal frequency (Hz)
frequency = 5;

% Initial phases (degrees)
phaseDegrees = [0 45 90];

% Convert phase to radians
phaseRadians = deg2rad(phaseDegrees);

% Sampling frequency (Hz)
samplingFrequency = 1000;

% Simulation duration (s)
simulationDuration = 1;

%% Generate Time Vector

time = 0:1/samplingFrequency:simulationDuration;

%% Create Figure

figure;
hold on;
grid on;
box on;

%% Generate and Plot Signals

for k = 1:length(phaseRadians)

    signal = generateSineWave( ...
        amplitude,...
        frequency,...
        phaseRadians(k),...
        time);

    plot( ...
        time,...
        signal,...
        'LineWidth',2);

end

%% Figure Formatting

title('Effect of Initial Phase on a Sinusoidal Wave');

xlabel('Time (s)');

ylabel('Amplitude');

legend( ...
    '\phi = 0°',...
    '\phi = 45°',...
    '\phi = 90°',...
    'Location','best');

set(gca,'FontSize',12);

axis tight;

%% Export Figure

% Uncomment to export the figure
%
 exportgraphics(gcf,...
     fullfile('..','Figures','Fig05_Initial_Phase_Comparison.png'),...
     'Resolution',300);

% Compatible with older MATLAB versions
%
% saveas(gcf,...
%     fullfile('..','Figures','Fig05_Initial_Phase_Comparison.png'));

%% End of Lesson
%
% Next Lesson:
% Lesson 06 - What Is Time Delay?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%