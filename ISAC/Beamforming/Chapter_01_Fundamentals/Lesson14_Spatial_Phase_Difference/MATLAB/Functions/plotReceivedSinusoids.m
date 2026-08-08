%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotReceivedSinusoids(f,timeDelay)

arguments
    f (1,1) double
    timeDelay (1,1) double
end

t = linspace(0,4/f,1000);

signal1 = sin(2*pi*f*t);

signal2 = sin(2*pi*f*(t-timeDelay));

figure('Color','w');

plot(t*1e9,...
     signal1,...
     'b',...
     'LineWidth',2);

hold on

plot(t*1e9,...
     signal2,...
     'r--',...
     'LineWidth',2);

grid on

xlabel('Time (ns)')
ylabel('Amplitude')

legend('Antenna 1',...
       'Antenna 2',...
       'Location','best')

title('Received Signals')