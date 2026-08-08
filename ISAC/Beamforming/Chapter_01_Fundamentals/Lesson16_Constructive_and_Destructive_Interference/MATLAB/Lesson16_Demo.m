%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Interactive Demonstration
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Interactive demonstration of constructive and destructive
% interference using a phase slider and automatic phase sweep.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization

clear;
close all;
clc;

%% Initialize Project Paths

initializeProjectPaths();

%% Initialize Demo

demo = initializeDemo();

%% Create Figure

handles = createDemoFigure(demo);
%% Store Shared Data

state.handles = handles;

guidata(handles.figure,state);

%% Create Slider

handles = createPhaseSlider(handles,demo);

%% Initialize Demo State

state.phase = demo.slider.initial;
state.autoSweep = demo.autoSweep.enabled;
state.paused = false;
state.time = 0;
%% Register Keyboard Callback

set(handles.figure,...
    'KeyPressFcn', ...
    @(src,event) onKeyPressed(src,event));

%% Main Loop

while isvalid(handles.figure)

    if ~state.paused

        if state.autoSweep

            state = autoSweepPhase(state,demo);

            set(handles.phaseSlider,...
                'Value',...
                state.phase);

        end

        updateDemoScene(handles,demo,state);

        state.time = state.time + demo.timeStep;

    end

    drawnow;

end