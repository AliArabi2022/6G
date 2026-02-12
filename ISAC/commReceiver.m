function [rxBits, BER] = commReceiver(rxTime, txSymMatrix, bits, params, H_est)
% commReceiver - OFDM demodulation, equalization, and BER calculation
% Input:
%   rxTime      - received baseband signal
%   txSymMatrix - transmitted OFDM symbols (Nfft x M_sym)
%   bits        - transmitted bits
%   params      - struct with Nfft, Ncp, M_sym, modOrder
%   H_est       - channel estimate (Nfft x M_sym)
% Output:
%   rxBits      - demodulated bits
%   BER         - bit error rate

Nfft = params.Nfft;
Ncp = params.Ncp;
M_sym = params.M_sym;
modOrder = params.modOrder;

rxBits = [];

% Loop over OFDM symbols
for m = 1:M_sym
    idx_start = (m-1)*(Nfft+Ncp)+1;
    idx_end = idx_start + Nfft + Ncp -1;
    rx_sym_withCP = rxTime(idx_start:idx_end);
    rx_sym_noCP = rx_sym_withCP(Ncp+1:end);
    
    % FFT to frequency domain
    RXf = fft(rx_sym_noCP, Nfft);
    
    % Equalization using channel estimate
    H_m = H_est(:,m);
    eqSymbols = RXf ./ H_m; % simple zero-forcing equalization
    
    % QPSK demodulation
    rxSymIdx = qamdemod(eqSymbols, modOrder, 'UnitAveragePower', true);
    
    % Convert symbols back to bits
    k = log2(modOrder);
    rxBitMatrix = de2bi(rxSymIdx, k, 'left-msb');
    rxBits = [rxBits; rxBitMatrix(:)];
end

% Compute BER
nBits = length(bits);
rxBits = rxBits(1:nBits); % trim to transmitted length
BER = sum(bits ~= rxBits)/nBits;

fprintf('Step 4 completed: BER = %.5f\n', BER);

end
