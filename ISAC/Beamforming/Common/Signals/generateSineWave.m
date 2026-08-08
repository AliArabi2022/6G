function signal = generateSineWave(amplitude, frequency, phase, time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : generateSineWave
%
% Description:
% Generates a sinusoidal waveform.
%
% Inputs:
%   amplitude  - Signal amplitude
%   frequency  - Signal frequency (Hz)
%   phase      - Initial phase (rad)
%   time       - Time vector (s)
%
% Output:
%   signal     - Generated sinusoidal waveform
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

signal = amplitude .* sin(2*pi*frequency*time + phase);

end