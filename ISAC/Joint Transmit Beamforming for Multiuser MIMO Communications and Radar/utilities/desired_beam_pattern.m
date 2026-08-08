function d = desired_beam_pattern(theta_grid_deg, target_dirs_deg, beamwidth_deg)
%DESIRED_BEAM_PATTERN  Piecewise ideal beam pattern d(theta), eq. (45).
%
%   d = DESIRED_BEAM_PATTERN(theta_grid_deg, target_dirs_deg, beamwidth_deg)
%
%   Implements:
%       d(theta) = 1,  if theta_p - Delta/2 <= theta <= theta_p + Delta/2
%                       for some p = 1,...,P
%                  0,  otherwise
%
%   Inputs:
%     theta_grid_deg   - 1xL vector of angle grid points (degrees)
%     target_dirs_deg  - 1xP vector of target directions theta_p (degrees)
%     beamwidth_deg    - scalar Delta, width of each ideal beam (degrees)
%
%   Output:
%     d - 1xL row vector, d(theta_l) in {0,1}
%
%   Equation reference: (45).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

if ~isvector(theta_grid_deg)
    error('desired_beam_pattern:invalidGrid', 'theta_grid_deg must be a vector.');
end
if ~isvector(target_dirs_deg)
    error('desired_beam_pattern:invalidTargets', 'target_dirs_deg must be a vector.');
end
if ~isscalar(beamwidth_deg) || beamwidth_deg <= 0
    error('desired_beam_pattern:invalidWidth', 'beamwidth_deg must be a positive scalar.');
end

theta_grid_deg  = theta_grid_deg(:).';     % 1xL
target_dirs_deg = target_dirs_deg(:);      % Px1

half_width = beamwidth_deg / 2;

% Broadcast compare: PxL logical matrix, any-across-P collapses to 1xL
in_beam = abs(theta_grid_deg - target_dirs_deg) <= half_width; % Px L

d = double(any(in_beam, 1));   % 1xL

end