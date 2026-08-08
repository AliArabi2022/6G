function gamma_achieved = compute_sinr(H, W, sigmaC2, target_type, WA)
%COMPUTE_SINR Achieved per-user SINR for a given communication beamformer.
%
%   gamma_achieved = COMPUTE_SINR(H, W, sigmaC2, target_type, WA)
%
%   POINT TARGET (target_type='point'), Eq. (9):
%       gamma_k = |h_k' w_k|^2 / ( sum_{i~=k} |h_k' w_i|^2 + sigmaC2 )
%
%   EXTENDED TARGET (target_type='extended'), Eq. (17) -- adds the
%   interference contribution from the dedicated radar-probing
%   streams WA, which communication users cannot cancel:
%       gamma_k = |h_k' w_k|^2 /
%                 ( sum_{i~=k} |h_k' w_i|^2 + ||h_k' WA||^2 + sigmaC2 )
%
%   Inputs:
%       H           : K x Nt, channel matrix (row k = h_k')
%       W           : Nt x K, communication beamforming matrix [w_1,...,w_K]
%       sigmaC2     : scalar, communication noise variance [W]
%       target_type : 'point' | 'extended'
%       WA          : Nt x Nt (extended) or [] (point) -- auxiliary
%                     probing beamformer; REQUIRED (non-empty) if
%                     target_type='extended', ignored otherwise
%
%   Outputs:
%       gamma_achieved : K x 1, linear SINR per user
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    [K, Nt] = size(H);
    validateattributes(W, {'numeric'}, {'size', [Nt K]});

    if nargin < 5
        WA = [];
    end
    if strcmp(target_type, 'extended')
        assert(~isempty(WA), 'compute_sinr:missingWA', ...
            'target_type=''extended'' requires a non-empty WA (Eq. 17 interference term).');
    end

    gamma_achieved = zeros(K,1);
    for k = 1:K
        hk = H(k,:)';                       % Nt x 1
        sig_power = abs(hk' * W(:,k))^2;

        other_idx = [1:k-1, k+1:K];
        interf_users = sum(abs(hk' * W(:,other_idx)).^2);

        switch target_type
            case 'point'
                interf_total = interf_users + sigmaC2;
            case 'extended'
                interf_radar = norm(hk' * WA)^2;    % Eq. (17) additional term
                interf_total = interf_users + interf_radar + sigmaC2;
            otherwise
                error('compute_sinr:badTargetType', 'target_type must be ''point'' or ''extended''.');
        end

        gamma_achieved(k) = sig_power / interf_total;
    end
end
