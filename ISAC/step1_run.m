%% step1_run.m
% Step 1: Generate OFDM and plot time/frequency/power changes
clear; close all; clc;

% 1) Initialize parameters
params = initParams();

% 2) Generate OFDM signal
[txTime, txSymMatrix, bits] = generateOFDM(params);

% Extract first symbol (with and without CP)
Nsym_samples = params.Nfft + params.Ncp;
first_sym = txTime(1:Nsym_samples);          
first_sym_noCP = first_sym(params.Ncp+1:end);

t_vec_sym = (0:length(first_sym)-1).' * params.dt;          
t_vec_sym_noCP = (0:length(first_sym_noCP)-1).' * params.dt;

%% --- Plot 1: Time-domain signal (real/imag/magnitude) before and after CP ---
figure('Name','Time domain: before vs after CP','NumberTitle','off');

subplot(3,2,1);
plot(t_vec_sym_noCP, real(first_sym_noCP)); 
xlabel('time (s)'); title('real(x(t)) - without CP'); grid on;

subplot(3,2,2);
plot(t_vec_sym_noCP, imag(first_sym_noCP));
xlabel('time (s)'); title('imag(x(t)) - without CP'); grid on;

subplot(3,2,3);
plot(t_vec_sym, real(first_sym));
xlabel('time (s)'); title('real(x(t)) - with CP'); grid on;

subplot(3,2,4);
plot(t_vec_sym, imag(first_sym));
xlabel('time (s)'); title('imag(x(t)) - with CP'); grid on;

subplot(3,2,5);
plot(t_vec_sym_noCP, abs(first_sym_noCP));
xlabel('time (s)'); title('magnitude |x(t)| - without CP'); grid on;

subplot(3,2,6);
plot(t_vec_sym, abs(first_sym));
xlabel('time (s)'); title('magnitude |x(t)| - with CP'); grid on;

%% --- Plot 2: Instantaneous power relative to itself ---
inst_power_noCP = abs(first_sym_noCP).^2; 
inst_power_withCP = abs(first_sym).^2;

figure('Name','Instantaneous Power','NumberTitle','off');
subplot(2,1,1);
plot(t_vec_sym_noCP, 10*log10(inst_power_noCP + eps));
xlabel('time (s)'); ylabel('Power (dB)'); title('Instantaneous Power (without CP)'); grid on;

subplot(2,1,2);
plot(t_vec_sym, 10*log10(inst_power_withCP + eps));
xlabel('time (s)'); ylabel('Power (dB)'); title('Instantaneous Power (with CP)'); grid on;

% Compute PAPR
peak_power = max(inst_power_noCP);
avg_power = mean(inst_power_noCP);
PAPR_linear = peak_power / avg_power;
PAPR_dB = 10*log10(PAPR_linear);
fprintf('PAPR (first symbol, without CP): %.2f dB\n', PAPR_dB);

%% --- Plot 3: FFT magnitude of first symbol (without CP) ---
Nfft_plot = 2048; 
X_fft = fftshift(fft(first_sym_noCP, Nfft_plot));
f_axis = linspace(-params.fs/2, params.fs/2, Nfft_plot);
figure('Name','Spectrum of one OFDM symbol','NumberTitle','off');
plot(f_axis/1e3, 20*log10(abs(X_fft) + eps));
xlabel('Frequency (kHz)'); ylabel('Magnitude (dB)'); title('FFT magnitude of one OFDM symbol (zero-padded)');
grid on;

%% --- Plot 4: PSD and 99% occupied bandwidth ---
[pxx,f] = periodogram(first_sym_noCP, rectwin(length(first_sym_noCP)), 4*length(first_sym_noCP), params.fs);
cumP = cumsum(pxx) / sum(pxx);
idx_low = find(cumP >= 0.005, 1, 'first');
idx_high = find(cumP >= 0.995, 1, 'first');
bw_low = f(idx_low);
bw_high = f(idx_high);
occupied_bw = bw_high - bw_low;

figure('Name','PSD and Occupied Bandwidth','NumberTitle','off');
plot(f/1e3, 10*log10(pxx + eps)); hold on;
yl = ylim;
plot([bw_low bw_low]/1e3, yl, 'r--', 'LineWidth',1.2);
plot([bw_high bw_high]/1e3, yl, 'r--', 'LineWidth',1.2);
xlabel('Frequency (kHz)'); ylabel('PSD (dB/Hz)'); title('Periodogram and occupied bandwidth (99%)');
legend('PSD','99% bandwidth edges'); grid on;
fprintf('Occupied bandwidth (99%% energy): %.1f kHz (from %.1f kHz to %.1f kHz)\n', occupied_bw/1e3, bw_low/1e3, bw_high/1e3);

%% --- Summary metrics ---
total_energy = sum(abs(first_sym_noCP).^2);
fprintf('Total energy (first symbol, no CP): %.4f (linear units)\n', total_energy);
fprintf('Average power: %.4f\n', mean(inst_power_noCP));
fprintf('Peak power: %.4f\n', peak_power);

fprintf('\nStep 1 complete: OFDM generation and time/frequency/power plots done.\n');