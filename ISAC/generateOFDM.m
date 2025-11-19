function [txTime, txSymMatrix, bits] = generateOFDM(params)
% generateOFDM  Generate baseband OFDM signal
% Inputs: params struct from initParams
% Outputs:
%   txTime      : time-domain vector (complex) of M_sym symbols with CP
%   txSymMatrix : frequency-domain matrix (Nfft x M_sym) of QAM subcarriers
%   bits        : transmitted bits (column vector)

%% 1) Generate random bits
bitsPerSym = log2(params.modOrder) * params.Nfft; % bits per OFDM symbol (all subcarriers data)
totalBits = bitsPerSym * params.M_sym;
bits = randi([0 1], totalBits, 1); % random bits
% Note: random bits are used for BER evaluation and spectrum analysis.

%% 2) QPSK modulation (Gray mapped)
k = log2(params.modOrder);
bitMatrix = reshape(bits, k, []).'; % each row = one symbol
symIdx = bi2de(bitMatrix, 'left-msb'); % bits -> symbol index
txSymbolsVec = qammod(symIdx, params.modOrder, 'UnitAveragePower', true);
% Note: unit average power ensures meaningful SNR comparison.

% Reshape into Nfft x M_sym
txSymMatrix = reshape(txSymbolsVec, params.Nfft, params.M_sym);

%% 3) IFFT per OFDM symbol and add CP
txTime = []; % store all symbols with CP
for m = 1:params.M_sym
    X = txSymMatrix(:,m);            % frequency-domain vector of symbol m
    x_time = ifft(X, params.Nfft);   % IFFT -> time-domain baseband signal
    % Note: IFFT is equivalent to subcarrier modulation; output is complex baseband.

    cp = x_time(end - params.Ncp + 1 : end); % extract CP from end
    tx_sym_with_cp = [cp; x_time];          % prepend CP
    txTime = [txTime; tx_sym_with_cp];      % append to total vector
end

% Output txTime is a column vector (complex)
end