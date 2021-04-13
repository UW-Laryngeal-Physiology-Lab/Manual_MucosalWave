function options = getStartingPointsFourier(model, order, fundFreq, ydata, maxValues)
% This function returns a fitoptions object containing starting points 
% for Fourier Series curve fitting.
%
% Author: Ben Schoepke
% Last modified: 5/19/09
%
% Inputs:
%   model: the name of the model used for curve fitting (e.g., 'sin1')
%   order: the order of the sinusoid to be fit
%   fundFreq: estimate of the fundmanetal frequency of the fit sinusoid
%   ydata: the y data points, with DC offset removed (zero mean)
% Outputs:
%   options: a fitoptions object containing the starting points 
        
options = fitoptions(model);

NPARAMETERS = 2+2*order;
startingPointsVector = zeros(1,NPARAMETERS);

% DC offset guess (always first starting point parameter)
startingPointsVector(1) = mean(ydata);

% Frequency guess (always last starting point parameter)
startingPointsVector(NPARAMETERS) = fundFreq;

options.StartPoint = startingPointsVector;

if ~isempty(maxValues)
    % Set max values for each amplitude
    lowerBounds = zeros(1,NPARAMETERS);
    lowerBounds(1) = -Inf;
    lowerBounds(end) = -Inf;
    
    upperBounds = zeros(1,NPARAMETERS);
    upperBounds(1) = Inf;
    upperBounds(end) = Inf;

    for i = 1:length(maxValues)
        lowerBounds(2*i) = -maxValues(i);
        lowerBounds(2*i+1) = -maxValues(i);
        upperBounds(2*i) = maxValues(i);
        upperBounds(2*i+1) = maxValues(i);
    end

    options.Lower = lowerBounds;
    options.Upper = upperBounds;
end