function CRB_val = compute_crb(RX, target_type, crb_params)
%COMPUTE_CRB Evaluate the Cramer-Rao Bound for a given transmit covariance.
%
%   CRB_val = COMPUTE_CRB(RX, target_type, crb_params)
%
%   POINT TARGET (target_type = 'point'), Eq. (23) (re-derived closed
%   form, Phase 3 Sec 3.2, from the Slepian-Bangs FIM (4) using the
%   orthogonality identity Re{a'*adot}=0, Eq. 21):
%
%       CRB(theta) = sigmaR2 * ||bdot||^2
%                    -----------------------------------------
%                    2 * |alpha|^2 * L * ||b||^2 * Re{a' * RX * a}
%
%   crb_params must contain: a_vec, b_vec, bdot_vec, alpha_true, L, sigmaR2
%
%   EXTENDED TARGET (target_type = 'extended'), Eq. (16):
%
%       CRB(G) = (sigmaR2 * Nr / L) * tr(RX^-1)
%
%   crb_params must contain: Nr, L, sigmaR2
%
%   Inputs:
%       RX          : Nt x Nt, Hermitian PSD transmit covariance
%       target_type : 'point' | 'extended'
%       crb_params  : struct, see above per target_type
%
%   Outputs:
%       CRB_val : scalar, linear units (rad^2 for point-target theta;
%                 linear MSE units for extended-target G). Unit
%                 conversion to degrees^2 or dB happens ONLY at the
%                 plotting layer (Phase 5 Module 13 design decision) --
%                 this function stays unit-pure and reusable.
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    Nt = size(RX,1);
    RX = (RX + RX')/2;   % defensive Hermitian symmetrization

    switch target_type
        case 'point'
            req = {'a_vec','b_vec','bdot_vec','alpha_true','L','sigmaR2'};
            assert(all(isfield(crb_params, req)), ...
                'compute_crb:missingFields', 'point-target crb_params must contain: %s', strjoin(req,', '));

            a_vec    = crb_params.a_vec;
            b_vec    = crb_params.b_vec;
            bdot_vec = crb_params.bdot_vec;
            alpha    = crb_params.alpha_true;
            L        = crb_params.L;
            sigmaR2  = crb_params.sigmaR2;

            denom_power = real(a_vec' * RX * a_vec);   % Eq.(23) denominator's RX-dependent term
            if denom_power < 1e-15
                warning('compute_crb:zeroDenominator', ...
                    'a''*RX*a is ~0 (beamformer places no power toward target angle); CRB(theta) -> Inf.');
                CRB_val = Inf;
                return;
            end

            CRB_val = sigmaR2 * norm(bdot_vec)^2 / ...
                      (2 * abs(alpha)^2 * L * norm(b_vec)^2 * denom_power);

        case 'extended'
            req = {'Nr','L','sigmaR2'};
            assert(all(isfield(crb_params, req)), ...
                'compute_crb:missingFields', 'extended-target crb_params must contain: %s', strjoin(req,', '));

            Nr      = crb_params.Nr;
            L       = crb_params.L;
            sigmaR2 = crb_params.sigmaR2;

            % Numerical guard: RX must be (near) full rank (Phase 3
            % Sec 3.4 Eq.16 critical note / Sec 3.10 table row 1).
            r = rcond(RX);
            if r < 1e-10
                warning('compute_crb:illConditioned', ...
                    'RX is near-singular (rcond=%.3e); using pinv() fallback. This likely indicates a rank-deficient beamformer upstream (K<Nt with no auxiliary probing streams).', r);
                RX_inv_trace = real(trace(pinv(RX)));
            else
                RX_inv_trace = real(trace(inv(RX))); %#ok<MINV>
            end

            CRB_val = (sigmaR2 * Nr / L) * RX_inv_trace;

        otherwise
            error('compute_crb:badTargetType', 'target_type must be ''point'' or ''extended'', got ''%s''.', target_type);
    end
end
