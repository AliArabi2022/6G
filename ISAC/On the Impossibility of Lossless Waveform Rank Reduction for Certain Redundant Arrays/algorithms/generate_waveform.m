function S = generate_waveform(T_len, Nt, type, params)
%GENERATE_WAVEFORM Generate a Tx waveform matrix S per Section IV.
%
%   S = GENERATE_WAVEFORM(T_len, Nt, type, params)
%
%   PURPOSE
%       Constructs the waveform matrix S used throughout the numerical
%       validation (Section IV), in one of two modes:
%
%       type = 'low_rank_random':
%           "10 random constant-modulus (low-rank) waveforms with i.i.d.
%            phases drawn uniformly from [0, 2*pi]", forced to a target
%            rank, with unit total transmit power (||S||_F^2 = 1).
%           params.rank_target - desired rank(S) (e.g. Nt-2)
%
%       type = 'orthogonal_diag':
%           Deterministic orthogonal (diagonal-Gram) waveform satisfying
%           S'*S = diag(diag_cov), matching the paper's Fig. 2
%           specification: S^H S = (1/7)*I_7 for Array 1 (full rank),
%           or S^H S = (1/5)*diag([1,1,0,1,0,1,1]) for Array 2 (rank 5,
%           zero power on the two dropped Tx sensors -- see the
%           documentation note preceding this file's introduction in
%           the chat response for why this is NOT literally full-rank
%           for Array 2, despite the paper's "full rank S" legend label).
%           params.diag_cov - 1xNt vector, target diagonal of S^H*S
%
%   INPUTS
%       T_len  - waveform temporal length (ASSUMPTION: T_len = Nt,
%                per config/parameters.m; see Phase 2 notes)
%       Nt     - number of Tx sensors
%       type   - 'low_rank_random' or 'orthogonal_diag'
%       params - struct with mode-specific fields (see above)
%
%   OUTPUTS
%       S - T_len x Nt waveform matrix
%
%   ASSUMPTIONS (explicitly flagged -- paper underspecifies exact
%   construction; see Phase 5/6 documentation)
%       - 'low_rank_random': exact rank-truncation-then-rescale
%         procedure below is OUR CONSTRUCTION, chosen to satisfy both
%         the stated rank AND the stated ||S||_F^2=1 power constraint;
%         the paper specifies neither the truncation method nor the
%         rescaling explicitly.
%       - 'orthogonal_diag': constructing S as sqrt(diag_cov) placed on
%         the diagonal of a T_len x Nt (T_len==Nt) matrix is the
%         simplest S achieving the stated Gram matrix exactly; the
%         paper does not specify this particular S, only its required
%         Gram matrix S^H*S.
%
%   ERROR CHECKING
%       Validates T_len >= Nt (required for S^H S to be able to reach
%       rank Nt), and validates params fields for each mode.
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    validateattributes(T_len, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'T_len');
    validateattributes(Nt, {'numeric'}, {'scalar','positive','integer'}, ...
        mfilename, 'Nt');

    if T_len < Nt
        error('generate_waveform:invalidLength', ...
            'T_len (%d) must be >= Nt (%d) for S to be able to reach rank Nt.', ...
            T_len, Nt);
    end

    switch type
        case 'low_rank_random'
            if ~isfield(params, 'rank_target')
                error('generate_waveform:missingParam', ...
                    'params.rank_target is required for type=''low_rank_random''.');
            end
            rank_target = params.rank_target;
            validateattributes(rank_target, {'numeric'}, ...
                {'scalar','positive','integer','<=',Nt}, mfilename, 'params.rank_target');

            % i.i.d. constant-modulus phases uniform in [0, 2*pi]
            phases = 2*pi*rand(T_len, Nt);
            S_full = exp(1i * phases);

            % Truncate to target rank via SVD (OUR CONSTRUCTION -- see
            % ASSUMPTIONS above).
            [U, Sv, V] = svd(S_full, 'econ');
            r = min(rank_target, min(T_len, Nt));
            Sv_trunc = zeros(size(Sv));
            Sv_trunc(1:r, 1:r) = Sv(1:r, 1:r);
            S = U * Sv_trunc * V';

            % Rescale to unit transmit power: ||S||_F^2 = 1
            frob_norm = norm(S, 'fro');
            if frob_norm < eps
                error('generate_waveform:degenerateWaveform', ...
                    'Truncated waveform has near-zero Frobenius norm; cannot rescale.');
            end
            S = S / frob_norm;

        case 'orthogonal_diag'
            if ~isfield(params, 'diag_cov')
                error('generate_waveform:missingParam', ...
                    'params.diag_cov is required for type=''orthogonal_diag''.');
            end
            diag_cov = params.diag_cov(:)';
            validateattributes(diag_cov, {'numeric'}, ...
                {'vector','nonnegative','numel',Nt}, mfilename, 'params.diag_cov');

            if T_len ~= Nt
                error('generate_waveform:diagModeRequiresSquare', ...
                    ['type=''orthogonal_diag'' constructs S as a diagonal ' ...
                     'T_len x Nt matrix and requires T_len == Nt (got ' ...
                     'T_len=%d, Nt=%d).'], T_len, Nt);
            end

            S = diag(sqrt(diag_cov));

            % Verify the Gram matrix matches the target exactly
            Gram = S' * S;
            if max(abs(diag(Gram) - diag_cov(:))) > 1e-10
                error('generate_waveform:gramMismatch', ...
                    'Internal error: constructed S does not match target diag_cov.');
            end

        otherwise
            error('generate_waveform:unknownType', ...
                'Unknown type ''%s''. Must be ''low_rank_random'' or ''orthogonal_diag''.', ...
                type);
    end

end
