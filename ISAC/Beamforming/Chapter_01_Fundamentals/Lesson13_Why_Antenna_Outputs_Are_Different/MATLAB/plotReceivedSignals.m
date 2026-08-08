function plotReceivedSignals(time, receivedSignals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Function : plotReceivedSignals
%
% Description:
% Visualizes the received signals of all antenna elements.
%
% Inputs:
%   time            - Time vector (s)
%   receivedSignals - Matrix of received signals
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Number of Antennas

numberOfAntennas = size(receivedSignals,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1
%% Individual Signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Color','w');

for k = 1:numberOfAntennas

    subplot(numberOfAntennas,1,k)

    plot(time*1e9,...
         receivedSignals(k,:),...
         'LineWidth',1.5);

    grid on

    ylabel(sprintf('A%d',k));

    if k==1
        title('Received Signal at Each Antenna');
    end

    if k==numberOfAntennas
        xlabel('Time (ns)');
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2
%% Overlay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Color','w');

hold on
grid on

for k = 1:numberOfAntennas

    plot(time*1e9,...
         receivedSignals(k,:),...
         'LineWidth',2);

end

xlabel('Time (ns)');
ylabel('Amplitude');

title('Comparison of Received Signals');

legendStrings = strings(1,numberOfAntennas);

for k = 1:numberOfAntennas

    legendStrings(k)=sprintf('A%d',k);

end

legend(legendStrings,...
       'Location','eastoutside');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Educational Message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(" ");
disp("========================================");
disp("Observation");
disp("========================================");
disp("All antennas received");
disp("the SAME transmitted signal.");
disp(" ");
disp("However...");
disp(" ");
disp("Their waveforms are NOT aligned.");
disp(" ");
disp("Question:");
disp("Why?");
disp(" ");
pause(3)

disp("Answer:");
disp("Different propagation distances.");
disp(" ");
pause(2)

disp("Different distances");
disp("      ↓");
disp("Different arrival times");
disp("      ↓");
disp("Different time delays");
disp("      ↓");
disp("Different phase shifts");
disp("      ↓");
disp("Beamforming");
disp("========================================");

end