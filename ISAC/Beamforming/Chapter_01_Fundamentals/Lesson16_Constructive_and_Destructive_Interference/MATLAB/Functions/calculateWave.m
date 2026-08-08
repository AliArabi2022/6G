function y = calculateWave(x, wave, time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% calculateWave
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Calculates a travelling sinusoidal wave.
%
% Inputs:
%   x       Spatial coordinate.
%   wave    Wave structure.
%   time    Current simulation time.
%
% Outputs:
%   y       Wave amplitude.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Wave Number

k = 2*pi*wave.frequency / wave.velocity;

%% Angular Frequency

omega = 2*pi*wave.frequency;

%% Travelling Wave

y = wave.amplitude .* cos( ...
    k .* (x - wave.direction .* wave.velocity .* time) ...
    + wave.phase);

end