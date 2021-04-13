% --------------------------------------------------------------------
function [amplitude,phase] = convertSineFormat(a, b)
%Converts sine waves from rectangular to polar format
%Uses trig identity amplitude*sin(wt+phase) = A*cos(wt)+B*sin(wt)
%Author: Ben Schoepke
%Last modified: 10/27/09
%Previous Version Calculated Phase Incorrectly as it used the ratio of sin
%amplitude to cos amplitude.  Yet the ratio of sin amplitude to cos
%amplitude was needed. - KS

%Inputs: 
%   a = A (cosine coefficient)
%   b = B (sine coefficient)
%Outputs:
%   amplitude = amplitude (as described above)
%   phase = phase, ranging from 0 to 2pi (as described above) 

amplitude = sqrt(a.^2 + b.^2);

% Calculate Phase.  Add Pi appropriately depending on Quadrant.  See
% Wikipedia article on Trig Identites for Formula and reference to proof.
if b ~= 0
    phase = atan(a ./ b);
    if b < 0
        phase = phase + pi;
    end
elseif b == 0 && a > 0
    phase = pi / 2;
elseif b == 0 && a < 0
    phase = -pi / 2;
end
end