% Runner for Step 3: Sensing receiver
clear; close all; clc;

% Load TX/RX
params = initParams();
[txTime, txSymMatrix, bits] = generateOFDM(params);
rxTime = channel_ISAC(txTime, params);

% Run sensing receiver
sensingResults = sensingReceiver(rxTime, txSymMatrix, params);

% Peak detection in range profile (optional)
[peaks, locs] = findpeaks(mean(sensingResults.range_profile,2),'SortStr','descend','NPeaks',2);
fprintf('Detected peak ranges (m): '); disp(sensingResults.range_axis(locs).');