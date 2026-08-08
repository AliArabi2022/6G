function watts = dBm2Watt(dBm_val)
%DBM2WATT Convert power from dBm to linear Watts.
%
%   watts = DBM2WATT(dBm_val) applies watts = 10^((dBm_val-30)/10).
%
%   Inputs:
%       dBm_val : scalar or array, power in dBm
%   Outputs:
%       watts   : same size as dBm_val, power in linear Watts
%
%   Used by config/parameters.m to ensure every power/noise quantity
%   entering the SDP solvers (CVX) is in linear units of O(1) magnitude
%   at the paper's operating point (30 dBm = 1 W), avoiding solver
%   scaling warnings (Phase 3 Sec 3.5, Appendix C numerical note).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    watts = 10.^((dBm_val - 30) / 10);
end
