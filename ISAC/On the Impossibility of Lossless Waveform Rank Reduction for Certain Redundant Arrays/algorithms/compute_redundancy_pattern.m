function [Upsilon, I_ell] = compute_redundancy_pattern(Dt, Dr, DSigma)
%COMPUTE_REDUNDANCY_PATTERN Compute the redundancy pattern matrix Upsilon.
%
%   [Upsilon, I_ell] = COMPUTE_REDUNDANCY_PATTERN(Dt, Dr, DSigma)
%
%   PURPOSE
%       Implements Definition 1 (Eq. 5): the (i,ell)-th entry of the
%       redundancy pattern matrix Upsilon is 1 if Tx-Rx sensor pair i
%       (linearized as i = m + (n-1)*Nr) contributes to virtual sensor
%       ell (i.e., dt[n] + dr[m] = dSigma[ell]), and 0 otherwise.
%
%       Also returns I_ell (Eq. 9), the explicit set of (n,m) Tx-Rx
%       index pairs contributing to each virtual sensor ell, needed by
%       check_NRS.m and useful for validating Eq. (10) (Phase 11).
%
%   INPUTS
%       Dt     - 1xNt vector, Tx sensor positions
%       Dr     - 1xNr vector, Rx sensor positions
%       DSigma - 1xNSigma vector, sorted unique sum co-array elements
%                (output of compute_sum_coarray.m)
%
%   OUTPUTS
%       Upsilon - (Nt*Nr) x NSigma sparse binary matrix (Eq. 5)
%       I_ell   - NSigma x 1 cell array; I_ell{ell} is a Kx2 matrix of
%                 [n, m] index pairs (1-based) satisfying
%                 dt[n] + dr[m] = DSigma(ell)  (Eq. 9)
%
%   REQUIRED EQUATIONS
%       Eq. (5):  Upsilon_{i,ell} definition, i = i[n,m] = m + (n-1)*Nr
%       Eq. (9):  I_ell definition
%
%   IMPLEMENTATION NOTE -- INDEXING CONVENTION (CRITICAL)
%       The linear index i = m + (n-1)*Nr means the Rx index m varies
%       FASTEST. This must be consistent with how S is later combined
%       via kron(S, eye(Nr)) in compute_W.m, since MATLAB's kron(A,B)
%       also varies the index of B (here, eye(Nr), i.e., m) fastest
%       within each block-row of A. This consistency is unit-tested in
%       Phase 11 (validate_kron_ordering test).
%
%   COMPLEXITY
%       O(Nt*Nr) using a value-to-index hash map (containers.Map),
%       avoiding the naive O(Nt*Nr*NSigma) triple loop with find().
%
%   ERROR CHECKING
%       Asserts that every (n,m) pair is assigned to exactly one column
%       of Upsilon (guaranteed by construction, but checked defensively).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    validateattributes(Dt, {'numeric'}, {'vector','integer'}, mfilename, 'Dt');
    validateattributes(Dr, {'numeric'}, {'vector','integer'}, mfilename, 'Dr');
    validateattributes(DSigma, {'numeric'}, {'vector','integer'}, mfilename, 'DSigma');

    Dt = Dt(:)';
    Dr = Dr(:)';
    Nt = numel(Dt);
    Nr = numel(Dr);
    NSigma = numel(DSigma);

    % Build value -> column-index map for O(1) lookup (Eq. 5 requires
    % locating dSigma[ell] for each dt[n]+dr[m]).
    valueToCol = containers.Map('KeyType', 'double', 'ValueType', 'double');
    for ell = 1:NSigma
        valueToCol(DSigma(ell)) = ell;
    end

    rows = zeros(Nt*Nr, 1);
    cols = zeros(Nt*Nr, 1);
    I_ell = cell(NSigma, 1);

    idx = 0;
    for n = 1:Nt
        for m = 1:Nr
            idx = idx + 1;
            i_lin = m + (n-1)*Nr;      % Eq. (5) linear index convention
            s = Dt(n) + Dr(m);

            if ~isKey(valueToCol, s)
                error('compute_redundancy_pattern:missingSum', ...
                    ['Sum dt[%d]+dr[%d]=%d not found in DSigma. DSigma ' ...
                     'must contain ALL pairwise sums of Dt and Dr ' ...
                     '(it should, by construction in compute_sum_coarray.m).'], ...
                    n, m, s);
            end
            ell = valueToCol(s);

            rows(idx) = i_lin;
            cols(idx) = ell;

            I_ell{ell} = [I_ell{ell}; n, m]; %#ok<AGROW> % small (<=Nt*Nr rows total)
        end
    end

    vals = ones(Nt*Nr, 1);
    Upsilon = sparse(rows, cols, vals, Nt*Nr, NSigma);

    % Defensive check: total nonzeros must equal Nt*Nr (every physical
    % pair contributes to exactly one virtual sensor).
    assert(nnz(Upsilon) == Nt*Nr, ...
        'compute_redundancy_pattern:internalError', ...
        'nnz(Upsilon)=%d does not match Nt*Nr=%d.', nnz(Upsilon), Nt*Nr);

end
