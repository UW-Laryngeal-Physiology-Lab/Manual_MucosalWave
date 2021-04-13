function kymoimagedata(varargin)
% KYMOIMAGEDATA Displays Mucosal Overlay on Kymograph Images
% kymoimagedata() - Asks the User for the .xls data file generated after
% using the mucosal wave program and the kymo image that was processed.
% Then in a new figure window the image is plotted w/ Overlayed Mucosal
% Wave.  In another new figure window the image is plotted w/ ovelayed
% fold points that were used for analysis.  Note this program ASSUMES 
% IMAGES NEED ROTATION to be processed as a kymograph image.  
% The program rotates the image 90 degrees counter clockwise 
% prior to plotting.
%
% kymoimagedata(dispMucosalWave) - dispMucosalWave accepts a logical which
% determines the display of the mucosal wave image
%
% kymoimagedata(dispMucosalWave,dispPts) - dispPts accepts a logical which
% determines the display of the fold points image
%
% kymoimagedata(dispMucosalWave,dispPts,xlsFileName)- Accepts the name of
% the xls file directly instead of using a uimenu.
%
% kymoimagedata(dispMucosalWave,dispPts,xlsFileName,imageFileName) -
% Accepts the name of the xls and image file directly instead of using a
% uimenu.

% Version 0.4
% Status - OPEN

% Check How Function is being used based on input arguments
if nargin == 1
    dispMucosalWave = varargin{1,1};
    dispPts = 1;
elseif nargin == 2
    dispMucosalWave = varargin{1,1};
    dispPts = varargin{1,2};
elseif nargin == 3
    dispMucosalWave = varargin{1,1};
    dispPts = varargin{1,2};
    dataName = varargin{1,3};
elseif nargin == 4
    dispMucosalWave = varargin{1,1};
    dispPts = varargin{1,2};
    dataName = varargin{1,3};
    imName = varargin{1,4};
else
    % No Disp Options
    dispMucosalWave = 1;
    dispPts = 1;
end

% Get the XLS File Name
if nargin < 3
    % Ask User Via uimenu
    [dataFile,dataPath,dfIndex] = uigetfile('*.xls','Select the Data File!');
    if (dfIndex ~= 1)
        return
    end
    dataName = fullfile(dataPath,dataFile);
else
    % XLS FileName was input via Function Arguments
    [dataPath dataFileName dataFileExt] = fileparts(dataName);
    dataFile = [dataFileName dataFileExt];    
end

% Get the Img File Name
if nargin < 4
    % Ask the user Via uimenus
    [imFile,imPath,imIndex] = uigetfile('*.jpg','Select the Image!');
    if (imIndex ~= 1)
        return
    end
    imName = fullfile(imPath,imFile);
else
    % Img FileName was input via function arguments
    [imPath imFileName imFileExt] = fileparts(imName);
    imFile = [imFileName imFileExt];
end

% Load Image - Exit Program if the img cannot be read
try
    A = imread(imName);
catch ME
    disp(['ERROR: Cannot Read Image File: ' imName]);
    disp(ME.message);
    return
end
A = imrotate(A,90);
[m n dummy] = size(A);

% Load XLS Data - Exit Program if the xls file cannot be read
try
    [numData txData rawData] = xlsread(dataName,'data'); % Used to Plot Mucosal Wave
    [numPts txPts rawPts] = xlsread(dataName,'Points'); % Used to Plot Folds
catch ME
    disp(['ERROR: Cannot Read XLS File: ' dataName]);
    disp(ME.message);
    return
end

% Grab the Data Column header
colHeader = rawData(3,:);

% locStruct Used To Identify Important Locations in Data Sheet
locStruct = getSheetInfo(colHeader,'leftCrop','a0','a1','Fold','freq');

if locStruct.leftCrop
    % Get Mucosal Waves and left crops
    [y leftCrops] = getMucosalWaves(rawData,colHeader,locStruct,n);
    % Get Fold Point Locations Used in Analysis
    [foldPoints] = getFoldPoints(numPts,txPts,leftCrops);
    
    % Display KymoImage w/ Overlayed Waves
    if dispMucosalWave
        figure
        imshow(A,'InitialMagnification',300);
        hold all
        cOrder = get(gca,'ColorOrder');
        for k = 1:4
            % Don't Display Waves that are all zeros
            if max(abs(y(k,:))) ~= 0
                plot(y(k,:),'LineWidth',2,'Color',cOrder(k,:));
            end
        end
        title(['Kymographic Image with Mucosal Waves: ' ...
            dataFile ' & ' imFile]);
    end
    
    % Display Fold Points
    if dispPts
        figure
        imshow(A,'InitialMagnification',300);
        hold all
        cOrder = get(gca,'ColorOrder');
        count = 0;
        for edg = ['r' 'l']
            for fold = ['u' 'l']
                count = count + 1;
                xVal = foldPoints.([edg fold 'X']);
                yVal = foldPoints.([edg fold 'Y']);
                % Don't Plot Points That are all zeros
                if max(abs(xVal)) ~= 0
                    plot(xVal,yVal,'.','Color',cOrder(count,:));
                end
            end
        end
        title(['Selected Fold Points for Kymographic Analysis: ' ...
            dataFile ' & ' imFile]);
    end
    
    else
        % Left Crop Property Does Not Exist in Sheet -> Old Mucosal Sheet
        disp(['Left Crop Property does not exist in Sheet.' ...
            '  Therefore appropriate images cannot be displayed.' ...
            '  Please Use Newer Version of Mucosal Wave.']);
        
end
end

function locStruct = getSheetInfo(colHeader,varargin)
% Determines Column Location of Specific Items in Data Sheet

% Parse Input Arguments into locStruct w/ colHeader location as value
for k = 1:(nargin-1)
    varName = varargin{k};
    colLoc = strmatch(varName,colHeader);
    locStruct.(varName) = colLoc;
end
end


% Generates all Mucosal Waves Signals in Data Sheet to Absolut Pixel
% Coordinates.  Stores the associated left crop for each wave
function [y leftCrops] = getMucosalWaves(rawData,colHeader,locStruct,N)
% Determine Number of Folds in Data
numMucWaves = size(rawData(4:end,:),1);

x = 1:N;
y = zeros(4,N);
leftCrops = zeros(4,1);
% Iterate Through Fold and Generate Mucosal Wave in Y
for k = 1:numMucWaves
    % Grab Row Data Associated with Current Fold
    dataRow = 3 + k;
    data = rawData(dataRow,:);
    
    % Determine Index Based on Fold Name
    idx = strmatch(data{1,locStruct.Fold},{'ru','rl','lu','ll'});

    % Signal Terms Associated with Current Fold
    leftCrops(idx,1) = cell2mat(data(1,locStruct.leftCrop));
    a0 = cell2mat(data(1,locStruct.a0));
    w = cell2mat(data(1,locStruct.freq));

    %y(idx,:) = a0 * y(idx,:); %Initialize y to DC Term
    if isnan(a0)
        a0 = 0;
    end
    y(idx,:) = a0 * ones(1,N); % Set DC Term
    
    % Iterate Through all Amplitude and Phase Terms
    term = 1;
    colLoc = locStruct.a1 + 2*(term-1);
    curCol = cell2mat(colHeader(1,colLoc));
    % Verify That Fourier Term Exists and Calculate
    while(strcmp(curCol,['a' num2str(term)]))
        a = cell2mat(data(1,colLoc)); % Amplitude
        p = cell2mat(data(1,colLoc+1)); % Phase

        % If XL Cell is Empty this is NaN, but should really be zero
        if isnan(a)
            a = 0;
        end
        if isnan(p)
            p = 0;
        end

        % Sum New Term w/ Old Terms
        y(idx,:) = y(idx,:) + a*sin(term*w*(x-leftCrops(idx,1)) + p);

        % Next Term Variables
        term = term + 1;
        colLoc = locStruct.a0+2+2*(term-1);
        curCol = cell2mat(colHeader(1,colLoc));
    end
end
end

function [foldPoints] = getFoldPoints(numPts,txPts,leftCrops)
foldPoints = struct('ruX',0,'ruY',0,'rlX',0,'rlY',0,...
                    'luX',0,'luY',0,'llX',0,'llY',0);
% Only Do This if Fold Points Exist in Sheet
if size(numPts)
    rowPoints = numPts(:,1);
    colPoints = numPts(:,2);
    edges = cell2mat(txPts(2:end,3));
    u_l = cell2mat(txPts(2:end,4));

    %foldPoints = struct([]);
    count = 0;
    % Get all Fold Points
    for edg = ['r' 'l']
        for fold = ['u' 'l']
            count = count+1;
            leftCrop = leftCrops(count);
            logical_indexes = and((edges == edg),u_l == fold);
            foldPoints.([edg fold 'X']) = leftCrop + colPoints(logical_indexes);
            foldPoints.([edg fold 'Y']) = rowPoints(logical_indexes);
        end
    end
end
end

    
    