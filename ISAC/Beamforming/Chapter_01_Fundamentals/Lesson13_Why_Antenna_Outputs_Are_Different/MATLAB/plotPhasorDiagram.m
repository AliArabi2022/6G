function plotPhasorDiagram(phaseDifferences)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : plotPhasorDiagram
%
% Description:
% Visualizes the phase of the received signal at each antenna
% using a phasor diagram.
%
% Inputs:
%   phaseDifferences - Phase of each antenna (degrees)
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure

figure('Color','w');

hold on;
grid on;
axis equal;

title('Received Signal Phases');

xlabel('In-Phase');
ylabel('Quadrature');

%% Unit Circle

theta = linspace(0,2*pi,500);

plot(cos(theta),...
     sin(theta),...
     'k',...
     'LineWidth',1.5);

%% Axes

plot([-1.2 1.2],[0 0],'k:');

plot([0 0],[-1.2 1.2],'k:');

%% Draw Phasors

numberOfAntennas = length(phaseDifferences);

colors = lines(numberOfAntennas);

for k = 1:numberOfAntennas

    phi = deg2rad(phaseDifferences(k));

    x = cos(phi);

    y = sin(phi);

    quiver(0,...
           0,...
           x,...
           y,...
           0,...
           'Color',colors(k,:),...
           'LineWidth',2,...
           'MaxHeadSize',0.4);

    plot(x,...
         y,...
         'o',...
         'MarkerFaceColor',colors(k,:),...
         'MarkerEdgeColor','k',...
         'MarkerSize',8);

    text(1.08*x,...
         1.08*y,...
         sprintf('A%d',k),...
         'FontWeight','bold');

end

%% Labels

text(1.05,0,'0°');

text(0,1.08,'90°',...
    'HorizontalAlignment','center');

text(-1.08,0,'180°',...
    'HorizontalAlignment','center');

text(0,-1.12,'270°',...
    'HorizontalAlignment','center');

legendStrings = strings(numberOfAntennas,1);

for k = 1:numberOfAntennas

    legendStrings(k)=sprintf('A%d',k);

end

legend(legendStrings,...
       'Location','eastoutside');

xlim([-1.3 1.6]);

ylim([-1.3 1.3]);

set(gca,'FontSize',12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Educational Message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(" ");
disp("Every antenna receives");
disp("the SAME sinusoidal signal.");
disp(" ");
disp("The only difference");
disp("is the PHASE.");
disp(" ");
disp("Beamforming exploits");
disp("these phase differences.");

end