%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% createWave.m
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wave = createWave(varargin)

p = inputParser;

addParameter(p,"Type","Sine");
addParameter(p,"Amplitude",1);
addParameter(p,"Frequency",1);
addParameter(p,"Phase",0);
addParameter(p,"Velocity",1);
addParameter(p,"Direction","Right");
addParameter(p,"Color",[0 0.4470 0.7410]);
addParameter(p,"LineWidth",2);

parse(p,varargin{:});

wave = p.Results;

wave.AngularFrequency = ...
    2*pi*wave.Frequency;

wave.WaveNumber = ...
    wave.AngularFrequency / wave.Velocity;

end