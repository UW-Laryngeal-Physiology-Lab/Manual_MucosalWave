./developmentVerification/README.txt
This folder contains resources to verify the core functionality of a newly developed version of the mucosal wave program.  Or more importantly identify problems with it.  The spreadsheet 'MucosalWaveVerify.xlsx' guides the verification process.  Both sheets of this .xlsx are described below:

1) Synthetic Videos
This sheet guides verification of program behavior using a set of synthetic glottis videos.  Prior to performing these checks the synthetic videos must be generated.  To do this run the script named 'generateVideosScript.m' in the folder 'syntheticVideos'.  Four .avi files will be generated: uncalibratedZeroPhase.avi, calibratedZeroPhase.avi, uncalibratedPhaseDifference.avi, and calibratedPhaseDifference.avi.  These four videos correspond to four sections in this sheet.  The four specific sections are addressed below:

- Uncalibrated Zero Phase
Perform mucosal wave analysis on 'uncalibratedZeroPhase.avi'.  Skip the calibration step.  Enter the four individual fold amplitudes in the column named 'Computed Amp (Pixels)' and the angular frequencies in the column named 'Computed w0 (rad)'.  The average error (expected - measured) for the amplitude and frequency are reported in the orange rows below.  The amplitude error should be within +/- 2 pixels and the w0 error should be within +/- 0.5 radians.  These are not hard limits so use your judgment if something seems suspicious

- Calibrated Zero Phase
Perform mucosal wave analysis on 'calibratedZeroPhase.avi'.  To calibrate this video set the calibration length to 10 mm.  This length corresponds to the length of the black rectangle at the top of the synthetic video.  Additionally set the FPS to 4000.  Perform mucosal wave analysis and enter the four individual fold amplitudes  in the column named 'Computed Amp (mm)' and the frequencies in the column named 'Computed f0 (Hz)'.  The average error (expected - measured) for the amplitude and frequency are reported in the orange rows below.  The amplitude error should be within +/- 0.5 mm and the f0 error should be within +/- 2 Hz.  These are not hard limits so use your judgment if something seems suspicious.

- Uncalibrated Phase Diff (Pi+0.5 R-L)
Perform mucosal wave analysis on 'uncalibratedPhaseDifference.avi'.  Skip the calibration step.  Enter the four individual fold phases in the column named 'Computed Phase (rad)' and the angular frequencies in the column named 'Computed w0 (rad)'.  The average error (expected - measured) for the right-left phase difference and angular frequency are reported in the orange rows below.   The phase difference error should be within +/- 0.1 radian and the w0 error should be within +/- 0.5 radians.  These are not hard limits so use your judgment if something seems suspicious

- Calibrated Phase Diff (Pi-0.3 R-L)
Perform mucosal wave analysis on 'calibratedPhaseDifference.avi'.   To calibrate this video set the calibration length to 10 mm.  This length corresponds to the length of the black rectangle at the top of the synthetic video.  Additionally set the FPS to 4000.  Enter the four individual fold phases in the column named 'Computed Phase (rad)' and the frequencies in the column named 'Computed f0 (Hz)'.  The phase difference error should be within +/- 0.1 radian and the f0 error should be within +/- 2 Hz.  These are not hard limits so use your judgment if something seems suspicious

- Uncalibrated Zero Phase Kymogram
This is the same as uncalibrated Zero Phase except that a kymogram will be loaded directly.  Load the kymogram named 'uncalibratedZeroPhaseKymogram.jpg' from the folder 'syntheticKymograms'.  Perform mucosal wave analysis and fill out the spreadsheet in a similar fashion to the uncalibrated zero phase video.

- Uncalibrated Phase Diff Kymogram (Pi-0.3 R-L)
This is the same as uncalibrated Phase Diff except that a kymogram will be loaded directly.  Load the kymogram named 'uncalibratedPhaseDifferenceKymogram.jpg' from the folder 'syntheticKymograms'.  Perform mucosal wave analysis and fill out the spreadsheet in a similar fashion to the uncalibrated phase difference video.

2) Real Video
This sheet guides verification using real high speed videos.  Select a HSV and perform uncalibrated analysis using the most recently released version of the mucosal wave program.  Note it is important to utilize a video of a larynx with regular vibration.  If an irregular video is used it is possible that large differences in parameter values can be found due to analysis sensitivity appose a bug in the program.  Enter the individual 'freq','a1', and 'p1' values in the columns corresponding to the old version after analysis.  Repeat this for the new version that is being tested.  It is important to utilize the same settings (frames, threshold, etc.) when using the different program versions to minimize parameter differences due to user driven analysis.  Error (differences in value between the released and version being tested) is reported in the orange box below.  Repeat this process for a calibrated video & a kymogram.  Large error indicates a possible problem with the new version of the program.
