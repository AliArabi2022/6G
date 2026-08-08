# Lesson 07 — Phase Shift vs. Time Delay

> *A phase shift may look like a time delay, but they describe different physical phenomena.*

---

## Introduction

Welcome to the seventh lesson of the **Beamforming From First Principles Using MATLAB** educational project.

In the previous lessons, we studied **initial phase** and **time delay** separately. Although both appear as horizontal shifts of a sinusoidal waveform, they have different physical meanings.

This lesson compares these two concepts, derives their mathematical relationship, and explains why the distinction is fundamental in communications, radar, and beamforming.

---

## Why This Lesson Matters

Understanding the relationship between phase shift and time delay is essential for:

* Wave propagation
* Signal synchronization
* Wireless communications
* Radar systems
* Antenna arrays
* Direction-of-Arrival (DOA) estimation
* Beamforming

This lesson provides the mathematical bridge between physical wave propagation and signal processing.

---

## Learning Question

> **Are phase shift and time delay the same thing? If not, how are they mathematically related?**

---

## Learning Objectives

After completing this lesson, you should be able to:

* Distinguish between phase shift and time delay.
* Explain the physical meaning of each quantity.
* Derive the relationship between phase and time delay.
* Understand why phase depends on frequency.
* Generate equivalent phase-shifted and time-delayed signals using MATLAB.
* Interpret their similarities and differences.

---

## Lesson Workflow

Every lesson in this project follows the same educational workflow.

1. Question
2. Objective
3. Background
4. Mathematics
5. MATLAB Implementation
6. Visualization
7. Discussion
8. Exercises
9. Key Takeaways

---

## Repository Structure

```text
Lesson07_Phase_Shift_vs_Time_Delay/
│
├── MATLAB/
│   └── Lesson07_Phase_Shift_vs_Time_Delay.m
│
├── Figures/
│   └── Fig07_Phase_Shift_vs_Time_Delay.png
│
├── Report/
│   └── Lesson07_Report.docx
│
├── References/
│
└── README.md
```

---

## Running the Simulation

1. Open MATLAB.
2. Navigate to the **MATLAB** folder.
3. Open

```text
Lesson07_Phase_Shift_vs_Time_Delay.m
```

4. Click **Run**.
5. Compare the original, phase-shifted, and time-delayed waveforms.
6. Observe the calculated equivalent time delay displayed in the MATLAB Command Window.

---

## Expected Output

Running the MATLAB script will produce:

* An original sinusoidal waveform.
* A phase-shifted waveform.
* An equivalent time-delayed waveform.
* A publication-quality comparison figure.
* Numerical values for phase shift and equivalent time delay.

---

## What You Will Learn Next

The next lesson introduces **angular frequency**, a compact mathematical representation that simplifies the analysis of sinusoidal signals and prepares students for complex exponentials and Fourier analysis.

| Lesson    | Topic                      |
| --------- | -------------------------- |
| Lesson 08 | What Is Angular Frequency? |
| Lesson 09 | What Is Wavelength?        |
| Lesson 10 | Wave Propagation           |
| Lesson 11 | Plane Waves                |

---

## References

Books

* Alan V. Oppenheim & Alan S. Willsky – *Signals and Systems*
* Simon Haykin & Barry Van Veen – *Signals and Systems*
* John G. Proakis & Dimitris G. Manolakis – *Digital Signal Processing: Principles, Algorithms, and Applications*

---

## Educational Philosophy

This project is based on one simple principle:

> **Understand the concept, not memorize the equation.**

The goal of this lesson is to understand *why* phase shift and time delay are related rather than simply memorizing their conversion formulas.

---

## License

This lesson is part of the **Beamforming From First Principles Using MATLAB** educational project.

The license information for the complete project is available in the repository root.
