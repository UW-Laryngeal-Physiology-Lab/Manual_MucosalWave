% --- Converts a radian frequency to actual frequency (Hz)
function ampWithUnits = convertAmpToRealUnits(amp, unitsStruct)

UNITS_CONVERSION_INDEX = 3;
ampWithUnits = amp .* unitsStruct{UNITS_CONVERSION_INDEX};