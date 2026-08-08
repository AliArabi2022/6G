function [time, receivedSignals] = generateReceivedSignals( ...
                                    arrivalTimes, ...
                                    frequency)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : generateReceivedSignals
%
% Description:
% Generates the received sinusoidal signal at each antenna based on
% its arrival time.
%
% Inputs:
%   arrivalTimes - Arrival times of the wave (s)
%   frequency    - Signal frequency (Hz)
%
% Outputs:
%   time             - Time vector (s)
%   receivedSignals  - Matrix containing received signals
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Simulation Parameters

samplingFrequency = 100 * frequency;

numberOfCycles = 5;

signalPeriod = 1 / frequency;

simulationTime = numberOfCycles * signalPeriod;

time = 0 : 1/samplingFrequency : simulationTime;

%% Generate Signals

numberOfAntennas = length(arrivalTimes);

receivedSignals = zeros(numberOfAntennas, length(time));

for k = 1:numberOfAntennas

    receivedSignals(k,:) = ...
        sin(2*pi*frequency*(time - arrivalTimes(k)));

end

%% Display Information

fprintf("\n");
fprintf("=============================================\n");
fprintf(" Generated Received Signals\n");
fprintf("=============================================\n");

for k = 1:numberOfAntennas

    fprintf("Antenna %d\n",k);

    fprintf("Arrival Time : %.3f ns\n", ...
        arrivalTimes(k)*1e9);

    fprintf("Time Delay   : %.3f ns\n\n", ...
        arrivalTimes(k)*1e9);

end

fprintf("Observation:\n");
fprintf("All antennas receive the SAME waveform.\n");
fprintf("Only the arrival time is different.\n");
fprintf("---------------------------------------------\n");

end