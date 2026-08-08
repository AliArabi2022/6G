# Lesson 15 – Wave Superposition

## Overview

This lesson introduces one of the most fundamental concepts in wave physics: the **Principle of Superposition**.

Through a series of MATLAB simulations, students observe how multiple waves coexist within the same medium and how the resultant displacement is obtained by adding the individual wave displacements point by point.

The lesson emphasizes physical intuition before mathematical analysis and serves as the foundation for future topics such as interference, standing waves, antenna arrays, phased arrays, and beamforming.

---

## Learning Objectives

After completing this lesson, students will be able to:

* Explain the Principle of Superposition.
* Distinguish between wave overlap and particle collision.
* Understand that waves preserve their identities after overlapping.
* Analyze the influence of amplitude, frequency, phase, and propagation direction on the resultant waveform.
* Interpret Gaussian wave packet interactions.
* Relate MATLAB simulations to the mathematical description of wave superposition.

---

## Folder Structure

```text
Lesson_15_Wave_Superposition
│
├── MATLAB
│   ├── Lesson15_MainSimulation.m
│   ├── Lesson15_Demo.m
│   └── Functions
│
├── Report
│   ├── Lesson15_Report.docx
│   └── README.md
│
├── References
│   ├── README.md
│   └── Reference Papers
│
└── README.md
```

---

## MATLAB Simulations

The lesson consists of six independent experiments.

| Experiment   | Description                             |
| ------------ | --------------------------------------- |
| Experiment 1 | Equal-amplitude sinusoidal waves        |
| Experiment 2 | Different amplitudes                    |
| Experiment 3 | Different frequencies                   |
| Experiment 4 | Different initial phases                |
| Experiment 5 | Waves propagating in the same direction |
| Experiment 6 | Gaussian wave packets                   |

Each experiment modifies only one physical parameter so that students can clearly observe its effect while the Principle of Superposition remains unchanged.

---

## Educational Features

* Modular MATLAB implementation.
* Publication-quality figures.
* Interactive animation.
* Press **SPACE** to pause or resume the animation.
* Independent simulation duration for each experiment.
* Smooth real-time animation by updating graphical objects instead of redrawing figures.

---

## Expected Learning Outcome

By the end of this lesson, students should understand that

> **The resultant displacement in a linear medium is always equal to the algebraic sum of the displacements produced by all individual waves.**

This principle remains valid regardless of differences in amplitude, frequency, phase, propagation direction, or waveform.

---

## Prerequisites

Students should already be familiar with

* Wave propagation
* Sinusoidal waves
* Wavelength
* Frequency
* Phase
* Wave velocity

---

## Related Lessons

* Lesson 13 – Standing Waves
* Lesson 14 – Plane Wave Propagation
* Lesson 16 – Constructive and Destructive Interference *(Next Lesson)*

---

## Software Requirements

* MATLAB R2023b or later (recommended)
* No additional toolboxes are required.

---

## Version

**Version:** 1.0.0

---

## Author

Beamforming From First Principles Using MATLAB

An educational project for learning waves, antennas, beamforming, radar, and wireless communications from first principles through visualization and MATLAB simulations.
