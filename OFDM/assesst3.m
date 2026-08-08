%% ===============================================================
%  OFDM with Pilot-based Channel Estimation and Equalization
%  Author: YOUR_NAME
%  Description:
%  This script implements OFDM with pilot insertion, frequency-domain
%  channel estimation, and equalization. BER is computed only for 
%  data subcarriers (pilot bits excluded) to avoid size mismatch.
%% ===============================================================

clear; clc;

%% ----------------------------
% System Parameters
%% ----------------------------
Nfft        = 64;       % FFT size
Ncp         = 16;       % Cyclic prefix length
M           = 16;       % QAM order
numSymbols  = 2000;     % Number of OFDM symbols
SNR_dB      = 20;       % Fixed SNR for simulation
pilotSpacing = 4;       % Insert pilot every 4 subcarriers

bitsPerSym  = Nfft * log2(M);
numBits     = bitsPerSym * numSymbols;

%% ----------------------------
% Channel Model
%% ----------------------------
h = [0.9 0.4 0.2 0.05]; % FIR multipath channel

%% ----------------------------
% Generate Random Bits
%% ----------------------------
tx_bits = randi([0 1], numBits, 1);

%% ----------------------------
% QAM Mapping
%% ----------------------------
tx_QAM = qammod(tx_bits, M, 'InputType','bit', 'UnitAveragePower', true);

%% ----------------------------
% Reshape into OFDM Symbols
%% ----------------------------
tx_matrix = reshape(tx_QAM, Nfft, numSymbols);

%% ----------------------------
% Pilot Insertion
%% ----------------------------
pilot_val = 1 + 0j;           % constant pilot symbol
pilot_idx = 1:pilotSpacing:Nfft; % pilot positions

tx_matrix(pilot_idx,:) = pilot_val;

%% ----------------------------
% IFFT (OFDM modulation)
%% ----------------------------
tx_ofdm = ifft(tx_matrix, Nfft);

%% ----------------------------
% Add Cyclic Prefix
%% ----------------------------
cp = tx_ofdm(end-Ncp+1:end, :);
tx_cp = [cp ; tx_ofdm];

%% ----------------------------
% Channel Convolution + AWGN
%% ----------------------------
rx_cp = filter(h, 1, tx_cp);          % FIR channel
rx_cp = awgn(rx_cp, SNR_dB, 'measured'); % Add AWGN

%% ----------------------------
% Receiver: Remove CP
%% ----------------------------
rx_no_cp = rx_cp(Ncp+1:end, :);

%% ----------------------------
% FFT (Frequency-domain OFDM)
%% ----------------------------
rx_fft = fft(rx_no_cp, Nfft);

%% ----------------------------
% Channel Estimation using Pilots
%% ----------------------------
H_est = zeros(Nfft, numSymbols);

for sym = 1:numSymbols
    % Estimate channel at pilot positions
    H_est(pilot_idx, sym) = rx_fft(pilot_idx, sym) / pilot_val;
    
    % Linear interpolation for all subcarriers
    H_est(:,sym) = interp1(pilot_idx, H_est(pilot_idx, sym), 1:Nfft, 'linear', 'extrap').';
end

%% ----------------------------
% Frequency-domain Equalization
%% ----------------------------
rx_equalized = rx_fft ./ H_est;

%% ----------------------------
% Remove Pilots from received symbols
%% ----------------------------
rx_equalized(pilot_idx,:) = [];  % keep only data subcarriers
rx_data = rx_equalized(:);

%% ----------------------------
% Remove Pilots from transmitted symbols
%% ----------------------------
tx_data_matrix = tx_matrix;
tx_data_matrix(pilot_idx,:) = [];
tx_data = tx_data_matrix(:);

%% ----------------------------
% QAM Demodulation
%% ----------------------------
rx_bits = qamdemod(rx_data, M, 'OutputType','bit', 'UnitAveragePower', true);
tx_bits_data = qamdemod(tx_data, M, 'OutputType','bit', 'UnitAveragePower', true);

%% ----------------------------
% BER Computation
%% ----------------------------
BER = sum(rx_bits ~= tx_bits_data) / length(tx_bits_data);
fprintf("BER after pilot-based equalization = %.3e\n", BER);
