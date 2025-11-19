function sensingResults = sensingReceiver(rxTime, txSymMatrix, params)
% sensingReceiver - process RX signal to obtain range and Doppler information
% Input:
%   rxTime      - received baseband signal from channel_ISAC
%   txSymMatrix - transmitted OFDM symbol matrix (Nfft x M_sym)
%   params      - parameter struct
% Output:
%   sensingResults - struct containing range profile, RD map, axis info

Nfft = params.Nfft;
Ncp = params.Ncp;
M_sym = params.M_sym;
dt = params.dt;
fs = params.fs;

% 1) Extract OFDM symbols from RX
rxSymbols = zeros(Nfft, M_sym); % to store FFT of each symbol

for m = 1:M_sym
    idx_start = (m-1)*(Nfft+Ncp)+1;
    idx_end = idx_start + Nfft + Ncp -1;
    rx_sym_withCP = rxTime(idx_start:idx_end);
    rx_sym_noCP = rx_sym_withCP(Ncp+1:end); % remove CP
    rxSymbols(:,m) = fft(rx_sym_noCP, Nfft); % FFT to frequency domain
end

% 2) Channel estimation (simplified: divide by TX symbols)
H_est = rxSymbols ./ txSymMatrix;

% 3) Range profile (IFFT across subcarriers)
range_profile = ifft(H_est, Nfft, 1); % IFFT along subcarrier axis
range_profile_mag = abs(range_profile);

% Convert subcarrier index to distance
c = 3e8; % speed of light
range_axis = (0:Nfft-1).' * (c/(2*fs)); % basic relation: d = c*τ/2, τ = k/fs

% 4) Range-Doppler map (FFT along slow-time / symbols)
RD_map = fftshift(fft(range_profile, M_sym, 2),2); % along symbol axis
RD_map_mag = abs(RD_map);

fc = params.fc; 
lambda = c/fc;

% Doppler axis
dT = (Nfft+Ncp)*dt;
f_doppler = linspace(-1/(2*dT),1/(2*dT),M_sym); % Hz
velocity_axis = f_doppler * lambda/2; % v = fd*lambda/2


% Save results
sensingResults.range_profile = range_profile_mag;
sensingResults.RD_map = RD_map_mag;
sensingResults.range_axis = range_axis;
sensingResults.velocity_axis = velocity_axis;
sensingResults.H_est = H_est;

%% --- Plotting ---
figure('Name','Range Profile','NumberTitle','off');
plot(range_axis, 20*log10(mean(range_profile_mag,2)+eps));
xlabel('Range (m)'); ylabel('Magnitude (dB)');
title('Average Range Profile'); grid on;

figure('Name','Range-Doppler Map','NumberTitle','off');
imagesc(sensingResults.velocity_axis, sensingResults.range_axis, 20*log10(RD_map_mag+eps));
xlabel('Velocity (m/s)'); ylabel('Range (m)');
title('Range-Doppler Map (dB)');
axis xy; colorbar; grid on;

fprintf('Step 3 completed: Range profile and RD map generated.\n');