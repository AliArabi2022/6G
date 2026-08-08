function experiments = createExperiments()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 16: Constructive and Destructive Interference
%
% Function:
% createExperiments
%
% Project:
% Beamforming From First Principles Using MATLAB
%
% Description:
% Creates the complete experiment list used in Lesson 16.
%
% Output
% ------
% experiments
%     Structure array containing all experiment definitions.
%
% Version:
% 1.0.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Common Wave Parameters

defaultAmplitude = 1;
defaultFrequency = 1;
defaultVelocity  = 1;

%% ========================================================================
% Experiment 1
% ========================================================================

experiments(1).id = 1;
experiments(1).title = "Review of Superposition";
experiments(1).type = "superposition";
experiments(1).simulationTime = 10;

experiments(1).wave1.amplitude = defaultAmplitude;
experiments(1).wave1.frequency = defaultFrequency;
experiments(1).wave1.velocity  = defaultVelocity;
experiments(1).wave1.phase     = 0;
experiments(1).wave1.direction = +1;

experiments(1).wave2.amplitude = defaultAmplitude;
experiments(1).wave2.frequency = defaultFrequency;
experiments(1).wave2.velocity  = defaultVelocity;
experiments(1).wave2.phase     = 0;
experiments(1).wave2.direction = -1;

%% ========================================================================
% Experiment 2
% ========================================================================

experiments(2).id = 2;
experiments(2).title = "Constructive Interference";
experiments(2).type = "phase";
experiments(2).simulationTime = 8;

experiments(2).wave1 = experiments(1).wave1;
experiments(2).wave2 = experiments(1).wave2;

experiments(2).wave2.phase = 0;

%% ========================================================================
% Experiment 3
% ========================================================================

experiments(3).id = 3;
experiments(3).title = "Partial Interference";
experiments(3).type = "phase";
experiments(3).simulationTime = 8;

experiments(3).wave1 = experiments(1).wave1;
experiments(3).wave2 = experiments(1).wave2;

experiments(3).wave2.phase = pi/2;

%% ========================================================================
% Experiment 4
% ========================================================================

experiments(4).id = 4;
experiments(4).title = "Destructive Interference";
experiments(4).type = "phase";
experiments(4).simulationTime = 8;

experiments(4).wave1 = experiments(1).wave1;
experiments(4).wave2 = experiments(1).wave2;

experiments(4).wave2.phase = pi;

%% ========================================================================
% Experiment 5
% ========================================================================

experiments(5).id = 5;
experiments(5).title = "Amplitude versus Phase Difference";
experiments(5).type = "amplitudeGraph";
experiments(5).simulationTime = 20;

experiments(5).wave1 = experiments(1).wave1;
experiments(5).wave2 = experiments(1).wave2;

%% ========================================================================
% Experiment 6
% ========================================================================

experiments(6).id = 6;
experiments(6).title = "Path Difference";
experiments(6).type = "pathDifference";
experiments(6).simulationTime = 12;

experiments(6).wave1 = experiments(1).wave1;
experiments(6).wave2 = experiments(1).wave2;

%% ========================================================================
% Experiment 7
% ========================================================================

experiments(7).id = 7;
experiments(7).title = "Spatial Interference Pattern";
experiments(7).type = "spatialPattern";
experiments(7).simulationTime = 12;

experiments(7).wave1 = experiments(1).wave1;
experiments(7).wave2 = experiments(1).wave2;

%% ========================================================================
% Experiment 8
% ========================================================================

experiments(8).id = 8;
experiments(8).title = "Coherence";
experiments(8).type = "coherence";
experiments(8).simulationTime = 12;

experiments(8).wave1 = experiments(1).wave1;
experiments(8).wave2 = experiments(1).wave2;

%% ========================================================================
% Experiment 9
% ========================================================================

experiments(9).id = 9;
experiments(9).title = "Energy Redistribution";
experiments(9).type = "energy";
experiments(9).simulationTime = 12;

experiments(9).wave1 = experiments(1).wave1;
experiments(9).wave2 = experiments(1).wave2;

end