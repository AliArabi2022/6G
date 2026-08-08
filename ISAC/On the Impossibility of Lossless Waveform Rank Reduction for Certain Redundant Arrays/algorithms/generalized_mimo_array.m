function [Dt, Dr] = generalized_mimo_array(Nt, Nr, Delta)
%GENERALIZED_MIMO_ARRAY Construct a GMA per Eq. (11) of the paper.
%
%   [Dt, Dr] = GENERALIZED_MIMO_ARRAY(Nt, Nr, Delta) returns the Tx and
%   Rx sensor position sets for the Generalized MIMO Array (GMA) family:
%       Dt = {0, Delta, ..., (Nt-1)*Delta}
%       Dr = {0, 1, ..., Nr-1}
%
%   PURPOSE
%       Provide a general, parametric constructor for the GMA family
%       introduced in Section III-B, used to instantiate array
%       geometries beyond the four hardcoded examples, and to validate
%       Corollary 1 numerically (Phase 11).
%
%   INPUTS
%       Nt    - number of Tx sensors (positive integer scalar)
%       Nr    - number of Rx sensors (positive integer scalar)
%       Delta - user-defined positive integer spacing (Eq. 11),
%               constrained by the paper to satisfy Delta <= Nr.
%
%   OUTPUTS
%       Dt - 1xNt vector, Tx sensor positions (half-wavelength units)
%       Dr - 1xNr vector, Rx sensor positions (half-wavelength units)
%
%   THEORY
%       By Corollary 1, if Nr/2 < Delta < Nr, the resulting sum
%       co-array contains a nonredundant singleton subset (NRS) and
%       therefore the redundancy subspace condition (RSC, Eq. 6)
%       cannot be satisfied by any rank-deficient waveform matrix S.
%
%   ERROR CHECKING
%       Validates that all inputs are positive integers and that
%       Delta <= Nr, per the explicit constraint stated below Eq. (11).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    validateattributes(Nt, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'Nt');
    validateattributes(Nr, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'Nr');
    validateattributes(Delta, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'Delta');

    if Delta > Nr
        error('generalized_mimo_array:invalidDelta', ...
            'Eq. (11) requires Delta <= Nr, got Delta=%d, Nr=%d.', ...
            Delta, Nr);
    end

    Dt = (0:Nt-1) * Delta;
    Dr = 0:(Nr-1);

end
