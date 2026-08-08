%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 08 - What Is Angular Frequency?
%
% File    : Lesson08_What_Is_Angular_Frequency.m
%
% Description:
% Demonstrates the concept of angular frequency and its relationship
% to ordinary frequency using sinusoidal waveforms.
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

% Signal frequencies (Hz)
frequency = [2 5 10];

% Angular frequencies (rad/s)
angularFrequency = 2*pi*frequency;

% Initial phase (rad)
phase = 0;

% Sampling frequency (Hz)
samplingFrequency = 1000;

% Simulation duration (s)
simulationDuration = 1.5;

%% Generate Time Vector

time = 0:1/samplingFrequency:simulationDuration;

%% Create Figure

figure;
hold on;
grid on;
box on;

%% Generate and Plot Signals

for k = 1:length(frequency)

    signal = generateSineWave( ...
        amplitude,...
        frequency(k),...
        phase,...
        time);

    plot(time,...
        signal,...
        'LineWidth',2);

end

%% Figure Formatting

title('Angular Frequency and Signal Oscillation');

xlabel('Time (s)');
ylabel('Amplitude');

legend( ...
    sprintf('f = %.0f Hz, \\omega = %.2f rad/s',frequency(1),angularFrequency(1)),...
    sprintf('f = %.0f Hz, \\omega = %.2f rad/s',frequency(2),angularFrequency(2)),...
    sprintf('f = %.0f Hz, \\omega = %.2f rad/s',frequency(3),angularFrequency(3)),...
    'Location','best');

set(gca,'FontSize',12);

axis tight;

%% Display Results

fprintf('\n');
fprintf('Angular Frequency\n');
fprintf('-----------------\n');

for k = 1:length(frequency)

    fprintf('f = %5.2f Hz   -->   omega = %8.4f rad/s\n', ...
        frequency(k), angularFrequency(k));

end

fprintf('\n');

%% Export Figure

% Uncomment to export the figure
%
% exportgraphics(gcf,...
% fullfile('..','Figures',...
% 'Fig08_Angular_Frequency.png'),...
% 'Resolution',300);

% Compatible with older MATLAB versions
%
% saveas(gcf,...
% fullfile('..','Figures',...
% 'Fig08_Angular_Frequency.png'));

%% End of Lesson
%
% Next Lesson:
% Lesson 09 - What Is Wavelength?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%