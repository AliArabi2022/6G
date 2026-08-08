# Full Documentation: Variable Table, Line-by-Line Explanation, Validation & QA

This supplements `README.md`. It covers the remaining phases of the
reproduction template: the variable table (Phase 2), line-by-line
explanations of the core files (Phase 8), the validation/debugging record
based on your first successful run (Phases 11–12), reproducibility
instructions (Phase 14), and the final QA checklist (Phase 15).

---

## PHASE 2 — Variable Table

| Symbol | Name | Meaning | Type/Dim | MATLAB var | Defined in | Input/Output/Intermediate |
|---|---|---|---|---|---|---|
| $N_t$ | Tx sensor count | number of transmit elements | scalar int | `cfg.Nt` | `parameters.m` | Input |
| $N_r$ | Rx sensor count | number of receive elements (even) | scalar int | `cfg.Nr` | `parameters.m` | Input |
| $L$ | Aperture | max physical sensor position (min fixed at 0) | scalar int | `L_opt`, `L` | `optimal_tx_array.m` | Input/derived |
| $D_t$ | Tx array geometry | Tx sensor positions (half-$\lambda$ units) | $1\times N_t$ | `D_t` | `arrays/*.m` | Input/Output |
| $D_r$ | Rx array geometry | Rx sensor positions | $1\times N_r$ | `D_r` | `arrays/*.m` | Input/Output |
| $D_\Sigma$ | Sum co-array | Minkowski sum $D_t\oplus D_r$ | set, $\le N_tN_r$ | `D_sigma` | `sum_coarray.m` | Output |
| $\chi(D)$ | Spatial variance | mean squared deviation from centroid, eq.(3) | scalar | `chi`, `chi_t`, `chi_r` | `spatial_variance.m` | Intermediate |
| $\omega$ | Electrical angle | target DOA parameter, $\in[-\pi,\pi)$ | scalar/vector | `omega`, `cfg.omega_true` | throughout | Input/Output |
| $\gamma$ | Reflectivity | complex target amplitude (unknown nuisance) | complex scalar | `cfg.gamma_true`, `gamma` | `parameters.m` | Input |
| $\sigma^2$ | Noise variance | i.i.d. circular Gaussian noise power | scalar/vector | `sigma2` | `compute_crb.m`, `monte_carlo_mle.m` | Input |
| $S$ | Waveform matrix | Tx spatio-temporal waveform, eq.(1) | $T\times N_t$ | `S` | `optimal_waveform_closedform.m` | Output |
| $T$ | Waveform length | number of fast-time samples | scalar int | `cfg.T` | `parameters.m` | Input |
| $u$ | Temporal weight vector | unit-power beamforming weights, eq.(5) | $T\times1$ | `cfg.u`, `u` | `parameters.m` | Input |
| $a_t(\omega)$ | Tx steering vector | $[e^{j\omega d}]_{d\in D_t}$ | $N_t\times1$ | `a_t`, `A_t` | `steering_vector.m` | Intermediate |
| $a_r(\omega)$ | Rx steering vector | $[e^{j\omega d}]_{d\in D_r}$ | $N_r\times1$ | `a_r`, `A_r` | `steering_vector.m` | Intermediate |
| $y$ | Received data | eq.(1) measurement vector | $TN_r\times1$ | `y` | `monte_carlo_mle.m` | Intermediate |
| $n$ | Noise vector | i.i.d. $\mathcal{CN}(0,\sigma^2 I)$ | $TN_r\times1$ | `noise` | `monte_carlo_mle.m` | Intermediate |
| $\kappa$ | CRB calibration constant | absorbs uncertain OCR'd scalar prefactor | scalar, default 1 | `cfg.kappa` | `parameters.m` | Assumption/Input |
| $R_s$ | Waveform covariance | $E[ss^H]$, PSD, used in CVX SDP only | $N_t\times N_t$ | `R_s` | `cvx_verify_optimal_waveform.m` | Intermediate |
| $P$ | Transmit power budget | trace constraint on $R_s$ | scalar | `P` | `cvx_verify_optimal_waveform.m` | Input |
| SNR (dB) | Signal-to-noise ratio | $10\log_{10}(|\gamma|^2/\sigma^2)$ | scalar/vector | `cfg.SNR_dB_range`, `snr_db` | `parameters.m` | Input |
| MSE | Mean squared error | Monte Carlo estimator performance | scalar/vector | `mse` | `monte_carlo_mle.m` | Output |
| $\hat\omega$ | MLE estimate | argmax of joint beamformer objective | scalar | `omega_hat` | `mle_beamformer.m` | Output |

---

## PHASE 8 — Line-by-Line Explanation of Core Files

### `arrays/optimal_rx_array.m` (Theorem 1, eq. 10)
```matlab
half = Nr / 2;
D_r = [0:(half-1), (L-half+1):L];
```
- **Why it exists**: implements the closed-form clustered array — the unique
  Rx geometry maximizing $\chi_r$ under an aperture constraint.
- **Which equation**: eq. (10), via the "push mass to the extremes"
  argument of Theorem 1/Lemma 1.
- **Expected output**: for `Nr=6, L=14` → `[0 1 2 12 13 14]` (verified above:
  $\chi_r=36.667$, matching brute-force search exactly).
- **Possible errors**: `Nr` odd (the construction assumes an even split);
  `L < Nr-1` (not enough room for `Nr` distinct integers) — both are
  caught by the input-validation block above this snippet.

### `arrays/optimal_tx_array.m` (Corollary 1, eq. 11)
```matlab
U_Nt  = index_set(Nt);
D_t   = (Nr/2) * U_Nt;
L_opt = (Nt + 1) * Nr / 2 - 1;
```
- **Why it exists**: constructs the companion Tx array that makes the
  *sum* co-array $D_t\oplus D_r$ both contiguous and nonredundant.
- **Which equation**: eq. (11), $D_t^\star=\frac{N_r}{2}\mathcal U_{N_t}$.
- **Expected output**: `Nt=4, Nr=6` → `D_t=[0 3 6 9]`, `L_opt=14` — this is
  exactly the pair your run confirmed via `sum_coarray.m`
  (`contiguous=true, nonredundant=true, |D_Sigma|=24`).
- **Possible errors**: none expected for valid even `Nr`; the formula is a
  direct closed-form, no iteration/convergence to worry about.

### `crb/compute_crb.m`
```matlab
chi_t = spatial_variance(D_t);
chi_r = spatial_variance(D_r);
crb = sigma2 ./ (kappa * 2 * T * abs(gamma)^2 * (chi_t + chi_r));
```
- **Why it exists**: this is the objective every other module is built to
  minimize — it's the metric plotted in Fig. 2 (solid lines).
- **Which equation**: eq. (2)-(3) and the Theorem 1 discussion
  (CRB $\propto 1/(\chi_t+\chi_r)$ under the optimal waveform).
- **Expected output**: monotonically decreasing in SNR (since
  `sigma2` shrinks as SNR grows for fixed `gamma`); geometry (a) and (b)
  should give *identical* CRB curves (equal $\chi_r$, see the Python
  cross-check above: both give $\chi_r=36.667$), which is a good
  regression check once you view `fig2_reproduction.png`.
- **Possible errors**: `kappa` misconfigured — this only rescales the
  y-axis, it does not change curve shape or relative ordering.

### `estimator/mle_beamformer.m`
```matlab
Sat = S * A_t(:,m);
h   = kron(Sat, A_r(:,m));
num = abs(y' * h)^2;
den = norm(Sat)^2;
obj_vals(m) = num / den;
```
- **Why it exists**: implements the paper's stated joint Tx-Rx beamformer
  MLE (Section 4) — the matched-filter statistic normalized by transmit
  gain, searched over a grid of candidate angles.
- **Which equation**: Section 4, $\hat\omega=\arg\max |y^H(Sa_t\otimes
  a_r)|^2/\|Sa_t\|_2^2$.
- **Expected output**: for high SNR, `omega_hat` should land very close
  to `cfg.omega_true` (0); the loop over `m` produces a beampattern-like
  objective curve useful for diagnosing spatial aliasing (see the MIMO
  nested array's known aliasing issue, discussed in the paper's Section 4).
- **Possible errors**: grid quantization (see Phase 12 below); the `kron`
  ordering must match `y`'s own stacking convention — both are built
  consistently as `(T*Nr)x1` with Rx varying fastest, so this is internally
  consistent, but if you ever change how `y` is stacked elsewhere, update
  both together.

### `sim/monte_carlo_mle.m`
```matlab
sigma2 = abs(cfg.gamma_true)^2 / (10^(snr_db/10));
noise = (sigma/sqrt(2)) * (randn(...) + 1i*randn(...));
y = cfg.gamma_true * h_true + noise;
omega_hat = mle_beamformer(y, S, D_t, D_r, omega_grid);
```
- **Why it exists**: reproduces Fig. 2's dashed/marker MLE curves via
  direct Monte Carlo, matching the paper's stated $10^4$-trial setup.
- **Which equation**: SNR definition from Section 4,
  $\mathrm{SNR}=10\log_{10}(|\gamma|^2/\sigma^2)$.
- **Expected output**: MSE curves that track the CRB at high SNR and
  flatten/diverge from it at low SNR (the classic "threshold effect"),
  matching the qualitative description in Section 4 about MLE performance
  differing between arrays (a) and (b) despite identical CRB.

---

## PHASE 11 — Validation (updated with your run's results)

| Check | Expected | Your result | Status |
|---|---|---|---|
| Corollary 1: $D_\Sigma$ contiguous | `true` | `true` | ✅ |
| Corollary 1: $D_\Sigma$ nonredundant | `true` | `true` | ✅ |
| $|D_\Sigma|$ | 24 | 24 | ✅ |
| Theorem 1 brute-force $\chi_r$ match | equal | `36.666667` = `36.666667` | ✅ |
| CVX SDP recovers closed-form eq.(5) | equal objective, rank 1 | `4.000000` = `4.000000`, rank 1 | ✅ |
| Fig. 1 export | file written | fixed (directory-creation patch) | ✅ (pending your re-run) |
| Fig. 2 export | file written | not yet run | ⏳ pending |
| Geometries (a),(b) identical CRB curve | overlapping lines | not yet visually confirmed | ⏳ pending |

**Remaining "possible inconsistency" to watch for**, per the assumptions
flagged earlier: absolute CRB values depend on the uncalibrated `kappa`;
if you have access to the published Fig. 2 image and want an exact
numerical match (not just correct shape/ordering), read off one
(SNR, CRB) point from the paper's plot and solve for `kappa` — I'm happy
to do that calibration with you if you share a data point.

## PHASE 12 — Debugging Catalog

| Symptom | Likely cause | Fix |
|---|---|---|
| `exportgraphics` "no such file" | `results/` missing (empty dirs dropped by zip) | fixed via `mkdir` guard (already applied) |
| MSE flattens at high SNR instead of continuing to fall below CRB asymptote | grid quantization floor in `mle_beamformer.m` | increase `cfg.omega_grid_N`, or add local refinement around the grid max |
| CVX block errors/skips | CVX not installed/on path | expected — wrapped in `try/catch`, rest of pipeline unaffected |
| Monte Carlo very slow | nested `for` loops, `cfg.n_trials=1e4` × ~17 SNR × 4 geometries | see Phase 13 optimization notes in `README.md` (vectorize/`parfor`) |
| Overflow/underflow | none expected — all quantities are $O(1)$–$O(10)$ magnitude, no exponentials of large arguments | n/a |

## PHASE 14 — Reproducibility Summary
- **MATLAB version**: R2020a+ (uses `exportgraphics`, introduced R2020a)
- **Toolboxes**: none required for core pipeline; **CVX** optional, only for `verify/cvx_verify_optimal_waveform.m`
- **Execution order**: `main.m` end-to-end (see numbered steps in its header comment)
- **Inputs**: none external — everything is generated from `config/parameters.m`
- **Outputs**: `results/fig1_reproduction.png`, `results/fig2_reproduction.png`, `results/reproduction_results.mat`
- **Expected runtime**: seconds (steps 1–7) + minutes (step 8, Monte Carlo — dominant cost)

## PHASE 15 — Final Quality Review

- ✅ Every named equation (1)-(3), (5), (8)/Theorem 1, (10)-(11)/Corollary 1 implemented and referenced in code comments
- ✅ Every array-geometry variable defined with a documented construction
- ✅ Theorem 1 and Corollary 1 independently confirmed (brute force + your MATLAB run + my Python cross-check)
- ✅ eq. (5) optimal waveform confirmed via CVX SDP (genuine convex-optimization use case; combinatorial array problem correctly routed to brute force instead)
- ⏳ Fig. 1 / Fig. 2 visual outputs — pending your re-run with the directory fix
- ⚠️ Open assumption: CRB scalar prefactor `kappa` (functional form, not absolute calibration, is verified)
- ⚠️ Open assumption: Fig. 1(c)/(d) exact position sets are standard-baseline reconstructions, not OCR-confirmed verbatim

Send me the Fig. 1/Fig. 2 output (or just describe what you see) once the full run completes, and I'll help interpret it against the paper's Fig. 1/Fig. 2, or calibrate `kappa` if you want an exact numeric match.
