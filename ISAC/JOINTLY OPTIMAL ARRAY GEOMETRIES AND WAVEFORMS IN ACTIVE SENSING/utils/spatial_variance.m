function chi = spatial_variance(D)
%SPATIAL_VARIANCE Computes chi(D), the "spatial variance" of an array
% geometry D, defined in the paper (eq. 3) as the mean squared distance
% of the sensor positions from their centroid:
%
%   chi(D) = (1/|D|) * sum_{d in D} (d - mean(D))^2
%
% This is the central quantity in the paper: the single-target CRB on
% the angle omega is shown to be inversely proportional to
% chi(D_t) + chi(D_r) under the optimal (coherent beamforming) waveform.
%
% Inputs:
%   D - 1xN (or Nx1) vector of real-valued sensor positions
%
% Outputs:
%   chi - scalar, the spatial variance of D
%
% Equation reference: eq. (3) in the paper.
%
% Numerical notes:
%   - No numerical instability expected; D is always a small finite
%     integer vector in this project (sensor position sets).
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    D = D(:);
    if isempty(D)
        error('spatial_variance:emptyInput', 'D must be non-empty.');
    end
    d_bar = mean(D);
    chi = mean((D - d_bar).^2);

end
