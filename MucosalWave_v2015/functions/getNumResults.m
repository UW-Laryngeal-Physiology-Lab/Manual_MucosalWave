% This function returns the integer number of results that exist.
% Author: Ben Schoepke
% Last modified: 4/24/09
function numResults = getNumResults(handles)
    
    numResults = 0;
    
    RIGHT_UPPER_RESULT_FIELD = 'ruresult';
    RIGHT_LOWER_RESULT_FIELD = 'rlresult';
    LEFT_UPPER_RESULT_FIELD = 'luresult';
    LEFT_LOWER_RESULT_FIELD = 'llresult';
    
    if ~isfield(handles, RIGHT_UPPER_RESULT_FIELD) ...
            || ~isfield(handles, RIGHT_LOWER_RESULT_FIELD) ...
            || ~isfield(handles, LEFT_UPPER_RESULT_FIELD) ...
            || ~isfield(handles, LEFT_LOWER_RESULT_FIELD)
        return
    end

    results = [handles.(RIGHT_UPPER_RESULT_FIELD), ...
               handles.(RIGHT_LOWER_RESULT_FIELD), ...
               handles.(LEFT_UPPER_RESULT_FIELD), ...
               handles.(LEFT_LOWER_RESULT_FIELD)];

    for i = 1:length(results)
        if (~isempty(results(i))), numResults = numResults + 1; end
    end
    
end