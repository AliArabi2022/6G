function [has_NRS, NRS_set, NRS_Rx_sensor] = check_NRS(Dt, Dr, DSigma, upsilon_mult)
%CHECK_NRS Detect a Nonredundant Singleton Subset (NRS), per Definition 2.
%
%   [has_NRS, NRS_set, NRS_Rx_sensor] = CHECK_NRS(Dt, Dr, DSigma, upsilon_mult)
%
%   PURPOSE
%       Determines whether the sum co-array DSigma contains an NRS, as
%       defined in Definition 2. By Theorem 1, if an NRS exists, NO
%       rank-deficient waveform matrix S can satisfy the redundancy
%       subspace condition (RSC, Eq. 6) -- i.e., lossless waveform rank
%       reduction is IMPOSSIBLE for this array geometry.
%
%   DEFINITION 2 RECALLED (Nonredundant Singleton Subset)
%       A subset S_NRS of DSigma is an NRS if:
%         1) |S_NRS| = Nt
%         2) Each element of S_NRS has multiplicity (redundancy) 1
%         3) Each element of S_NRS is the sum of the SAME Rx sensor
%            with one of the Nt Tx sensors (i.e., S_NRS = Dt + d'_r for
%            some fixed d'_r in Dr)
%
%   NOTE ON NON-UNIQUENESS OF THE NRS
%       Definition 2 does not claim the NRS is unique. This function
%       returns the FIRST NRS found, scanning Rx sensors in ascending
%       order of Dr. For example, for Array 1 (Section IV: Nt=7, Nr=6,
%       Dt={0,4,8,12,16,20,24}, Dr={0,...,5}), this function returns
%       the NRS via Rx sensor 2 (NRS_set = {2,6,10,14,18,22,26}), which
%       is a DIFFERENT but equally valid NRS from the one explicitly
%       cited in the paper's text (Rx sensor 3, NRS_set =
%       {3,7,11,15,19,23,27}, matching the supplementary proof of
%       Corollary 1). Both satisfy Definition 2; Theorem 1 only
%       requires EXISTENCE of an NRS, not uniqueness. This was verified
%       numerically (see Phase 11 validation) -- both Rx sensors 2 and
%       3 yield all-multiplicity-1 sums for Array 1.
%
%   ALGORITHM (efficiency note)
%       A brute-force search over all size-Nt subsets of DSigma would be
%       combinatorially infeasible (C(NSigma, Nt) subsets). However,
%       Property 3 means any NRS must take the form {Dt + d'_r} for
%       SOME single Rx sensor d'_r. Since Dt has Nt DISTINCT elements,
%       {Dt + d'_r} automatically has Nt distinct elements for any
%       fixed d'_r (satisfying Property 1 automatically). Hence we only
%       need to check, for each of the Nr candidate Rx sensors d'_r,
%       whether all Nt resulting sums have multiplicity exactly 1
%       (Property 2). This reduces the search to O(Nr * Nt) instead of
%       an exponential subset search.
%
%   INPUTS
%       Dt           - 1xNt vector, Tx sensor positions
%       Dr           - 1xNr vector, Rx sensor positions
%       DSigma       - 1xNSigma vector, sorted sum co-array (from
%                      compute_sum_coarray.m)
%       upsilon_mult - 1xNSigma vector, multiplicity of each DSigma
%                      element (from compute_sum_coarray.m)
%
%   OUTPUTS
%       has_NRS       - logical, true if an NRS exists
%       NRS_set       - 1xNt vector, the NRS elements (sorted), or []
%                       if has_NRS is false
%       NRS_Rx_sensor - scalar, the shared Rx sensor d'_r defining the
%                       NRS (Property 3), or [] if has_NRS is false
%
%   REQUIRED EQUATIONS / DEFINITIONS
%       Definition 2, Theorem 1
%
%   ERROR CHECKING
%       Verifies every Dt(n)+Dr(m) sum is indeed present in DSigma
%       (should always hold if DSigma was produced by
%       compute_sum_coarray.m on the same Dt, Dr) -- surfaces as an
%       explicit error rather than a silent NaN/empty lookup.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    Dt = Dt(:)';
    Dr = Dr(:)';
    Nt = numel(Dt);

    has_NRS = false;
    NRS_set = [];
    NRS_Rx_sensor = [];

    for m = 1:numel(Dr)
        d_prime = Dr(m);
        s = Dt + d_prime; % candidate NRS elements for this Rx sensor

        [found, loc] = ismember(s, DSigma);
        if ~all(found)
            error('check_NRS:sumNotInCoarray', ...
                ['Sum %g (Tx sensor + Rx sensor %g) not found in DSigma. ' ...
                 'DSigma must be the sum co-array of the SAME Dt, Dr ' ...
                 'passed to this function.'], s(find(~found,1)), d_prime);
        end

        mult_here = upsilon_mult(loc);

        if all(mult_here == 1)
            % Property 1: |s|==Nt guaranteed since Dt has Nt distinct
            % elements and adding a constant preserves distinctness.
            % Property 2: verified by all(mult_here==1) above.
            % Property 3: satisfied by construction (fixed d_prime).
            has_NRS = true;
            NRS_set = sort(s);
            NRS_Rx_sensor = d_prime;
            return;
        end
    end

end
