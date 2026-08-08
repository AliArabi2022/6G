%% ===============================================================
%  OFDM over Multipath Channel (No EQ) + QAM Constellation + Subcarrier Spectrum
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
% Multipath Channel
%% ----------------------------
h = [0.9 0.4 0.2 0.05];

%% ----------------------------
% Bitstream
%% ----------------------------
tx_bits = randi([0 1], numBits, 1);

%% ----------------------------
% QAM Mapper
%% ----------------------------
tx_QAM = qammod(tx_bits, M,...
    'InputType','bit',...
    'UnitAveragePower', true);

%% ----------------------------
% Reshape to OFDM frames
%% ----------------------------
tx_frames = reshape(tx_QAM, Nfft, numSymbols);

%% ----------------------------
% IFFT
%% ----------------------------
tx_time = ifft(tx_frames, Nfft);

%% ----------------------------
% Cyclic Prefix
%% ----------------------------
cp = tx_time(end-Ncp+1:end,:);
tx_cp = [cp ; tx_time];

%% ----------------------------
% Channel
%% ----------------------------
rx_conv = filter(h,1,tx_cp);

%% ----------------------------
% AWGN
%% ----------------------------
rx_awgn = awgn(rx_conv, SNR_dB, 'measured');

%% ===============================================================
% Receiver - WITH CP
%% ===============================================================
rx_no_cp = rx_awgn(Ncp+1:end,:);
rx_fft = fft(rx_no_cp, Nfft);
rx_syms = rx_fft(:);

rx_bits = qamdemod(rx_syms, M,...
    'OutputType','bit',...
    'UnitAveragePower', true);

BER_with_CP = mean(rx_bits ~= tx_bits);

fprintf("BER with CP    = %.3e\n", BER_with_CP);

%% ===============================================================
% Receiver - WITHOUT CP
%% ===============================================================
rx_trim = rx_awgn(1:end-Ncp,:);
rx_fft2 = fft(rx_trim, Nfft);
rx_syms2 = rx_fft2(:);

rx_bits2 = qamdemod(rx_syms2, M,...
    'OutputType','bit',...
    'UnitAveragePower', true);

BER_no_CP = mean(rx_bits2 ~= tx_bits);

fprintf("BER without CP = %.3e\n", BER_no_CP);


%% ===============================================================
% -------- QAM CONSTELLATION PLOT ----------------
%% ===============================================================

figure;
plot(real(rx_syms(1:500:end)), imag(rx_syms(1:500:end)),'.');
grid on;
axis equal;
xlabel('In-Phase');
ylabel('Quadrature');
title('QAM Constellation (received)');


%% ===============================================================
% -------- SUBCARRIER SPECTRUM PLOT ---------------
%% ===============================================================

% frequency resolution
Fs = 1;            % normalized sampling
Nfft_spectrum = 4096;

figure;
hold on;
for k = 1:8           % plot 8 subcarriers for clarity
    
    % get isolated carrier in frequency domain
    isolated = zeros(Nfft,1);
    isolated(k) = 1;
    
    % IFFT to pulse in time
    pulse_t = ifft(isolated, Nfft);
    
    % FFT for spectrum
    H = fft(pulse_t, Nfft_spectrum);
    
    f = linspace(-Fs/2, Fs/2, Nfft_spectrum);
    
    plot(f, fftshift(abs(H)));
    
end

grid on;
xlabel('Normalized Frequency');
ylabel('Magnitude');
title('Spectrum of Individual OFDM Subcarriers');

legend(arrayfun(@(x) sprintf("Subcarrier %d",x),1:8,'UniformOutput',false));
