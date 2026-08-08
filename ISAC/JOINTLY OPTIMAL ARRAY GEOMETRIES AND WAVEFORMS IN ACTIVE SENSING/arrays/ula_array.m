function [D_t, D_r] = ula_array(Nt, Nr)
%ULA_ARRAY Constructs the Fig. 1(c) comparison geometry: a conventional
% (colocated) Uniform Linear Array, used as the classical baseline with
% "significantly higher CRB ... due to its smaller spatial variance."
%
% Assumption (figure legend/text did not give explicit position sets for
% this panel; reconstructed as the standard textbook baseline):
%   Both Tx and Rx elements occupy a single shared unit-spacing ULA of
%   Nt+Nr total sensors: positions 0, 1, ..., Nt+Nr-1, split so that
%   D_t is the first Nt positions and D_r the remaining Nr positions.
%   This is the conventional "phased array" configuration the paper
%   contrasts against the sparse Tx-Rx design.
%
% Inputs:
%   Nt - number of Tx sensors
%   Nr - number of Rx sensors
%
% Outputs:
%   D_t - 1xNt vector, Tx positions (unit-spacing ULA segment)
%   D_r - 1xNr vector, Rx positions (unit-spacing ULA segment)
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    if ~(isscalar(Nt) && Nt > 0 && Nt == floor(Nt))
        error('ula_array:invalidNt', 'Nt must be a positive integer.');
    end
    if ~(isscalar(Nr) && Nr > 0 && Nr == floor(Nr))
        error('ula_array:invalidNr', 'Nr must be a positive integer.');
    end

    
    D_t = index_set(Nt);
    D_r = index_set(Nr);
    

end
