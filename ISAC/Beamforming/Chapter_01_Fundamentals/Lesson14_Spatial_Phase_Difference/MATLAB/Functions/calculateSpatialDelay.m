%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
% Lesson  : 14 - Spatial Phase Difference
%
% File    : calculateSpatialDelay.m
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pathDifference,timeDelay] = ...
    calculateSpatialDelay(d,theta,c)

arguments
    d (1,1) double
    theta (1,1) double
    c (1,1) double
end

theta = deg2rad(theta);

pathDifference = d*cos(theta);

timeDelay = pathDifference/c;

end