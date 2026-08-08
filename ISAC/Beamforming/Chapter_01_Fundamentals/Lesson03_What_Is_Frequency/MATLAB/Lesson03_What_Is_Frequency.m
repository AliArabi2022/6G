%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 03 - What Is Frequency?
%
% File    : Lesson03_What_Is_Frequency.m
%
% Description:
% Demonstrates how frequency affects a sinusoidal waveform while keeping
% amplitude and phase unchanged.
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add Common Functions to MATLAB Path

projectRoot = fileparts( ...
              fileparts( ...
              fileparts( ...
              fileparts(mfilename('fullpath')))));

addpath(genpath(fullfile(projectRoot,'Common')));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization

clear;
clc;
close all;

%% Simulation Parameters

% Signal amplitudes
amplitude = 1;

% Signal frequencies (Hz)
frequencies = [2 5 10];

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
for k = 1:length(frequencies)

    signal = generateSineWave( ...
        amplitude,...
        frequencies(k),...
        phase,...
        time);

    plot( ...
        time,...
        signal,...
        'LineWidth',2);

end

%% Figure Formatting

title('Effect of Frequency on a Sinusoidal Wave');

xlabel('Time (s)');

ylabel('Amplitude');

legend( ...
    'f = 2 Hz',...
    'f = 5 Hz',...
    'f = 10 Hz',...
    'Location','best');

set(gca,'FontSize',12);

%% Export Figure

exportgraphics(gcf,...
fullfile('..','Figures','Fig03_Frequency_Comparison.png'),...
'Resolution',300);

% Compatible with older MATLAB versions
%
% saveas(gcf,...
% fullfile('..','Figures','Fig03_Frequency_Comparison.png'));

%% End of Lesson

% Next Lesson:
% Lesson 04 - What Is Period?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%