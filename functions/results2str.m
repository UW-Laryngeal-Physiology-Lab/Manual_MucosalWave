function resultstrings = results2str(resultsstruct)
% This function outputs curve fitting results to a formatted
% cell array of strings, similar to the output of evalc('cfitObject')
% Author: Ben Schoepke
% Last modified: 4/3/09

% note: 'end' is a reserved word: the last index in a array/cell array

resultstrings = {};
if nargin < 1, return; end
if isempty(resultsstruct), return; end

vocalFold = resultsstruct.fold;
cfitObject = resultsstruct.cfitObject;
frameRate = resultsstruct.frameRate;

units = resultsstruct.units;
ampUnits = units{1};
freqUnits = units{2};
ampUnitsConversionFactor = units{3};

if strcmp(freqUnits, 'Hz')
    freqVariable = 'f';
    freqTerm = sprintf('2\\pi%s',freqVariable);
else
    freqVariable = 'w';
    freqTerm = freqVariable;
end

if isempty(cfitObject), return; end
goodness = resultsstruct.goodness;
model = resultsstruct.model;
if ~strcmp(model, 'LLS'), model = model(1:end-1); end
order = resultsstruct.order;
if order < 1 || order > 8, return; end

% Build vocal fold string
if strcmp(vocalFold, 'ru')
    vocalFold = 'RIGHT UPPER';
elseif strcmp(vocalFold, 'lu')
    vocalFold = 'LEFT UPPER';
elseif strcmp(vocalFold, 'rl')
    vocalFold = 'RIGHT LOWER';
elseif strcmp(vocalFold, 'll')
    vocalFold = 'LEFT LOWER';
else
    vocalFold = 'ERROR: INVALID VOCAL FOLD NAME';
end
resultstrings{end+1} = vocalFold;
% resultstrings{end+1} = sprintf('  Amplitude units: %s, Frequency units: %s\n',...
%     ampUnits, freqUnits);

resultstrings{end+1} = ['Amp = ', num2str(resultsstruct.realamp), ' in ', ampUnits];

resultstrings{end+1} = sprintf('Fit method: %s, order %d', ...
    model,order);
resultstrings{end+1} = sprintf('  y = a0 + a1*sin(1*%s*t + p1)\n',freqTerm);
for i = 2:order
        resultstrings{end} = [resultstrings{end} ...
            sprintf('         + a%d*sin(%d*%s*t + p%d)\n',i,i,freqTerm,i)];
end
    
coefficients = coeffvalues(cfitObject);
coefficients(1:end-1) = coefficients(1:end-1) .* ampUnitsConversionFactor;

% Special condition for old linear least squares curve fitting method
% that does not consider noise so it has no confidence intervals.  Also 
% does not provide goodness of fit info.
% if (strcmp(model, 'LLS'))
    resultstrings{end+1} = 'Coefficients:';
    resultstrings{end+1} = sprintf('  %s  = %0.4g %s',...
        freqVariable,convertFreqToRealUnits(coefficients(end),frameRate),freqUnits);
    resultstrings{end+1} = sprintf('  a0 = %0.4g %s', coefficients(1),...
        ampUnits);
    for i = 1:order
        [amp,phase] = ...
            convertSineFormat(coefficients(2*i),coefficients(2*i+1));
        resultstrings{end+1} = sprintf('  a%d = %0.4g %s  p%d = %0.4g',...
            i,amp,ampUnits,i,phase);
    end
    

% else
%     confIntervals = confint(cfitObject);
%     
%     
%     
%     % Convert all amplitude confidence intervals to real units
%     confIntervals(1:end-2) = confIntervals(1:end-2)...
%         .* ampUnitsConversionFactor;
%     
%     resultstrings{end+1} = 'Coefficients (95% conf. range):';            
%     resultstrings{end+1} = sprintf('  f  =  %0.4g %s (%0.4g, %0.4g)', ...
%         convertFreqToRealUnits(coefficients(end),frameRate),...
%         freqUnits,...
%         convertFreqToRealUnits(confIntervals(end-1),frameRate),...
%         convertFreqToRealUnits(confIntervals(end),frameRate));
%     resultstrings{end+1} = sprintf('  a0 =  %0.4g %s (%0.4g, %0.4g)', ...
%         coefficients(1)*units{3},ampUnits,confIntervals(1),confIntervals(2));
%     
%     for i = 1:order
%         [amp,phase] = convertSineFormat(coefficients(2*i), coefficients(2*i+1));
%         
%         a_low = confIntervals(4*i-1);
%         a_high = confIntervals(4*i);
%         b_low = confIntervals(4*i+1);
%         b_high = confIntervals(4*i+2);
%         [ampRange, phaseRange] = ...
%             convertConfIntFormat([a_low a_high], [b_low b_high]);
%         
%         
%         resultstrings{end+1} = sprintf('  a%d =  %0.4g %s (%0.4g, %0.4g)', ...
%             i,amp,ampUnits,ampRange(1),ampRange(2));
%         resultstrings{end+1} = sprintf('  p%d =  %0.4g (%0.4g, %0.4g)',...
%             i,phase,phaseRange(1),phaseRange(2));
% %             
%     end

%     resultstrings{end+1} = sprintf('\nGoodness of fit:');
%     resultstrings{end+1} = sprintf('  SSE: %0.4g',goodness.sse);
    if isfield(goodness, 'rsquare')
        resultstrings{end+1} = ...
            sprintf('\nR-square: %0.4g',goodness.rsquare);
    end
%     resultstrings{end+1} = sprintf('  Adjusted R-square: %0.4g', ...
%         goodness.adjrsquare);
%     resultstrings{end+1} = sprintf('  RMSE: %0.4g',goodness.rmse);
end