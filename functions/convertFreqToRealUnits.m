% --- Converts a radian frequency to actual frequency (Hz)
function freq = convertFreqToRealUnits(w, framerate)

if framerate == 0    % 0 is a special value for case when framerate is unknown
    freq = w;
else
    freq = (w .* framerate) ./ (2*pi); 
end