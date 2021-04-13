function currFrameIm = displayPreprImage(image, axis, rotationDeg, cropRect, columnIndex)
% Displays an image on a given axis with a given rotation and crop
% rectangle + kymographic column index line overlaid.
% Inputs:
%   image: the image to display
%   axis: the axis to display the image on
%   rotationDeg: the amount of rotation to apply to image, in degrees
%   cropRect: a rectange with the image crop dimensions
%   lineIndex: the kymographic columnn index
% Author: Ben Schoepke

axes(axis); % Makes "axis" the current axis
cla(axis, 'reset') % Clears the axis and resets it to default dimensions
currFrameIm = imrotate(image, rotationDeg, 'bilinear', 'loose');
hold on
    imshow(currFrameIm);
    rectangle('Position', cropRect, 'LineStyle', '--', 'EdgeColor', 'r');
    line ([columnIndex columnIndex], [0 size(currFrameIm, 1)]);
hold off