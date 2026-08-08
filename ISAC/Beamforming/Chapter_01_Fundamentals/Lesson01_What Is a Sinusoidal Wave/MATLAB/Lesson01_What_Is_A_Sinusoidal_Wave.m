%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 01
%
% Title:
% What Is a Sinusoidal Wave?
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Version:
% 1.0.0
%
% Description:
% This lesson introduces the mathematical representation and visualization
% of a sinusoidal wave. It serves as the foundation for understanding wave
% propagation, antenna arrays, beamforming, radar, and communication
% systems.
%
% Educational Objective:
% By the end of this lesson, learners will be able to:
%   1. Understand what a sinusoidal wave is.
%   2. Generate a sinusoidal waveform in MATLAB.
%   3. Interpret the waveform using a time-domain plot.
%
% Prerequisites:
% None
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
% Clear the MATLAB environment to ensure that no variables,
% figures, or command window outputs from previous simulations
% affect the current lesson.

clear;
clc;
close all;

%% Simulation Parameters
% All simulation parameters are defined in one place to improve
% readability and make future modifications easier.

% Signal amplitude
signalAmplitude = 1;

% Signal frequency (Hz)
signalFrequency = 5;

% Initial phase (radians)
initialPhase = 0;

% Sampling frequency (samples/second)
samplingFrequency = 1000;

% Simulation duration (seconds)
simulationDuration = 1;

%% Time Vector
% Generate a uniformly sampled time vector.

time = 0 : 1/samplingFrequency : simulationDuration;

%% Signal Generation
% Generate the sinusoidal waveform using its mathematical model.
%
% Mathematical Equation:
%
% x(t) = A sin(2*pi*f*t + phi)
%
% where
% A   : Amplitude
% f   : Frequency (Hz)
% t   : Time (s)
% phi : Initial phase (rad)

sinusoidalSignal = signalAmplitude * ...
                   sin(2*pi*signalFrequency*(time+0) + (initialPhase+0));
%% Visualization
% Visualize the generated sinusoidal waveform.
% A publication-quality figure is created to clearly present
% the relationship between signal amplitude and time.

figure('Color', 'w', ...
       'Name', 'Lesson 01 - Sinusoidal Wave');

plot(time, ...
     sinusoidalSignal, ...
     'b', ...
     'LineWidth', 2);

hold on;

%% Figure Formatting
% Configure the figure appearance to improve readability.

grid on;
grid minor;
box on;

title('Sinusoidal Wave', ...
      'FontSize', 16, ...
      'FontWeight', 'bold');

xlabel('Time (s)', ...
       'FontSize', 13);

ylabel('Amplitude', ...
       'FontSize', 13);

set(gca, ...
    'FontSize', 12, ...
    'LineWidth', 1.2);

xlim([0 simulationDuration]);

ylim([-1.2*signalAmplitude 1.2*signalAmplitude]);

%% Add Reference Line
% Draw the zero-amplitude reference line.

yline(0, ...
      '--k', ...
      'LineWidth', 1);

%% Annotation
% Display the mathematical model on the figure.

text(0.02, ...
     1.05*signalAmplitude, ...
     '$x(t)=A\sin(2\pi ft+\phi)$', ...
     'Interpreter', 'latex', ...
     'FontSize', 14);

%% Export Figure
% Export a publication-quality image.
%
% Uncomment the following commands after creating the Figures folder.

%exportgraphics(gcf, ...
%     fullfile('..','Figures','Fig01_Sinusoidal_Wave.png'), ...
%     'Resolution',300);


 saveas(gcf,...
     fullfile('..','Figures',...
     'Fig01_Sinusoidal_Wave.png'));

%% End of Script

disp(' ');
disp('==============================================');
disp(' Lesson 01 completed successfully.');
disp(' Sinusoidal waveform generated.');
disp('==============================================');
disp(' ');