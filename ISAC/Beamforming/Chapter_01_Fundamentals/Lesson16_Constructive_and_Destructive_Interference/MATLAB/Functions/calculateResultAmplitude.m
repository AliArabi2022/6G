function amplitude = calculateResultAmplitude(phaseDifference)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% calculateResultAmplitude
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Calculates the resultant amplitude for two waves with
% equal amplitudes as a function of phase difference.
%
% Inputs:
%   phaseDifference    Phase difference (radians).
%
% Outputs:
%   amplitude          Resultant amplitude.
%
% Version:
% 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

amplitude = 2 .* abs(cos(phaseDifference ./ 2));

end