%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% runExperiment.m
%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 Fundamentals of Waves
%
% Lesson : 15
%
% Version : 1.1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function runExperiment(experiment)

arguments
    experiment struct
end

%% Initialize

scene = initializeLesson15();


wave1 = experiment.wave1;
wave2 = experiment.wave2;

wave1 = updateWave(wave1,0);
wave2 = updateWave(wave2,0);
%% Simulation Time Override

if isfield(experiment,"simulationTime")

    scene.simulationTime = experiment.simulationTime;

    scene.timeVector = ...
        0:scene.dt:scene.simulationTime;

end

%% Initial Data

y1 = calculateWave(wave1,scene.x);
y2 = calculateWave(wave2,scene.x);
y  = y1 + y2;

%% Figure

figure(scene.figure);

ax1 = subplot(3,1,1);

hWave1 = plot( ...
    scene.x,...
    y1,...
    'Color',wave1.Color,...
    'LineWidth',wave1.LineWidth);

grid(ax1,'on')

ylim(ax1,[-2.2 2.2])

title(ax1,'Wave 1')

ylabel(ax1,'Amplitude')

%%

ax2 = subplot(3,1,2);

hWave2 = plot( ...
    scene.x,...
    y2,...
    'Color',wave2.Color,...
    'LineWidth',wave2.LineWidth);

grid(ax2,'on')

ylim(ax2,[-2.2 2.2])

title(ax2,'Wave 2')

ylabel(ax2,'Amplitude')

%%

ax3 = subplot(3,1,3);

hResult = plot( ...
    scene.x,...
    y,...
    'k',...
    'LineWidth',2.5);

grid(ax3,'on')

ylim(ax3,[-2.2 2.2])

xlabel(ax3,'Position')

ylabel(ax3,'Amplitude')

title(ax3,'Superposition')

sgtitle(experiment.name,'FontWeight','bold')
annotation( ...
    'textbox',...
    [0.74 0.01 0.25 0.04],...
    'String','Press SPACE to Pause / Resume',...
    'EdgeColor','none',...
    'HorizontalAlignment','right',...
    'FontSize',9,...
    'Color',[0.35 0.35 0.35],...
    'Interpreter','none');

%% Animation

for k = 1:length(scene.timeVector)

    while getappdata(scene.figure,'Paused')

        pause(0.05);

        drawnow;

    end

    t = scene.timeVector(k);

    wave1 = updateWave(experiment.wave1,t);
    wave2 = updateWave(experiment.wave2,t);

    y1 = calculateWave(wave1,scene.x);

    y2 = calculateWave(wave2,scene.x);

    y = y1 + y2;

    hWave1.YData = y1;

    hWave2.YData = y2;

    hResult.YData = y;

    drawnow limitrate
    pause(scene.animationDelay)
    
end

end