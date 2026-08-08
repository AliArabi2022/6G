# MATLAB Files

This folder contains the MATLAB simulation scripts and supporting functions for **Lesson 14 – Spatial Phase Difference**.

## Main Simulation

### `Lesson14_Spatial_Phase_Difference.m`

The main simulation script of this lesson.

**Responsibilities**

* Defines all simulation parameters.
* Creates the antenna array.
* Calls the required functions.
* Executes the complete simulation workflow.
* Displays the simulation results.

---

## Educational Demonstration

### `Demo_Lesson14_Spatial_Phase_Difference.m`

An interactive educational demonstration designed for teaching.

**Responsibilities**

* Introduces the lesson concept.
* Guides the learner through each simulation step.
* Calls the same functions used by the main simulation.
* Demonstrates how the arrival angle produces a spatial phase difference.

No simulation logic is implemented inside this file. It only orchestrates the educational workflow.

---

# Functions

## `createTwoElementArray.m`

Creates a simple two-element linear antenna array.

**Inputs**

* Element spacing

**Outputs**

* Antenna element positions

---

## `showIncomingPlaneWave.m`

Visualizes the incoming plane wave and its direction of arrival.

**Responsibilities**

* Draws the antenna array.
* Displays the incoming wave direction.
* Illustrates the arrival angle.

---

## `calculateSpatialDelay.m`

Calculates the propagation path difference and the corresponding time delay between antenna elements.

**Outputs**

* Path difference
* Time delay

---

## `calculateSpatialPhaseDifference.m`

Computes the spatial phase difference produced by the propagation path difference.

**Output**

* Spatial phase difference (radians)

---

## `displaySimulationResults.m`

Displays the numerical simulation results in the MATLAB Command Window.

**Displayed Values**

* Arrival angle
* Element spacing
* Path difference
* Time delay
* Spatial phase difference

---

## `plotSpatialPhaseDifference.m`

Generates a static visualization of the spatial phase difference.

**Visualization**

* Two-element array
* Incoming wave direction
* Path difference
* Spatial phase difference

---

## `animateSpatialPhaseDifference.m`

Animates the propagation of the incoming plane wave across the antenna array.

**Visualization**

* Moving wavefront
* Arrival direction
* Antenna positions
* Path difference
* Spatial phase difference

---

# Simulation Workflow

```text
Lesson14_Spatial_Phase_Difference.m
            │
            ▼
createTwoElementArray
            │
            ▼
showIncomingPlaneWave
            │
            ▼
calculateSpatialDelay
            │
            ▼
calculateSpatialPhaseDifference
            │
            ▼
displaySimulationResults
            │
            ▼
plotSpatialPhaseDifference
            │
            ▼
animateSpatialPhaseDifference
```

---

# Educational Objective

This lesson demonstrates how the **direction of arrival (DOA)** of an incoming plane wave creates:

1. A propagation path difference.
2. A time delay.
3. A spatial phase difference between antenna elements.

These concepts establish the physical foundation required for understanding antenna arrays and beamforming in the following chapters.
