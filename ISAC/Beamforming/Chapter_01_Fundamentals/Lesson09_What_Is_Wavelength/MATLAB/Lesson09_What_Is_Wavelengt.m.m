%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 09 - What Is Wavelength?
%
% File    : Lesson09_What_Is_Wavelength.m
%
% Description:
% Demonstrates the concept of wavelength by visualizing sinusoidal
% waves with different frequencies propagating at a constant speed.
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

% Frequencies (Hz)
frequency = [2 4 8];

% Wave propagation speed (m/s)
waveSpeed = 20;

% Wavelengths (m)
wavelength = waveSpeed ./ frequency;

% Distance axis (m)
distance = linspace(0,25,2000);

%% Create Figure

figure;
hold on;
grid on;
box on;

%% Generate Waves

for k = 1:length(frequency)

    signal = amplitude * sin( ...
        2*pi*distance/wavelength(k));

    plot(distance,...
         signal,...
         'LineWidth',2);

end

%% Figure Formatting

title('Effect of Frequency on Wavelength');

xlabel('Distance (m)');

ylabel('Amplitude');

legend( ...
sprintf('f = %.0f Hz   \\lambda = %.2f m',frequency(1),wavelength(1)),...
sprintf('f = %.0f Hz   \\lambda = %.2f m',frequency(2),wavelength(2)),...
sprintf('f = %.0f Hz   \\lambda = %.2f m',frequency(3),wavelength(3)),...
'Location','best');

set(gca,'FontSize',12);

axis tight;

%% Display Results

fprintf('\n');
fprintf('Wavelength Calculation\n');
fprintf('----------------------\n');

for k=1:length(frequency)

    fprintf('f = %5.2f Hz    lambda = %8.3f m\n',...
        frequency(k),...
        wavelength(k));

end

fprintf('\nWave Speed = %.2f m/s\n',waveSpeed);

%% Export Figure

% exportgraphics(gcf,...
% fullfile('..','Figures',...
% 'Fig09_Wavelength.png'),...
% 'Resolution',300);

%% End of Lesson

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%