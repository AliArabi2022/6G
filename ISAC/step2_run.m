%% step2_run.m
% Runner for Step 2: Apply ISAC channel (target delays + Doppler + noise)
clear; close all; clc;

% Load TX from Step 1
params = initParams();
[txTime, txSymMatrix, bits] = generateOFDM(params);

% 1) Pass TX through ISAC channel
rxTime = channel_ISAC(txTime, params);

% 2) Visualize TX vs RX (first symbol)
Nsym_samples = params.Nfft + params.Ncp;
tx_sym1 = txTime(1:Nsym_samples);
rx_sym1 = rxTime(1:Nsym_samples);

t_vec_sym = (0:length(tx_sym1)-1).' * params.dt;

figure('Name','TX vs RX Time Domain (first symbol)','NumberTitle','off');
plot(t_vec_sym, real(tx_sym1), 'b', 'LineWidth',1.2); hold on;
plot(t_vec_sym, real(rx_sym1), 'r--', 'LineWidth',1.2);
xlabel('time (s)'); ylabel('Amplitude'); legend('TX real','RX real'); grid on;
title('Time domain: first symbol real part');

figure('Name','TX vs RX Magnitude','NumberTitle','off');
plot(t_vec_sym, abs(tx_sym1), 'b', 'LineWidth',1.2); hold on;
plot(t_vec_sym, abs(rx_sym1), 'r--', 'LineWidth',1.2);
xlabel('time (s)'); ylabel('Magnitude'); legend('TX','RX'); grid on;
title('Time domain magnitude: TX vs RX');

% 3) Instantaneous power
inst_power_tx = abs(tx_sym1).^2;
inst_power_rx = abs(rx_sym1).^2;
figure('Name','Instantaneous Power TX vs RX','NumberTitle','off');
plot(t_vec_sym, 10*log10(inst_power_tx + eps), 'b', 'LineWidth',1.2); hold on;
plot(t_vec_sym, 10*log10(inst_power_rx + eps), 'r--', 'LineWidth',1.2);
xlabel('time (s)'); ylabel('Power (dB)'); legend('TX','RX'); grid on;
title('Instantaneous power: TX vs RX (first symbol)');

% 4) FFT spectrum
Nfft_plot = 2048;
Xf_tx = fftshift(fft(tx_sym1,Nfft_plot));
Xf_rx = fftshift(fft(rx_sym1,Nfft_plot));
f_axis = linspace(-params.fs/2, params.fs/2, Nfft_plot);

figure('Name','Spectrum TX vs RX','NumberTitle','off');
plot(f_axis/1e3, 20*log10(abs(Xf_tx)+eps), 'b', 'LineWidth',1.2); hold on;
plot(f_axis/1e3, 20*log10(abs(Xf_rx)+eps), 'r--', 'LineWidth',1.2);
xlabel('Frequency (kHz)'); ylabel('Magnitude (dB)'); legend('TX','RX'); grid on;
title('FFT magnitude: TX vs RX (first symbol)');

% 5) Summary metrics
total_energy_tx = sum(inst_power_tx);
total_energy_rx = sum(inst_power_rx);
fprintf('Total energy (TX first symbol): %.4f\n', total_energy_tx);
fprintf('Total energy (RX first symbol): %.4f\n', total_energy_rx);

% Peak locations in RX spectrum (to visualize Doppler effects)
[~,locs_rx] = findpeaks(abs(Xf_rx),'SortStr','descend','NPeaks',5);
fprintf('Top 5 peaks in RX spectrum indices: '); disp(locs_rx.');

fprintf('\nStep 2 completed: ISAC channel applied, TX vs RX plots generated.\n');
fprintf('Next step: receiver processing (Sensing + Communication) to extract range/Doppler and BER.\n');