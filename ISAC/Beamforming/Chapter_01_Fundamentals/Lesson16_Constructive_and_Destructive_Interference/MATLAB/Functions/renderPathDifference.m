function renderPathDifference(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% renderPathDifference
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Demonstrates how path difference produces phase difference.
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
fprintf('Understand how path difference creates phase difference.\n\n');

%% Parameters

lambda = 2;

pathDifference = linspace(0, 2*lambda, 300);

phaseDifference = 2*pi*pathDifference/lambda;

%% Figure

figure( ...
    'Name', experiment.title, ...
    'NumberTitle', 'off', ...
    'Position', scene.figurePosition);

%% Geometry

subplot(2,1,1)

hold on
grid on
axis equal

xlim([0 12])
ylim([0 5])

title('Path Difference')

plot([1 10],[4 4],'b','LineWidth',2)
plot([1 11],[2 2],'r','LineWidth',2)

text(10.2,4,'Wave 1')
text(11.2,2,'Wave 2')

deltaHandle = text(5.2,1,...
    '',...
    'FontSize',13,...
    'FontWeight','bold');

%% Phase Difference Plot

subplot(2,1,2)

hold on
grid on
box on

plot( ...
    pathDifference,...
    phaseDifference,...
    'k',...
    'LineWidth',2);

pointHandle = plot( ...
    pathDifference(1),...
    phaseDifference(1),...
    'ro',...
    'MarkerSize',10,...
    'LineWidth',2);

xlabel('\DeltaL')
ylabel('\Delta\phi (rad)')

title('Phase Difference Produced by Path Difference')

%% Pause Hint

annotation( ...
    'textbox',...
    [0.76 0.965 0.22 0.03],...
    'String',scene.pauseMessage,...
    'EdgeColor','none',...
    'HorizontalAlignment','right',...
    'FontSize',10);

%% Animation

for k = 1:length(pathDifference)

    set(pointHandle,...
        'XData',pathDifference(k),...
        'YData',phaseDifference(k));

    deltaHandle.String = sprintf( ...
        '\\DeltaL = %.2f    \\Delta\\phi = %.2f rad',...
        pathDifference(k),...
        phaseDifference(k));

    drawnow;

end

%% Educational Conclusion

fprintf('Conclusion:\n');
fprintf('A path difference produces a phase difference.\n');
fprintf('The relationship is:\n');
fprintf('DeltaPhi = (2*pi/lambda) * DeltaL\n\n');

end