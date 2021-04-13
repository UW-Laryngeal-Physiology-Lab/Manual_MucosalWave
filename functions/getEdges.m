function [y,x] = ...
    getEdges(mwaveimage, bwimage, usethreshold, vocalFold, order, ncycles)
% This function allows the user to manually extract the vocal fold edges
% from a thresholded (binary) mucosal wave image.
% Adapted to function form by Ben Schoepke
% 5/19/09

% Modified Function to ensure edge pixels that are accurately choosen by
% selection rectangle 08/04/2010 KS


close(setdiff(allchild(0),gcf)); % close all open figures
if strcmp(vocalFold,'ru'), vocalFoldName = 'right upper';
elseif strcmp(vocalFold,'rl'), vocalFoldName = 'right lower';
elseif strcmp(vocalFold,'lu'), vocalFoldName = 'left upper';
elseif strcmp(vocalFold,'ll'), vocalFoldName = 'left lower'; end

y = 0;
x = 0;
%global points_matrix_nik;
%global points_matrix_nik_edge;

if nargin < 5, return; end

% Initialize output image
imageSize = size(bwimage);
edgeImage = zeros(imageSize(1), imageSize(2));
displayImage = bwimage * 255;

edgeFig = figure();

if usethreshold
    % Compute Magnification Settings
    scrsz = get(0,'ScreenSize');
    mag = min([(3/4)*(scrsz(3)/size(mwaveimage,2)) ...
        (3/4)*(scrsz(4)/size(mwaveimage,1))]);
    figWidth = mag*size(displayImage,2);
    figHeight = mag*size(displayImage,1);
    figX = (1/2)*(scrsz(3) - figWidth);
    figY = (1/2)*(scrsz(4) - figHeight);
    
    
    % Setup Edge Display Figure
    colormap(hot);
    imagesc(displayImage);
    currAxis = gca;
    
    % Set Magnification 
    set(gcf,'Position',[figX figY figWidth figHeight]);
    
    axis off;
    set(gcf, 'Name', 'Select vocal fold edges');

    numEdges = order * ncycles;
    instructions = sprintf('Select all edges within each cycle of the %s vocal fold, for a total of %d edges.',vocalFoldName,numEdges);

    % The user extracts each required edge, one-by-one with the getrect fcn.
    for i = 1:numEdges
        temp = zeros(imageSize);
        validRect = [false false]; % sentinel values for while loop
        while (~validRect(1) || ~validRect(2))
            validRect = [false false];
            try
                % User chooses a rectangular region in curr figure
                figure(edgeFig);
                title(currAxis, instructions);
                rect = getrect(edgeFig); 
            catch 
                return % if no rectangle selected
            end
            
            % Find Bounds on Rectangle
            % Set Bounds such that it selectes pixels contained by drawn 
            % rectangle.  NOTE: The Matrix Index Corresponding to a pixel
            % exists @ the center of the pixel in the axis.
            colMin = round(rect(1)); colMax = round(rect(1) + rect(3));
            rowMin = round(rect(2)); rowMax = round(rect(2) + rect(4));
            width = 1 + (colMax - colMin); height = 1 + (rowMax - rowMin);
            
            if (width < 1 || height < 1)
                errordlg('Invalid rectangle (cannot be a single point). Try again.')
                uiwait; % wait until user closes error dialog
            else
                validRect(1) = true;
            end

            % Constrain rectangle to dimensions of current image
            if colMin < 1
                %width = width + xselect;
                colMin = 1;
            end
            if rowMin < 1
                %height = height + yselect;
                rowMin = 1; 
            end
            if colMax > imageSize(2)
                %width = imageSize(2) - xselect;
                colMax = imageSize(2);
            end
            if rowMax > imageSize(1)
                %height = imageSize(1) - yselect;
                rowMax = imageSize(1);
            end

            %temp is part of bwimage selected
            %temp(yselect:yselect+height,xselect:xselect+width) = bwimage(yselect:yselect+height,xselect:xselect+width); 
            temp(rowMin:rowMax,colMin:colMax) = bwimage(rowMin:rowMax,colMin:colMax);
            [row, col] = find(temp ~= 0);

            if ~any(row) && validRect(1)
                errordlg('Invalid rectangle (must include at least one white point). Try again.')
                uiwait; % wait until user closes error dialog
            else
                if validRect(1), validRect(2) = true; end
            end

            % Store Selected Pixels & Display
            if validRect(2)
                edgeImage(rowMin:rowMax,colMin:colMax) = ...
                    bwimage(rowMin:rowMax,colMin:colMax);
                
                % Change color of pixels in selected edge and display
                displayImage = updateImage(displayImage,rowMin,rowMax,...
                    colMin,colMax,vocalFold);
                imagesc(displayImage)
                
                axis off
            end
        end
    end
    % Store Edge Locations
    [y,x] = find(edgeImage);
else
    % Determine Window Magnification so Figure width is 3/4th screen
    scrsz = get(0,'ScreenSize');
    mag = 100*min([(3/4)*(scrsz(3)/size(mwaveimage,2)) ...
        (3/4)*(scrsz(4)/size(mwaveimage,1))]);
    
    imshow(mwaveimage,'InitialMagnification',mag)
    currAxis = gca;
    hold on
    title(currAxis, 'Hit "backspace" to delete last point(s). Hit "Enter" when finished selecting all points.')
    axis off
    set(gcf, 'Name', 'Select points on vocal fold edges');
    colormap('gray')
    try
        [x,y] = getpts;  % user interactively choose points on image
        %points_matrix_nik=[points_matrix_nik;round(x) round(y)];
        %A loop to label each point with its vocal fold
        %for count = 1: length(x)
        %    points_matrix_nik_edge=[points_matrix_nik_edge;vocalFold];
        %end
        plot(x,y,'r.')
    catch
        % do nothing (usual expection occurs if figure window is closed)
        return 
    end
    hold off

%     try
%         title(currAxis, 'Red dots are selected points');
%     catch
%     % Do nothing, error will occur if selection window closed
%     end
%     pause(1);
    
end % end of if
close(gcf);
pause(0.5);
end % end of function

% This function changes the color of the pixels of the selected edge
% Author: Ben Schoepke
% Last Modified: 4/15/09
function updatedImage = updateImage(displayImage,rowmi,rowma,colmi,colma,vocalFold)
    COLOR_VALUE = 96;
    updatedImage = displayImage;
    %global points_matrix_nik;
    %global points_matrix_nik_edge;
    for r = rowmi:rowma
        for c = colmi:colma
            if updatedImage(r,c) ~= 0, 
                updatedImage(r,c) = COLOR_VALUE;
                %points_matrix_nik=[points_matrix_nik;r c];
                %points_matrix_nik_edge=[points_matrix_nik_edge;vocalFold];
            end
        end
    end
end