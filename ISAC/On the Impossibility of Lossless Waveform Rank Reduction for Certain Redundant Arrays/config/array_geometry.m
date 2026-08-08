function arrays = array_geometry()
%ARRAY_GEOMETRY Instantiate the named example array geometries.
%
%   arrays = ARRAY_GEOMETRY() returns a 1x4 struct array with fields
%       .name   - human-readable identifier, e.g. 'Array 1'
%       .Dt     - 1xNt vector of Tx sensor positions (half-wavelength units)
%       .Dr     - 1xNr vector of Rx sensor positions (half-wavelength units)
%       .has_NRS_expected - logical, ground-truth expectation from the
%                           paper's text (used only for validation in
%                           Phase 11, NOT fed into the actual detection
%                           algorithm, which must derive this itself).
%
%   PURPOSE
%       Reproduce, verbatim, the four array geometries discussed in
%       Section III-B and Section IV of the paper:
%           Array 1 (Nt=7,Nr=6,Delta=4): has an NRS -> RSC impossible
%           Array 2 (Nt=7,Nr=6): same co-array as Array 1, no NRS
%           Array 3 (Nt=3): has an NRS {5,6,7} (from prior work [32])
%           Array 4 (Nt=3): same co-array as Array 3, no NRS
%
%   INPUTS
%       None.
%
%   OUTPUTS
%       arrays - 1x4 struct array, see above.
%
%   IMPORTANT IMPLEMENTATION NOTE
%       Arrays 1-4 are HARDCODED as literal integer vectors exactly as
%       given in the paper text, rather than being regenerated purely
%       from the GMA formula (Eq. 11), to avoid transcription drift.
%       Array 1 happens to also be an instance of the GMA family
%       (Eq. 11) with Delta = 4; this is cross-checked via the separate
%       helper function GENERALIZED_MIMO_ARRAY.M (in algorithms/), used
%       for Corollary 1 validation more generally (see Phase 11 tests).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    arrays(1).name = 'Array 1';
    arrays(1).Dt   = [0 4 8 12 16 20 24];   % Section III-B / IV
    arrays(1).Dr   = 0:5;
    arrays(1).has_NRS_expected = true;       % NRS = {3,7,11,15,19,23,27}

    arrays(2).name = 'Array 2';
    arrays(2).Dt   = [0 6 9 12 15 18 24];    % Section III-B / IV
    arrays(2).Dr   = 0:5;
    arrays(2).has_NRS_expected = false;

    arrays(3).name = 'Array 3';
    arrays(3).Dt   = [0 1 2];                % Section III-B
    arrays(3).Dr   = [0 1 2 5];
    arrays(3).has_NRS_expected = true;        % NRS = {5,6,7}

    arrays(4).name = 'Array 4';
    arrays(4).Dt   = [0 1 2];                % same Dt as Array 3
    arrays(4).Dr   = [0 1 3 5];
    arrays(4).has_NRS_expected = false;

end
