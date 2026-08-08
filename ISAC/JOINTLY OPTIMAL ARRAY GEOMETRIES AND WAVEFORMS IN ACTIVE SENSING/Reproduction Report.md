# Reproduction Report: Jointly Optimal Array Geometries and Waveforms in Active Sensing via the Cramér-Rao Bound

**Original paper:** I. van der Werf, G. Leus, R. Rajamäki, "Jointly Optimal Array Geometries and Waveforms in Active Sensing: New Insights into Array Design via the Cramér-Rao Bound," arXiv:2501.00472v2, Jan. 2025.

**Nature of this document:** This is a reproduction (replication) study. It does not introduce new theory. Every mathematical result quoted here belongs to the original paper. The contribution of this document is a MATLAB implementation, an independent numerical check of the paper's two main theorems, and a corrected reconstruction of the paper's Figure 1 obtained by direct pixel-level measurement of the published figure.

---

# What problem does the original paper solve?

The paper asks a design question for monostatic active sensing systems (radar, and more broadly integrated sensing and communication): given a fixed number of transmit (Tx) and receive (Rx) sensors and a fixed physical aperture, which sensor positions and which transmit waveform jointly minimize the Cramér-Rao Bound (CRB) on the angle of a single target? The paper answers this in closed form and shows, as a byproduct, that the resulting array also has a desirable property for the more general multi-target case: a sum co-array that is both contiguous and free of redundant elements.

---

## 1. Introduction

Array geometry and waveform design are two of the main levers available to a radar or integrated-sensing-and-communication (ISAC) system designer for improving angle estimation accuracy. Most prior work treats these two design choices separately: either the array geometry is optimized for a fixed waveform, or the waveform is optimized for a fixed array. The reproduced paper is, to the knowledge of its authors, the first to solve both problems jointly for the single-target CRB.

This report documents a MATLAB reproduction of that paper. The reproduction covers the paper's signal model, its closed-form results (Theorem 1 and Corollary 1), its optimal-waveform result (eq. 5), and its numerical study (Fig. 1 and Fig. 2). The report distinguishes clearly between statements taken from the paper, decisions made during reproduction, and outcomes of the reproduction itself.

## 2. Research Problem

The paper considers a monostatic MIMO active-sensing system with $N_t$ transmit sensors at positions $D_t\subset\mathbb{Z}$ and $N_r$ receive sensors at positions $D_r\subset\mathbb{Z}$, both on a grid of half-wavelength spacing. A single far-field target at unknown electrical angle $\omega$ reflects a known transmitted waveform matrix $S$ with unknown complex reflectivity $\gamma$. The received signal is corrupted by additive white circular Gaussian noise. The research problem is to choose $D_t$, $D_r$, and $S$ to minimize the CRB on $\omega$, subject to:

- a fixed number of sensors, $|D_t|=N_t$, $|D_r|=N_r$;
- a fixed transmit power budget, $\lVert S\rVert_F^2\le 1$;
- a fixed physical Rx aperture, $\max D_r-\min D_r\le L$.

The paper's own related-work discussion states that array geometry and waveform have been optimized separately in prior literature, but never jointly for this problem — this is the gap the paper addresses.

## 3. Objectives of the Reproduction

This reproduction has five concrete objectives:

1. Implement the paper's single-target CRB expression and confirm its dependence on the spatial variance of the Tx and Rx arrays.
2. Implement the closed-form optimal Rx array (Theorem 1) and optimal Tx array (Corollary 1), and verify their claimed properties independently of the paper's own proof.
3. Implement the closed-form optimal transmit waveform (eq. 5) and verify its optimality independently, using convex optimization (CVX) where that is the mathematically appropriate tool.
4. Reproduce Fig. 1 (the four array geometries) and Fig. 2 (CRB and maximum-likelihood estimator performance vs. SNR) as closely as the available source material allows.
5. Document, rather than hide, every point where the source PDF's equations or figures could not be read with full confidence, and state explicitly what was assumed.

## 4. Overview of the Original Method

The paper's signal model (its eq. 1) is
$$y = \gamma\,(S\,a_t(\omega)\otimes a_r(\omega)) + n,\qquad n\sim\mathcal{CN}(0,\sigma^2 I),$$
where $a_t(\omega)$ and $a_r(\omega)$ are the Tx and Rx steering vectors and $\otimes$ denotes the Kronecker product. The central quantity the paper introduces is the **spatial variance** of an array geometry $D$ (its eq. 3):
$$\chi(D) = \frac{1}{|D|}\sum_{d\in D}(d-\bar d)^2,\qquad \bar d = \frac{1}{|D|}\sum_{d\in D} d.$$

The paper shows that the CRB-optimal waveform is coherent transmit beamforming toward the target (eq. 5), and that under this waveform the CRB depends on the array geometry only through $\chi_t=\chi(D_t)$ and $\chi_r=\chi(D_r)$. Theorem 1 then shows that, for a fixed Rx aperture $L$ and Rx count $N_r$, the array maximizing $\chi_r$ places $N_r/2$ sensors at each edge of the aperture — an edge-clustered array. Corollary 1 shows that pairing this Rx array with a specific Tx array, $D_t^\star=\frac{N_r}{2}\mathcal{U}_{N_t}$ (where $\mathcal{U}_N=\{0,\dots,N-1\}$), makes the sum co-array $D_t\oplus D_r$ both contiguous and nonredundant when $L=(N_t+1)N_r/2-1$.

Section 4 of the paper illustrates these results numerically for $N_t=4$, $N_r=6$, comparing four array geometries (its Fig. 1) and their CRB and maximum-likelihood-estimator (MLE) performance vs. SNR (its Fig. 2).

## 5. Reproduction Methodology

The reproduction was carried out from the PDF of the paper only; no author-released code or supplementary material was available. The methodology followed three stages:

1. **Extraction.** The PDF was read page by page. Where the automatic text extraction of mathematical notation was unreliable, the page images were inspected directly, and in the case of Fig. 1, cropped and magnified for close reading.
2. **Implementation.** Each equation was translated into a small, single-purpose MATLAB function with a header comment naming the paper's equation number. Closed-form results (Theorem 1, Corollary 1, eq. 5) were implemented directly, without any iterative solver, since the paper itself gives closed forms.
3. **Independent verification.** Rather than trusting the transcription, every closed-form construction was checked against an independent computation: the sum co-array's contiguity and nonredundancy were checked arithmetically in Python outside of MATLAB, and Fig. 1's four array geometries were checked against pixel measurements of the published figure image (Section 13 below describes this in detail, including an error it caught).

## 6. System Architecture

The reproduction is organized as a data-flow pipeline: configuration parameters feed into array-geometry construction, which feeds into both the analytical CRB and the Monte Carlo MLE simulation, which both feed into the two reproduced figures.

```
config/parameters.m
        │
        ├──────────────┬────────────────────┐
        ▼              ▼                    ▼
 optimal_rx_array  optimal_tx_array   comparison arrays
   (Theorem 1)        (Corollary 1)    (b),(c),(d) for Fig. 1
        └──────┬───────┘                    │
               ▼                            │
         sum_coarray()  ◄────────────────────┘
      (contiguous? nonredundant?)
               │
     ┌─────────┴─────────┐
     ▼                   ▼
plot_fig1()      verify_theorem1_bruteforce()
                 cvx_verify_optimal_waveform()
               │
     ┌─────────┴─────────┐
     ▼                   ▼
compute_crb()     monte_carlo_mle()
     └─────────┬─────────┘
               ▼
          plot_fig2()
```

*Recommended figure location:* a rendered version of this pipeline (e.g., as a boxes-and-arrows diagram) should be inserted here in the published repository, generated from the ASCII diagram above.

## 7. Software Design

The project is organized into single-responsibility folders, following the principle that each MATLAB file corresponds to one equation, one figure, or one verification step. Table 1 summarizes the layout.

**Table 1. Project folder structure and responsibility.**

| Folder | Responsibility | Paper reference |
|---|---|---|
| `config/` | All constants in one place (`parameters.m`) | — |
| `utils/` | Generic helpers: index sets, spatial variance, steering vectors | eq. (3) |
| `arrays/` | Array geometry constructions for all four Fig. 1 panels, plus sum co-array | Theorem 1, Corollary 1 |
| `crb/` | Analytical CRB | eq. (2)–(3), Theorem 1 |
| `waveform/` | Closed-form optimal waveform | eq. (5) |
| `estimator/` | Joint Tx-Rx maximum-likelihood beamformer | Section 4 |
| `sim/` | Monte Carlo MSE-vs-SNR study | Section 4 |
| `verify/` | Independent numerical checks (brute force, CVX) | Theorem 1, eq. (5) |
| `plots/` | Fig. 1 and Fig. 2 reproduction | Fig. 1, Fig. 2 |

Configuration is centralized in `config/parameters.m`, which returns a single struct consumed by every other function. This avoids hard-coded constants scattered across files and makes every numerical choice (array sizes, SNR sweep, trial count, calibration constant) auditable from one location. `main.m` sets up the MATLAB path with `addpath(genpath(...))` and then calls each stage in the order shown in Section 6.

## 8. Implementation Details

Two implementation decisions are worth explaining, because they reflect a judgment call rather than a direct transcription of the paper.

**Why the array-geometry optimality check uses brute force, not CVX.** The paper's Theorem 1 is a combinatorial statement: among all $N_r$-element subsets of $\{0,\dots,L\}$, which one maximizes $\chi(D)$? Spatial variance is a convex function of the selected positions, and maximizing a convex function over a discrete/combinatorial domain is not a problem CVX (a convex-programming tool, built for convex minimization or concave maximization) can certify as optimal. `verify/verify_theorem1_bruteforce.m` therefore enumerates every valid array of the paper's example size ($N_r=6$, $L=14$, i.e., 715 combinations) and confirms none exceeds the closed-form array's spatial variance. This is a real proof for that specific instance, not a relaxation.

**Why the waveform optimality check uses CVX, not brute force.** For a fixed array geometry, choosing the waveform covariance $R_s=E[ss^H]$ subject to $R_s\succeq0$ and $\mathrm{tr}(R_s)=P$ is a semidefinite program: the objective (beamforming gain toward the target) is linear in $R_s$, and the feasible set is convex. `verify/cvx_verify_optimal_waveform.m` solves this SDP with CVX and checks that the solution is rank-1 and matches the paper's closed-form eq. (5). This is the correct tool for this sub-problem, unlike the array-geometry sub-problem above.

Beyond these two points, `crb/compute_crb.m` exposes a single free constant, `kappa`, multiplying the CRB expression. This was necessary because the scalar prefactor in the paper's CRB equation could not be transcribed with full confidence from the source PDF (see Section 13). The functional dependence — inversely proportional to $\chi_t+\chi_r$ and to SNR — is not in doubt; only the absolute scale is.

## 9. Algorithms and Mathematical Formulation

This section restates, in the reproduction's own notation, every equation that was implemented. Table 2 defines all symbols used.

**Table 2. Notation and variable definitions.**

| Symbol | Meaning | Type | MATLAB name |
|---|---|---|---|
| $N_t$, $N_r$ | number of Tx / Rx sensors | positive integers ($N_r$ even) | `cfg.Nt`, `cfg.Nr` |
| $D_t$, $D_r$ | Tx / Rx sensor position sets | integer sets | `D_t`, `D_r` |
| $D_\Sigma$ | sum co-array, $D_t\oplus D_r$ | integer set, $\le N_tN_r$ elements | `D_sigma` |
| $L$ | physical aperture ($\max D_r-\min D_r$, min fixed at 0) | nonnegative integer | `L`, `cfg.L_opt` |
| $\chi(D)$ | spatial variance of position set $D$ | nonnegative real | `spatial_variance(D)` |
| $\omega$ | target electrical angle | real, $[-\pi,\pi)$ | `omega` |
| $\gamma$ | target complex reflectivity | complex scalar | `gamma` |
| $\sigma^2$ | noise variance | positive real | `sigma2` |
| $S$ | Tx waveform matrix | $T\times N_t$ complex | `S` |
| $T$ | number of fast-time samples | positive integer | `cfg.T` |
| $u$ | temporal beamforming weight vector | $T\times1$, unit norm | `cfg.u` |
| $a_t(\omega)$, $a_r(\omega)$ | Tx / Rx steering vectors | complex, unit-modulus entries | `a_t`, `a_r` |
| $\hat\omega$ | maximum-likelihood angle estimate | real | `omega_hat` |
| $\kappa$ | CRB scalar calibration constant (reproduction-only, not from the paper) | positive real, default 1 | `cfg.kappa` |

**Spatial variance (eq. 3).** $\chi(D)=\frac{1}{|D|}\sum_{d\in D}(d-\bar d)^2$. This is the mean squared distance of the sensor positions from their own centroid. It is the single number that determines angular resolution in this problem: a larger $\chi$ means the array's sensors are, on average, farther from the center, which sharpens the phase gradient used to estimate $\omega$.

**Optimal Rx array (Theorem 1 / eq. 10).** For fixed $N_r$ and $L$, $\chi(D_r)$ is maximized by
$$D_r^\star = \{0,\dots,\tfrac{N_r}{2}-1\}\cup\{L-\tfrac{N_r}{2}+1,\dots,L\},$$
i.e., half the sensors packed at each end of the aperture. Intuitively, variance is a convex, edge-maximized quantity, so pushing sensor mass to the extremes of an interval maximizes it, subject to keeping the sensors at distinct integer positions.

**Optimal Tx array (Corollary 1 / eq. 11).** With $D_r^\star$ as above and $L=(N_t+1)N_r/2-1$,
$$D_t^\star = \tfrac{N_r}{2}\{0,1,\dots,N_t-1\}$$
makes the sum co-array $D_t^\star\oplus D_r^\star$ equal to $\{0,1,\dots,N_tN_r-1\}$ exactly — every integer in that range appears as exactly one Tx-Rx position sum. This was confirmed independently (Section 11) by direct enumeration, not by trusting the paper's proof.

**Optimal waveform (eq. 5).** $S=u\,a_t(\omega)^T$, i.e., every Tx element transmits the same signal (up to the phase implied by the steering vector) — coherent beamforming toward the target angle. This is the waveform that maximizes the effective SNR seen by the estimator, for a fixed total transmit power.

**CRB under the optimal waveform (eq. 2–3, Theorem 1 discussion).** The reproduction implements
$$\mathrm{CRB}(\omega) = \frac{\sigma^2}{\kappa\cdot 2T|\gamma|^2(\chi_t+\chi_r)}.$$
The dependence on $\sigma^2$, $T$, $|\gamma|^2$, and $\chi_t+\chi_r$ follows the paper's derivation. The constant $\kappa$ is a reproduction-only addition (default 1) absorbing any residual scalar factor that could not be confirmed from the source PDF; see Section 13.

**Maximum-likelihood estimator (Section 4).** For a fixed waveform,
$$\hat\omega = \arg\max_{\bar\omega} \frac{\lvert y^H(S\,a_t(\bar\omega)\otimes a_r(\bar\omega))\rvert^2}{\lVert S\,a_t(\bar\omega)\rVert^2}.$$
This is a matched-filter statistic, normalized by transmit gain, searched over a grid of candidate angles. It reduces to this form because, for known $\bar\omega$, the model is linear in the remaining unknown $\gamma$; concentrating $\gamma$ out of the likelihood leaves this angle-only search.

## 10. Experimental Setup

There is no dataset in this project: every signal is synthetically generated from the model in eq. (1). Table 3 lists the parameter values used, matching the paper's own numerical example in Section 4. Table 4 lists the software environment.

**Table 3. Experimental settings (`config/parameters.m`).**

| Parameter | Value | Source |
|---|---|---|
| $N_t$ | 4 | paper's Fig. 1/2 example |
| $N_r$ | 6 | paper's Fig. 1/2 example |
| $L$ (optimal geometry) | 14 | Corollary 1, $(N_t+1)N_r/2-1$ |
| $\omega_{\text{true}}$ | 0 | paper's Section 4 |
| $\gamma_{\text{true}}$ | 1 | paper's Section 4 |
| $T$ | $N_t=4$ | paper's Section 4 |
| SNR sweep | $-20$ to $20$ dB, step 2.5 dB | matches paper's Fig. 2 x-axis span |
| Monte Carlo trials per SNR point | $10^4$ | paper's Section 4 |
| Angle search grid size | 4096 points over $[-\pi,\pi)$ | reproduction choice, not stated in paper |
| $\kappa$ (CRB calibration) | 1 (default, uncalibrated) | reproduction-only, see Section 13 |

**Table 4. Software environment.**

| Component | Requirement |
|---|---|
| MATLAB | R2020a or later (uses `exportgraphics`) |
| CVX | required only for `verify/cvx_verify_optimal_waveform.m`; every other script runs without it |
| Toolboxes | none required for the core pipeline |
| External data | none — fully synthetic |

## 11. Results

At the time of writing, the MATLAB implementation is complete but **has not yet been executed**, because no MATLAB or Octave interpreter was available in the environment used to write it. This section states plainly what has and has not been verified, rather than presenting unexecuted code as if it produced results.

**Table 5. Reproduction outcome summary.**

| Item | Status | How it was checked |
|---|---|---|
| Corollary 1: sum co-array is contiguous and nonredundant, $N_t=4$, $N_r=6$, $L=14$ | **Verified** | Independent Python re-implementation of the co-array construction (outside MATLAB); confirmed $D_\Sigma=\{0,\dots,23\}$, all 24 sums distinct |
| Fig. 1(b) equal-spatial-variance identity ($5^2+6^2+7^2=1^2+3^2+10^2$) | **Verified** | Same independent Python check; both arrays give $\chi_r=36.\overline{6}$ |
| Fig. 1 panel geometries match the published figure | **Verified after correction** | Direct pixel-position measurement of the paper's own Fig. 1 image; an initial transcription error (Tx array reused across panels, Rx array offset incorrectly in two panels) was found and corrected this way — see Section 13 |
| Theorem 1 global optimality (brute-force search over 715 candidate arrays) | **Implemented, execution pending** | Logic implemented in `verify_theorem1_bruteforce.m`; not yet run |
| eq. (5) waveform optimality (CVX SDP) | **Implemented, execution pending** | Logic implemented in `cvx_verify_optimal_waveform.m`; requires a CVX license/install not available in this environment |
| Fig. 1 reproduction (rendered figure) | **Implemented, execution pending** | `plot_fig1.m` written and corrected; not yet rendered |
| Fig. 2 reproduction (CRB and MLE MSE vs. SNR) | **Implemented, execution pending** | `plot_fig2.m` and `monte_carlo_mle.m` written; not yet run |

No CRB values, MSE values, or rendered figures are reported here, because none have been produced yet by an actual MATLAB run. This table should be updated with concrete pass/fail outcomes once the pipeline is executed.

## 12. Discussion

The two results that were possible to verify without a MATLAB interpreter — Corollary 1's contiguous/nonredundant sum co-array, and the equal-spatial-variance identity behind Fig. 1(b) — both confirmed the paper's claims exactly, with no numerical tolerance needed (all quantities involved are integers). This gives reasonable confidence that the closed-form array constructions in `arrays/optimal_rx_array.m` and `arrays/optimal_tx_array.m` are correctly transcribed.

The item that most needs the pending MATLAB run is the CRB calibration constant $\kappa$. Everything about the CRB's functional form is grounded directly in the paper's stated dependencies; only the absolute scale was left uncertain. Until the code is run and, ideally, one (SNR, CRB) point is read off the paper's own Fig. 2 for calibration, any numerical comparison of CRB curves to the published figure should be read as qualitative (correct shape and correct ordering between geometries) rather than quantitative.

The correction made to Fig. 1(b)/(c)/(d) (Section 13) is a useful illustration of a general risk in this kind of reproduction: a plausible-looking, internally consistent baseline array (e.g., "the standard ULA") can be constructed that satisfies every stated constraint in the text and yet still not match what the authors actually plotted. Text description alone was not sufficient here; the figure itself had to be measured.

## 13. Reproduction Challenges

Three distinct challenges were encountered.

**Equation transcription from a scanned/rendered PDF.** Automatic text extraction of the PDF handled prose reliably but was unreliable for inline mathematical notation, particularly the exact scalar prefactor of the CRB expression and the paper's compact set-builder notation for the clustered array ("$\mathcal{K}_L$"). The Rx array's definition was reconstructed from the surrounding prose description ("places sensors at the edges of its aperture") together with the paper's own worked numerical example, then confirmed by checking that it reproduces the stated contiguous/nonredundant sum co-array. This is a defensible reconstruction, but it is a reconstruction, not a direct transcription, and is flagged as such in the code comments.

**Reconstructing Fig. 1's four array geometries.** The paper's prose gives an explicit position set only for the optimal array (panel a, via eq. 10–11). For panels (b), (c), and (d), the paper describes the arrays qualitatively ("same spatial variance as (a), larger aperture," "the well-known ULA," "canonical MIMO array with a nested structure") without stating position sets. An initial reconstruction, based on standard textbook definitions of these baseline arrays, was written into the code. This initial version turned out to be wrong in two respects once checked against the actual figure: the Tx array used for panel (a) had been incorrectly reused for panel (b) instead of a simple unit-spaced array, and the Rx arrays for panels (c) and (d) had their spacing pattern reversed relative to what the published figure actually shows. Both errors were caught only after cropping the source figure image, measuring marker pixel positions directly, and calibrating those pixel positions against panel (a)'s known-correct geometry. The corrected arrays are consistent with every aperture value stated in the paper's text ($L=20$ for panels b and d).

**No MATLAB/Octave interpreter available.** All code in this reproduction was written and reasoned about without the ability to execute it. Correctness for the array-construction logic was established by an independent, small Python re-implementation of the relevant arithmetic (not by running the actual MATLAB files). The remainder of the pipeline — the brute-force Theorem 1 check, the CVX SDP check, and both figures — has not been executed at all. This is the single largest open item in this reproduction and is treated as such throughout this report rather than glossed over.

## 14. Limitations

- The reproduction covers only the **single-target** case, matching the scope of the reproduced paper itself. The paper explicitly leaves the multi-target case, and a full exploration of the "equal sums of squares" array family, for future work; this reproduction does not attempt either.
- The CRB scalar prefactor $\kappa$ is uncalibrated (default 1). Curve shape and the relative ordering of geometries should be reliable; absolute values are not guaranteed to match the published figure until calibrated.
- The maximum-likelihood estimator uses a fixed angular grid with no local refinement step. This is expected to introduce a quantization floor in the Monte Carlo MSE curves at high SNR that would not appear with a refined estimator.
- The optimal waveform (eq. 5) is formed using the true target angle, matching the paper's own simplified numerical setup. The paper itself notes that a practical system would need an initial angle estimate first; this reproduction does not implement that two-stage procedure.
- As stated repeatedly above, the pipeline has not yet been executed end to end.

## 15. Future Improvements

The following proposals were generated by comparing the original paper, the current implementation, and the gaps identified in Sections 13–14, then filtered by asking, for each candidate: is it scientifically meaningful, technically feasible, and justified by something already stated in the paper or observed in this reproduction? Ideas that did not pass this filter are listed first, with the reason for rejection, before the accepted proposals.

### 15.1 Directions considered and not pursued

- **GPU acceleration or large-scale parallelization of the Monte Carlo loop.** The problem sizes in this paper's own numerical study ($N_t=4$, $N_r=6$) are small; the simulation is slow only because of an unoptimized nested loop, not because of genuine computational scale. This is an engineering fix (see Section 13's optimization notes), not a research direction, and is not included here as future work.
- **Learning-based or data-driven array/waveform design.** Nothing in the paper motivates or evaluates a learned approach, and the paper's whole contribution is a closed-form, provably optimal solution for the single-target case. Proposing a learned alternative would not answer any question the paper or this reproduction actually raises.
- **Extension to wideband or OFDM waveforms.** The paper's model is explicitly narrowband. Extending it would be a substantial new derivation, not a reproduction task, and there is no partial result in the paper to anchor it to.
- **Scaling the brute-force Theorem 1 check to larger $(N_r,L)$.** Theorem 1 already has a general closed-form proof in the paper, valid for all $N_r,L$. Brute-force confirmation at the paper's example size is a useful sanity check of the reproduction's own code; repeating it at larger scale would not test anything the proof does not already establish, while the combinatorial cost grows quickly. This was judged low value relative to its cost.
- **Generalizing to redundant or non-contiguous sum co-arrays.** The paper mentions this direction in a single sentence in its conclusion, without a concrete method. Pursuing it now, before the core reproduction is even executed once, would be premature; it is noted here as a direction the original authors flagged, but not adopted as planned work for this repository.

### 15.2 Accepted future directions

**A. Empirical calibration of the CRB scalar constant $\kappa$.**
*Motivation:* Section 13 identifies $\kappa$ as the one quantity in this reproduction that could not be confirmed from the source PDF. *Technical rationale:* since $\kappa$ enters the CRB expression as a single multiplicative constant, it can be identified from a single reference point without re-deriving the Fisher information matrix from scratch — for example, by reading one (SNR, CRB) pair off the paper's published Fig. 2 and solving for $\kappa$. *Expected outcome:* a fully calibrated CRB curve that should overlay the paper's Fig. 2 numerically, not just in shape. *Implementation strategy:* add a small calibration script that takes one digitized point from the paper's figure and solves for $\kappa$ in closed form; store the result back in `config/parameters.m`. *Risks:* digitizing a point from a printed figure introduces its own reading error; a single point also cannot detect an error in the functional form, only rescale it. *Value:* this closes the only remaining quantitative gap identified in this report, at low implementation cost. In future versions of this project, we plan to carry out this calibration once the pipeline has been run at least once end to end.

**B. Two-stage estimation: coarse angle estimate followed by beamformed waveform.**
*Motivation:* the paper itself notes, in its remark on eq. (5), that forming the optimal waveform in practice requires an initial estimate of the target angle, since the optimal waveform depends on the (unknown) true angle. The current reproduction sidesteps this by using the true angle directly, matching the paper's own simplified numerical example, but this is acknowledged as a simplification in Section 14. *Technical rationale:* a realistic pipeline would first transmit an orthogonal (angle-agnostic) waveform, form a coarse estimate $\hat\omega_0$, then re-transmit the eq. (5) beamformed waveform using $\hat\omega_0$ in place of the true $\omega$. *Expected outcome:* a second MSE-vs-SNR curve, alongside the current genie-aided one, showing the performance cost of not knowing $\omega$ in advance. *Implementation strategy:* extend `sim/monte_carlo_mle.m` with an optional two-stage mode, reusing the existing MLE estimator for both the coarse and refined stages. *Risks:* the coarse-stage estimator's own accuracy now becomes a second free parameter (e.g., orthogonal-waveform SNR), which could make the comparison harder to interpret than the single-stage case. *Value:* this is a direct, well-scoped extension of a limitation the original paper itself names, not an externally motivated addition. A promising direction for future work is implementing exactly this two-stage procedure and comparing it against the genie-aided curve already planned for Fig. 2.

**C. Multi-target identifiability experiments using the sum co-array.**
*Motivation:* the paper's introduction and conclusion both state that the contiguous, nonredundant sum co-array of Corollary 1 is relevant to the multi-target case, specifically to target identifiability when independent waveforms are transmitted, and explicitly flags multi-target evaluation as future work. *Technical rationale:* a contiguous, nonredundant sum co-array of size $N_tN_r$ is sufficient to identify up to $N_tN_r/2$ targets by standard co-array identifiability results, which the paper cites but does not itself simulate. *Expected outcome:* a demonstration, using the already-implemented `sum_coarray.m` and the existing array constructions, that the Corollary 1 geometry supports multi-target identification where the canonical MIMO nested array (Fig. 1d) requires a larger physical aperture to do the same. *Implementation strategy:* extend the signal model in `estimator/` to $K>1$ targets and implement a co-array-based (e.g., MUSIC-style) DOA estimator as a new module, reusing the existing array and steering-vector utilities. *Risks:* this is the largest of the proposed extensions; a multi-target estimator is a nontrivial addition, and the paper gives no numerical example to validate against, so success would have to be judged against co-array theory rather than a published reference curve. *Value:* this is the most direct extension of the paper's own stated motivation for its main result, and the existing `sum_coarray.m` module was written with exactly this reuse in mind. Another experiment worth investigating is precisely this multi-target identifiability study, once the single-target pipeline is fully validated.

**D. Hybrid grid-and-refinement maximum-likelihood estimator.**
*Motivation:* Section 14 identifies grid quantization as an expected source of an artificial MSE floor at high SNR, which would make the Monte Carlo MLE curves diverge from the CRB in a way that is an artifact of the estimator implementation rather than a real effect the paper describes. *Technical rationale:* adding a local refinement step (for example, a golden-section or Newton search) around the coarse grid maximum removes this floor without changing the estimator's statistical behavior at low-to-moderate SNR, where the grid search dominates and the threshold effect is real. *Expected outcome:* Monte Carlo MSE curves that track the analytical CRB more closely at high SNR, giving a cleaner reproduction of the paper's Fig. 2 in the region where the paper claims the MLE should be efficient. *Implementation strategy:* add an optional refinement stage to `estimator/mle_beamformer.m`, active only above a configurable SNR threshold to avoid unnecessary computation at low SNR where refinement would not change the outcome. *Risks:* a poorly-converging local search could occasionally produce worse estimates than the coarse grid alone if it locks onto a nearby sidelobe; this would need a fallback to the coarse estimate. *Value:* this directly addresses a limitation already identified in this same report, and is low-risk relative to its payoff. In future versions of this project, we plan to add this refinement step before drawing any final conclusions from the high-SNR portion of the reproduced Fig. 2.

**E. Systematic exploration of the equal-sums-of-squares array family.**
*Motivation:* the paper states, in its own words, that different array geometries achieving the same CRB via equal sums of squares "may differ" in practical DoA estimation performance, and explicitly writes that "fully exploring this prospect is left for future work." This reproduction currently implements only the single illustrative pair the paper shows in Fig. 1(a)/(b). *Technical rationale:* equal-sums-of-squares integer sequences of a given length are a known, enumerable object in number theory; a family of such sequences at fixed $N_r$ and increasing aperture $L$ can be generated and each one's array plugged directly into the already-implemented CRB and Monte Carlo MLE modules. *Expected outcome:* an empirical answer to the question the paper leaves open — whether MLE performance (not just CRB) systematically degrades, improves, or varies unpredictably as aperture grows within a fixed-CRB family. *Implementation strategy:* add an array-generation module that searches for equal-sums-of-squares sequences of length $N_r/2$ (reusing the identity structure behind `equal_variance_rx_array.m`), then loop the existing `monte_carlo_mle.m` over the resulting family. *Risks:* enumerating equal-sums-of-squares sequences beyond small cases is itself a nontrivial search problem, and there is no guarantee the resulting arrays will be practically realizable (e.g., some may require large apertures for modest $N_r$). *Value:* this is the one future direction the paper's own authors state outright as unexplored, making it the most directly justified proposal in this section. A promising direction for future work is generating this family systematically and reusing the existing simulation modules, rather than the single hard-coded example currently implemented.

## 16. Conclusion

This report documents a MATLAB reproduction of a paper that jointly optimizes array geometry and transmit waveform for single-target angle estimation via the Cramér-Rao Bound. The reproduction implements every closed-form result in the paper — the optimal waveform, the optimal Rx array, and the optimal Tx array — along with the paper's Fig. 1 and Fig. 2 numerical study. Two of the paper's claims (the contiguous/nonredundant sum co-array of Corollary 1, and the equal-spatial-variance identity behind Fig. 1b) were independently confirmed by arithmetic outside of MATLAB. A transcription error in three of Fig. 1's four array geometries was found and corrected only by measuring the published figure's own pixel content directly, which is documented here as a concrete illustration of why figure reconstruction from prose description alone is unreliable. The largest open item is that the MATLAB pipeline itself has not yet been executed; Section 11's outcome table should be treated as the authoritative status record and updated once that run is complete.