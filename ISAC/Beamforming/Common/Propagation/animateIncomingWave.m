function animateIncomingWave(antennaPositions, arrivalAngle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : animateIncomingWave
%
% Description:
% Animates an incoming plane wave reaching a Uniform Linear Array.
%
% Inputs:
%   antennaPositions - Antenna x coordinates (m)
%   arrivalAngle     - Angle of arrival (degrees)
%
% Version : 2.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure

figure('Color','w');

hold on;
grid on;
axis equal;

xlabel('x (m)');
ylabel('y (m)');

title('Incoming Plane Wave');

%% Draw Array

for k = 1:length(antennaPositions)

    plot(antennaPositions(k),...
         0,...
         'ko',...
         'MarkerFaceColor','b',...
         'MarkerSize',8);

    text(antennaPositions(k),...
         -0.25,...
         sprintf('A%d',k),...
         'HorizontalAlignment','center');

end

%% Wave Parameters

theta = deg2rad(arrivalAngle);

normal = [cos(theta) sin(theta)];

waveLength = max(antennaPositions)+6;

halfLength = 5;

startDistance = 6;
endDistance   = -1;

%% Animation

for d = startDistance:-0.05:endDistance

    cla

    hold on
    grid on
    axis equal

    %% Draw Antennas

    for k = 1:length(antennaPositions)

        plot(antennaPositions(k),...
             0,...
             'ko',...
             'MarkerFaceColor','b',...
             'MarkerSize',8);

        text(antennaPositions(k),...
             -0.25,...
             sprintf('A%d',k),...
             'HorizontalAlignment','center');

    end

    %% Wavefront Centre

    centre = d*normal;

    %% Tangential Direction

    tangent = [-normal(2) normal(1)];

    p1 = centre-halfLength*tangent;

    p2 = centre+halfLength*tangent;

    plot([p1(1) p2(1)],...
         [p1(2) p2(2)],...
         'b',...
         'LineWidth',3);

    %% Propagation Arrow

    quiver(centre(1),...
           centre(2),...
           -normal(1),...
           -normal(2),...
           0.8,...
           'r',...
           'LineWidth',2,...
           'MaxHeadSize',2);

    %% Check Arrival

    for k = 1:length(antennaPositions)

        antenna = [antennaPositions(k) 0];

        distance = dot(antenna-centre,normal);

        if abs(distance)<0.03

            plot(antenna(1),...
                 antenna(2),...
                 'go',...
                 'MarkerFaceColor','g',...
                 'MarkerSize',14);

        end

    end

    xlabel('x (m)');
    ylabel('y (m)');
    title(sprintf('Incoming Plane Wave (AOA = %.0f°)',arrivalAngle));

    xlim([-2 max(antennaPositions)+2]);
    ylim([-3 5]);

    drawnow

end

disp('-------------------------------------')
disp('One transmitted signal')
disp('Different propagation distances')
disp('Different arrival times')
disp('Different phase shifts')
disp('Beamforming starts here.')
disp('-------------------------------------')

end