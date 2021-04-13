% --------------------------------------------------------------------
function displayFitResults(resultsStructs, mwaveImage)
% This function plots a mucosal wave image with subplots consisting of the
% curve fitting results.
% Author: Ben Schoepke
% Last modified: 4/24/09

if nargin < 2, return; end
if mwaveImage == 0, return; end

maxOrder = 1;
for i = 1:length(resultsStructs)
    if ~isempty(resultsStructs(i))
        currResult = resultsStructs(i);
        if currResult.order > maxOrder, maxOrder = currResult.order; end
    end
end

% scrsz = get(0,'ScreenSize');
% figure('Position', [40 40 4*scrsz(3)/5 4*scrsz(4)/5]);
figure
set(gcf, 'Name', 'Curve fitting results')

% nResults = length(resultsStructs);  
% 
% if nResults > 2 && maxOrder < 5
%     nRows = 2;
%     nColumns = 3;
%     subplot(nRows, nColumns, [1 (nColumns + 1)])
% else
%     nRows = 2;
%     nColumns = 3;
%     subplot(nRows, nColumns, [1 (nColumns + 1)])
% %     nRows = 1;
% %     nColumns = 1 + nResults;
% %     subplot(nRows, nColumns, 1)
% end

subplot(2,4, 5:8)

imshow(mwaveImage)

% Use standard color order for plots and corresponding text backgrounds
colors = get(gca,'ColorOrder');

% Plot all curves
hold on;
for i = 1:length(resultsStructs)
    if strcmp(resultsStructs(i).fold, 'ru'), FOLD_INDEX = 1;
    elseif strcmp(resultsStructs(i).fold, 'rl'), FOLD_INDEX = 2;
    elseif strcmp(resultsStructs(i).fold, 'lu'), FOLD_INDEX = 3;
    elseif strcmp(resultsStructs(i).fold, 'll'), FOLD_INDEX = 4;
    end
    if ~isempty(resultsStructs(i))
        plot(resultsStructs(i).xdata, resultsStructs(i).ydata, ...
            'Color', colors(FOLD_INDEX,:));
    end
end
hold off;

% Put curve result text for each curve in subplots
for i = 1:length(resultsStructs)
    if strcmp(resultsStructs(i).fold, 'ru'), FOLD_INDEX = 1;
    elseif strcmp(resultsStructs(i).fold, 'rl'), FOLD_INDEX = 2;
    elseif strcmp(resultsStructs(i).fold, 'lu'), FOLD_INDEX = 3;
    elseif strcmp(resultsStructs(i).fold, 'll'), FOLD_INDEX = 4;
    end
    
%     if ~isempty(resultsStructs(i))
%         if nRows == 1 || i <= 2 
%             subplot(nRows, nColumns, i+1)
%         else
%             subplot(nRows, nColumns, i+2)
%         end
% %         plot(rand(10,1));
        subplot(2,4,i)
        text(0,0.5, ...
            results2str(resultsStructs(i)), ...
            'BackgroundColor', colors(FOLD_INDEX,:), 'FontName','FixedWidth');
        axis off
%     else
%         i = i+1;
    end
end
