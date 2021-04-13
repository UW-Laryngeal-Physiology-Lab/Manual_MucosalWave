% generateVideosScript.m
% This .m script will generate 4 videos for use in testing new versions of
% the mucosal wave program.  The videos are of a sythetic glottis and
% correspond to the spreadsheet MucosalWaveVerify.

% KS 2011-03-08

% -------------------------------------------------------------------------
synthGlotNoCal(100,300,0.1,0,20,100,10,'uncalibratedZeroPhase.avi');
% uncalibratedZeroPhase.avi
% Frame Size: (100x300)
% w0: 0.1 radians
% R-L Phase Difference: pi Radians
% Amplitude: 20 Pixels
% Midline Length: 100 Pixels
% # Cycles: 10
% -------------------------------------------------------------------------
synthGlotCal(100,300,4000,10,180,0,20,100,10,'calibratedZeroPhase.avi');
% calibratedZeroPhase.avi
% Frame Size: (100x300)
% FPS: 4000
% Calibration Distance: 10 mm
% F0: 180 Hz
% Phase Difference: 0
% Uncalibrated Amplitude: 20 Pixels -> 2.0 mm Calibrated
% Midline Length: 100Pixels
% # Cycles: 10
% ---------------------------------------------------------------------------
synthGlotNoCal(100,300,0.12,0.5,20,100,10,'uncalibratedPhaseDiff.avi');
% uncalibratedPhaseDifference
% Frame Size: (100x300)
% w0: 0.12 radians
% R-L Phase Difference: pi+0.5 Radians
% Amplitude: 20 (Does not truly apply to phase diff videos)
% Midline Length: 100 Pixels
% # Cycles: 10
% ---------------------------------------------------------------------------
synthGlotCal(100,300,4000,10,220,-0.3,10,100,10,'calibratedPhaseDiff.avi');
% calibratedPhaseDiff.avi
% Frame Size: (100x300)
% FPS: 4000
% Calibration Distance: 10 mm
% F0: 220 Hz
% Phase Difference: (pi-0.3) Radians
% Uncalibrated Amplitude: 10 Pixels -> 1.0 mm Calibrated (Not Applicable)
% Midline Length: 100 Pixels
% # Cycles: 10
% -------------------------------------------------------------------------