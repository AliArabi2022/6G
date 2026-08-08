function out = radar_receiver_sim(W, target_list, params, mode)
%RADAR_RECEIVER_SIM  Section V-C receive-side radar processing.
%
%   out = RADAR_RECEIVER_SIM(W, target_list, params, mode)
%
%   IMPORTANT SCOPE NOTE: this paper's core contribution is the transmit
%   beamforming DESIGN (Sections II-IV, Algorithms 1-2), which is fully
%   specified and reproduced exactly in algorithms/sdr_beamforming.m and
%   algorithms/zf_beamforming.m. The receive-side processing in this
%   module (Section V-C) relies on THREE externally-cited references
%   ([73]-[76]: range compression, LS-Capon spatial spectrum, and a
%   GLRT detector) whose exact equations are NOT reproduced in this
%   paper's text -- only their names and role are given. Consequently,
%   this module implements STANDARD, textbook versions of each technique
%   (matched-filter range compression, Capon/MVDR spatial spectrum,
%   energy-threshold detection derived from the complex-Gaussian noise
%   model in eq. 9 via the Neyman-Pearson criterion), clearly flagged
%   here as our own faithful-but-not-verbatim implementation rather than
%   a line-by-line reproduction of [73]-[76].
%
%   Signal model (eq. 9): for each target p with complex amplitude
%   beta_p, range-bin (delay) n'_p and angle theta_p,
%       r[n] = sum_p beta_p * conj(a(theta_p)) * (a(theta_p)' * x[n-n'_p])
%              + v[n],   v[n] ~ CN(0, sigma_r^2 * I_M)
%
%   Inputs:
%     W           - M x (M+K) precoder used to generate x[n] (radar
%                   waveform s[n] and comm symbols c[n] are drawn fresh)
%     target_list - struct array with fields range_bin, angle_deg,
%                   amplitude
%     params      - struct from config/parameters.m
%     mode        - 'range_angle' (Experiment 1, Fig. 10) or
%                   'rmse_detection' (Experiment 2, Figs. 11-12)
%
%   Output: out struct, fields depend on mode (see code below).
%
%   MATLAB functions used: xcorr (matched-filter range compression), \
%   (linear solve for Capon spectrum), randn/rand (noise/symbol generation).
%
%   Author: Ali Arabi Bavil
%   Date:   2026

M = params.M;
N = params.N_block;
K = size(W,1); %#ok<NASGU>
Kcols = size(W,2) - M; % number of comm columns
sigma_r = sqrt(params.sigma_r2);

% --- Generate transmit signal x[n], n = 0..N-1 (eq. 1) ---
s = qpsk_symbols(M, N);
c = qpsk_symbols(Kcols, N);
Wc = W(:, 1:Kcols);
Wr = W(:, Kcols+1:end);
x = Wr * s + Wc * c; % M x N

max_delay = max([target_list.range_bin]) + 5;
Ntot = N + max_delay;

% --- Simulate received signal r[n] (eq. 9), zero-padding x for delays ---
x_padded = [zeros(M, max_delay), x]; % so x_padded(:, max_delay+1+n) = x[n]
r = sigma_r * (randn(M, Ntot) + 1j*randn(M, Ntot)) / sqrt(2); % noise term

for p = 1:numel(target_list)
    beta_p = target_list(p).amplitude;
    theta_p = target_list(p).angle_deg;
    delay_p = target_list(p).range_bin;
    a_p = steering_vector(theta_p, M); % M x 1

    % Contribution: beta_p * conj(a_p) * (a_p' * x[n - delay_p])
    % Build the shifted signal directly at full length Ntot (=N+max_delay)
    % rather than concatenating-then-truncating, since delay_p can be
    % smaller than max_delay -- the previous concatenation approach left
    % x_shifted too short in that case, causing an out-of-bounds index.
    x_shifted = zeros(M, Ntot);
    x_shifted(:, delay_p + (1:N)) = x;
    scalar_signal = a_p' * x_shifted; % 1 x Ntot, = a_p'*x[n-delay_p]
    r = r + beta_p * (conj(a_p) * scalar_signal);
end

switch mode
    case 'range_angle'
        out = experiment1_range_angle(r, x, params, target_list, max_delay, N);
    case 'rmse_detection'
        out = experiment2_rmse_detection(r, x, params, target_list, max_delay, N);
    otherwise
        error('radar_receiver_sim:badMode', 'mode must be ''range_angle'' or ''rmse_detection''.');
end

end

% =========================================================================
function s = qpsk_symbols(rows, cols)
%QPSK_SYMBOLS  Unit-power random QPSK sequence, per assumptions (2)-(4).
if rows == 0
    s = zeros(0, cols);
    return;
end
bits = randi([0 1], rows, cols, 2);
s = (2*bits(:,:,1)-1 + 1j*(2*bits(:,:,2)-1)) / sqrt(2); % unit average power
end

% =========================================================================
function out = experiment1_range_angle(r, x, params, target_list, max_delay, N)
%EXPERIMENT1_RANGE_ANGLE  Range profile + Capon spectrum at bin 20 (Fig. 10).
M = params.M;
theta_grid = params.angle_grid_deg;
A_grid = steering_vector(theta_grid, M); % M x L

% --- Range compression via matched filtering against reference beam signal ---
% Reference: beamform receive signal toward theta=0 (paper's Fig.10 uses
% direction 0 deg for the range profile), then correlate with the known
% transmitted reference y_ref[n] = a(0)' * x[n].
a0 = steering_vector(0, M);
y_ref = a0' * x;                 % 1 x N, known transmitted probe at theta=0
z = a0' * r;                     % 1 x length(r), receive-beamformed signal

% Cross-correlation (matched filter) to estimate delay-domain profile
[c_xcorr, lags] = xcorr(z, y_ref);
% We want range_bin index n' corresponding to lag = max_delay - n'
range_bins = 0:params.exp1_num_range_bins;
range_profile = zeros(size(range_bins));
for i = 1:numel(range_bins)
    n_prime = range_bins(i);
    lag_wanted = max_delay - n_prime; % because x was shifted by n_prime in generation
    idx = find(lags == lag_wanted, 1);
    if ~isempty(idx)
        range_profile(i) = abs(c_xcorr(idx));
    end
end
if max(range_profile) > 0
    range_profile = range_profile / max(range_profile); % normalize, matches Fig.10 y-axis in [0,1.2]
end

% --- LS-Capon spatial spectrum at the 20th range resolution bin ---
target_bin = 20;
delay_comp = max_delay - target_bin;
if delay_comp < 0 || delay_comp + N > size(r,2)
    error('experiment1_range_angle:badDelay', 'Target range bin out of simulated window.');
end
r_bin = r(:, delay_comp + (1:N)); % M x N snapshots delay-compensated to this bin

Rhat = (r_bin * r_bin') / N; % sample covariance
Rhat = Rhat + 1e-6 * trace(Rhat)/M * eye(M); % diagonal loading for numerical stability (our choice)

capon_spectrum = zeros(1, numel(theta_grid));
Rinv = inv(Rhat); %#ok<MINV>  % small M, direct inverse is fine and matches Capon's classical formula
for l = 1:numel(theta_grid)
    al = A_grid(:,l);
    capon_spectrum(l) = 1 / real(al' * Rinv * al);
end
if max(capon_spectrum) > 0
    capon_spectrum = capon_spectrum / max(capon_spectrum);
end

out = struct('range_bins', range_bins, 'range_profile', range_profile, ...
    'theta_grid', theta_grid, 'capon_spectrum', capon_spectrum, ...
    'target_list', target_list);
end

% =========================================================================
function out = experiment2_rmse_detection(r, x, params, target_list, max_delay, N) %#ok<INUSD>
%EXPERIMENT2_RMSE_DETECTION  Angle RMSE (eq.47) + detection probability (Fig.12).
M = params.M;
theta_grid = params.angle_grid_deg;
A_grid = steering_vector(theta_grid, M);

% All 3 targets share the same range bin in this experiment (Sec. V-C).
target_bin = target_list(1).range_bin;
delay_comp = max_delay - target_bin;
r_bin = r(:, delay_comp + (1:N));

Rhat = (r_bin * r_bin') / N;
Rhat = Rhat + 1e-6 * trace(Rhat)/M * eye(M); % diagonal loading (our choice)
Rinv = inv(Rhat); %#ok<MINV>

capon_spectrum = zeros(1, numel(theta_grid));
for l = 1:numel(theta_grid)
    al = A_grid(:,l);
    capon_spectrum(l) = 1 / real(al' * Rinv * al);
end

% --- Peak search & assignment to true targets (robust nearest-peak match) ---
true_angles = [target_list.angle_deg];
[pk_vals, pk_locs] = findpeaks_simple(capon_spectrum, theta_grid);
est_angles = nan(size(true_angles));
if ~isempty(pk_locs)
    % Sort peaks by amplitude (descending), assign nearest unused peak to
    % each true target -- avoids double-assigning one peak to two targets.
    [~, order] = sort(pk_vals, 'descend');
    used = false(size(pk_locs));
    for t = 1:numel(true_angles)
        best_d = inf; best_j = -1;
        for jj = 1:numel(order)
            j = order(jj);
            if used(j), continue; end
            d = abs(pk_locs(j) - true_angles(t));
            if d < best_d
                best_d = d; best_j = j;
            end
        end
        if best_j > 0 && best_d < 15 % reject implausible matches (our choice, deg)
            est_angles(t) = pk_locs(best_j);
            used(best_j) = true;
        end
    end
end

valid = ~isnan(est_angles);
if any(valid)
    rmse = sqrt(mean((true_angles(valid) - est_angles(valid)).^2)); % eq. (47), single-trial version
else
    rmse = NaN;
end

% --- Detection: energy-threshold test at each true target's Capon output ---
% Neyman-Pearson threshold for exponential |output|^2 statistic under
% complex-Gaussian noise, calibrated to the requested false-alarm prob.
Pfa = params.Pfa;
noise_floor = median(capon_spectrum); % robust noise-power proxy (our choice)
threshold = -noise_floor * log(Pfa);   % NP threshold for exponential distribution
detections = false(size(true_angles));
for t = 1:numel(true_angles)
    [~, idx] = min(abs(theta_grid - true_angles(t)));
    detections(t) = capon_spectrum(idx) > threshold;
end
detection_flag = all(detections); % "detected" if all targets cross threshold

out = struct('rmse', rmse, 'est_angles', est_angles, 'true_angles', true_angles, ...
    'capon_spectrum', capon_spectrum, 'theta_grid', theta_grid, ...
    'detection_flag', detection_flag);
end

% =========================================================================
function [pk_vals, pk_locs] = findpeaks_simple(y, x)
%FINDPEAKS_SIMPLE  Minimal local-maximum peak finder (avoids Signal
%                   Processing Toolbox dependency for findpeaks()).
pk_vals = [];
pk_locs = [];
for i = 2:numel(y)-1
    if y(i) > y(i-1) && y(i) > y(i+1)
        pk_vals(end+1) = y(i); %#ok<AGROW>
        pk_locs(end+1) = x(i); %#ok<AGROW>
    end
end
end