function varargout = synthGlotCal(numRows,numCols,fps,calDist,...
    f0,phaseDiff,maxAmp,midLineLen,numCycles,varargin)
%SYNTHGLOTCAL Generates Synthetic Glottis Video w/ calibration
%
%[AREAVID,ENV,AMP] = synthGlotCal(NUMROWS,NUMCOLS,FPS,CALDIST,F0,...
%PHASEDIFF,MAXAMP,MIDLINELEN,NUMCYCLES) Creates a video of a synthetic
%glottis at AREAVID. The video has spatial dimensions (NUMROWSxNUMCOLS).
%The video is temporally sampled at FPS with oscillation at frequency F0
%(cycles/s).  A black bar is drawn at the top of the video to be used for
%distance calibration.  The horizontal length of this bar (in mm) is
%CALDIST.  A phase difference of PHASEDIFF exists between the left & right
%fold. At the maximum point of oscillation there is a MAXAMP pixel
%deflection from the midline.  The sythetic glottis has a MIDLINELEN pixel
%midline. The #frames in the video depends on the desired NUMCYCLES. ENV is
%an array showing the amplitude envelope along the midline.  AMP is the
%oscillation amplitude in mm based on the calibration distance.
%
%[ENV,AMP] = synthGlotCal(NUMROWS,NUMCOLS,FPS,CALDIST,F0,PHASEDIFF,...
%MAXAMP,MIDLINELEN,NUMCYCLES,FILENAME) Instead of returning the sythetic 
%glottis video it is saved as a .avi at FILENAME.

% 03/08/2011 KS

%% Video Parameters
imSize = [numRows numCols]; w = (2*pi*f0)/fps;
numFrames = ceil((numCycles*2*pi)/w);

%% Calculate Calibrated Amplitude
amp = (calDist/midLineLen)*maxAmp;
fprintf('Calibrated Amplitude is %3.6f mm\n',amp);

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

calStop = max([midLineRow - (maxAmp + 20) 1]);

% Iterate Through Frames Building Glottal Shape
for k = 1:numFrames
    % Draw Calibration Line
    areaVid(1:calStop,midLineCols,k) = 1;
    
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
if nargin == 10
    %Write Video
    fileName = varargin{1};
    aviObj = VideoWriter(fileName,'Uncompressed AVI'); open(aviObj);
    writeVideo(aviObj,areaVid);
    close(aviObj);
    
    %Output Arguments
    varargout{1} = env; varargout{2} = amp;
elseif nargin == 9
    %Output Arguments
    varargout{1} = areaVid;varargout{2} = env;varargout{3} = amp;
end
    