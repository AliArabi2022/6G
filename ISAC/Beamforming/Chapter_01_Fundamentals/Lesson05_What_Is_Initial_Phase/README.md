# Lesson 05 — What Is Initial Phase?

> *The initial phase determines where a sinusoidal waveform begins at the initial instant.*

---

## Introduction

Welcome to the fifth lesson of the **Beamforming From First Principles Using MATLAB** educational project.

In the previous lessons, we explored amplitude, frequency, and period. In this lesson, we introduce another fundamental characteristic of sinusoidal signals: **initial phase**.

Although two sinusoidal waves may have the same amplitude and frequency, they do not necessarily start at the same point in time. The initial phase determines the waveform's starting position without changing its amplitude or frequency.

Understanding initial phase is essential because phase differences are the foundation of antenna arrays and beamforming.

---

## Why This Lesson Matters

Initial phase plays a fundamental role in many engineering applications.

It is directly related to:

* Waveform alignment
* Signal synchronization
* Interference phenomena
* Antenna arrays
* Beamforming
* Wireless communications
* Radar systems
* Digital signal processing

Mastering the concept of phase is a key step toward understanding how multiple signals combine constructively or destructively.

---

## Learning Question

> **What is the initial phase of a sinusoidal wave, and how does it affect the waveform without changing its amplitude or frequency?**

---

## Learning Objectives

After completing this lesson, you should be able to:

* Explain the meaning of initial phase.
* Distinguish phase from amplitude and frequency.
* Express phase in degrees and radians.
* Generate sinusoidal signals with different initial phases using MATLAB.
* Interpret the effect of phase shifts in the time domain.

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

This consistent structure allows learners to focus on understanding concepts rather than adapting to different lesson formats.

---

## Repository Structure

```text
Lesson05_What_Is_Initial_Phase/
│
├── MATLAB/
│   └── Lesson05_What_Is_Initial_Phase.m
│
├── Figures/
│   └── Fig05_Initial_Phase_Comparison.png
│
├── Report/
│   └── Lesson05_Report.docx
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
Lesson05_What_Is_Initial_Phase.m
```

4. Click **Run**.
5. Compare the generated sinusoidal waveforms with different initial phases.
6. (Optional) Export the generated figure for use in reports.

---

## Expected Output

Running the MATLAB script will produce:

* Three sinusoidal waveforms with identical amplitudes and frequencies.
* A publication-quality comparison figure.
* A clear visualization showing that only the starting position of the waveform changes.

---

## What You Will Learn Next

The next lesson introduces **time delay**, another important concept that shifts a waveform in time and is closely related to phase.

| Lesson    | Topic                      |
| --------- | -------------------------- |
| Lesson 06 | Time Delay                 |
| Lesson 07 | Phase Shift vs. Time Delay |
| Lesson 08 | Angular Frequency          |
| Lesson 09 | Wavelength                 |

These concepts provide the mathematical foundation for antenna arrays and beamforming.

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

Every lesson begins with intuition, followed by mathematics, MATLAB implementation, visualization, and discussion.

---

## License

This lesson is part of the **Beamforming From First Principles Using MATLAB** educational project.

The license information for the complete project is available in the repository root.
