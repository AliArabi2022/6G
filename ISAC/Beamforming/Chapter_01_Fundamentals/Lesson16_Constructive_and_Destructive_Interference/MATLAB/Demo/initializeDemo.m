function demo = initializeDemo()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% initializeDemo
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Initializes the interactive demo configuration.
%
% Outputs:
%   demo    Demo configuration structure.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure

demo.figurePosition = [80 60 1500 850];

%% Animation

demo.frameRate = 30;
demo.timeStep  = 1/demo.frameRate;

%% Slider

demo.slider.minimum = 0;
demo.slider.maximum = 360;
demo.slider.initial = 0;

%% Auto Sweep

demo.autoSweep.enabled = true;
demo.autoSweep.speed   = 1;      % degree/frame

%% Pause

demo.pauseKey = "space";

%% Display

demo.showAmplitudeGraph = true;
demo.showInterferenceLabel = true;

%% Wave Parameters

demo.wave.amplitude = 1;
demo.wave.frequency = 1;
demo.wave.velocity  = 1;
demo.wave.direction = 1;

end