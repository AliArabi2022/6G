# Lesson 02 — What Is Amplitude?

> *Amplitude determines how large a waveform is, not how fast it oscillates.*

---

## Introduction

Welcome to the second lesson of the **Beamforming From First Principles Using MATLAB** educational project.

In the previous lesson, we introduced the concept of a sinusoidal wave. In this lesson, we focus on one of its most fundamental parameters: **amplitude**.

You will learn what amplitude represents, how it affects a sinusoidal waveform, and how to visualize its effect using MATLAB while keeping all other signal parameters unchanged.

The concepts learned in this lesson provide the foundation for understanding signal strength in communication systems, radar, and beamforming applications.

---

## Why This Lesson Matters

Amplitude is one of the most important properties of a signal.

It is directly related to:

* Signal magnitude
* Signal strength
* Received power
* Radar echo intensity
* Communication system performance
* Audio signal level
* Electromagnetic wave intensity
* Sensor measurements

Understanding amplitude is essential before studying frequency, phase, and time delay.

---

## Learning Question

> **What is amplitude, and how does it affect a sinusoidal waveform without changing its frequency or phase?**

---

## Learning Objectives

After completing this lesson, you should be able to:

* Explain the meaning of signal amplitude.
* Describe how amplitude changes a sinusoidal waveform.
* Distinguish amplitude from frequency and phase.
* Generate sinusoidal signals with different amplitudes in MATLAB.
* Interpret the effect of amplitude using time-domain plots.

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
Lesson02_What_Is_Amplitude/
│
├── MATLAB/
│   ├── Lesson02_What_Is_Amplitude.m
│   └── generateSineWave.m
│
├── Figures/
│   └── Fig02_Amplitude_Comparison.png
│
├── Report/
│   └── Lesson02_Report.docx
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
Lesson02_What_Is_Amplitude.m
```

4. Click **Run**.
5. Compare the generated sinusoidal waveforms with different amplitudes.
6. (Optional) Export the generated figure for use in reports.

---

## Expected Output

Running the MATLAB script will produce:

* Three sinusoidal waveforms with different amplitudes.
* A publication-quality comparison figure.
* A clear visualization showing that amplitude changes only the vertical scale of the waveform.

---

## What You Will Learn Next

This lesson investigates only one waveform parameter.

The following lessons will continue exploring the remaining parameters one at a time.

| Lesson    | Topic                      |
| --------- | -------------------------- |
| Lesson 03 | Frequency                  |
| Lesson 04 | Period                     |
| Lesson 05 | Initial Phase              |
| Lesson 06 | Time Delay                 |
| Lesson 07 | Phase Shift vs. Time Delay |

By studying one concept at a time, learners can build a strong conceptual foundation before progressing to antenna arrays and beamforming.

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

Rather than presenting equations first, every lesson begins with intuition, followed by mathematics, MATLAB implementation, visualization, and discussion.

---

## License

This lesson is part of the **Beamforming From First Principles Using MATLAB** educational project.

The license information for the complete project is available in the repository root.
