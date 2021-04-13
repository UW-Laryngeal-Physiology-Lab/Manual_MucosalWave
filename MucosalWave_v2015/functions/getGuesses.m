function guesses = getGuesses(tuneHandles)

% Get amplitude and phase guesses from Tune GUI
guesses = zeros(tuneHandles.MAX_ORDER, 1);
for i = 1:length(guesses)
    ampHandle = sprintf('a%dedit',i);
    guesses(i) = str2double(get(tuneHandles.(ampHandle),'String'))/sqrt(2);
    % Note: the divide by sqrt(2) is necessary because curve fitting is 
    % performed in acos(w) + bsin(w) form while the user is entering max
    % amplitudes in asin(w+p) form.
end