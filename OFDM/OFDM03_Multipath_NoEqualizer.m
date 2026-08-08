%% ===============================================================
%  OFDM over Multipath Channel (No Equalization)
%  Author: Ali Arabi Bavil
%  Description:
%  This script evaluates OFDM performance over a fixed multipath
%  channel with and without cyclic prefix.

%% ===============================================================

clear; clc;

%% ----------------------------
% System Parameters
%% ----------------------------
Nfft        = 64;
Ncp         = 16;
M           = 16;
numSymbols  = 2000;
SNR_dB      = 20;     % fixed SNR

bitsPerSym  = Nfft * log2(M);
numBits     = bitsPerSym * numSymbols;

%% ----------------------------
% Channel Model
%% ----------------------------
% Sample multipath channel impulse response
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

%% ----------------------------
% Group symbols
%% ----------------------------
tx_matrix = reshape(tx_QAM, Nfft, numSymbols);

%% ----------------------------
% IFFT
%% ----------------------------
tx_ofdm = ifft(tx_matrix, Nfft);

%% ----------------------------
% Cyclic Prefix
%% ----------------------------
cp = tx_ofdm(end-Ncp+1:end, :);
tx_cp = [cp ; tx_ofdm];

%% ----------------------------
% Channel Convolution
%% ----------------------------
rx_conv = filter(h,1,tx_cp);

%% ----------------------------
% Add AWGN
%% ----------------------------
rx_cp_awgn = awgn(rx_conv, SNR_dB, 'measured');


%% ===============================================================
% ----------- Receiver: WITH cyclic prefix  -----------------------
%% ===============================================================

% Remove CP
rx_no_cp = rx_cp_awgn(Ncp+1:end, :);

% FFT
rx_fft = fft(rx_no_cp, Nfft);

% Serialize
rx_syms = rx_fft(:);

% QAM Demapping
rx_bits = qamdemod(rx_syms, M, ...
    'OutputType','bit', ...
    'UnitAveragePower', true);

% BER
BER_with_CP = sum(rx_bits ~= tx_bits) / numBits;
fprintf("BER (with CP) = %.3e\n", BER_with_CP);


%% ===============================================================
% ----------- Receiver: WITHOUT cyclic prefix  --------------------
%% ===============================================================

rx_trim = rx_cp_awgn(1:end-Ncp, :);     % remove CP region but NO CP logic

rx_fft2 = fft(rx_trim, Nfft);

rx_syms2 = rx_fft2(:);

rx_bits2 = qamdemod(rx_syms2, M, ...
    'OutputType','bit', ...
    'UnitAveragePower', true);

BER_no_CP = sum(rx_bits2 ~= tx_bits) / numBits;
fprintf("BER (NO CP) = %.3e\n", BER_no_CP);
