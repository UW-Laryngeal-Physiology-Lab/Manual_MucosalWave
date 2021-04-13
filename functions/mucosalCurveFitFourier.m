function result = mucosalCurveFitFourier(vocalFold,x,y,imageSize,order,...
    nCycles,units,frameRate,maxAmpValues)
% This function does 'Fourier Series' nonlinear least squares curve fitting 
% for a mucosal wave image. The input image must be binary and is assumed
% to contain only the edges desired to be fit.
%
% Type 'doc fit' in the Matlab Command Window for more information. The fit
% function is part of the Curve Fitting Toolbox.
%
% Author: Ben Schoepke
% Last modified: 5/5/09
%
% Inputs
%   vocalFold: the name of the vocal fold being fit (e.g., 'ru')
%   y: y coordinates of points to fit
%   x: x coordinates of points to fit
%   order: the order of the fit, normally 1 (first order)
%   nCyles: the number of cycles present in the image (obtained from GUI)
%   units: an array containing the [amplitude frequency] units
%   frameRate: the frame rate (frames per second) of the video used
%   maxAmpValues: the guesses used to limit max amplitude values in curve
%                   fitting
%
% Outputs
%   result: a structure containing...
%       fold: the vocal fold the result is for
%       model: the curve fitting type used (e.g., 'LLS' or 'Fourier')
%       order: the order of the mucosal wave
%       nycycles: the # of cycles in the mucosal wave
%       cfitObject: cfit object containing model type and coefficients
%       goodness: goodness of fit data (not applicable for LLS)
%       xdata: xdata for plotting
%       ydata: ydata for plotting
%       a0: DC offset of fitted curve
%       units: a cell array containing the 
%                {amplitude frequency ampConversionFactor} units
%       frameRate: the frame rate (frames per second) of the video used

% Initialize the output structure
result = struct('fold', {}, 'model', {}, 'order', {}, 'ncycles', {}, ...
    'cfitObject', {}, 'goodness', {}, 'xdata', {}, 'ydata', {},...
    'a0', {}, 'units', {}, 'frameRate', {});

% Validate inputs that are necessary for curve fitting
% Note: the vocalFold, units, and frameRate inputs are not validated since 
%       they are not required for curve fitting routine
if (isempty(x) || isempty(y)),return;
elseif (order <= 0 || order > 8),return;
elseif (nCycles <= 0),return;
end

% Perform curve fitting, using the 'Fourier' library model
libraryModel = sprintf('fourier%d',order);

% Compute best guesses for initial fitting parameters
fundFreqEstimate = 2*pi/(imageSize(2)/nCycles);
startingPoints = getStartingPointsFourier(libraryModel,order,fundFreqEstimate,y,maxAmpValues(1:order));
[model, goodness] = fit(x,y,libraryModel,startingPoints);

modelCoeff = coeffvalues(model);

% Save the model and fitted points, used for plotting purposes\
result = setfield(result,{1},'fold',vocalFold);
result = setfield(result,{1},'model',libraryModel);
result = setfield(result,{1},'order',order);
result = setfield(result,{1},'ncycles',nCycles);
result = setfield(result,{1},'cfitObject',model); % contains coefficients
result = setfield(result,{1},'goodness',goodness);  
result = setfield(result,{1},'a0',modelCoeff(1));
result = setfield(result,{1},'units',units);
result = setfield(result,{1},'frameRate',frameRate);

[plotX, plotY] = getPlotPoints(imageSize, result, 0.1);
result = setfield(result,{1},'xdata',plotX);
result = setfield(result,{1},'ydata',plotY);