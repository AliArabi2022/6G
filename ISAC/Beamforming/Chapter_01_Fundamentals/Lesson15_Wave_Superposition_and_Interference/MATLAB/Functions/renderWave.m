%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% renderWave.m
%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 Fundamentals of Waves
%
% Lesson : 15
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function renderWave( ...
    x,...
    y,...
    wave)

arguments

    x (1,:) double

    y (1,:) double

    wave struct

end

plot( ...
    x,...
    y,...
    'Color',wave.Color,...
    'LineWidth',wave.LineWidth);

end