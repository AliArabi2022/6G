%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 11 - What Is Propagation Speed?
%
% File    : Lesson11_What_Is_Propagation_Speed.m
%
% Description:
% Demonstrates how propagation speed affects wave propagation while
% frequency remains constant.
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

% Frequency (Hz)
frequency = 2;

% Propagation speeds (m/s)
waveSpeed = [2 4 8];

% Simulation time
currentTime = 1.0;

% Distance axis
distance = linspace(0,20,2000);

%% Create Figure

figure('Color','w');
hold on;
grid on;
box on;

%% Generate Waves

for k = 1:length(waveSpeed)

    wavelength = waveSpeed(k)/frequency;

    omega = 2*pi*frequency;

    waveNumber = 2*pi/wavelength;

    wave = amplitude * sin( ...
        omega*currentTime ...
        - waveNumber*distance);

    plot(distance,...
         wave,...
         'LineWidth',2);

end

%% Figure Formatting

title('Effect of Propagation Speed');

xlabel('Distance (m)');
ylabel('Amplitude');

legend( ...
sprintf('v = %.0f m/s',waveSpeed(1)),...
sprintf('v = %.0f m/s',waveSpeed(2)),...
sprintf('v = %.0f m/s',waveSpeed(3)),...
'Location','best');

set(gca,'FontSize',12);

%% Display Results

fprintf('\n');
fprintf('Propagation Speed Analysis\n');
fprintf('------------------------------\n');

for k = 1:length(waveSpeed)

    wavelength = waveSpeed(k)/frequency;

    fprintf('Speed = %5.2f m/s   Wavelength = %6.2f m\n',...
        waveSpeed(k),...
        wavelength);

end

fprintf('\nFrequency = %.2f Hz\n',frequency);

%% Export Figure

% exportgraphics(gcf,...
% fullfile('..','Figures',...
% 'Fig11_Propagation_Speed.png'),...
% 'Resolution',300);

%% End of Lesson

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%