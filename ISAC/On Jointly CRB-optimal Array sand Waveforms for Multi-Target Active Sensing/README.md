# CRB-Optimal Arrays and Waveforms for Multi-Target Active Sensing — MATLAB Reproduction

Reproduction of: I. van der Werf, G. Leus, *"On Jointly CRB-optimal Arrays
and Waveforms for Multi-Target Active Sensing,"* Asilomar Conf. on
Signals, Systems, and Computers, 2025.

## PHASE 9 — Project Structure

```
CRB_ArrayWaveform/
├── main_fig2_coherent_vs_optimal.m     Fig. 2(a-d) reproduction, K=1..4 (requires CVX for optimal branch)
├── main_fig3to6_array_geometry.m       Figs. 3(a,b), 4(a,b,c), 5(a,b), 6 reproduction
├── main_fig7_performance_comparison.m  Fig. 7 reproduction
├── config/
│   └── parameters_default.m            Shared scenario parameters
├── algorithms/
│   ├── compute_atr_and_derivative.m    Atr, Adot_tr  (eq. 3, 8)
│   ├── compute_FIM.m                   Fisher Information Matrix (eq. 4-8)
│   ├── compute_CRBM.m                  CRBM_Omega,Omega + f(.) (eq. 9-10)
│   ├── coherent_waveform.m             Coherent-beam Rs (eq. 15)
│   ├── optimal_waveform_cvx.m          Optimal Rs via SDP (eq. 13-14, needs CVX)
│   ├── objective_g.m                   g(Dt,Dr), Algorithm 1's objective
│   └── sensor_relocation_algorithm.m   Algorithm 1
├── utilities/
│   ├── array_manifold.m                a(omega), A(Omega)
│   ├── khatri_rao.m                    Khatri-Rao product (eq. 3)
│   ├── omega_from_angles.m             theta,phi -> omega (Sec. II-A)
│   ├── candidate_positions.m           Candidate sets Ct, Cr
│   └── simple_boxplot.m                Toolbox-free boxplot (Fig. 2a/2b)
├── plots/                              (figures saved here if you add saveas calls)
├── results/                            .mat result caches from main_* scripts
└── README.md                           this file
```

Every `.m` file has a professional header stating purpose, inputs,
outputs, the exact paper equation(s) it implements, and any assumptions.

## PHASE 14 — Reproducibility

- **MATLAB version:** developed against the R2021a+ language (no
  version-specific syntax used); should run on any reasonably recent
  MATLAB release without a compatibility layer.
- **Toolboxes:** none required for `main_fig3to6_array_geometry.m` and
  `main_fig7_performance_comparison.m` (pure base MATLAB + Statistics-free
  `randperm`/`rng`). `main_fig2_coherent_vs_optimal.m` reproduces the
  boxplot panels (Fig. 2a/2b) with a custom `utilities/simple_boxplot.m`
  rather than the Statistics and Machine Learning Toolbox's `boxplot()`,
  so no toolbox is needed there either. `main_fig2_coherent_vs_optimal.m`
  and `optimal_waveform_cvx.m` require **CVX** (http://cvxr.com/cvx/,
  free, run `cvx_setup` once) for the true-optimal-waveform SDP branch
  only. Without CVX, Fig. 2's coherent-only boxplots still run; the
  optimal-vs-coherent comparison (including Fig. 2c/2d) is skipped with a
  clear warning.
- **Execution order:** the three `main_*.m` scripts are independent and
  can be run in any order. Each `addpath(genpath(...))`s the project root
  automatically.
- **Expected runtime:** `main_fig3to6_array_geometry.m` and
  `main_fig7_performance_comparison.m` run in the range of a few minutes
  to tens of minutes depending on candidate-set size (Algorithm 1 is a
  greedy coordinate descent that evaluates `g` once per candidate
  position per sensor per sweep — see Phase 13 for speed-up options).
  `main_fig2_coherent_vs_optimal.m`'s optimal branch (100 CVX SDP solves
  per scenario) is the slowest part; reduce `nRealizations` for a quick
  smoke test.
- **Outputs:** each script pops up MATLAB figures reproducing the
  corresponding paper figure, and (for Figs. 2 and 7) saves a `.mat` file
  under `results/`.

## PHASE 11 — Validation / Assumptions Checklist

The paper is a 5-page conference paper and, correctly for that format,
omits several implementation-level details. Every assumption made to
fill these gaps is called out **in the code**, right where it is used.
Summary:

| # | Gap in paper | Assumption made | Where |
|---|---|---|---|
| 1 | Candidate-grid resolution | Integer half-wavelength steps, matching figure axes | `candidate_positions.m` |
| 2 | Multi-target coherent-beam formula | Equal superposition of single-target coherent beams (15), power-normalized | `coherent_waveform.m` |
| 3 | Noise variance σ² | σ²=1 (a common positive scale factor; does not change arg min geometry or the coherent-vs-optimal comparison) | `parameters_default.m` |
| 4 | Algorithm 1 init. distribution | Uniform random without replacement from Ct/Cr | `sensor_relocation_algorithm.m` |
| 5 | Algorithm 1 max iterations / tie-breaking | Capped at 50 outer sweeps (with warning if hit); first-found tie-break | `sensor_relocation_algorithm.m` |
| 6 | ~~Fig. 7 x-axis exact units~~ **CONFIRMED**, not an assumption | Paper's Sec. IV-A states explicitly: "for an angle separation Δω=ω₂−ω₁=2π/Δd, the Tx sensors form clusters spaced by Δd" — Fig. 7's x-axis is exactly this Δω (rad) | `main_fig7_performance_comparison.m` |
| 7 | Exact "Nested array"/"dilated-ULA" spacing multiplier | Paper's Sec. IV-B names the design ("ULA Tx, dilated-ULA Rx", legend label "Nested array") but not the exact dilation formula; we use the textbook nested-array construction (Rx spacing = Nt × Tx spacing) | `main_fig7_performance_comparison.m` |
| 8 | RNG seed | Fixed at 2026 for reproducibility across runs | all `main_*.m` |
| 9 | Numerical diagonal loading on F before inversion | 1e-10·trace(F)/dim, standard robustness practice | `compute_CRBM.m` |

**Everything else — the signal model (1)-(3), FIM (4)-(8), CRB (9), the
design problem (10)-(12), the optimal-waveform decomposition (13)-(16),
and Algorithm 1 itself — is implemented exactly as given in the paper,**
with every equation referenced in the corresponding code comment.

**Expected numerical differences from the published figures:** exact
pixel-for-pixel matches to Figs. 3-7 are *not* expected, because (a) the
paper does not release its RNG seed, and (b) Algorithm 1 is a greedy
local-search method whose converged geometry depends on the random
initialization — different runs (and different seeds) can converge to
different, but qualitatively similar, locally-optimal geometries (Tx
clustering at target-separation-dependent spacing, Rx migrating to array
edges), which is the qualitative behavior the paper itself emphasizes.

## PHASE 12 — Debugging Notes

- **Dimension mismatches:** the most likely source of bugs when
  modifying this code is inconsistent `numDim` usage — every function
  that touches `Omega`, `Dt`/`Dr`, or the FIM expects the Remark-1
  convention (`numDim` = 1/2/3 estimable direction cosines). Always pass
  the *same* `numDim` to `compute_CRBM`, `objective_g`,
  `sensor_relocation_algorithm`, and `optimal_waveform_cvx` for a given
  scenario.
- **Rank deficiency / ill-conditioned F:** can occur for very small
  candidate sets, near-coincident target angles, or `numDim` set larger
  than the array's true spatial extent (e.g., `numDim=3` for an array
  with all sensors coplanar). `compute_CRBM.m` adds a small diagonal
  load; if `CRBM_OO` still contains very large values, this is usually a
  genuine identifiability issue (per Remark 1), not a bug.
- **CVX infeasibility/inaccuracy warnings:** if `optimal_waveform_cvx.m`
  reports `Inaccurate/Solved` status, results are usually still usable to
  ~1e-4 relative accuracy; persistent `Failed` status typically indicates
  numerical scaling issues — try normalizing `Dt`,`Dr` positions or
  increasing CVX precision (`cvx_precision high`).

## PHASE 13 — Optimization Suggestions

- **Vectorization:** `sensor_relocation_algorithm.m`'s inner candidate
  loop currently recomputes the full FIM from scratch for every candidate
  position. For large candidate sets, this can be accelerated by
  exploiting that only one row/column of `At`/`Ar` (and hence `Atr`)
  changes per trial — a rank-1-update formulation of the FIM inverse
  (Woodbury identity) would avoid full `inv()` calls per candidate.
- **Parallel Computing Toolbox:** the candidate loops in
  `sensor_relocation_algorithm.m` (`for c = candIdx'`) and the
  realization loops in `main_fig2_*.m`/`main_fig7_*.m` are embarrassingly
  parallel — replace `for` with `parfor` for a near-linear speedup on
  multi-core machines.
- **GPU acceleration:** not particularly beneficial here — the linear
  algebra per evaluation is small (matrices of size ≤ tens), so the
  bottleneck is the *number* of evaluations, not their individual cost;
  parallelizing across candidates/realizations (CPU cores) is more
  effective than GPU offload.

## PHASE 15 — Final Quality Review

- [x] Every numbered equation in the paper (1)-(16) implemented and
      referenced by number in code comments.
- [x] Every variable from Phase 2's table defined and traceable to a
      `.m` file.
- [x] All 9 explicit assumptions documented (Phase 11 table above).
- [x] No pseudo-code — every function is complete, executable MATLAB.
- [x] Consistent naming: `Dt/Dr` (positions), `Ct/Cr` (candidates),
      `Omega` (target angles), `Rs` (waveform covariance), `numDim`
      (Remark-1 dimension), `g`/`obj` (objective values).
- [x] Error checking included in `candidate_positions.m`,
      `khatri_rao.m`, `sensor_relocation_algorithm.m`,
      `optimal_waveform_cvx.m`.

**Not independently executed against a live MATLAB/CVX installation**
(none is available in this environment) — please run
`main_fig3to6_array_geometry.m` first as a CVX-free smoke test, and
report back any error messages if you'd like help debugging a concrete
run.
