function H = generate_channel(K, M)
%GENERATE_CHANNEL  Draw a Rayleigh-fading downlink channel realization.
%
%   H = GENERATE_CHANNEL(K, M)
%
%   "The multi-user communications channel obeys a Rayleigh fading model,
%   i.e., the entries of H are i.i.d. standard complex normal random
%   variables" (Section V).
%
%   Inputs:
%     K - number of users
%     M - number of antennas
%
%   Output:
%     H - K x M matrix, entries i.i.d. CN(0,1)
%
%   Author: (auto-generated MATLAB reproduction)
%   Date:   2026

H = (randn(K, M) + 1j * randn(K, M)) / sqrt(2);

end