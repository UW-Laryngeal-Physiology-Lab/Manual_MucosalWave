function result = mucosalCurveFitLLS(vocalFold,x,y,imageSize,order,nCycles,...
    units,frameRate)
% This function does 'sum of sines' linear least squares curve fitting 
% for a mucosal wave image. The input image must be binary and is assumed
% to contain only the edges desired to be fit.
%
% Note this is the original ('old') curve fitting method implemented in the
% mucosal wave program.
%
% ******* ONLY WORKS FOR 1ST ORDER WAVES! ******* 
%
% Written by: Henry Tsui
% Revised by: Erik Bieging
% Revised by: Yue Gao
% Revised by: Lizhu Qi
% Converted to function form by: Ben Schoepke
% Last modified: 5/5/09
%
% Inputs
%   vocalFold: the name of the vocal fold being fit (e.g., 'ru')
%   x: x coordinates of points to fit
%   y: y coordinates of points to fit
%   order: the order of the fit, normally 1 (first order)
%   nCyles: the number of cycles present in the image (obtained from GUI)
%   units: an array containing the [amplitude frequency] units
%   frameRate: the frame rate (frames per second) of the video used
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

% Validate inputs
if (isempty(y) || isempty(x)),return;
elseif (order <= 0 || order > 2),return;
elseif (nCycles <= 0),return;
end

%     period = handles.ncycles;
period = nCycles;
% s = size(edgeImage);

%x and y are vectors containing the x and y coordinates of each edge
%point in newbwlu
% [y,x] = find(edgeImage ~= 0);

%This is used to calculate the period of the data. t is the period
% if (order == 2)
%     me = sinMean;
% else
    me = floor(mean(y));
% end

try
    tr = x(find(y == me));
    t = (sum(tr) - period*tr(1))*2/(1+period-1)/(period-1);
    if (order == 2)
        t = (sum(tr) - period/2*tr(1))*2/(1+period/2-1)/(period/2-1);
    end;
catch
    errordlg('Error: cannot use Linear Least Squares fitting with "Select Points" edge selection method. Use threshold method instead');
    return
end
n = [];
V = [];
var = 2*pi*x/t;

% This creates an array containing a sine and cosine corresponding to
% each order using the calculated period and x-values specified in x.
for i = 1:order
    xx{2*i-1} = sin(i*var);  %%[sinw cosw sin2w cos2w sin3w cos3w]
    xx{2*i} = cos(i*var);
end

% This performs the actual curve fitting by calculating the optimal
% amplitude for each sinusoidal function in the array xx.
for j = 1:2*order
    ly(j) = sum(y.*xx{j}) - mean(y)*sum(xx{j});
    n = [n ly(j)];
    m = [];
    for k = 1:2*order
        l(j,k) = sum(xx{k}.*xx{j}) - mean(xx{k})*sum(xx{j});
        m= [m l(j,k)];
    end
    V = [V m'];
end

a = V'\n';  % % (n'/V')

%a0 is the DC offset of the sinusoid
a0 = mean(y);

for ii = 1:2*order
    a0 = a0 - a(ii)*mean(xx{ii});
end

% xxx and yyy are created based on the calculated sinusoid function 
% and are used to plot the results.
xxx= 1:0.1:imageSize(2);
yyy = a0;
for jj = 1:order
    yyy = yyy +  a(2*jj-1)*sin(2*jj*pi*xxx/t) + a(2*jj) * ...
        cos(2*jj*pi*xxx/t);
end

% Save the fitted points, used for plotting purposes
result = setfield(result,{1},'fold',vocalFold);
result = setfield(result,{1},'model','LLS');
result = setfield(result,{1},'order',order);
result = setfield(result,{1},'ncycles',nCycles);
result = setfield(result,{1},'cfitObject', ...
    createCfitObj(order,a0,a,t));
result = setfield(result,{1},'goodness',struct([]));
result = setfield(result,{1},'xdata',xxx);
result = setfield(result,{1},'ydata',yyy);
result = setfield(result,{1},'a0',a0);
result = setfield(result,{1},'units',units);
result = setfield(result,{1},'frameRate',frameRate);

end


% --------------------------------------------------------------------
function cfitobj = createCfitObj(order, a0, amplitudeVec, period)
% This function puts the fitted parameters into a cfit object
% Done this way to be consistent with the Fourier Series
% fitting function's output.
% Assumes order is equal to 1 or 2.

if (order == 1)
    cfitobj = cfit(fittype('fourier1'),a0,amplitudeVec(2), ...
        amplitudeVec(1),2*pi/period);
elseif (order == 2)
    cfitobj = cfit(fittype('fourier2'),a0,amplitudeVec(2), ...
        amplitudeVec(1),amplitudeVec(4),amplitudeVec(3),2*pi/period);
end

end