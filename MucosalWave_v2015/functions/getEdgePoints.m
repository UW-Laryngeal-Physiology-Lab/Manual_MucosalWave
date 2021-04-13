function [y,x] = getEdgePoints(mwaveImage)
% This function allows the user to manually extract the vocal fold edges
% by clicking points on a kymographic image
% Adapted to function form by Ben Schoepke
% Last modified: 4/30/09

y = 0;
x = 0;

if nargin ~= 1, return; end

figure;
imagesc(mwaveImage)
currAxis = gca;
hold on
title(currAxis, 'Hit "backspace" to delete last point(s). Right click when finished selecting all points.')
axis off
set(gcf, 'Name', 'Select points on vocal fold edges');
colormap('gray')
try
    [x,y] = getpts;  % user interactively choose points on image
    plot(x,y,'r.')
%     x = round(x);    % round points to correspond to pixel indices
%     y = round(y);
%     
%     % Put selected points into output image and plot them in current figure
%     % for review
%     for i = 1:length(x)
%         if y(i) > 0 && y(i) <= size(mwaveImage,1) && x(i) > 0 && x(i) <= size(mwaveImage,2)
%             edgeImage(y(i), x(i)) = 255;
%             plot(x(i),y(i),'r.')
%         end
%     end

catch
    % do nothing (usual expection occurs if figure window is closed)
end
hold off

try
    title(currAxis, 'Red dots are selected points');
catch
% Do nothing, error will occur if selection window closed
end

