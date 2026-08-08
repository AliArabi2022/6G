function renderCoherence(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% renderCoherence
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Demonstrates the importance of coherence for maintaining
% a stable interference pattern.
%
% Inputs:
%   scene       Scene configuration structure.
%   experiment  Experiment structure.
%
% Outputs:
%   None
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Display Objective

fprintf('\n');
fprintf('Objective:\n');
fprintf('Observe the effect of coherence on interference.\n\n');

%% Spatial Grid

x = linspace(scene.xLimits(1), ...
             scene.xLimits(2), ...
             1000);

%% Time Vector

t = 0 : scene.timeStep : experiment.simulationTime;

%% Wave Parameters

wave1 = experiment.wave1;
wave2 = experiment.wave2;

%% Create Figure

figure( ...
    'Name', experiment.title, ...
    'NumberTitle', 'off', ...
    'Position', scene.figurePosition);

%% Subplot 1

ax1 = subplot(3,1,1);

wave1Plot = plot(ax1, x, zeros(size(x)), ...
    'Color', scene.colors.wave1, ...
    'LineWidth', scene.lineWidth);

grid(ax1,'on')
xlim(ax1,scene.xLimits)
ylim(ax1,scene.yLimits)

title(ax1,'Wave 1')
ylabel(ax1,'Amplitude')

%% Subplot 2

ax2 = subplot(3,1,2);

wave2Plot = plot(ax2, x, zeros(size(x)), ...
    'Color', scene.colors.wave2, ...
    'LineWidth', scene.lineWidth);

grid(ax2,'on')
xlim(ax2,scene.xLimits)
ylim(ax2,scene.yLimits)

title(ax2,'Wave 2 (Frequency Slowly Changes)')
ylabel(ax2,'Amplitude')

%% Subplot 3

ax3 = subplot(3,1,3);

resultPlot = plot(ax3, x, zeros(size(x)), ...
    'Color', scene.colors.result, ...
    'LineWidth', scene.lineWidth);

grid(ax3,'on')
xlim(ax3,scene.xLimits)
ylim(ax3,scene.yLimits)

title(ax3,'Resultant Wave')
xlabel(ax3,'Position')
ylabel(ax3,'Amplitude')

%% Status Label

statusText = annotation( ...
    'textbox', ...
    [0.30 0.94 0.40 0.04], ...
    'EdgeColor','none', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold', ...
    'FontSize',15);

%% Pause Hint

annotation( ...
    'textbox', ...
    [0.76 0.965 0.22 0.03], ...
    'String', scene.pauseMessage, ...
    'EdgeColor','none', ...
    'HorizontalAlignment','right', ...
    'FontSize',10);

%% Animation

for k = 1:length(t)

    currentTime = t(k);

    wave2.frequency = ...
        experiment.wave2.frequency + 0.05*sin(0.2*currentTime);

    y1 = calculateWave(x, wave1, currentTime);

    y2 = calculateWave(x, wave2, currentTime);

    yResult = calculateSuperposition(y1, y2);

    set(wave1Plot,'YData',y1);
    set(wave2Plot,'YData',y2);
    set(resultPlot,'YData',yResult);

    if abs(wave2.frequency-wave1.frequency) < 0.01

        statusText.String = "Nearly Coherent";

    else

        statusText.String = "Loss of Coherence";

    end

    drawnow;

end

%% Educational Conclusion

fprintf('Conclusion:\n');
fprintf('Stable interference requires coherent sources.\n');
fprintf('When the frequency relationship changes,\n');
fprintf('the interference pattern is no longer stable.\n\n');

end