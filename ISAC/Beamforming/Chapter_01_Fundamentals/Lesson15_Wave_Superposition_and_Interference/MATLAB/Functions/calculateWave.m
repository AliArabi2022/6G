%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculateWave.m
%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 Fundamentals of Waves
%
% Lesson 15
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = calculateWave(wave,x)

arguments

    wave struct

    x (1,:) double

end

t = wave.Time;

switch lower(wave.Type)

    case "sine"

        if strcmpi(wave.Direction,"Right")

            y = wave.Amplitude .* ...
                sin( ...
                wave.WaveNumber .* x ...
                - wave.AngularFrequency .* t ...
                + wave.Phase);

        else

            y = wave.Amplitude .* ...
                sin( ...
               -wave.WaveNumber .* x ...
                -wave.AngularFrequency .* t ...
                +wave.Phase);

        end

    case "gaussian"

        width = 1.2;

        if strcmpi(wave.Direction,"Right")

            center = -8 + wave.Velocity*t;

        else

            center = 8 - wave.Velocity*t;

        end

        envelope = ...
            exp( ...
            -((x-center).^2) ...
            /(2*width^2));

        carrier = ...
            cos( ...
            wave.WaveNumber.*(x-center) ...
            + wave.Phase);

        y = ...
            wave.Amplitude ...
            .* envelope ...
            .* carrier;

    otherwise

        error("Unsupported wave type.")

end

end