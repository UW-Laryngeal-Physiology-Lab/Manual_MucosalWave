% --------------------------------------------------------------------
function perimeterImage = extractEdgesLQ(bwimage)
% This function finds edge pixels in a binary image.  A pixel is part of an
% edge if any of the pixels in its 4-connected neighborhood are black.
% This is rudimentary vertical edge detection, used in place of Canny edge
% detection for videos with low image quality.

% Author: Ben Schoepke
% Last modified: 1/30/09

newpicSize = size(bwimage);
perimeterImage = zeros(newpicSize(1),newpicSize(2));
for i = 1:newpicSize(1)
    for j = 1:newpicSize(2)
        if (isEdge(bwimage,i,j))
            perimeterImage(i,j) = 1;
        end
    end
end