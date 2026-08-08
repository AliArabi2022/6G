%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 06 - What Is Time Delay?
%
% File    : Lesson06_What_Is_Time_Delay.m
%
% Description:
% Demonstrates the effect of time delay on a sinusoidal waveform while
% keeping amplitude, frequency, and initial phase unchanged.
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Common Functions to MATLAB Path

projectRoot = fileparts( ...
              fileparts( ...
              fileparts( ...
              fileparts(mfilename('fullpath')))));

addpath(fullfile(projectRoot,'Common'));

%% Initialization

clear;
clc;
close all;

%% Simulation Parameters

% Signal amplitude
amplitude = 1;

% Signal frequency (Hz)
frequency = 5;

% Initial phase (rad)
phase = 0;

% Time delays (s)
timeDelay = [0 0.02 0.04];

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

for k = 1:length(timeDelay)

    delayedTime = time - timeDelay(k);

    signal = generateSineWave( ...
        amplitude,...
        frequency,...
        phase,...
        delayedTime);

    plot( ...
        time,...
        signal,...
        'LineWidth',2);

end

%% Figure Formatting

title('Effect of Time Delay on a Sinusoidal Wave');

xlabel('Time (s)');

ylabel('Amplitude');

legend( ...
    '\tau = 0 ms',...
    '\tau = 20 ms',...
    '\tau = 40 ms',...
    'Location','best');

set(gca,'FontSize',12);

axis tight;

%% Export Figure

% Uncomment to export the figure
%
% exportgraphics(gcf,...
%     fullfile('..','Figures','Fig06_Time_Delay_Comparison.png'),...
%     'Resolution',300);

% Compatible with older MATLAB versions
%
% saveas(gcf,...
%     fullfile('..','Figures','Fig06_Time_Delay_Comparison.png'));

%% End of Lesson
%
% Next Lesson:
% Lesson 07 - Phase Shift vs. Time Delay
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%