function params = initParams()
% initParams  Initialize baseband OFDM simulation parameters
% Output: params struct containing fs, Nfft, Ncp, M_sym, modulation order, SNR, etc.

%% --- Baseband parameters ---
params.fs = 8e6;        % Baseband sampling rate (1 MHz) for light simulation
% Note: fs must be enough for subcarrier spacing = fs/Nfft. Very high fs causes memory issues.

params.Nfft = 256;      % Number of subcarriers (FFT size)
% Explanation: Nfft affects range resolution in sensing. 256 is sufficient for demonstration.

params.Ncp = 32;        % Cyclic prefix length (samples)
% CP should be longer than channel delay spread. For simple simulation, 32 samples are enough.

params.M_sym = 8;       % Number of OFDM symbols in a coherent processing interval (CPI)
% Number of symbols for later range-Doppler map calculations.

params.modOrder = 4;    % QPSK (M = 4)
params.SNR_dB = 30;     % SNR for plotting
params.comm_SNR_dB = 30;% SNR for communication link (for later steps)

% Carrier frequency only used for Doppler calculation (signal is baseband)
params.fc = 3.5e9;      % Only for Doppler, not used in time-domain signal

% Derived parameters
params.subcarrier_spacing = params.fs / params.Nfft;
params.dt = 1/params.fs;
params.symbol_time = (params.Nfft + params.Ncp) * params.dt; % Duration of one OFDM symbol

% Parameters for plotting
params.plot_time_window_sym = 1; % Plot first symbol

end