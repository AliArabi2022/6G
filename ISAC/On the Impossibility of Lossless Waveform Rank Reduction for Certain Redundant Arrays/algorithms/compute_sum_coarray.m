function [DSigma, NSigma, upsilon_mult, is_contiguous] = compute_sum_coarray(Dt, Dr)
%COMPUTE_SUM_COARRAY Compute the sum co-array of a Tx-Rx array pair.
%
%   [DSigma, NSigma, upsilon_mult, is_contiguous] = ...
%       COMPUTE_SUM_COARRAY(Dt, Dr)
%
%   PURPOSE
%       Implements Eq. (4): DSigma = Dt + Dr (Minkowski sum of Tx and Rx
%       sensor position sets), and additionally computes each element's
%       multiplicity (redundancy count), which is needed by
%       check_NRS.m (Definition 2, Property 2) and useful diagnostic
%       output in its own right.
%
%   INPUTS
%       Dt - 1xNt vector of Tx sensor positions (integers, half-wavelength
%            units)
%       Dr - 1xNr vector of Rx sensor positions (integers, half-wavelength
%            units)
%
%   OUTPUTS
%       DSigma        - 1xNSigma vector, sorted unique sum co-array
%                       elements (Eq. 4)
%       NSigma        - scalar, number of unique elements, |DSigma|
%       upsilon_mult  - 1xNSigma vector, multiplicity upsilon(dSigma) of
%                       each co-array element (i.e., how many (dt,dr)
%                       pairs sum to it) -- this is the "redundancy" of
%                       that virtual sensor, as used in Definition 2.
%       is_contiguous - logical, true if DSigma consists of consecutive
%                       integers (the assumption underlying Lemma 1 /
%                       Theorem 1 as stated; see Section II and
%                       footnote 2).
%
%   REQUIRED EQUATIONS
%       Eq. (4): DSigma = Dt + Dr = {dt + dr | dt in Dt; dr in Dr}
%
%   ERROR CHECKING
%       Validates Dt, Dr are non-empty integer-valued numeric vectors.
%       Issues a WARNING (not an error) if the resulting co-array is
%       not contiguous, since the paper's main theorems assume
%       contiguity but the geometry itself is still well-defined
%       without it.
%
%   EXPECTED NUMERICAL BEHAVIOR
%       Pure integer arithmetic -- no floating point issues. NSigma
%       satisfies Nt <= NSigma <= Nt*Nr (lower bound assumes Dr fixed
%       cardinality reasoning is not tight in general, but NSigma is
%       always <= Nt*Nr, with equality iff the array is nonredundant).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    validateattributes(Dt, {'numeric'}, {'vector','integer'}, mfilename, 'Dt');
    validateattributes(Dr, {'numeric'}, {'vector','integer'}, mfilename, 'Dr');

    Dt = Dt(:); % Nt x 1
    Dr = Dr(:)'; % 1 x Nr

    all_sums = Dt + Dr; % Nt x Nr matrix of all pairwise sums (broadcasting)

    [DSigma, ~, ic] = unique(all_sums(:)'); % sorted unique row vector
    NSigma = numel(DSigma);

    % Multiplicity: count how many (dt,dr) pairs map to each unique value.
    upsilon_mult = accumarray(ic, 1)';

    % Sanity check: multiplicities must sum to Nt*Nr (every pair counted once)
    Nt = numel(Dt);
    Nr = numel(Dr);
    assert(sum(upsilon_mult) == Nt*Nr, ...
        'compute_sum_coarray:internalError', ...
        'Multiplicity sum (%d) does not match Nt*Nr (%d). This indicates a bug.', ...
        sum(upsilon_mult), Nt*Nr);

    is_contiguous = all(diff(DSigma) == 1);

    if ~is_contiguous
        warning('compute_sum_coarray:nonContiguous', ...
            ['Sum co-array is NOT contiguous. Lemma 1 and Theorem 1, as ' ...
             'stated in the paper, assume a contiguous sum co-array ' ...
             '(Section II); the redundancy subspace condition (Eq. 6) ' ...
             'remains NECESSARY but not proven SUFFICIENT in the ' ...
             'noncontiguous case (see paper footnote 2).']);
    end

end
