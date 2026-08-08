%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 04 - What Is Period?
%
% File    : Lesson04_What_Is_Period.m
%
% Description:
% Demonstrates the concept of period by generating a sinusoidal waveform
% and illustrating one complete cycle.
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

% Sampling frequency (Hz)
samplingFrequency = 1000;

% Simulation duration (s)
simulationDuration = 1;

%% Calculate Period

period = 1 / frequency;

%% Generate Time Vector

time = 0:1/samplingFrequency:simulationDuration;

%% Generate Signal

signal = generateSineWave( ...
    amplitude,...
    frequency,...
    phase,...
    time);

%% Create Figure

figure;
plot(time,signal,'LineWidth',2);

grid on;
box on;
hold on;

%% Highlight One Complete Period

startTime = 0;

endTime = period;

xline(startTime,'--k','LineWidth',1.5);

xline(endTime,'--k','LineWidth',1.5);

yPosition = -1.25 * amplitude;

plot([startTime endTime],...
     [yPosition yPosition],...
     'r',...
     'LineWidth',2);

text(period/2,...
     yPosition-0.1,...
     sprintf('T = %.3f s',period),...
     'HorizontalAlignment','center',...
     'FontSize',12);

%% Figure Formatting

title('Illustration of the Period of a Sinusoidal Wave');

xlabel('Time (s)');

ylabel('Amplitude');

set(gca,'FontSize',12);

axis tight;

%% Export Figure

% Uncomment to export the figure
%
exportgraphics(gcf,...
     fullfile('..','Figures','Fig04_Period_Illustration.png'),...
     'Resolution',300);

% Compatible with older MATLAB versions
%
% saveas(gcf,...
%     fullfile('..','Figures','Fig04_Period_Illustration.png'));

%% End of Lesson
%
% Next Lesson:
% Lesson 05 - What Is Initial Phase?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%