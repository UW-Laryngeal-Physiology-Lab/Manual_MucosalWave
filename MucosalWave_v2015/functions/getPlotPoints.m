% Compute x and y points from the fitted curve equation, used for plotting
% Inputs:
%   mwaveImageSize: the output of size(mucosalWaveImage)
%   cfitResult: the result structure output from the curve fitting function
%   xstep: the spacing between points in the x direction
% Outputs: x and y are points used for plotting
% Author: Ben Schoepke
% Last modified: 5/15/09
function [x,y] = getPlotPoints(mwaveImageSize, cfitResult, xstep)

order = cfitResult.order;
cfitObject = cfitResult.cfitObject;

x = 1:xstep:mwaveImageSize(2);

modelCoeff = coeffvalues(cfitObject);
a0 = modelCoeff(1);
w = modelCoeff(length(modelCoeff));

y = a0;
for i = 1:order
    y = y + modelCoeff(2*i)*cos(w*i*x) + modelCoeff(2*i+1)*sin(w*i*x);
end