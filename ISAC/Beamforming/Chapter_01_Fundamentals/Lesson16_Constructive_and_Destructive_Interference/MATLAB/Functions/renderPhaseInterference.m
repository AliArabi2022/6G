function renderPhaseInterference(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% renderPhaseInterference
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Renders phase interference experiments:
%   - Constructive Interference
%   - Partial Interference
%   - Destructive Interference
%
% Inputs:
%   scene       Scene configuration structure.
%   experiment  Experiment structure.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Display Objective

fprintf("\nObjective:\n");
fprintf("Observe how phase difference changes the resultant wave.\n\n");

%% Spatial Grid

x = linspace( ...
    scene.xLimits(1), ...
    scene.xLimits(2), ...
    1000);

%% Time Vector

t = 0 : scene.timeStep : experiment.simulationTime;

%% Create Figure

figure( ...
    'Name', experiment.title, ...
    'NumberTitle', 'off', ...
    'Position', scene.figurePosition);

%% Axes

ax1 = subplot(3,1,1);
wave1Plot = plot(ax1,x,zeros(size(x)), ...
    'Color',scene.colors.wave1, ...
    'LineWidth',scene.lineWidth);

grid(ax1,'on');
xlim(ax1,scene.xLimits);
ylim(ax1,scene.yLimits);
ylabel(ax1,'Amplitude');
title(ax1,'Wave 1');

ax2 = subplot(3,1,2);
wave2Plot = plot(ax2,x,zeros(size(x)), ...
    'Color',scene.colors.wave2, ...
    'LineWidth',scene.lineWidth);

grid(ax2,'on');
xlim(ax2,scene.xLimits);
ylim(ax2,scene.yLimits);
ylabel(ax2,'Amplitude');
title(ax2,'Wave 2');

ax3 = subplot(3,1,3);
resultPlot = plot(ax3,x,zeros(size(x)), ...
    'Color',scene.colors.result, ...
    'LineWidth',scene.lineWidth);

grid(ax3,'on');
xlim(ax3,scene.xLimits);
ylim(ax3,scene.yLimits);

xlabel(ax3,'Position');
ylabel(ax3,'Amplitude');

%% Interference Label

labelHandle = annotation( ...
    'textbox', ...
    [0.34 0.94 0.32 0.045], ...
    'HorizontalAlignment','center', ...
    'EdgeColor','none', ...
    'FontWeight','bold', ...
    'FontSize',16);

%% Pause Hint

annotation( ...
    'textbox', ...
    [0.76 0.965 0.22 0.03], ...
    'String',scene.pauseMessage, ...
    'HorizontalAlignment','right', ...
    'EdgeColor','none', ...
    'FontSize',10);

%% Determine Interference Type

phaseDifference = mod(experiment.wave2.phase,2*pi);

tolerance = deg2rad(5);

if abs(phaseDifference) < tolerance || ...
        abs(phaseDifference-2*pi) < tolerance

    interferenceText = "Constructive Interference";

elseif abs(phaseDifference-pi) < tolerance

    interferenceText = "Destructive Interference";

else

    interferenceText = "Partial Interference";

end

labelHandle.String = interferenceText;

%% Animation

for k = 1:length(t)

    currentTime = t(k);

    y1 = calculateWave( ...
        x, ...
        experiment.wave1, ...
        currentTime);

    y2 = calculateWave( ...
        x, ...
        experiment.wave2, ...
        currentTime);

    yResult = calculateSuperposition(y1,y2);

    set(wave1Plot,'YData',y1);
    set(wave2Plot,'YData',y2);
    set(resultPlot,'YData',yResult);

    drawnow;

end

%% Educational Conclusion

fprintf("\nConclusion:\n");

switch interferenceText

    case "Constructive Interference"

        fprintf("Maximum amplitude occurs because both waves are in phase.\n");

    case "Destructive Interference"

        fprintf("The waves cancel because they are 180 degrees out of phase.\n");

    otherwise

        fprintf("The resultant amplitude depends continuously on phase difference.\n");

end

fprintf("\n");

end