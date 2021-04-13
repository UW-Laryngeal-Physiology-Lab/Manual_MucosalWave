function displayEdges(edges, mwaveImage, useNewFigure)

MARKER_SIZE = 20; % units are points
if useNewFigure, figure; end

colors = get(gca,'ColorOrder'); %standard Matlab plot color sequence
imshow(mwaveImage);
colormap('gray')
hold on

for i = 1:length(edges)
    currEdges = edges{i};
    if currEdges ~= 0
        scatter(currEdges(:,2),currEdges(:,1),MARKER_SIZE,colors(i,:),'filled');
    end
end
hold off