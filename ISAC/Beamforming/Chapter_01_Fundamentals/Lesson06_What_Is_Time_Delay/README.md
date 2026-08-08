# Lesson 06 — What Is Time Delay?

> *Time delay describes when a waveform arrives, making it one of the most important concepts in wave propagation and beamforming.*

---

## Introduction

Welcome to the sixth lesson of the **Beamforming From First Principles Using MATLAB** educational project.

In the previous lesson, we studied how the initial phase changes the starting position of a sinusoidal waveform. In this lesson, we introduce **time delay**, a physical quantity that describes when a signal arrives at a particular location.

Time delay plays a central role in communications, radar, acoustics, and antenna arrays. It is also one of the fundamental concepts behind beamforming.

---

## Why This Lesson Matters

Time delay is encountered whenever a wave propagates through space.

It is directly related to:

* Wave propagation
* Signal arrival time
* Synchronization
* Wireless communications
* Radar systems
* Sonar
* Acoustic signal processing
* Antenna arrays
* Beamforming

Understanding time delay is essential before studying phase differences and steering vectors.

---

## Learning Question

> **What is time delay, and how does it affect a sinusoidal waveform without changing its amplitude or frequency?**

---

## Learning Objectives

After completing this lesson, you should be able to:

* Explain the meaning of time delay.
* Define the SI unit of time delay.
* Distinguish time delay from initial phase.
* Generate delayed sinusoidal signals using MATLAB.
* Interpret the effect of time delay in the time domain.

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
Lesson06_What_Is_Time_Delay/
│
├── MATLAB/
│   └── Lesson06_What_Is_Time_Delay.m
│
├── Figures/
│   └── Fig06_Time_Delay_Comparison.png
│
├── Report/
│   └── Lesson06_Report.docx
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
Lesson06_What_Is_Time_Delay.m
```

4. Click **Run**.
5. Observe how different time delays shift the waveform.
6. (Optional) Export the generated figure for use in reports.

---

## Expected Output

Running the MATLAB script will produce:

* Three sinusoidal waveforms with identical amplitudes and frequencies.
* A publication-quality comparison figure.
* A clear visualization showing how time delay shifts a waveform along the time axis.

---

## What You Will Learn Next

The next lesson compares **time delay** and **phase shift**, showing how these two concepts are mathematically related while representing different physical quantities.

| Lesson    | Topic                      |
| --------- | -------------------------- |
| Lesson 07 | Phase Shift vs. Time Delay |
| Lesson 08 | Angular Frequency          |
| Lesson 09 | Wavelength                 |
| Lesson 10 | Wave Propagation           |

These topics prepare students for antenna arrays and beamforming.

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
