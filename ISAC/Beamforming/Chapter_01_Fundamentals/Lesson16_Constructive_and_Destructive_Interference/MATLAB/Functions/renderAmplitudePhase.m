function renderAmplitudePhase(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% renderAmplitudePhase
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Demonstrates how the resultant amplitude changes as a function of
% phase difference.
%
% Inputs:
%   scene       Scene configuration structure.
%   experiment  Experiment structure.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Display Objective

fprintf('\n');
fprintf('Objective:\n');
fprintf('Observe the relationship between phase difference ');
fprintf('and resultant amplitude.\n\n');

%% Phase Difference

phaseDegrees = linspace(0,360,361);
phaseRadians = deg2rad(phaseDegrees);

%% Resultant Amplitude

resultAmplitude = calculateResultAmplitude(phaseRadians);

%% Create Figure

figure( ...
    'Name',experiment.title,...
    'NumberTitle','off',...
    'Position',scene.figurePosition);

%% ------------------------------------------------------------------------
% Left Side
% -------------------------------------------------------------------------

subplot(1,2,1)

hold on
grid on
box on

xlim(scene.xLimits)
ylim(scene.yLimits)

xlabel('Position')
ylabel('Amplitude')
title('Wave Superposition')

x = linspace(scene.xLimits(1),scene.xLimits(2),1000);

wave1Plot = plot( ...
    x,...
    zeros(size(x)),...
    'Color',scene.colors.wave1,...
    'LineWidth',scene.lineWidth);

wave2Plot = plot( ...
    x,...
    zeros(size(x)),...
    'Color',scene.colors.wave2,...
    'LineWidth',scene.lineWidth);

resultPlot = plot( ...
    x,...
    zeros(size(x)),...
    'Color',scene.colors.result,...
    'LineWidth',scene.lineWidth);

legend( ...
    'Wave 1',...
    'Wave 2',...
    'Resultant',...
    'Location','southoutside');

%% ------------------------------------------------------------------------
% Right Side
% -------------------------------------------------------------------------

subplot(1,2,2)

hold on
grid on
box on

plot( ...
    phaseDegrees,...
    resultAmplitude,...
    'LineWidth',2);

currentPoint = plot( ...
    phaseDegrees(1),...
    resultAmplitude(1),...
    'ro',...
    'MarkerSize',10,...
    'LineWidth',2);

xlabel('Phase Difference (degrees)')
ylabel('Resultant Amplitude')
title('Amplitude versus Phase Difference')

xlim([0 360])
ylim([0 2.2])

%% Phase Label

phaseText = annotation( ...
    'textbox',...
    [0.38 0.93 0.24 0.04],...
    'HorizontalAlignment','center',...
    'EdgeColor','none',...
    'FontWeight','bold',...
    'FontSize',15);

%% Pause Hint

annotation( ...
    'textbox',...
    [0.76 0.965 0.22 0.03],...
    'String',scene.pauseMessage,...
    'EdgeColor','none',...
    'HorizontalAlignment','right',...
    'FontSize',10);

%% Animation

time = 0;

for k = 1:length(phaseDegrees)

    phase = phaseRadians(k);

    wave1 = experiment.wave1;
    wave2 = experiment.wave2;

    wave2.phase = phase;

    y1 = calculateWave(x,wave1,time);

    y2 = calculateWave(x,wave2,time);

    yResult = calculateSuperposition(y1,y2);

    set(wave1Plot,'YData',y1);
    set(wave2Plot,'YData',y2);
    set(resultPlot,'YData',yResult);

    set(currentPoint,...
        'XData',phaseDegrees(k),...
        'YData',resultAmplitude(k));

    phaseText.String = sprintf( ...
        '\\Delta\\phi = %.0f°', ...
        phaseDegrees(k));

    drawnow;

end

%% Educational Conclusion

fprintf('Conclusion:\n');
fprintf('The resultant amplitude varies continuously ');
fprintf('with the phase difference.\n\n');

end