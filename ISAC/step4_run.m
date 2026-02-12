% Runner for Step 4: Communication receiver and BER evaluation
clear; close all; clc;

% Load TX/RX and sensing H_est
params = initParams();
[txTime, txSymMatrix, bits] = generateOFDM(params);
rxTime = channel_ISAC(txTime, params);

% Use channel estimate from sensing step
sensingResults = sensingReceiver(rxTime, txSymMatrix, params);
H_est = sensingResults.H_est;

% Run communication receiver
[rxBits, BER] = commReceiver(rxTime, txSymMatrix, bits, params, H_est);

fprintf('Bit Error Rate (BER) = %.5f\n', BER);

% Optional: plot constellation for first OFDM symbol after equalization
Nfft = params.Nfft;
Ncp = params.Ncp;
RXf = fft(rxTime(Ncp+1:Ncp+Nfft), Nfft);
eqSymbols = RXf ./ H_est(:,1);

figure('Name','Constellation after equalization','NumberTitle','off');
scatter(real(eqSymbols), imag(eqSymbols), 'filled'); grid on;
xlabel('Real'); ylabel('Imag'); title('Equalized constellation first OFDM symbol');
axis equal;

