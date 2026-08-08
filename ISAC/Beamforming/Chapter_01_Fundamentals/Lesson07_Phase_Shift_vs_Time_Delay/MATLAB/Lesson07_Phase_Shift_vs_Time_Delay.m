%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 07 - Phase Shift vs. Time Delay
%
% File    : Lesson07_Phase_Shift_vs_Time_Delay.m
%
% Description:
% Compares a phase-shifted sinusoidal signal with an equivalent
% time-delayed sinusoidal signal and demonstrates the relationship
% between phase shift and time delay.
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

% Phase shift (degrees)
phaseDegrees = 90;

% Phase shift (radians)
phaseRadians = deg2rad(phaseDegrees);

% Equivalent time delay (s)
timeDelay = phaseRadians / (2*pi*frequency);

% Sampling frequency (Hz)
samplingFrequency = 1000;

% Simulation duration (s)
simulationDuration = 1;

%% Generate Time Vector

time = 0:1/samplingFrequency:simulationDuration;

%% Generate Signals

% Original signal
originalSignal = generateSineWave( ...
    amplitude,...
    frequency,...
    0,...
    time);

% Phase-shifted signal
phaseShiftedSignal = generateSineWave( ...
    amplitude,...
    frequency,...
    phaseRadians,...
    time);

% Time-delayed signal
timeDelayedSignal = generateSineWave( ...
    amplitude,...
    frequency,...
    0,...
    time - timeDelay);

%% Create Figure

figure;

plot( ...
    time,...
    originalSignal,...
    'LineWidth',2);

hold on;
grid on;
box on;

plot( ...
    time,...
    phaseShiftedSignal,...
    '--',...
    'LineWidth',2);

plot( ...
    time,...
    timeDelayedSignal,...
    ':',...
    'LineWidth',3);

%% Figure Formatting

title('Phase Shift vs. Equivalent Time Delay');

xlabel('Time (s)');

ylabel('Amplitude');

legend( ...
    'Original Signal',...
    sprintf('Phase Shift = %d°',phaseDegrees),...
    sprintf('Equivalent Delay = %.3f s',timeDelay),...
    'Location','best');

set(gca,'FontSize',12);

axis tight;

%% Display Results

fprintf('\n');
fprintf('Phase Shift Comparison\n');
fprintf('----------------------\n');

fprintf('Frequency      : %.2f Hz\n',frequency);
fprintf('Phase Shift    : %.2f deg\n',phaseDegrees);
fprintf('Phase Shift    : %.4f rad\n',phaseRadians);
fprintf('Time Delay     : %.6f s\n',timeDelay);

fprintf('\n');

%% Export Figure

% Uncomment to export the figure
%
%exportgraphics(gcf,...
%     fullfile('..','Figures',...
%     'Fig07_Phase_Shift_vs_Time_Delay.png'),...
%     'Resolution',300);

% Compatible with older MATLAB versions
%
 saveas(gcf,...
     fullfile('..','Figures',...
     'Fig07_Phase_Shift_vs_Time_Delay.png'));

%% End of Lesson
%
% Next Lesson:
% Lesson 08 - What Is Angular Frequency?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%