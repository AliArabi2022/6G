function animatePhasorDiagram(phaseDifferences, frequency)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : animatePhasorDiagram
%
% Description:
% Animates the rotating phasors corresponding to the received
% signals at each antenna.
%
% Inputs:
%   phaseDifferences - Initial phase of each antenna (degrees)
%   frequency        - Signal frequency (Hz)
%
% Version : 2.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameters

omega = 2*pi*frequency;

numberOfAntennas = length(phaseDifferences);

colors = lines(numberOfAntennas);

%% Figure

figure('Color','w');

hold on
grid on
axis equal

xlabel('In-Phase')
ylabel('Quadrature')

title('Rotating Phasors')

%% Unit Circle

theta = linspace(0,2*pi,500);

plot(cos(theta),...
     sin(theta),...
     'k',...
     'LineWidth',1.5);

plot([-1.2 1.2],[0 0],'k:')
plot([0 0],[-1.2 1.2],'k:')

%% Create Phasors

phasorLine = gobjects(numberOfAntennas,1);
phasorTip  = gobjects(numberOfAntennas,1);

for k=1:numberOfAntennas

    phasorLine(k)=plot([0 0],[0 0],...
        'LineWidth',2,...
        'Color',colors(k,:));

    phasorTip(k)=plot(0,0,'o',...
        'MarkerFaceColor',colors(k,:),...
        'MarkerEdgeColor','k',...
        'MarkerSize',8);

end

xlim([-1.3 1.3])
ylim([-1.3 1.3])

%% Animation

simulationTime = 2/frequency;

frameRate = 80;

time = linspace(0,...
                simulationTime,...
                frameRate);

for t=time

    for k=1:numberOfAntennas

        phi = omega*t + deg2rad(phaseDifferences(k));

        x = cos(phi);

        y = sin(phi);

        set(phasorLine(k),...
            'XData',[0 x],...
            'YData',[0 y]);

        set(phasorTip(k),...
            'XData',x,...
            'YData',y);

    end

    drawnow

end

disp("Animation Finished")
disp("-------------------")
disp("Notice:")
disp("All phasors rotate")
disp("with the SAME speed.")
disp(" ")
disp("Only their")
disp("initial phase")
disp("is different.")
disp(" ")
disp("This constant")
disp("phase difference")
disp("contains the")
disp("direction information.")
disp(" ")
disp("Beamforming estimates")
disp("or exploits")
disp("these phase differences.")

end