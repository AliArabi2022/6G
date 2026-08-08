# Lesson 13 — Why Aren't All Antenna Outputs the Same?

> *Understanding the physical origin of phase differences in antenna arrays.*

---

## Introduction

Welcome to Lesson 13 of the **Beamforming From First Principles Using MATLAB** educational project.

This lesson answers one of the most important questions in antenna array processing:

> **If every antenna receives the same transmitted signal, why aren't all antenna outputs identical?**

Rather than starting with equations, this lesson begins with physical intuition and gradually builds the connection between propagation distance, time delay, phase shift, and beamforming.

---

## Why This Lesson Matters

Every beamforming algorithm is built upon one simple observation:

Different antennas receive the **same transmitted waveform** at **different times**.

These tiny propagation delays create phase differences that encode the direction of arrival of the incoming wave.

Understanding this idea is essential before studying steering vectors, array response, DOA estimation, or adaptive beamforming.

---

## Learning Question

> **Why do different antennas observe different versions of the same transmitted signal?**

---

## Learning Objectives

After completing this lesson, you will be able to:

- Explain why antenna outputs are different.
- Understand propagation distance and arrival time.
- Relate propagation delay to phase difference.
- Explain why phase carries spatial information.
- Understand the physical origin of beamforming.

---

## Lesson Workflow

This lesson follows the standard educational workflow adopted throughout the project.

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
Lesson13_Why_Antenna_Outputs_Are_Different/
│
├── MATLAB/
│   └── Lesson13_Why_Antenna_Outputs_Are_Different.m
│
├── Figures/
│
├── Report/
│   └── Lesson13_Report.docx
│
├── References/
│
└── README.md
```

---

## MATLAB Demonstration

The MATLAB lesson demonstrates the complete physical chain behind beamforming.

- Create a Uniform Linear Array (ULA)
- Animate an incoming plane wave
- Compute arrival times
- Generate received signals
- Compare antenna outputs
- Compute phase differences
- Visualize rotating phasors

The lesson emphasizes conceptual understanding before introducing mathematical equations.

---

## Expected Learning Outcome

At the end of this lesson, the following relationship should be completely clear.

```text
One transmitted signal
        ↓
Different propagation distances
        ↓
Different arrival times
        ↓
Different phase shifts
        ↓
Beamforming
```

---

## Next Lesson

**Lesson 14**

**Spatial Phase Difference**

The next lesson derives the mathematical relationship between antenna spacing, arrival angle, wavelength, and phase difference.

---

## References

- Constantine A. Balanis — *Antenna Theory: Analysis and Design*
- David K. Cheng — *Field and Wave Electromagnetics*
- Matthew N. O. Sadiku — *Elements of Electromagnetics*

---

## Educational Philosophy

> **Understand the concept, not memorize the equation.**

This lesson emphasizes physical intuition before mathematical derivation.