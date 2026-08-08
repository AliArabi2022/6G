%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson  : 12 - What Is a Wavefront?
%
% File    : Lesson12_What_Is_A_Wavefront.m
%
% Description:
% Visualizes circular wavefronts radiating from a point source.
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

waveSpeed = 2;          % m/s
time = 1:1:5;           % seconds

theta = linspace(0,2*pi,500);

%% Create Figure

figure('Color','w');
hold on;
grid on;
axis equal;

%% Draw Wavefronts

for k = 1:length(time)

    radius = waveSpeed*time(k);

    x = radius*cos(theta);
    y = radius*sin(theta);

    plot(x,...
         y,...
         'LineWidth',2);

end

plot(0,0,...
    'ko',...
    'MarkerFaceColor','r',...
    'MarkerSize',8);

xlabel('x (m)');
ylabel('y (m)');

title('Circular Wavefronts from a Point Source');

legend( ...
'1 s',...
'2 s',...
'3 s',...
'4 s',...
'5 s',...
'Source',...
'Location','eastoutside');

set(gca,'FontSize',12);

%% End of Lesson