function H = generate_channel(K, Nt)
%GENERATE_CHANNEL Generate one Monte Carlo realization of the Rayleigh comm. channel.
%
%   H = GENERATE_CHANNEL(K, Nt) generates the K x Nt communication
%   channel matrix H with i.i.d. standard complex Gaussian entries
%   (Sec. V: "the entries of H are i.i.d. standard complex normal
%   random variables"), i.e. each entry ~ CN(0,1).
%
%   Inputs:
%       K  : scalar, number of communication users
%       Nt : scalar, number of transmit antennas
%
%   Outputs:
%       H : K x Nt complex, i.i.d. CN(0,1) entries
%
%   Author: Ali Arabi Bavil
%   Date:   2026-07-03
%
%   PITFALL (Phase 5 Module 2): the 1/sqrt(2) normalization on the
%   real/imaginary parts is REQUIRED for unit average power per
%   complex entry (E|H_ij|^2 = 1). Omitting it silently doubles the
%   average channel gain and biases every downstream SINR/CRB number.

    validateattributes(K, {'numeric'}, {'scalar','positive','integer'});
    validateattributes(Nt, {'numeric'}, {'scalar','positive','integer'});

    H = (randn(K, Nt) + 1i*randn(K, Nt)) / sqrt(2);
end
