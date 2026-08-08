function updateDemoScene(handles, demo, state)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% updateDemoScene
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Updates all graphics objects for one animation frame.
%
% Inputs:
%   handles    Graphics handles.
%   demo       Demo configuration structure.
%   state      Demo state structure.
%
% Outputs:
%   None
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Spatial Grid

x = linspace(-10,10,1000);

%% Wave Definitions

wave1 = demo.wave;
wave2 = demo.wave;

wave2.phase = deg2rad(state.phase);
wave2.direction = -1;

%% Wave Calculation

y1 = calculateWave(x,wave1,state.time);

y2 = calculateWave(x,wave2,state.time);

yResult = calculateSuperposition(y1,y2);

%% Update Wave 1

set(handles.wave1,...
    'XData',x,...
    'YData',y1);

%% Update Wave 2

set(handles.wave2,...
    'XData',x,...
    'YData',y2);

%% Update Resultant Wave

set(handles.result,...
    'XData',x,...
    'YData',yResult);

%% Resultant Amplitude

amplitude = calculateResultAmplitude( ...
    deg2rad(state.phase));

%% Update Amplitude Graph

set(handles.currentPoint,...
    'XData',state.phase,...
    'YData',amplitude);

%% Update Phase Label

handles.phaseText.String = ...
    sprintf('\\Delta\\phi = %.0f°',state.phase);

%% Update Interference Label

tolerance = 5;

if abs(state.phase) < tolerance || ...
        abs(state.phase-360) < tolerance

    label = 'Constructive Interference';

elseif abs(state.phase-180) < tolerance

    label = 'Destructive Interference';

else

    label = 'Partial Interference';

end

handles.interferenceText.String = label;

end