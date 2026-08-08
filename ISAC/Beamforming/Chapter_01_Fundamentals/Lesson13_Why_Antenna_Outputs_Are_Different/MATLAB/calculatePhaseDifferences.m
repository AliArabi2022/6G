function phaseDifferences = calculatePhaseDifferences( ...
                                arrivalTimes, ...
                                frequency)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : calculatePhaseDifferences
%
% Description:
% Calculates the phase difference at each antenna caused by
% different wave arrival times.
%
% Inputs:
%   arrivalTimes - Wave arrival times (s)
%   frequency    - Signal frequency (Hz)
%
% Output:
%   phaseDifferences - Phase difference (degrees)
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Calculate Phase Difference

phaseDifferences = 360 * frequency .* arrivalTimes;

%% Wrap Phase to [0,360)

phaseDifferences = mod(phaseDifferences,360);

%% Display Results

fprintf('\n');
fprintf('=========================================================\n');
fprintf('        Phase Difference at Each Antenna\n');
fprintf('=========================================================\n');

fprintf('%8s %18s %18s\n', ...
        'Antenna', ...
        'Delay (ns)', ...
        'Phase (deg)');

fprintf('---------------------------------------------------------\n');

for k = 1:length(arrivalTimes)

    fprintf('A%-7d %14.3f %16.2f\n', ...
        k, ...
        arrivalTimes(k)*1e9, ...
        phaseDifferences(k));

end

fprintf('---------------------------------------------------------\n');

%% Educational Explanation

disp(" ");
disp("Why are the phases different?");
disp(" ");

pause(2)

disp("Different propagation distances");

pause(2)

disp("          ↓");

pause(1)

disp("Different arrival times");

pause(2)

disp("          ↓");

pause(1)

disp("Different time delays");

pause(2)

disp("          ↓");

pause(1)

disp("Different phase shifts");

pause(2)

disp("          ↓");

pause(1)

disp("Different antenna outputs");

pause(2)

disp("          ↓");

pause(1)

disp("Beamforming");

fprintf('\n');

%% Phase Formula

disp("---------------------------------------------");
disp("Phase Difference Equation");
disp("---------------------------------------------");

fprintf('\n');

disp("Phase = 360 × Frequency × Delay");

fprintf('\n');

fprintf("or\n\n");

disp("Δφ = 360 × f × Δt");

fprintf('\n');

disp("Since");

fprintf('\n');

disp("Δt = Δd / c");

fprintf('\n');

disp("Therefore");

fprintf('\n');

disp("Δφ = 360 × Δd / λ");

fprintf('\n');

disp("---------------------------------------------");

end