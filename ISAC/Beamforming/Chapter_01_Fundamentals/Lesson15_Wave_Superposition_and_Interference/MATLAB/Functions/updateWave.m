%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updateWave.m
%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 Fundamentals of Waves
%
% Lesson 15
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wave = updateWave(wave,time)

arguments

    wave struct

    time (1,1) double

end

wave.Time = time;

end