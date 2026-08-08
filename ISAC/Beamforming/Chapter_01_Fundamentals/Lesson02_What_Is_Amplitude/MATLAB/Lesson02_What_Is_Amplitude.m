%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 02 - What Is Amplitude?
%
% File    : Lesson02_What_Is_Amplitude.m
%
% Description:
% Demonstrates how the amplitude affects a sinusoidal waveform while
% keeping the frequency and phase unchanged.
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Common Functions to MATLAB Path
projectRoot = fileparts( ...
              fileparts( ...
              fileparts( ...
              fileparts(mfilename('fullpath')))));

addpath(fullfile(projectRoot,'Common'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Project Structure
%
% Main Script:
%   Lesson02_What_Is_Amplitude.m
%
% MATLAB Function:
%   generateSineWave.m
%
% The Main Script controls the simulation workflow.
% The function generates the sinusoidal signal.

%% Initialization

clear;
clc;
close all;

%% Simulation Parameters

% Signal amplitudes
amplitudes = [0.5 1 2];

% Signal frequency (Hz)
frequency = 5;

% Initial phase (rad)
phase = 0;

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
for k = 1:length(amplitudes)

    signal = generateSineWave( ...
        amplitudes(k), ...
        frequency, ...
        phase, ...
        time);

    plot( ...
        time, ...
        signal, ...
        'LineWidth',2);

end

%% Figure Formatting

title('Effect of Amplitude on a Sinusoidal Wave');

xlabel('Time (s)');

ylabel('Amplitude');

legend( ...
    'A = 0.5', ...
    'A = 1.0', ...
    'A = 2.0', ...
    'Location','best');

set(gca,'FontSize',12);

%% Export Figure

% Uncomment to export the figure
% exportgraphics(gcf,...
%     fullfile('..','Figures','Fig02_Amplitude_Comparison.png'),...
%     'Resolution',300);

% Compatible with older MATLAB versions
%
 saveas(gcf,...
     fullfile('..','Figures','Fig02_Amplitude_Comparison.png'));

%% End of Lesson
%
% Next Lesson:
% Lesson 03 - What Is Frequency?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%