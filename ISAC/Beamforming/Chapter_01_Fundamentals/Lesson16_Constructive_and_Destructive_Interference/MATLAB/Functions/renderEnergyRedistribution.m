function renderEnergyRedistribution(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% renderEnergyRedistribution
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Demonstrates that destructive interference does not destroy
% energy. Instead, energy is redistributed in space.
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
fprintf('Understand that destructive interference does ');
fprintf('not eliminate energy.\n\n');

%% Spatial Grid

x = linspace(-10,10,1000);

%% Phase Sweep

phase = linspace(0,2*pi,240);

%% Create Figure

figure( ...
    'Name',experiment.title,...
    'NumberTitle','off',...
    'Position',scene.figurePosition);

%% Resultant Wave

ax1 = subplot(2,1,1);

resultPlot = plot(ax1,x,zeros(size(x)), ...
    'Color',scene.colors.result,...
    'LineWidth',scene.lineWidth);

grid(ax1,'on')
xlim(ax1,scene.xLimits)
ylim(ax1,[-2.2 2.2])

title(ax1,'Resultant Wave')
ylabel(ax1,'Amplitude')

%% Energy Indicator

ax2 = subplot(2,1,2);

energyBar = bar(ax2,[1 2],[1 1]);

ylim(ax2,[0 2.2])

set(ax2,'XTick',[1 2]);
set(ax2,'XTickLabel',{'Constructive Region','Destructive Region'});

ylabel(ax2,'Relative Energy')

title(ax2,'Energy Redistribution')

grid(ax2,'on')

%% Status Label

statusText = annotation( ...
    'textbox',...
    [0.28 0.94 0.45 0.04],...
    'HorizontalAlignment','center',...
    'EdgeColor','none',...
    'FontWeight','bold',...
    'FontSize',15);

%% Pause Hint

annotation( ...
    'textbox',...
    [0.76 0.965 0.22 0.03],...
    'String',scene.pauseMessage,...
    'HorizontalAlignment','right',...
    'EdgeColor','none',...
    'FontSize',10);

%% Animation

wave1.amplitude = 1;
wave1.frequency = 1;
wave1.phase = 0;
wave1.direction = 1;

wave2 = wave1;

time = 0;

for k = 1:length(phase)

    wave2.phase = phase(k);

    y1 = calculateWave(x,wave1,time);
    y2 = calculateWave(x,wave2,time);

    yTotal = calculateSuperposition(y1,y2);

    set(resultPlot,'YData',yTotal);

    constructiveEnergy = ...
        (1+cos(phase(k)))/2;

    destructiveEnergy = ...
        1-constructiveEnergy;

    energyBar.YData = ...
        [constructiveEnergy destructiveEnergy];

    if abs(phase(k)-pi) < 0.2

        statusText.String = ...
            "Energy is redistributed, not destroyed.";

    else

        statusText.String = ...
            "Energy shifts between regions.";

    end

    drawnow;

end

%% Educational Conclusion

fprintf('Conclusion:\n');
fprintf('Destructive interference does not violate ');
fprintf('energy conservation.\n');
fprintf('Energy is redistributed rather than destroyed.\n\n');

end