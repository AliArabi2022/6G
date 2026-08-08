function antennaPositions = createLinearArray( ...
                                    numberOfAntennas, ...
                                    antennaSpacing)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function: createLinearArray
%
% Description:
% Creates and visualizes a Uniform Linear Array (ULA).
%
% Inputs:
%   numberOfAntennas - Number of antenna elements
%   antennaSpacing   - Distance between adjacent antennas (m)
%
% Output:
%   antennaPositions - x-coordinates of antenna elements
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate Antenna Positions

antennaPositions = (0:numberOfAntennas-1) * antennaSpacing;

%% Visualization

figure('Color','w');

hold on;
grid on;
axis equal;

for k = 1:numberOfAntennas

    plot(antennaPositions(k), ...
         0, ...
         'ko', ...
         'MarkerFaceColor','b', ...
         'MarkerSize',8);

    text(antennaPositions(k), ...
         -0.08, ...
         sprintf('A%d',k), ...
         'HorizontalAlignment','center', ...
         'FontSize',10);

end

xlabel('Distance (m)');
ylabel('Array Axis');

title('Uniform Linear Array (ULA)');

xlim([-antennaSpacing ...
      antennaPositions(end)+antennaSpacing]);

ylim([-0.3 0.3]);

set(gca,'FontSize',12);

end