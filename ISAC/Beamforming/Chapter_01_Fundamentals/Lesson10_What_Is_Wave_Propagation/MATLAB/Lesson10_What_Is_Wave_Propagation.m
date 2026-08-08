%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 10 - What Is Wave Propagation?
%
% File    : Lesson10_What_Is_Wave_Propagation.m
%
% Description:
% Demonstrates wave propagation by visualizing how a sinusoidal wave
% travels through space over time using an animated plot.
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

% Wave amplitude
amplitude = 1;

% Wave frequency (Hz)
frequency = 1;

% Wave propagation speed (m/s)
waveSpeed = 4;

% Initial phase (rad)
phase = 0;

% Wavelength (m)
wavelength = waveSpeed / frequency;

% Angular frequency (rad/s)
omega = 2*pi*frequency;

% Wave number (rad/m)
waveNumber = 2*pi / wavelength;

% Distance axis (m)
distance = linspace(0,20,1500);

% Simulation time (s)
simulationTime = 5;

% Frame rate (frames/s)
frameRate = 25;

% Time vector
time = 0:1/frameRate:simulationTime;

%% Create Figure

figure('Color','w');

%% Animation

for n = 1:length(time)

    % Propagating wave
    wave = amplitude * sin( ...
        omega*time(n) ...
        - waveNumber*distance ...
        + phase);

    plot(distance,...
         wave,...
         'LineWidth',2);

    grid on;
    box on;

    xlabel('Distance (m)');
    ylabel('Amplitude');

    title(sprintf('Wave Propagation   t = %.2f s',time(n)));

    ylim([-1.2 1.2]);
    xlim([0 max(distance)]);

    set(gca,'FontSize',12);

    drawnow;

end

%% Display Wave Parameters

fprintf('\n');
fprintf('Wave Parameters\n');
fprintf('-----------------------------\n');
fprintf('Frequency          : %.2f Hz\n',frequency);
fprintf('Propagation Speed  : %.2f m/s\n',waveSpeed);
fprintf('Wavelength         : %.2f m\n',wavelength);
fprintf('Angular Frequency  : %.2f rad/s\n',omega);
fprintf('Wave Number        : %.2f rad/m\n',waveNumber);
fprintf('\n');

%% Export Animation (Optional)

% Uncomment to export frames manually or create a video.
%
% exportgraphics(gcf,...
% fullfile('..','Figures',...
% 'Fig10_Wave_Propagation.png'),...
% 'Resolution',300);

%% End of Lesson
%
% Next Lesson:
% Lesson 11 - What Is Propagation Speed?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%