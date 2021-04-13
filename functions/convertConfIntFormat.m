% This function converts the confindence intervals for a sinusiodal fit
% from their a*cos(w) + b*sin(w) values to amp*sin(w+phase) values
% Author: Ben Schoepke
% Last modified: 4/9/09
%
% Inputs:
%   aRange: array containing the 'a' coeff. confidence range [low high]
%   bRange: array containing the 'b' coeff. confidence range [low high]
% Outputs:
%   ampRange: array containing the amplitude confidence range [low high]
%   phaseRange: array containing the phase confidence range [low high]
function [ampRange, phaseRange] = convertConfIntFormat(aRange, bRange)

% Initialize output arrays
ampRange = zeros(1, 2);
phaseRange = zeros(1, 2);

intersections = [aRange(1) bRange(1); aRange(1) bRange(2);...
                 aRange(2) bRange(1); aRange(2) bRange(2)];

minAmp = 1E6;
maxAmp = -1E6;

minPhase = 1E6;
maxPhase = -1E6;
% special case
if aRange(2) >= 0 && bRange(1) <= 0 && bRange(2) >= 0
    minPhase = 0; 
    maxPhase = 2*pi;
end

% Iterate through all intersection points
for i = 1:length(intersections)
    aPoint = intersections(i,1);
    bPoint = intersections(i,2);
    [amp, phase] = convertSineFormat(aPoint, bPoint);
    
    if amp < minAmp, minAmp = amp; end
    if amp > maxAmp, maxAmp = amp; end
    
    if phase < minPhase, minPhase = phase; end
    if phase > maxPhase, maxPhase = phase; end
end

ampRange(1) = minAmp;
ampRange(2) = maxAmp;

phaseRange(1) = minPhase;
phaseRange(2) = maxPhase;

end