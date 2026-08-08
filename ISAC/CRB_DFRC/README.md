# CRB-Optimal DFRC Beamforming — MATLAB Reproduction

Reproduction of:

> F. Liu, Y.-F. Liu, A. Li, C. Masouros, Y. C. Eldar, "Cramér-Rao Bound
> Optimization for Joint Radar-Communication Design," arXiv:2101.12530v1.

Benchmarked against:
- Design 1: X. Liu, T. Huang, N. Shlezinger, Y. Liu, J. Zhou, Y. C. Eldar,
  "Joint Transmit Beamforming for Multiuser MIMO Communications and
  Radar," arXiv:1912.03420 (ref [10] of the CRB paper).
- Design 2: F. Liu, C. Masouros, A. Li, H. Sun, L. Hanzo, "MU-MIMO
  Communications with MIMO Radar: From Co-existence to Joint
  Transmission," arXiv:1707.00519 (ref [11] of the CRB paper).

## Requirements

- MATLAB (R2020a or later recommended)
- CVX (with SDPT3 or SeDuMi solver backend), on the MATLAB path with
  `cvx_setup` already run

## Quick start

```matlab
>> main
```

Runs Figures 2–7 in order, writing `results/figN.png` and
`results/figN_data.mat` for each (plus a plain `output/figN.png` copy —
see below). Re-running `main` skips any figure
whose `_data.mat` already exists (delete it to force a rerun). A
failure in one figure is caught and logged; the run continues with
the next figure.

Expect a multi-hour run for the full reproduction at the default
`Ntrials = 500` (see `config/parameters.m`) — Fig. 4's exhaustive MLE
grid search and the K=14 point of Fig. 5 are the long poles. Reduce
`Ntrials` for a quick smoke-test.

## Project structure

```
config/parameters.m          Central configuration (all physical/algorithmic constants)
initialization/               Random channel and target generators
utilities/                     Steering vectors, CRB/SINR/beampattern metrics,
                                MLE search, rank-1 extraction, unit conversion
algorithms/                    The 4 proposed-method algorithm branches
                                (Theorems 1-4) + top-level dispatcher
benchmarks/                    Design 1 (ref [10]) and Design 2 (ref [11]),
                                adapted to a total-power constraint
postprocessing/aggregate_mc.m  Per-method Monte Carlo averaging w/ feasibility filtering
plots/generate_fig{2..7}.m     One self-contained script per figure
main.m                         Orchestrator with checkpointing
results/                       Output .png + .mat (created at runtime; this is the
                                checkpoint store and the styled/dual-format export)
output/                        Plain saveas(fig,...) PNG copy of each figure, written
                                at the end of each generate_figN.m (created at runtime)
```

## Key modeling assumptions (see PROGRESS.md history / conversation log
for full derivation)

| ID | Assumption |
|----|------------|
| A1 | Monte Carlo trial count not stated in paper → `Ntrials = 500` |
| A2 | Design 1/2 benchmarks adapted to a **total** power constraint (paper's own budget form), not the per-antenna equality of their source papers — **user-confirmed** |
| A3 | Fig. 5 reproduced with **K = 14 and K = 6** (legend values) — **user-confirmed** |
| A4 | Point-target `alpha_true` phase fixed at 0 (real, positive); only `|alpha|` is physically meaningful to the CRB |
| A5 | All angles stored internally in radians; degrees only at the plotting boundary |
| A6 | Theorem 1 Case-2 `x2` phase convention chosen to maximize `|a'w1|`; validated against CVX in Fig. 2 (phase is otherwise non-unique and metric-invariant) |
| A7 | Design 1's cross-correlation loss term is zero for the CRB paper's single-mainlobe target (no direction pairs exist) |
| A8 | Global RNG seeded `rng(42)` in `main.m` for reproducibility |

## Known reproduction caveats

- Fig. 4's MLE RMSE will plateau near the 0.1° grid-quantization floor
  at high radar SNR — this is an expected artifact of the paper's own
  stated grid resolution, not a bug.
- Design 2 (comm-only precoding, DoF ≤ K) is expected to show a
  qualitatively worse beampattern/CRB than Design 1 and the proposed
  method when K < Nt — this is the paper's own predicted effect, not
  a solver failure.
- CVX SDP infeasibility at high SINR thresholds is tracked per-method
  via `feasible_fraction` in each figure's `_data.mat` and excluded
  from that method's Monte Carlo average at that sweep point.

## License / provenance

Independent reverse-engineering reproduction for research purposes.
Not affiliated with the original authors.
