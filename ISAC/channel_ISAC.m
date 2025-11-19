function rxTime = channel_ISAC(txTime, params)
% channel_ISAC - simulate ISAC channel with targets (delay + Doppler) and AWGN
% Input:
%   txTime - transmitted OFDM baseband signal (column vector)
%   params - struct from initParams
% Output:
%   rxTime - received baseband signal after reflections + noise

%% 1) Define targets [range_m, velocity_m/s, RCS gain]
% Example: 2 targets
targets = [
    150,  20,  1.0;   % target 1: 150 m, 20 m/s, gain=1
    320, -10,  0.6    % target 2: 320 m, -10 m/s, gain=0.6 cannot detect while fs=8e3 or target=450
];

c = 3e8; % speed of light
fc = params.fc; 
lambda = c/fc;

t_vec = (0:length(txTime)-1).' * params.dt; % time vector for entire tx

rxTime = zeros(size(txTime)); % initialize received signal

%% 2) Apply target reflections
for k = 1:size(targets,1)
    R = targets(k,1);     % range in meters
    v = targets(k,2);     % velocity in m/s
    g = targets(k,3);     % target gain
    tau = 2*R/c;          % round-trip delay (seconds)
    fd = 2*v/lambda;      % Doppler frequency shift (Hz)
    
    % Convert delay to samples (fractional delay)
    sampleDelay = tau * params.fs;
    intDelay = floor(sampleDelay);    % integer part
    fracDelay = sampleDelay - intDelay; % fractional part
    
    % Fractional delay filter (using frequency domain method)
    N = length(txTime);
    Xf = fft(txTime,N);
    f = (0:N-1)'/N; % normalized frequency
    H_frac = exp(-1j*2*pi*f*fracDelay); % fractional delay phase shift
    x_delayed = ifft(Xf .* H_frac, N);   % apply fractional delay
    
    % Apply integer delay by zero-padding
    x_delayed = [zeros(intDelay,1); x_delayed(1:end-intDelay)];
    
    % Apply Doppler shift (phase rotation)
    doppler_phase = exp(1j*2*pi*fd*t_vec);
    x_doppler = x_delayed .* doppler_phase;
    
    % Apply target gain (simple model)
    attenuation = g / (R^2); % simple path loss ~ 1/R^2
    rxTime = rxTime + attenuation * x_doppler;
end

%% 3) Add AWGN
rxTime = awgn(rxTime, params.SNR_dB, 'measured');

end
