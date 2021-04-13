% The number of edges to extract depends on curve fitting method
% The original linear least squares method only requires the 1st order
% edges.

function instructions = getInstructions(model, order, ncycles)

if (strcmp(model,'LLS'))
    numEdges = ncycles;
    instructions = sprintf('Select the first edge for each cycle of the desired vocal fold, for a total of %d edges.',numEdges);
else
    numEdges = order * ncycles;
    instructions = sprintf('Select all edges within each cycle of the desired vocal fold, for a total of %d edges.',numEdges);
end

end