function done = allEdgesSelected(ruEdge, rlEdge, luEdge, llEdge)

done = false;

if (any(ruEdge) & any(rlEdge) & any(luEdge) & any(llEdge)), done = true; end