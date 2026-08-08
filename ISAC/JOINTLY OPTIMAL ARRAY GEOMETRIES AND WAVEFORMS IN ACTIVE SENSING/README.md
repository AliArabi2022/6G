# Reproduction: Jointly Optimal Array Geometries and Waveforms in Active Sensing

MATLAB reproduction of:
*"Jointly Optimal Array Geometries and Waveforms in Active Sensing: New
Insights into Array Design via the Cramer-Rao Bound"* (5-page ICASSP-style
paper).

## Requirements
- MATLAB R2020a or later (no special toolboxes needed for the core code)
- **CVX** (http://cvxr.com/cvx/) — only needed for
  `verify/cvx_verify_optimal_waveform.m`. Every other script runs without it.
- No datasets required — this is a purely theoretical/simulation paper.

## Project structure
```
Project/
├── main.m                        # orchestrates everything, run this first
├── config/
│   └── parameters.m              # all constants (Nt, Nr, L, SNR range, ...)
├── utils/
│   ├── index_set.m               # U_N = {0,...,N-1} notation
│   ├── spatial_variance.m        # chi(D), eq. (3)
│   └── steering_vector.m         # a(omega) steering vector
├── arrays/
│   ├── optimal_rx_array.m        # Theorem 1 / eq. (10): clustered Rx array
│   ├── optimal_tx_array.m        # Corollary 1 / eq. (11): optimal Tx array
│   ├── equal_variance_rx_array.m # Fig. 1(b) comparison array
│   ├── ula_array.m               # Fig. 1(c) comparison array
│   ├── mimo_nested_array.m       # Fig. 1(d) comparison array
│   └── sum_coarray.m             # D_Sigma + contiguity/nonredundancy check
├── crb/
│   └── compute_crb.m             # single-target CRB, eq. (2)-(3)
├── waveform/
│   └── optimal_waveform_closedform.m  # eq. (5), coherent beamforming waveform
├── estimator/
│   └── mle_beamformer.m          # joint Tx-Rx MLE (Section 4)
├── sim/
│   └── monte_carlo_mle.m         # Monte Carlo MSE-vs-SNR study (Fig. 2)
├── verify/
│   ├── cvx_verify_optimal_waveform.m     # SDP check of eq. (5) via CVX
│   └── verify_theorem1_bruteforce.m      # combinatorial check of Theorem 1
├── plots/
│   ├── plot_fig1.m                # array geometry diagrams
│   └── plot_fig2.m                # CRB + MLE MSE vs SNR
└── results/                       # outputs land here (.png, .mat)
```

## How to run
```matlab
cd Project
main
```
This executes steps 1–9 in order (see comments at the top of `main.m`).
Reduce `cfg.n_trials` in `config/parameters.m` (e.g. to 200) for a fast
smoke test before running the full 1e4-trial Monte Carlo study.

## Expected outputs
- `results/fig1_reproduction.png` — 4-panel array geometry diagram
- `results/fig2_reproduction.png` — CRB + MLE MSE vs SNR, semilog-y
- `results/reproduction_results.mat` — all numerical results
- Console output validating:
  - Corollary 1 (contiguous & nonredundant sum co-array for the optimal
    array, `Nt*Nr` = 24 distinct positions 0..23)
  - Theorem 1 (brute-force search confirms clustered array maximizes chi_r)
  - eq. (5) (CVX SDP recovers the closed-form rank-1 beamforming waveform)

## Expected runtime
- Steps 1–7: < 1 second
- Step 8 (Monte Carlo, 4 geometries × ~17 SNR points × 1e4 trials each):
  several minutes on a typical laptop (this is the dominant cost — see
  "Optimization" below)

## Assumptions / known limitations (read before trusting absolute numbers)
1. **CRB prefactor (`cfg.kappa`)**: OCR of the paper's exact CRB scalar
   constant was unreliable. The implemented functional form,
   `CRB ~ sigma^2 / (kappa * 2*T*|gamma|^2*(chi_t+chi_r))`, is solid
   (matches the paper's stated 1/SNR and 1/(chi_t+chi_r) dependence,
   and the *relative ordering* of the four geometries' CRB curves will
   be correct), but `kappa` may need calibration if you need the curve
   to sit at the exact published dB values on Fig. 2.
2. **Fig. 1(c) ULA and 1(d) canonical MIMO nested array**: exact
   position sets weren't legible in the source; reconstructed as the
   standard textbook baselines, consistent with the apertures (5 and 20
   respectively) stated in the paper's text.
3. **Fig. 1(b) array**: hardcoded from the specific "equal sum of
   squares" numeric identity the paper cites (5²+6²+7² = 1²+3²+10²) —
   this is NOT a general formula for arbitrary Nr, only a reconstruction
   of that one illustrative example.
4. **Not executed**: this code was written without access to a
   MATLAB/Octave interpreter. The array/co-array arithmetic was
   hand-verified (see chat), but `main.m` has not been run end-to-end —
   please do a first-run sanity check, especially on the `kron`-based
   MLE objective in `estimator/mle_beamformer.m` and the CVX block.

## Optimization notes (Phase 13)
- `sim/monte_carlo_mle.m` is the bottleneck. To speed up:
  - Replace the inner `for trial = 1:cfg.n_trials` loop with a
    vectorized noise draw + `parfor` (Parallel Computing Toolbox) over
    trials or SNR points.
  - `mle_beamformer.m`'s per-angle loop can be vectorized further using
    `pagemtimes`/broadcasting instead of the `for m = 1:M` loop, at the
    cost of higher memory use.
- No GPU acceleration necessary at this problem scale (small matrices).

## Debugging notes (Phase 12)
- Grid-search quantization in `mle_beamformer.m` introduces a floor on
  achievable MSE at high SNR (visible as MSE curves flattening instead
  of continuing to decrease). Increase `cfg.omega_grid_N` or add a
  local refinement (e.g. golden-section search) around the grid maximum
  if you see this artifact and want to match the paper's high-SNR CRB
  asymptote more closely.
- `sum_coarray.m`'s nonredundancy/contiguity check is a good regression
  test: re-run it any time you modify `optimal_rx_array.m` or
  `optimal_tx_array.m` to confirm Corollary 1 still holds.
