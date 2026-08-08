function cfg = parameters()
%PARAMETERS Global configuration for the paper reproduction.
%
%   cfg = PARAMETERS() returns a struct containing every user-defined
%   constant and hyperparameter used throughout this project, as
%   extracted from:
%       R. Rajamaki and P. Pal, "On the Impossibility of Lossless
%       Waveform Rank Reduction for Certain Redundant Arrays."
%
%   PURPOSE
%       Centralize all "magic numbers" so that every other file reads
%       its settings from a single, documented source, per Section IV
%       of the paper.
%
%   INPUTS
%       None.
%
%   OUTPUTS
%       cfg - struct with fields described inline below.
%
%   ASSUMPTIONS (explicitly flagged, not stated numerically in the paper)
%       - cfg.seed        : paper does not specify a random seed. We fix
%                            one here for reproducibility (OUR ADDITION).
%       - cfg.T_len       : paper does not specify waveform temporal
%                            length T numerically. We assume the minimal
%                            value T_len = Nt (OUR ASSUMPTION), since the
%                            paper only constrains rank(S) <= Nt, and any
%                            T_len >= Nt suffices; Nt is the smallest
%                            choice consistent with achieving rank Nt
%                            (full-rank case).
%
%   Author: Ali Arabi bavil
%   Date:   2026-07-07

    % ---------------------------------------------------------------
    % Section IV: array sizes for Arrays 1 and 2 (also used by 3 and 4
    % via config/array_geometry.m, which does not need Nt/Nr here since
    % Arrays 3-4 hardcode their own smaller Nt/Nr).
    % ---------------------------------------------------------------
    cfg.Nt = 7;     % # Tx sensors (Arrays 1 & 2, Section IV)
    cfg.Nr = 6;     % # Rx sensors (Arrays 1 & 2, Section IV)

    % Waveform temporal length. NOT specified numerically in the paper.
    % ASSUMPTION: minimal length achieving the required ranks.
    cfg.T_len = cfg.Nt;

    % ---------------------------------------------------------------
    % Waveform rank settings (Section IV)
    % ---------------------------------------------------------------
    cfg.rank_reduction = 2;                  % Nt - 2 = 5 (low-rank case)
    cfg.rank_low       = cfg.Nt - cfg.rank_reduction;

    % ---------------------------------------------------------------
    % Monte Carlo settings (Section IV, explicitly stated)
    % ---------------------------------------------------------------
    cfg.nTrials    = 1000;   % "Results are averaged over 10^3 Monte Carlo trials"
    cfg.nWaveforms = 10;     % "10 random constant-modulus (low-rank) waveforms"

    % ---------------------------------------------------------------
    % Fig. 1 sweep: number of targets K = 1,3,5,...,15
    % ---------------------------------------------------------------
    cfg.K_sweep = 1:2:15;

    % ---------------------------------------------------------------
    % Fig. 2 sweep: SNR in dB. Paper's axis shows gridlines at
    % 0,5,10,20,25,30 dB; we use a finer, evenly spaced sweep spanning
    % the same range for a smoother curve (OUR CHOICE, documented).
    % ---------------------------------------------------------------
    cfg.SNR_dB_sweep = 0:2.5:30;

    % Fixed number of targets used for the SNR sweep (Fig. 2), per
    % paper: "The number of targets is K = 15."
    cfg.K_fixed_for_snr_sweep = 15;

    % ---------------------------------------------------------------
    % Reproducibility (OUR ADDITION -- not specified in the paper)
    % ---------------------------------------------------------------
    cfg.seed = 0;

    % ---------------------------------------------------------------
    % Numerical tolerances
    % ---------------------------------------------------------------
    cfg.rank_tol_scale = 1;  % multiplier on default rank() tolerance
                             % (see utilities/numerical_rank.m)

    % ---------------------------------------------------------------
    % CVX solver verbosity: 'quiet' suppresses per-solve solver logs
    % (recommended, since thousands of SDPs will be solved).
    % ---------------------------------------------------------------
    cfg.cvx_quiet = true;

end
