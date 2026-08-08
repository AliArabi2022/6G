%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Lesson 14
%
% File : animateWaveArrival.m
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function animateWaveArrival( ...
    antennaPosition,...
    arrivalAngle,...
    pathDifference,...
    timeDelay,...
    phaseDifference)

arguments
    antennaPosition (1,:) double
    arrivalAngle (1,1) double
    pathDifference (1,1) double
    timeDelay (1,1) double
    phaseDifference (1,1) double
end

theta = deg2rad(arrivalAngle);

%% Propagation Direction

k = [cos(theta) -sin(theta)];

%% Wavefront Direction (Perpendicular)

n = [-k(2) k(1)];

figure('Color','w');

for s = -1.2:0.03:1.2

    clf
    hold on
    grid on
    axis equal

    title('Wave Arrival Animation')

    xlim([-1 1])
    ylim([-0.8 0.8])

    %% Wavefront

    center = s*k;

    p1 = center + 1.5*n;
    p2 = center - 1.5*n;

    plot([p1(1) p2(1)],...
         [p1(2) p2(2)],...
         'b',...
         'LineWidth',3);

    %% Propagation Arrow

    quiver(-0.8,...
            0.55,...
            k(1)*0.35,...
            k(2)*0.35,...
            0,...
            'r',...
            'LineWidth',2);

    %% Antennas

    plot(antennaPosition,...
        [0 0],...
        'ko',...
        'MarkerFaceColor','r',...
        'MarkerSize',10);

    text(antennaPosition(1),...
        -0.08,...
        'Antenna 1',...
        'HorizontalAlignment','center');

    text(antennaPosition(2),...
        -0.08,...
        'Antenna 2',...
        'HorizontalAlignment','center');

    %% Information

    text(-0.95,0.72,...
        sprintf('Arrival Angle = %.1f°',arrivalAngle));

    text(-0.95,0.63,...
        sprintf('Path Difference = %.4f m',pathDifference));

    text(-0.95,0.54,...
        sprintf('Time Delay = %.3e s',timeDelay));

    text(-0.95,0.45,...
        sprintf('Phase Difference = %.1f°', ...
        rad2deg(phaseDifference)));

    drawnow

end

end