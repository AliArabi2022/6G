# Lesson 14 – Spatial Phase Difference

## Question

If two antennas receive the same incoming plane wave, why do they observe different phases?

---

## Objective

The objective of this lesson is to explain how the direction of arrival of a plane wave creates a spatial phase difference between antenna elements.

By the end of this lesson, the learner will understand that the phase difference is a direct consequence of different propagation distances and arrival times.

---

## Learning Outcomes

After completing this lesson, you will be able to:

* Explain why antenna elements observe different phases.
* Describe the relationship between arrival angle and propagation path difference.
* Calculate the propagation path difference between two antennas.
* Compute the corresponding propagation time delay.
* Calculate the resulting spatial phase difference.
* Visualize the effect of the arrival angle on antenna signals.

---

## Lesson Structure

```text
Question
    ↓
Incoming Plane Wave
    ↓
Propagation Path Difference
    ↓
Propagation Time Delay
    ↓
Spatial Phase Difference
    ↓
MATLAB Simulation
    ↓
Visualization
    ↓
Animation
```

---

## MATLAB Contents

### Main Simulation

* `Lesson14_Spatial_Phase_Difference.m`

### Educational Demonstration

* `Demo_Lesson14_Spatial_Phase_Difference.m`

### Functions

* `createTwoElementArray.m`
* `showIncomingPlaneWave.m`
* `calculateSpatialDelay.m`
* `calculateSpatialPhaseDifference.m`
* `displaySimulationResults.m`
* `plotSpatialPhaseDifference.m`
* `animateSpatialPhaseDifference.m`

---

## Figures

The simulation generates figures illustrating:

* Two-element antenna array
* Incoming plane wave
* Arrival angle
* Propagation path difference
* Spatial phase difference
* Plane wave animation

---

## Report

The lesson report explains:

* The physical origin of spatial phase difference
* Geometric interpretation of propagation distance
* Relationship between path difference, time delay, and phase difference
* Mathematical derivation
* MATLAB implementation
* Discussion of simulation results

---

## References

The References folder contains books, papers, and educational resources related to:

* Electromagnetic wave propagation
* Antenna arrays
* Spatial phase
* Beamforming fundamentals

---

## Key Concept

The entire lesson is summarized by the following relationship:

```text
Arrival Angle
      ↓
Propagation Path Difference
      ↓
Propagation Time Delay
      ↓
Spatial Phase Difference
```

Understanding this relationship provides the physical foundation for antenna arrays and beamforming developed in the following chapters.
