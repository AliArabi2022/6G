%% ===============================================================
%  OFDM over Multipath Channel (No Equalization)
%  + Constellation plot
%  + Subcarrier Magnitude Spectrum plot
%
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
% Multipath Channel Model
%% ----------------------------
h = [0.9 0.4 0.2 0.05];

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
% Reshape to OFDM
%% ----------------------------
tx_mat = reshape(tx_QAM, Nfft, numSymbols);

%% ----------------------------
% IFFT
%% ----------------------------
tx_ofdm = ifft(tx_mat, Nfft);

%% ----------------------------
% Cyclic Prefix
%% ----------------------------
cp = tx_ofdm(end-Ncp+1:end,:);
tx_cp = [cp ; tx_ofdm];

%% ----------------------------
% Convolution + AWGN
%% ----------------------------
rx_conv  = filter(h,1,tx_cp);
rx_noisy = awgn(rx_conv,SNR_dB,'measured');

%% ===============================================================
% Receiver path WITH CP
%% ===============================================================

rx_rm = rx_noisy(Ncp+1:end,:);

rx_fft = fft(rx_rm,Nfft);
rx_syms = rx_fft(:);

rx_bits = qamdemod(rx_syms,M, ...
    'OutputType','bit', ...
    'UnitAveragePower',true);

BER_with_CP = mean(rx_bits~=tx_bits);
fprintf("BER (with CP) = %.3e\n", BER_with_CP);


%% ===============================================================
% PLOTS SECTION
%% ===============================================================

figure;
tiledlayout(1,2);

%% ---------------------------------------------------------------
% (1) QAM constellation
%% ---------------------------------------------------------------
nexttile;

plot(rx_syms,'.'); grid on;
title('Rx QAM Constellation');
xlabel('In-Phase');
ylabel('Quadrature');

%% ---------------------------------------------------------------
% (2) Subcarrier magnitude spectrum
%% ---------------------------------------------------------------
nexttile;

hold on;

for k = 1:Nfft
    plot(abs(rx_fft(k,:)));   % each subcarrier
end

hold off;
grid on;
title('Subcarrier Magnitude Spectrum');
xlabel('Symbol Index');
ylabel('|Amplitude|');

% Create legend entries automatically
leg = arrayfun(@(x) sprintf("SC %d",x), 1:Nfft, 'UniformOutput', false);
legend(leg, 'Location','eastoutside');

