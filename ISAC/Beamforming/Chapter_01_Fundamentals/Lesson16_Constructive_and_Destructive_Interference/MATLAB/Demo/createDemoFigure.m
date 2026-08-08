function handles = createDemoFigure(demo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% createDemoFigure
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Creates the interactive demonstration figure and all
% graphics objects. No animation is performed here.
%
% Inputs:
%   demo    Demo configuration structure.
%
% Outputs:
%   handles Graphics handles used by the demo.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure

handles.figure = figure( ...
    'Name','Lesson 16 Interactive Demo', ...
    'NumberTitle','off', ...
    'Color','w', ...
    'Position',demo.figurePosition);

%% -----------------------------------------------------------------------
% Wave 1
%% -----------------------------------------------------------------------

handles.axWave1 = subplot(2,2,1);

hold(handles.axWave1,'on');
grid(handles.axWave1,'on');
box(handles.axWave1,'on');

title(handles.axWave1,'Wave 1');
xlabel(handles.axWave1,'Position');
ylabel(handles.axWave1,'Amplitude');

xlim(handles.axWave1,[-10 10]);
ylim(handles.axWave1,[-2.2 2.2]);

handles.wave1 = plot( ...
    handles.axWave1,...
    nan,nan,...
    'LineWidth',2);

%% -----------------------------------------------------------------------
% Wave 2
%% -----------------------------------------------------------------------

handles.axWave2 = subplot(2,2,2);

hold(handles.axWave2,'on');
grid(handles.axWave2,'on');
box(handles.axWave2,'on');

title(handles.axWave2,'Wave 2');
xlabel(handles.axWave2,'Position');
ylabel(handles.axWave2,'Amplitude');

xlim(handles.axWave2,[-10 10]);
ylim(handles.axWave2,[-2.2 2.2]);

handles.wave2 = plot( ...
    handles.axWave2,...
    nan,nan,...
    'LineWidth',2);

%% -----------------------------------------------------------------------
% Resultant Wave
%% -----------------------------------------------------------------------

handles.axResult = subplot(2,2,3);

hold(handles.axResult,'on');
grid(handles.axResult,'on');
box(handles.axResult,'on');

title(handles.axResult,'Resultant Wave');
xlabel(handles.axResult,'Position');
ylabel(handles.axResult,'Amplitude');

xlim(handles.axResult,[-10 10]);
ylim(handles.axResult,[-2.2 2.2]);

handles.result = plot( ...
    handles.axResult,...
    nan,nan,...
    'LineWidth',2);

%% -----------------------------------------------------------------------
% Amplitude Graph
%% -----------------------------------------------------------------------

handles.axAmplitude = subplot(2,2,4);

hold(handles.axAmplitude,'on');
grid(handles.axAmplitude,'on');
box(handles.axAmplitude,'on');

title(handles.axAmplitude,'Resultant Amplitude');
xlabel(handles.axAmplitude,'Phase Difference (deg)');
ylabel(handles.axAmplitude,'Amplitude');

phase = 0:360;

amp = 2*abs(cosd(phase/2));

plot(handles.axAmplitude, ...
    phase,...
    amp,...
    'k',...
    'LineWidth',1.5);

handles.currentPoint = plot( ...
    handles.axAmplitude,...
    0,...
    2,...
    'ro',...
    'MarkerSize',9,...
    'LineWidth',2);

xlim(handles.axAmplitude,[0 360]);
ylim(handles.axAmplitude,[0 2.2]);

%% -----------------------------------------------------------------------
% Phase Label
%% -----------------------------------------------------------------------

handles.phaseText = annotation( ...
    'textbox',...
    [0.39 0.95 0.22 0.035],...
    'String','Δφ = 0°',...
    'HorizontalAlignment','center',...
    'EdgeColor','none',...
    'FontWeight','bold',...
    'FontSize',14);

%% -----------------------------------------------------------------------
% Interference Label
%% -----------------------------------------------------------------------

handles.interferenceText = annotation( ...
    'textbox',...
    [0.33 0.91 0.34 0.035],...
    'String','Constructive Interference',...
    'HorizontalAlignment','center',...
    'EdgeColor','none',...
    'FontWeight','bold',...
    'FontSize',13);

%% -----------------------------------------------------------------------
% Pause Hint
%% -----------------------------------------------------------------------

annotation( ...
    'textbox',...
    [0.73 0.965 0.25 0.025],...
    'String','Press SPACE to Pause / Resume',...
    'HorizontalAlignment','right',...
    'EdgeColor','none',...
    'FontSize',10);

end