function [WD_out, WA_out, diagnostics] = dispatch_beamformer(target_type, K, H, target_data, params)
%DISPATCH_BEAMFORMER Route to the correct closed-form/SDR algorithm (A/B/C/D).
%
%   [WD_out, WA_out, diagnostics] = DISPATCH_BEAMFORMER(target_type, K, H, target_data, params)
%
%   Implements the Phase 4 Sec.4.2 decision tree:
%
%       target_type=='point'    & K==1  -> Algorithm A (pointtarget_singleuser,   Theorem 1)
%       target_type=='point'    & K>1   -> Algorithm B (pointtarget_multiuser_sdr, Theorem 2)
%       target_type=='extended' & K==1  -> Algorithm C (extended_singleuser,       Theorem 3)
%       target_type=='extended' & K>1   -> Algorithm D (extended_multiuser_sdr,    Theorem 4)
%
%   Inputs:
%       target_type : 'point' | 'extended'
%       K           : scalar, number of users
%       H           : K x Nt, channel matrix
%       target_data : struct.
%                     point:    must contain field a_vec (Nt x 1)
%                     extended: no additional fields required (the
%                               extended-target algorithms only need
%                               H, Gamma, sigmaC2, PT, Nt -- G itself
%                               is not an input to the BEAMFORMER, only
%                               to echo synthesis elsewhere)
%       params      : struct from config/parameters.m; must contain
%                     Gamma (K x 1, sliced by caller for this K),
%                     sigmaC2, PT, Nt
%
%   Outputs:
%       WD_out : Nt x K, communication beamformer columns (both target types)
%       WA_out : [] (point) or Nt x Nt (extended), auxiliary probing beamformer
%       diagnostics : struct, passthrough from whichever of the 4
%                     algorithms was called, plus an added field
%                     .branch_taken (string, e.g. 'A','B','C','D')
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    Nt = params.Nt;
    Gamma = params.Gamma;    % caller is responsible for slicing to K x 1
    sigmaC2 = params.sigmaC2;
    PT = params.PT;

    validateattributes(H, {'numeric'}, {'size', [K Nt]});
    validateattributes(Gamma, {'numeric'}, {'numel', K});

    switch target_type
        case 'point'
            assert(isfield(target_data,'a_vec'), 'dispatch_beamformer:missingField', ...
                'target_data.a_vec is required for target_type=''point''.');
            a_vec = target_data.a_vec;
            WA_out = [];

            if K == 1
                [w1, diag_inner] = pointtarget_singleuser(a_vec, H(1,:)', Gamma(1), sigmaC2, PT);
                WD_out = w1;
                diagnostics = diag_inner;
                diagnostics.branch_taken = 'A';
            else
                [WD_out, diag_inner] = pointtarget_multiuser_sdr(a_vec, H, Gamma, sigmaC2, PT);
                diagnostics = diag_inner;
                diagnostics.branch_taken = 'B';
            end

        case 'extended'
            if K == 1
                [WC, WA, diag_inner] = extended_singleuser(H(1,:)', Gamma(1), sigmaC2, PT, Nt);
                WD_out = WC;
                WA_out = WA;
                diagnostics = diag_inner;
                diagnostics.branch_taken = 'C';
            else
                [WC, WA, diag_inner] = extended_multiuser_sdr(H, Gamma, sigmaC2, PT, Nt);
                WD_out = WC;
                WA_out = WA;
                diagnostics = diag_inner;
                diagnostics.branch_taken = 'D';
            end

        otherwise
            error('dispatch_beamformer:badTargetType', ...
                'target_type must be ''point'' or ''extended'', got ''%s''.', target_type);
    end
end
