%% ===============================================================
%  OFDM Baseline Implementation (No Noise, No Channel)
%  Author: Ali Arabi Bavil
%  Description:
%  This script generates a basic OFDM system.
%  It includes: bit generation, QAM mapping, OFDM modulation,
%  cyclic prefix insertion/removal, demodulation, and BER check.
%% ===============================================================

clear; clc;

%% ----------------------------
% System Parameters
%% ----------------------------
Nfft        = 64;              % FFT size
Ncp         = 16;              % Cyclic prefix length
M           = 16;              % QAM Modulation order
numSymbols  = 1000;            % Number of OFDM symbols

bitsPerSym  = Nfft * log2(M);  % Bits per OFDM symbol

%% ----------------------------
% Bit Generation
%% ----------------------------
tx_bits = randi([0 1], bitsPerSym * numSymbols, 1);

%% ----------------------------
% QAM Modulation
%% ----------------------------
tx_symbols = qammod(tx_bits, M, 'InputType','bit','UnitAveragePower',true);

%% ----------------------------
% Reshape into OFDM symbols
%% ----------------------------
tx_symbols_mat = reshape(tx_symbols, Nfft, numSymbols);

%% ----------------------------
% IFFT (Time-domain OFDM symbols)
%% ----------------------------
tx_ofdm_time = ifft(tx_symbols_mat, Nfft);

%% ----------------------------
% Add Cyclic Prefix
%% ----------------------------
cyclic_prefix = tx_ofdm_time(end-Ncp+1:end, :);
tx_with_cp = [cyclic_prefix ; tx_ofdm_time];

%% ----------------------------
% Receiver Side
%% ----------------------------

% Remove cyclic prefix
rx_no_cp = tx_with_cp(Ncp+1:end, :);

% FFT
rx_symbols_mat = fft(rx_no_cp, Nfft);

% Serialize
rx_symbols = rx_symbols_mat(:);

%% ----------------------------
% QAM Demodulation
%% ----------------------------
rx_bits = qamdemod(rx_symbols, M, 'OutputType','bit','UnitAveragePower',true);

%% ----------------------------
% BER
%% ----------------------------
BER = sum(rx_bits ~= tx_bits) / length(tx_bits);
fprintf("BER (no noise, no channel) = %e\n", BER);
