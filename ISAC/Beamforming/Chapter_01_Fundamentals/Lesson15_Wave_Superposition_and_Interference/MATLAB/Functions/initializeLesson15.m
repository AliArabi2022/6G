%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initializeLesson15.m
%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson : 15
%
% Version : 1.1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scene = initializeLesson15()

arguments
end

%% Spatial Domain

scene.x = linspace(-10,10,1000);

%% Time

scene.dt = 0.02;

scene.simulationTime = 8;

scene.timeVector = 0:scene.dt:scene.simulationTime;

%% Animation

scene.animationDelay = 0.04;

%% Figure

scene.figure = figure( ...
    'Name','Lesson 15',...
    'Color','w',...
    'NumberTitle','off');
%% Keyboard Control

setappdata(scene.figure,'Paused',false);

scene.figure.WindowKeyPressFcn = @togglePause;

end