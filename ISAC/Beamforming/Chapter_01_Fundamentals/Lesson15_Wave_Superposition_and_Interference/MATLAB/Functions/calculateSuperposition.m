%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculateSuperposition.m
%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson : 15
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = calculateSuperposition(wave1, wave2, x)

arguments
    wave1 struct
    wave2 struct
    x (1,:) double
end

y1 = calculateWave(wave1, x);

y2 = calculateWave(wave2, x);

y = y1 + y2;

end