% --------------------------------------------------------------------
function edge = isEdge(bwimage,row,col)
% Helper function for the extractEdgesLQ() function, for better readability

% Author: Ben Schoepke
% Last modified: 1/30/09
if (bwimage(row,col) == 0)
    edge = false;
    return;
end

bwimagesize = size(bwimage);
edge = true;

if (row > 1)
    if (bwimage(row-1,col) == 0)
        return;
    end
end

if (row < bwimagesize(1))
    if (bwimage(row+1,col) == 0)
        return;
    end
end

if (col > 1)
    if (bwimage(row,col-1) == 0)
        return;
    end
end

if (col < bwimagesize(2))
    if (bwimage(row,col+1) == 0)
        return;
    end
end

edge = false;