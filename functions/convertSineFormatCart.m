% --------------------------------------------------------------------
function [A,B] = convertSineFormatCart(amp, phase)
%Converts sine waves from polar to cartesian format
%Uses trig identity amplitude*sin(wt+phase) = A*cos(wt)+B*sin(wt)
%Author: Ben Schoepke
%Last modified: 5/119/09

%Inputs: 
%   amplitude = amplitude (as described above)
%   phase = phase, ranging from 0 to 2pi (as described above) 
%Outputs:
%   A (cosine coefficient)
%   B (sine coefficient)

A = amp*cos(phase);
B = amp*sin(phase);