%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
% Lesson  : 14 - Spatial Phase Difference
%
% File    : calculateSpatialPhaseDifference.m
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function phaseDifference = ...
    calculateSpatialPhaseDifference(...
    pathDifference,...
    lambda)

arguments
    pathDifference (1,1) double
    lambda (1,1) double {mustBePositive}
end

phaseDifference = ...
    2*pi*pathDifference/lambda;

end