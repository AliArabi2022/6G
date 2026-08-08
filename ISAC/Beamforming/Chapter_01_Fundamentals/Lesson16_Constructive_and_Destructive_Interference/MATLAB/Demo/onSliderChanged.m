function onSliderChanged(src,~)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% onSliderChanged
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Callback executed when the phase slider is moved.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig = ancestor(src,'figure');

state = guidata(fig);

%% Update Phase

state.phase = get(src,'Value');

%% Manual Control Stops Auto Sweep

state.autoSweep = false;

%% Update Slider Label

set(state.handles.phaseValue,...
    'String',...
    sprintf('%.0f°',state.phase));

%% Save State

guidata(fig,state);

end