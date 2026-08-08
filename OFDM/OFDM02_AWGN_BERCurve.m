%% ===============================================================
%  OFDM + AWGN Channel + BER Curve
%  Author: Ali Arabi Bavil
%  Description:
%  This script extends the baseline OFDM implementation by
%  adding AWGN channel and computing BER for a range of SNR values.
%% ===============================================================

clear; clc;

%% ----------------------------
% System Parameters
%% ----------------------------
Nfft        = 64;
Ncp         = 16;
M           = 16;
numSymbols  = 2000;
SNR_dB      = 0:2:30;

bitsPerSym  = Nfft * log2(M);
numBits     = bitsPerSym * numSymbols;

BER = zeros(length(SNR_dB),1);

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

%% ----------------------------
% Arrange into OFDM Frames
%% ----------------------------
tx_matrix = reshape(tx_QAM, Nfft, numSymbols);

%% ----------------------------
% IFFT Modulation
%% ----------------------------
tx_ofdm = ifft(tx_matrix, Nfft);

%% ----------------------------
% Cyclic Prefix
%% ----------------------------
cp = tx_ofdm(end-Ncp+1:end, :);
tx_cp = [cp ; tx_ofdm];

%% ===============================================================
% Loop over SNR values
%% ===============================================================
for k = 1:length(SNR_dB)

    % Add AWGN
    rx_cp = awgn(tx_cp, SNR_dB(k), 'measured');

    % Remove CP
    rx_no_cp = rx_cp(Ncp+1:end, :);

    % FFT
    rx_fft = fft(rx_no_cp, Nfft);

    % Serialize
    rx_symbols = rx_fft(:);

    % QAM Demapping
    rx_bits = qamdemod(rx_symbols, M, ...
        'OutputType','bit', ...
        'UnitAveragePower', true);

    % BER computation
    BER(k) = sum(rx_bits ~= tx_bits) / numBits;

end

%% ===============================================================
% Plot BER curve
%% ===============================================================
figure;
semilogy(SNR_dB, BER, 'o-','LineWidth',1.5);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('OFDM over AWGN - BER Curve');
