function renderSpatialPattern(scene, experiment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% renderSpatialPattern
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Demonstrates the formation of spatial interference
% patterns produced by two coherent wave sources.
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
fprintf('Observe how constructive and destructive ');
fprintf('interference vary with observation position.\n\n');

%% Simulation Parameters

x = linspace(-6,6,300);
y = linspace(-6,6,300);

[X,Y] = meshgrid(x,y);

lambda = 1.0;

k = 2*pi/lambda;

source1 = [-1.5 0];
source2 = [ 1.5 0];

%% Distances

R1 = sqrt((X-source1(1)).^2 + (Y-source1(2)).^2);

R2 = sqrt((X-source2(1)).^2 + (Y-source2(2)).^2);

%% Wave Fields

wave1 = cos(k*R1);

wave2 = cos(k*R2);

result = wave1 + wave2;

%% Create Figure

figure( ...
    'Name',experiment.title,...
    'NumberTitle','off',...
    'Position',scene.figurePosition);

%% Plot

imagesc(x,y,result)

axis equal
axis tight

xlabel('x')
ylabel('y')

title('Spatial Interference Pattern')

colorbar

hold on

plot(source1(1),source1(2), ...
    'wo',...
    'MarkerFaceColor','w',...
    'MarkerSize',8)

plot(source2(1),source2(2), ...
    'wo',...
    'MarkerFaceColor','w',...
    'MarkerSize',8)

text(source1(1),source1(2)-0.4,'Source 1',...
    'HorizontalAlignment','center')

text(source2(1),source2(2)-0.4,'Source 2',...
    'HorizontalAlignment','center')

%% Pause Hint

annotation( ...
    'textbox',...
    [0.76 0.965 0.22 0.03],...
    'String',scene.pauseMessage,...
    'HorizontalAlignment','right',...
    'EdgeColor','none',...
    'FontSize',10);

%% Educational Conclusion

fprintf('Conclusion:\n');
fprintf('Interference depends on observation position.\n');
fprintf('Different locations experience constructive ');
fprintf('or destructive interference.\n\n');
