function varargout = synthGlotNoCal(numRows,numCols,w,phaseDiff,...
    maxAmp,midLineLen,numCycles,varargin)
%SYNTHGLOTNOCAL Generates Synthetic Glottis Video w/ no calibration
%
%[AREAVID,ENV] = synthGlotNoCal(NUMROWS,NUMCOLS,W,PHASEDIFF,MAXAMP,...
%MIDLINELEN,NUMCYCLES) Creates a video of a synthetic glottis at AREAVID.
%The video has spatial dimensions (NUMROWSxNUMCOLS).  The folds in the
%video oscillate with angular frequency W (radians/frame) and a phase
%difference of PHASEDIFF exists between the left & right fold.  At the
%maximum point of oscillation there is a MAXAMP pixel deflection from the
%midline.  The sythetic glottis has a MIDLINELEN pixel midline.  The number
%of frames in the video depends on the desired NUMCYCLES.  ENV is an array
%showing the amplitude envelope along the midline.
%
%ENV = synthGlotNoCal(NUMROWS,NUMCOLS,W,PHASEDIFF,...
%MAXAMP,MIDLINELEN,NUMCYCLES,FILENAME) Instead of returning the sythetic
%glottis video it is saved @ FILENAME.

% 03/08/11 KS

%% Video Parameters
imSize = [numRows numCols]; numFrames = ceil((numCycles*2*pi)/w);

%% Envelope Function
env = ones(midLineLen,1);

% Partion the Envelop into Decay & Max Amplitude Sections
flatLen = round(0.30*midLineLen);

if (midLineLen-flatLen)/2 ~= round((midLineLen-flatLen)/2)
    % Ensure Posterior & Anterior Decay are the Same Length
    flatLen = flatLen + 1;
end
decayLen = (midLineLen-flatLen)/2;

% Decay Parameter
alpha = -log(0.001)/(decayLen-1);
decay = 1-exp(-alpha*(0:decayLen-1));

% Build env
env(1:decayLen,1) = decay; % Posterior Decay
env(1+flatLen+decayLen:end,1) = fliplr(decay); % Anterior Decay
env = maxAmp*env;

%% Oscillation Function
n = 1:numFrames;
oscFunctionLeft = sin(w*n);
oscFunctionRight = sin(w*n + phaseDiff);

%% Build Synthetic Video
areaVid = false([imSize numFrames]);

midLineRow = round(imSize(1)/2);
midLineCols = round((imSize(2)-midLineLen)/2):...
    (midLineLen-1)+round((imSize(2)-midLineLen)/2);

% Iterate Through Frames Building Glottal Shape
for k = 1:numFrames
    % Locate Left & Right Fold Edges
    leftEdge = round(midLineRow - env*oscFunctionLeft(k));
    rightEdge = round(midLineRow + env*oscFunctionRight(k));
    for colNum = 1:midLineLen
        % If Glottis Exists @ Midline Point Draw It Into Video
        if(leftEdge(colNum) < rightEdge(colNum))
            areaVid(leftEdge(colNum):rightEdge(colNum),...
                midLineCols(colNum),k) = 1;
        end
    end
end

% Make The Video Look Like a Larnex
areaVid = uint8(190*reshape(~areaVid,[imSize 1 numFrames]));

%% Create Video
if nargin == 8
    %Write Video
    fileName = varargin{1};
    aviObj = VideoWriter(fileName,'Uncompressed AVI'); open(aviObj);
    writeVideo(aviObj,areaVid);
    close(aviObj);
    
    %Output Arguments
    varargout{1} = env;
elseif nargin == 7
    %Output Arguments
    varargout{1} = areaVid;
    varargout{2} = env;
end

