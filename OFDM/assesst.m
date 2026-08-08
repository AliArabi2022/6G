%% ===============================================================
%  OFDM over Multipath Channel (No Equalization)
%  Author: YOUR_NAME
%% ===============================================================

clear; clc;

%% ----------------------------
% System Parameters
%% ----------------------------
Nfft        = 64;
Ncp         = 16;
M           = 16;
numSymbols  = 2000;
SNR_dB      = 20;

bitsPerSym  = Nfft * log2(M);
numBits     = bitsPerSym * numSymbols;

%% ----------------------------
% Channel Model
%% ----------------------------
h = [0.9  0.4  0.2  0.05];

%% ----------------------------
% Bit Generation
%% ----------------------------
tx_bits = randi([0 1], numBits, 1);

%% ----------------------------
% QAM Mapping
%% ----------------------------
tx_QAM = qammod(tx_bits, M, ...
    'InputType','bit', ...
    'UnitAveragePower', true);


%% ===============================================================
% === ADDED: Plot QAM Constellation ==============================
%% ===============================================================

figure;
plot(real(tx_QAM(1:3000)), imag(tx_QAM(1:3000)), '.', 'MarkerSize', 8);
title('QAM Constellation (Transmitted Symbols)');
xlabel('In-Phase');
ylabel('Quadrature');
grid on;


%% ----------------------------
% Group symbols
%% ----------------------------
tx_matrix = reshape(tx_QAM, Nfft, numSymbols);

%% ----------------------------
% IFFT
%% ----------------------------
tx_ofdm = ifft(tx_matrix, Nfft);

%% ===============================================================
% === ADDED: Frequency-domain subcarriers plot ===================
%% ===============================================================

figure; hold on;
for k = 1:8
    plot(abs(tx_matrix(:,k)));
end
grid on;
title('OFDM Subcarriers in Frequency Domain');
xlabel('Subcarrier Index');
ylabel('Magnitude');
legend("Symbol-1","Symbol-2","Symbol-3","Symbol-4","Symbol-5","Symbol-6","Symbol-7","Symbol-8");
hold off;


%% ----------------------------
% Cyclic Prefix
%% ----------------------------
cp = tx_ofdm(end-Ncp+1:end, :);
tx_cp = [cp ; tx_ofdm];

%% ----------------------------
% Channel
%% ----------------------------
rx_conv = filter(h,1,tx_cp);

%% ----------------------------
% Noise
%% ----------------------------
rx_cp_awgn = awgn(rx_conv, SNR_dB, 'measured');


%% ----------------------------
% Receiver w/ CP
%% ----------------------------
rx_no_cp = rx_cp_awgn(Ncp+1:end, :);

rx_fft = fft(rx_no_cp, Nfft);
rx_syms = rx_fft(:);

rx_bits = qamdemod(rx_syms, M, ...
    'OutputType','bit', ...
    'UnitAveragePower', true);

BER_with_CP = sum(rx_bits ~= tx_bits) / numBits;
fprintf("BER (with CP) = %.3e\n", BER_with_CP);


%% ----------------------------
% Receiver w/o CP
%% ----------------------------
rx_trim = rx_cp_awgn(1:end-Ncp, :);

rx_fft2 = fft(rx_trim, Nfft);
rx_syms2 = rx_fft2(:);

rx_bits2 = qamdemod(rx_syms2, M, ...
    'OutputType','bit', ...
    'UnitAveragePower', true);

BER_no_CP = sum(rx_bits2 ~= tx_bits) / numBits;
fprintf("BER (NO CP) = %.3e\n", BER_no_CP);
