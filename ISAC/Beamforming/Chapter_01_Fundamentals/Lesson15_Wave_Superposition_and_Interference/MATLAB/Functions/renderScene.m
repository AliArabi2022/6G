%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% renderScene.m
%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 Fundamentals of Waves
%
% Lesson : 15
%
% Description
% Render both waves and their superposition.
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function renderScene( ...
    wave1,...
    wave2,...
    x)

arguments

    wave1 struct

    wave2 struct

    x (1,:) double

end

y1 = calculateWave( ...
    wave1,...
    x);

y2 = calculateWave( ...
    wave2,...
    x);

y = calculateSuperposition( ...
    wave1,...
    wave2,...
    x);

clf

subplot(3,1,1)

renderWave( ...
    x,...
    y1,...
    wave1);

grid on

ylim([-2.2 2.2])

title('Wave 1')

ylabel('Amplitude')

subplot(3,1,2)

renderWave( ...
    x,...
    y2,...
    wave2);

grid on

ylim([-2.2 2.2])

title('Wave 2')

ylabel('Amplitude')

subplot(3,1,3)

plot( ...
    x,...
    y,...
    'k',...
    'LineWidth',2.5);

grid on

ylim([-2.2 2.2])

xlabel('Position')

ylabel('Amplitude')

title('Superposition')

drawnow

end