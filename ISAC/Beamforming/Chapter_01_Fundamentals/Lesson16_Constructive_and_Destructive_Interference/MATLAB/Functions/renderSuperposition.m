function renderSuperposition(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% renderSuperposition
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Renders Experiment 1:
% Review of the Principle of Superposition.
%
% Inputs:
%   scene       Scene configuration structure.
%   experiment  Experiment structure.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Display Objective

disp(" ");
disp("Objective:");
disp("Review the Principle of Superposition.");
disp(" ");

%% Create Spatial Grid

x = linspace(scene.xLimits(1), ...
             scene.xLimits(2), ...
             1000);

%% Time Vector

t = 0:scene.timeStep:experiment.simulationTime;

%% Create Figure

figure( ...
    'Name', experiment.title, ...
    'NumberTitle', 'off', ...
    'Position', scene.figurePosition);

%% Create Subplots

ax1 = subplot(3,1,1);
wave1Plot = plot(ax1, x, zeros(size(x)), ...
    'Color', scene.colors.wave1, ...
    'LineWidth', scene.lineWidth);

title(ax1,'Wave 1');
ylabel(ax1,'Amplitude');
grid(ax1,scene.grid);
xlim(ax1,scene.xLimits);
ylim(ax1,scene.yLimits);

ax2 = subplot(3,1,2);
wave2Plot = plot(ax2, x, zeros(size(x)), ...
    'Color', scene.colors.wave2, ...
    'LineWidth', scene.lineWidth);

title(ax2,'Wave 2');
ylabel(ax2,'Amplitude');
grid(ax2,scene.grid);
xlim(ax2,scene.xLimits);
ylim(ax2,scene.yLimits);

ax3 = subplot(3,1,3);
resultPlot = plot(ax3, x, zeros(size(x)), ...
    'Color', scene.colors.result, ...
    'LineWidth', scene.lineWidth);

title(ax3,'Resultant Wave');
xlabel(ax3,'Position');
ylabel(ax3,'Amplitude');
grid(ax3,scene.grid);
xlim(ax3,scene.xLimits);
ylim(ax3,scene.yLimits);

%% Pause Hint

annotation( ...
    'textbox', ...
    [0.76 0.965 0.22 0.03], ...
    'String', scene.pauseMessage, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'right', ...
    'FontSize', 10);

%% Animation Loop

for k = 1:numel(t)

    time = t(k);

    y1 = calculateWave(x, experiment.wave1, time);
    y2 = calculateWave(x, experiment.wave2, time);

    yTotal = calculateSuperposition(y1, y2);

    set(wave1Plot, 'YData', y1);
    set(wave2Plot, 'YData', y2);
    set(resultPlot, 'YData', yTotal);

    drawnow;

end

%% Educational Conclusion

disp(" ");
disp("Conclusion:");
disp("The resultant displacement is the algebraic sum of");
disp("the individual wave displacements.");
disp(" ");

end