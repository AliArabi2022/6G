%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project : Beamforming From First Principles Using MATLAB
%
% Chapter : 01 - Fundamentals of Waves
%
% Lesson 14
% Spatial Phase Difference
%
% Educational Demonstration
%
% Version : 2.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

initializeProjectPaths();

%% Parameters

c = 3e8;
f = 1e9;

lambda = c/f;
d = lambda/2;

arrivalAngle = 40;

disp('============================================================');
disp('Lesson 14');
disp('Spatial Phase Difference');
disp('============================================================');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Question');
disp('------------------------------------------------------------');
disp('Suppose two antennas receive exactly the same electromagnetic wave.');
pause(2);

disp('Will both antennas observe exactly the same signal?');
pause(3);

disp('At first, the answer seems to be YES.');
pause(2);

disp('But antenna arrays tell us something different.');
pause(2);

disp('Let us discover why.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 1');
disp('Observe a Plane Wave');
disp('------------------------------------------------------------');

pause(2);

showPlaneWaveOnly(arrivalAngle);

disp('This is a Plane Wave.');
pause(3);

disp('Every blue line is called a Wavefront.');
pause(3);

disp('Every point on the same Wavefront has exactly the same phase.');
pause(4);

disp('So far there are no antennas.');
pause(2);

disp('Only the wave exists.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 2');
disp('Propagation Direction');
disp('------------------------------------------------------------');

pause(2);

showPropagationDirection(arrivalAngle);

disp('Now we add the propagation direction.');
pause(3);

disp('The red arrow shows the direction in which');
disp('the electromagnetic wave travels.');
pause(4);

disp('Notice something very important.');
pause(3);

disp('The wavefront is NOT moving along itself.');
pause(3);

disp('It moves perpendicular to the wavefront.');
pause(4);

disp('The Arrival Angle is measured from');
disp('the propagation direction.');
pause(4);

disp('NOT from the wavefront.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 3');
disp('Place Two Antennas');
disp('------------------------------------------------------------');

pause(2);

antennaPosition = createTwoElementArray(d);

showArrayWithWave(...
    arrivalAngle,...
    antennaPosition);

disp('Now we place two antennas.');
pause(3);

disp('Both antennas will receive the SAME wave.');
pause(3);

disp('But will they receive it');
disp('at exactly the same time?');
pause(4);

disp('Look carefully at the geometry.');
pause(3);

disp('The antennas are located');
disp('at different positions.');
pause(3);

disp('Therefore...');
pause(2);

disp('the wave must travel');
disp('different distances.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Prediction');
disp('------------------------------------------------------------');

disp('Think before continuing...');
pause(3);

disp('Which antenna will receive');
disp('the wave first?');
pause(6);

disp('Press any key to reveal the answer.');
pause;
%% ------------------------------------------------------------------------
disp(' ');
disp('Step 4');
disp('Wave Arrival Animation');
disp('------------------------------------------------------------');

pause(2);

[pathDifference,timeDelay] = ...
    calculateSpatialDelay(...
    d,...
    arrivalAngle,...
    c);

phaseDifference = ...
    calculateSpatialPhaseDifference(...
    pathDifference,...
    lambda);

animateWaveArrival(...
    antennaPosition,...
    arrivalAngle,...
    pathDifference,...
    timeDelay,...
    phaseDifference);

disp('Did you notice what happened?');
pause(3);

disp('The wavefront reached one antenna');
disp('before the other.');
pause(4);

disp('The transmitted signal never changed.');
pause(3);

disp('Only the observation point changed.');
pause(3);

disp('That small geometric difference');
disp('is the key idea behind Beamforming.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 5');
disp('Propagation Path Difference');
disp('------------------------------------------------------------');

pause(2);

disp('Because the antennas');
disp('are separated in space...');
pause(3);

disp('the wave travels');
disp('different distances.');
pause(3);

disp('This distance difference');
disp('is called the');
disp('Propagation Path Difference.');
pause(4);

fprintf('\n');
fprintf('Path Difference = %.6f meters\n',pathDifference);

pause(5);

disp('Even a very small');
disp('distance difference');
disp('is important.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 6');
disp('Propagation Time Delay');
disp('------------------------------------------------------------');

pause(2);

disp('Distance difference');
pause(2);

disp('produces');
pause(1);

disp('Time difference.');
pause(3);

fprintf('\n');
fprintf('Time Delay = %.3e seconds\n',timeDelay);

pause(5);

disp('The wave needs');
disp('extra time');
disp('to reach the second antenna.');
pause(4);

disp('Nothing mysterious happened.');
pause(2);

disp('The wave simply');
disp('needed more time.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 7');
disp('Received Signals');
disp('------------------------------------------------------------');

pause(2);

plotReceivedSinusoids(...
    f,...
    timeDelay);

disp('These are the received signals.');
pause(4);

disp('Notice that');
disp('their shapes are identical.');
pause(3);

disp('Their amplitudes are identical.');
pause(3);

disp('Their frequencies are identical.');
pause(3);

disp('Only one signal');
disp('appears slightly later.');
pause(4);

disp('That tiny delay');
disp('creates a phase difference.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Question');
disp('------------------------------------------------------------');

disp('If the signals');
disp('have the same amplitude');
disp('and the same frequency...');
pause(4);

disp('What is actually different?');
pause(5);

disp('Exactly...');
pause(2);

disp('Their PHASE.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 8');
disp('Spatial Phase Difference');
disp('------------------------------------------------------------');

pause(2);

fprintf('\n');
fprintf('Phase Difference = %.2f degrees\n', ...
    rad2deg(phaseDifference));

pause(5);

disp('This phase difference');
disp('did not exist');
disp('inside the transmitter.');
pause(4);

disp('It was created');
disp('by wave propagation.');
pause(4);

disp('This is why');
disp('it is called');
disp('Spatial Phase Difference.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Press any key');
disp('to visualize the phase.');
pause;
%% ------------------------------------------------------------------------
disp(' ');
disp('Step 9');
disp('Phasor Representation');
disp('------------------------------------------------------------');

pause(2);

plotPhasorDiagram(phaseDifference);

disp('The received signals can also be represented');
disp('as rotating vectors called phasors.');
pause(5);

disp('The blue vector represents');
disp('the signal received by Antenna 1.');
pause(4);

disp('The red vector represents');
disp('the signal received by Antenna 2.');
pause(4);

disp('Notice that');
disp('both vectors have the same magnitude.');
pause(4);

disp('Only their angle is different.');
pause(4);

disp('That angular separation');
disp('is exactly the Spatial Phase Difference.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 10');
disp('What Have We Learned?');
disp('------------------------------------------------------------');

pause(2);

disp('Let us summarize the entire process.');
pause(3);

disp('The wave arrives from a particular direction.');
pause(3);

disp('Different antenna positions');
disp('produce different propagation distances.');
pause(4);

disp('Different propagation distances');
disp('produce different propagation times.');
pause(4);

disp('Different propagation times');
disp('produce different signal phases.');
pause(4);

disp('This entire chain is purely a');
disp('consequence of wave propagation.');
pause;

%% ------------------------------------------------------------------------
disp(' ');
disp('Concept Chain');
disp('------------------------------------------------------------');

pause(2);

disp('Arrival Angle');
pause(2);

disp('        ↓');
pause(1);

disp('Propagation Path Difference');
pause(2);

disp('        ↓');
pause(1);

disp('Propagation Time Delay');
pause(2);

disp('        ↓');
pause(1);

disp('Spatial Phase Difference');
pause(2);

disp('        ↓');
pause(1);

disp('Beamforming');
pause(4);

%% ------------------------------------------------------------------------
disp(' ');
disp('Step 11');
disp('Simulation Results');
disp('------------------------------------------------------------');

pause(2);

displaySimulationResults( ...
    arrivalAngle,...
    d,...
    pathDifference,...
    timeDelay,...
    phaseDifference);

pause(5);

%% ------------------------------------------------------------------------
disp(' ');
disp('Final Conclusion');
disp('------------------------------------------------------------');

disp('Two antennas may receive');
disp('the same transmitted signal.');
pause(3);

disp('However...');
pause(2);

disp('they do NOT receive it');
disp('at exactly the same instant.');
pause(4);

disp('The propagation delay');
disp('creates a spatial phase difference.');
pause(4);

disp('Beamforming uses this');
disp('phase difference to determine');
disp('where the wave came from');
disp('and to electronically steer the array.');
pause(5);

disp(' ');
disp('============================================================');
disp('End of Lesson 14');
disp('Spatial Phase Difference');
disp('============================================================');