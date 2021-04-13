function ampResults = getAmplitudeResults(cfitObject, order)
% This function sets all the amp result labels in the Tune GUI

coeff = coeffvalues(cfitObject);
ampResults = [];
for k = 1:order
    [amp, phase] = convertSineFormat(coeff(2*k), coeff(2*k+1));
    ampResults(end+1) = amp;
end
