<!-- Banner placeholder: add a project banner image here, e.g. ![Banner](docs/banner.png) -->

<div align="center">

# CRB-Optimal Arrays and Waveforms for Multi-Target Active Sensing
### An Independent MATLAB Reproduction

🌍 **Languages**

🇺🇸 English (Current) · 🇮🇷 [فارسی → README.fa.md](README.fa.md)

<!-- Badges placeholder — replace with real shields once the repository is public -->
<!-- ![MATLAB](https://img.shields.io/badge/MATLAB-R2021a%2B-orange) ![CVX](https://img.shields.io/badge/optional-CVX-blue) ![License](https://img.shields.io/badge/license-TBD-lightgrey) -->

</div>

---

## Overview

This repository is an independent MATLAB implementation of the array-waveform
design method proposed in:

> I. van der Werf and G. Leus, *"On Jointly CRB-optimal Arrays and Waveforms
> for Multi-Target Active Sensing,"* 2025 59th Asilomar Conference on
> Signals, Systems, and Computers, 2025.
> DOI: [10.1109/IEEECONF67917.2025.11443763](https://doi.org/10.1109/IEEECONF67917.2025.11443763)

The paper studies how to jointly place transmit (Tx) and receive (Rx) sensors
and design a transmit waveform so that a MIMO radar system estimates the
angles of several targets as accurately as possible, measured through the
Cramér-Rao Bound (CRB). It shows that a simple *coherent* transmit beam is
close to optimal for this task, and proposes a local-search algorithm that
places sensors to further reduce the CRB.

This repository turns that method into runnable, documented, tested-against-the-figures
MATLAB code. It is not the authors' own implementation and is not affiliated
with Delft University of Technology. It was built by reading the paper as a
specification and translating every equation, algorithm step, and figure
into code.

## Motivation

Published radar and array-processing papers rarely release their simulation
code. Reproducing their figures from the paper text alone forces a reader to
resolve ambiguities the authors did not need to write down — noise variance,
random seeds, tie-breaking rules, axis units, candidate-grid resolution. This
project exists to do that resolution work once, carefully, and document every
choice, so that:

- students can study a full working implementation of a CRB-based array
  design method instead of only the equations;
- researchers extending this line of work have a starting codebase instead
  of a blank file;
- anyone checking the paper's claims can see exactly which numbers come
  directly from the paper and which were filled in, and why.

## Key Features

- **Equation-traceable implementation.** Every function header cites the
  exact paper equation it implements (e.g. `compute_FIM.m` → eq. 4–8).
- **No hidden assumptions.** Every place where the paper does not fully
  specify an implementation detail is documented in code, in one place (see
  [Reproducibility](#reproducibility-and-assumptions)).
- **Toolbox-light by default.** Only base MATLAB is required for the array
  geometry and performance-comparison simulations. The Statistics and
  Machine Learning Toolbox's `boxplot()` is deliberately not used; a
  from-scratch box-and-whisker function (`utilities/simple_boxplot.m`) is
  included instead. CVX is required only for the true CRB-optimal waveform
  (a semidefinite program); the coherent-waveform experiments run without it.
- **Numerically defensive.** CRB traces close to zero, ill-conditioned
  geometries, and non-positive values before a `log10` call are handled
  explicitly (`utilities/to_dB_safe.m`) rather than left to produce silent
  `NaN`/complex-number bugs.
- **Self-saving outputs.** Every generated figure is written to `plots/` as
  both `.png` and `.fig`; result tables are cached to `results/` as `.mat`
  files.

## Research Background

*This section summarizes, in the repository author's own words, concepts
introduced in the cited papers. It is not a substitute for reading them, and
no text is reproduced from the originals.*

Active MIMO radar sensing estimates target parameters — here, target angles
— from signals that a radar transmits and receives back after reflection.
The achievable estimation accuracy is bounded below by the Cramér-Rao Bound,
which depends jointly on where the transmit and receive sensors are placed
and on the transmit waveform's spatial covariance.

Prior work (Forsythe & Bliss, 2005; Li, Xu, Stoica, Forsythe & Bliss, 2008)
showed that for a *single* target, the CRB-optimal transmit waveform reduces
to one of two simple forms — a *coherent beam*, which focuses transmit
energy toward the target, or a *difference beam*, which does not — depending
on the array geometry. Van der Werf, Leus & Rajamäki (ICASSP 2025) then
identified array-waveform pairs that are jointly optimal for that
single-target case.

The Asilomar 2025 paper reproduced here extends this line of work to
*multiple* simultaneous targets, a setting where target-to-target coupling
prevents a closed-form solution. Its two central contributions are: (1)
empirical evidence that the coherent beam remains a near-optimal, and much
cheaper, proxy objective even with multiple targets, and (2) an iterative
sensor-relocation algorithm that uses this proxy to find locally CRB-optimal
array geometries, compared against random and canonical (nested-array)
designs.

All scientific ideas above belong to the cited authors. This repository's
contribution is a software implementation, not a scientific one.

## Scientific Scope

Implemented, following the paper's own structure:

- the bistatic MIMO signal model and Khatri-Rao array manifold (paper eq. 1–3);
- the Fisher Information Matrix and Cramér-Rao Bound for target angles,
  including the reduced-dimension treatment for linear/planar arrays (paper
  eq. 4–9, Remark 1);
- the convex optimal-waveform problem and its low-rank parametrization
  (paper eq. 10–14);
- the closed-form coherent and difference beams for the single-target case
  (paper eq. 15–16);
- the iterative sensor-relocation algorithm (paper Algorithm 1) and its
  simplified, coherent-beam-based objective;
- reproductions of the paper's Figures 2, 3, 4, 5, 6, and 7.

Not implemented: the difference-beam contribution to the multi-target
waveform (the paper itself leaves the multi-target closed-form waveform as
an open problem, using only the coherent beam as a practical proxy), and any
extension beyond what the paper describes.

## Repository Architecture

The codebase is split into four layers with distinct responsibilities, so
that a change in one layer does not ripple through the others:

- **`utilities/`** — pure, stateless math and plotting helpers with no
  knowledge of the radar problem (array manifolds, Khatri-Rao products,
  candidate grids, a safe dB conversion, a toolbox-free boxplot, a figure
  saver). These are the kind of functions that could be reused in an
  unrelated array-processing project.
- **`algorithms/`** — the radar/estimation-specific logic (FIM, CRB,
  waveform design, the sensor-relocation algorithm). Each function does one
  step of the pipeline and is unit-sized enough to check against a single
  paper equation.
- **`config/`** — scenario parameters (wavelength, noise variance, target
  angle pool) kept separate from logic, so a parameter sweep never requires
  editing algorithm code.
- **`main_*.m`** — orchestration scripts, one per group of paper figures.
  They call into `utilities/` and `algorithms/` but contain no CRB math
  themselves; they decide *what experiment to run and how to plot it*, not
  *how the CRB is computed*.

This separation exists for three practical reasons: it makes each unit
independently checkable against the paper, it lets `plots/` and `results/`
stay simple output sinks instead of being wired into the math, and it means
extending the project (e.g. adding a new figure or a new objective function)
touches one file instead of several.

## Repository Structure

```
CRB_ArrayWaveform/
├── main_fig2_coherent_vs_optimal.m     Fig. 2(a-d): coherent vs. optimal waveform, K=1..4
├── main_fig3to6_array_geometry.m       Figs. 3(a,b), 4(a,b,c), 5(a,b), 6: array geometries
├── main_fig7_performance_comparison.m  Fig. 7: proposed vs. random vs. nested array
│
├── config/
│   └── parameters_default.m            Shared scenario parameters (lambda, sigma^2, target pool)
│
├── algorithms/
│   ├── compute_atr_and_derivative.m    Joint Tx-Rx steering matrix and its angle derivative
│   ├── compute_FIM.m                   Fisher Information Matrix
│   ├── compute_CRBM.m                  CRB matrix and scalar objective f(.)
│   ├── coherent_waveform.m             Coherent-beam transmit covariance
│   ├── optimal_waveform_cvx.m          CRB-optimal transmit covariance via SDP (needs CVX)
│   ├── objective_g.m                   Algorithm 1's simplified objective g(Dt,Dr)
│   └── sensor_relocation_algorithm.m   The paper's Algorithm 1
│
├── utilities/
│   ├── array_manifold.m                Steering vector/matrix evaluation
│   ├── khatri_rao.m                    Khatri-Rao (column-wise Kronecker) product
│   ├── omega_from_angles.m             Azimuth/elevation to spatial-frequency conversion
│   ├── candidate_positions.m           Candidate Tx/Rx position grids
│   ├── simple_boxplot.m                Box-and-whisker plot without the Statistics Toolbox
│   ├── to_dB_safe.m                    log10 conversion that cannot produce complex/NaN surprises
│   └── save_figure.m                   Saves every figure to plots/ as .png and .fig
│
├── plots/                              Auto-generated figures (created on first run)
├── results/                            Auto-generated .mat result caches (created on first run)
└── README.md
```

## MATLAB Design

Each `main_*.m` script is self-contained: it adds the project's folders to
the MATLAB path, runs its experiment, plots the result in a figure styled to
match the corresponding paper figure, and saves that figure automatically.
None of the three scripts depend on another having been run first.

Reusable logic never lives in a script — it lives in `algorithms/` or
`utilities/`, each function with a header comment stating its purpose,
inputs, outputs, and the paper equation it corresponds to. This means a
function such as `compute_FIM.m` can be called directly from the MATLAB
console for debugging or extended experimentation, without needing to run a
full figure-reproduction script.

Numerical robustness is treated as a first-class concern rather than an
afterthought: diagonal loading before matrix inversion, explicit filtering
of non-finite or non-real values before plotting, and defensive checks in
the box-plot helper were added specifically because ordinary random array
draws can occasionally produce near-singular geometries. These are noted
in-line where they occur.

## Simulation Workflow

Each `main_*.m` script follows the same pattern:

1. Load shared parameters from `config/parameters_default.m`.
2. Build the candidate Tx/Rx position grids for the scenario (`utilities/candidate_positions.m`).
3. Run the relevant algorithm(s) — random draws, `sensor_relocation_algorithm.m`, and/or `optimal_waveform_cvx.m`.
4. Convert results to the same units and scale used in the paper's figures.
5. Plot, styled to match the paper (axis labels, color/marker convention, layout).
6. Save the figure to `plots/` and, where applicable, cache numeric results to `results/`.

## Validation

This implementation was checked against the published paper in two ways.

**Equation-level:** every implemented equation is annotated in code with its
paper equation number, and the Fisher Information Matrix construction was
independently re-derived by hand (a standard mixed real/complex-parameter
Fisher Information derivation) to confirm the block-matrix structure used in
`compute_FIM.m`, after an early implementation draft was found and fixed to
contain a sign error.

**Structural / figure-level:** the array geometries produced by
`main_fig3to6_array_geometry.m` were compared directly against the actual
published Figures 3 and 4 (rendered from the paper PDF). The qualitative
structure the paper reports — transmit sensors clustering at a spacing
determined by the target angular separation, and receive sensors migrating
toward the array edges — was confirmed to match.

**What is *not* claimed:** point-for-point numerical agreement with the
paper's exact figures. Algorithm 1 is a local-search method whose converged
geometry depends on its random initialization, and the paper does not
publish a random seed. Different runs of this code, and runs against the
paper's own (unpublished) implementation, are expected to converge to
different — but structurally similar — local optima. This is a property of
the method itself, stated by the paper, not a limitation specific to this
implementation.

## Reproduced Experiments

| Paper figure | Script | What it shows |
|---|---|---|
| Fig. 2(a–d) | `main_fig2_coherent_vs_optimal.m` | Coherent vs. CRB-optimal waveform performance over random linear/planar arrays, K = 1–4 targets |
| Fig. 3(a,b) | `main_fig3to6_array_geometry.m` | Locally optimal linear array geometry, K = 2, varying target separation |
| Fig. 4(a,b,c) | `main_fig3to6_array_geometry.m` | Locally optimal planar array geometry, K = 2, varying target separation |
| Fig. 5(a,b) | `main_fig3to6_array_geometry.m` | Locally optimal cubic array geometry, K = 2 |
| Fig. 6 | `main_fig3to6_array_geometry.m` | Locally optimal planar array geometry, K = 3 |
| Fig. 7 | `main_fig7_performance_comparison.m` | Proposed algorithm vs. random selection vs. nested array, K = 2 |

## Results

Running the scripts populates `plots/` with one `.png`/`.fig` pair per
sub-figure listed above (for example `fig3a_linear_array.png`,
`fig7_performance_comparison.png`). Numeric results backing Fig. 2 and Fig.
7 are cached to `results/fig2_results.mat` and `results/fig7_results.mat`.
No result files are committed to the repository in advance — they are
generated by running the code, which is the point of a reproducible
simulation.

## Installation

```bash
git clone <repository-url>
cd CRB_ArrayWaveform
```

No build step is required — this is a plain MATLAB script/function
collection.

## Requirements

- MATLAB, R2021a or newer (no version-specific language features are used,
  so somewhat older releases will likely also work).
- No toolboxes required for `main_fig3to6_array_geometry.m` or
  `main_fig7_performance_comparison.m`.
- [CVX](http://cvxr.com/cvx/) (free), only for the CRB-optimal waveform
  branch of `main_fig2_coherent_vs_optimal.m`. Without it, that script still
  runs and produces the coherent-waveform results, with a warning that the
  optimal-waveform comparison was skipped.

## Quick Start

```matlab
% From MATLAB, with the repository folder as the current folder:
main_fig3to6_array_geometry   % no toolboxes needed — good first run
main_fig7_performance_comparison
main_fig2_coherent_vs_optimal % install CVX first for the full comparison
```

## Running Simulations

Each script can be run independently from the MATLAB command window or
editor ("Run" button). They add the repository's subfolders to the MATLAB
path automatically, so no manual `addpath` is needed. Console output reports
progress (which K value, which scenario, how many array realizations
completed) and flags any numerically degenerate random draws it excludes
from the plotted statistics.

## Expected Outputs

- MATLAB figure windows matching the layout and axis convention of the
  corresponding paper figure.
- `.png` and `.fig` files under `plots/`.
- `.mat` result caches under `results/` for Fig. 2 and Fig. 7.
- Console diagnostics, including per-scenario realization counts and (for
  Fig. 2) Fisher Information Matrix conditioning statistics, useful for
  verifying a run before trusting its plot.

## Reproducibility and Assumptions

The source paper is a five-page conference paper and, appropriately for
that format, does not specify every implementation detail. Every gap this
implementation had to fill is documented at the point in the code where it
matters, and summarized here:

| # | Undocumented detail | Choice made | Where |
|---|---|---|---|
| 1 | Candidate-grid resolution | Integer half-wavelength steps, matching the paper's own figure axes | `candidate_positions.m` |
| 2 | Multi-target coherent-beam formula | Equal superposition of the paper's single-target coherent beam (eq. 15), power-normalized | `coherent_waveform.m` |
| 3 | Noise variance σ² | Fixed at 1 (a common positive scale factor that does not change the optimal geometry or the coherent-vs-optimal comparison) | `parameters_default.m` |
| 4 | Algorithm 1 initialization | Uniform random sampling without replacement from the candidate set | `sensor_relocation_algorithm.m` |
| 5 | Algorithm 1 stopping/tie-breaking | Capped at 50 outer sweeps (converges well before this in practice); first-found tie-break | `sensor_relocation_algorithm.m` |
| 6 | Nested-array (canonical) Rx spacing | Standard construction: receive spacing equal to the number of transmit sensors, per classical sparse-array design | `main_fig7_performance_comparison.m` |
| 7 | Random seed | Fixed for run-to-run reproducibility of this codebase (not published by the paper) | all `main_*.m` |
| 8 | Diagonal loading before matrix inversion | Small load proportional to the matrix trace, standard numerical practice | `compute_CRBM.m` |

Everything else — the signal model, the Fisher Information Matrix, the CRB,
the convex waveform design problem, and the sensor-relocation algorithm
itself — follows the paper's equations directly, with the corresponding
equation number cited in the code.

## Repository Highlights

- Every function is under roughly 150 lines and does one job, matching one
  identifiable piece of the paper.
- The Fisher Information Matrix implementation carries an explicit
  derivation comment justifying its block signs, added after an earlier
  version was found to contain an error — kept in place as documentation
  rather than silently fixed, since it is the kind of mistake future
  maintainers are likely to repeat.
- Plotting code (`simple_boxplot.m`, `to_dB_safe.m`) was written to fail
  safely and visibly (dropped-point warnings, non-finite counts printed to
  console) instead of silently producing an empty or misleading plot.

## Related Publications

**Primary paper reproduced by this repository:**

I. van der Werf and G. Leus, "On Jointly CRB-optimal Arrays and Waveforms
for Multi-Target Active Sensing," in *2025 59th Asilomar Conference on
Signals, Systems, and Computers*, 2025, pp. 1724–1728.
DOI: [10.1109/IEEECONF67917.2025.11443763](https://doi.org/10.1109/IEEECONF67917.2025.11443763)

**Key publications the primary paper builds on**, cited here because this
repository's `coherent_waveform.m` and the single-target theory referenced
throughout the code depend on them:

- K. Forsythe and D. Bliss, "Waveform Correlation and Optimization Issues
  for MIMO Radar," in *Proc. of the Asilomar Conf. Signals, Syst. and
  Comput.*, 2005, pp. 1306–1310.
- J. Li, L. Xu, P. Stoica, K. W. Forsythe, and D. W. Bliss, "Range
  compression and waveform optimization for MIMO radar: A Cramér-Rao bound
  based study," *IEEE Trans. Signal Process.*, vol. 56, no. 1, pp. 218–232,
  2008.
- I. van der Werf, G. Leus, and R. Rajamäki, "Jointly Optimal Array
  Geometries and Waveforms in Active Sensing: New Insights Into Array
  Design via the Cramér-Rao Bound," in *Proc. of the IEEE Int. Conf. on
  Acoustics, Speech and Signal Process. (ICASSP)*, 2025, pp. 1–5.

For the complete reference list, see the primary paper itself.

## Citation

If this implementation is useful in your own work, please cite both the
original paper and, separately, this repository.

**Original paper (please cite this for the scientific method):**

```bibtex
@inproceedings{vanderwerf2025jointly,
  author    = {van der Werf, Ids and Leus, Geert},
  title     = {On Jointly {CRB}-optimal Arrays and Waveforms for Multi-Target Active Sensing},
  booktitle = {2025 59th Asilomar Conference on Signals, Systems, and Computers},
  year      = {2025},
  pages     = {1724--1728},
  doi       = {10.1109/IEEECONF67917.2025.11443763}
}
```

**This software (please cite this for the implementation):**

```bibtex
@software{crb_array_waveform_matlab_repro,
  author  = {[Your Name]},
  title   = {CRB-Optimal Arrays and Waveforms for Multi-Target Active Sensing: An Independent MATLAB Reproduction},
  year    = {[Year]},
  url     = {[repository-url]},
  note    = {Independent MATLAB implementation of van der Werf and Leus (2025)}
}
```

Plain-text form:

> [Your Name], *CRB-Optimal Arrays and Waveforms for Multi-Target Active
> Sensing: An Independent MATLAB Reproduction*, [Year]. Available:
> [repository-url]

## Acknowledgments

All scientific credit for the method implemented here belongs to Ids van
der Werf and Geert Leus (Delft University of Technology) and to the authors
of the prior work their paper builds on. This repository contributes only
an independent software implementation, written to be readable,
reproducible, and useful for study and further research — it does not claim
any of the underlying scientific ideas as its own.

## Disclaimer

This repository is an independent, unofficial reproduction created for
research and educational purposes. It is **not** produced, reviewed, or
endorsed by the original authors or by Delft University of Technology.
Any errors in this implementation are the responsibility of this
repository, not of the original paper. Where this implementation could not
determine an exact detail from the published paper, that gap is documented
explicitly in [Reproducibility and Assumptions](#reproducibility-and-assumptions)
rather than presented as a confirmed fact.

## License

*License to be determined — replace this section with your chosen license
(e.g. MIT, BSD-3-Clause, Apache-2.0) before publishing this repository.*
