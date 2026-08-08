%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
% Lesson  : 14 - Spatial Phase Difference
%
% File    : createTwoElementArray.m
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function antennaPositions = createTwoElementArray(d)

arguments
    d (1,1) double {mustBePositive}
end

antennaPositions = [0 d];

end