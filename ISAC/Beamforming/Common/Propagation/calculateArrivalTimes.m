function arrivalTimes = calculateArrivalTimes( ...
                                antennaPositions,...
                                arrivalAngle,...
                                propagationSpeed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : calculateArrivalTimes
%
% Description:
% Calculates the arrival time of an incoming plane wave at each
% antenna element of a Uniform Linear Array (ULA).
%
% Inputs:
%   antennaPositions - Antenna x coordinates (m)
%   arrivalAngle     - Angle of arrival (degrees)
%   propagationSpeed - Wave propagation speed (m/s)
%
% Output:
%   arrivalTimes     - Arrival time at each antenna (s)
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Convert Angle

theta = deg2rad(arrivalAngle);

%% Project Antenna Positions onto Wave Direction

pathDifference = antennaPositions .* cos(theta);

%% Arrival Times

arrivalTimes = pathDifference ./ propagationSpeed;

%% Shift First Arrival to Zero

arrivalTimes = arrivalTimes - min(arrivalTimes);

%% Display Results

fprintf('\n');
fprintf('=============================================\n');
fprintf('          Wave Arrival Times\n');
fprintf('=============================================\n');

fprintf('%8s %18s\n','Antenna','Arrival Time (ns)');
fprintf('---------------------------------------------\n');

for k = 1:length(arrivalTimes)

    fprintf('A%-7d %12.3f\n', ...
        k, ...
        arrivalTimes(k)*1e9);

end

fprintf('---------------------------------------------\n');

end