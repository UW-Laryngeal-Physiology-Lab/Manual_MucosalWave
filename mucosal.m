%%Written by: Henry Tsui
% Revised by: Erik Bieging
% Revised by: Yue Gao
% Revised by: Lizhu Qi
% Major redesign by: Ben Schoepke Spring 2009
% Revised by: Andy Kochie & KS
% Revised by: KS 11/01/2010
% Revised by: KS 03/08/2011
% Revised by: Andrew Vamos 07/18/2016

function varargout = mucosal(varargin)
% MUCOSAL M-file for mucosal.fig
%      MUCOSAL, by itself, creates a new MUCOSAL or raises the existing
%      singleton*.
% 
%      H = MUCOSAL returns the handle to a new MUCOSAL or the handle to
%      the existing singleton*.
%
%      MUCOSAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUCOSAL.M with the given input arguments.
%
%      MUCOSAL('Property','Value',...) creates a new MUCOSAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mucosal_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mucosal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mucosal

% Last Modified by GUIDE v2.5 14-Sep-2010 18:43:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mucosal_OpeningFcn, ...
                   'gui_OutputFcn',  @mucosal_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mucosal is made visible.
function mucosal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command pixelindex arguments to mucosal (see VARARGIN)

% Choose default command pixelindex output for mucosal
path(path,genpath(cd))
path(path,genpath(fullfile(cd, 'subfigures')))
path(path,genpath(fullfile(cd, 'documentation')))
path(path,genpath(fullfile(cd, 'functions')))
handles.output = hObject;
guidata(hObject, handles); % Update handles structure


% --- Outputs from this function are returned to the command pixelindex.
function varargout = mucosal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command pixelindex output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in load.
function file_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Initialize the Handles Structure
initHandles(hObject,handles);
handles = guidata(hObject);

% This opens an .avi file
currDirectory = cd;
if isfield(handles, 'lastVideoPath')
    cd(handles.lastVideoPath); % Remember last video path for convenience
end
[name, path] = uigetfile('.avi', 'File Name');
cd(currDirectory);
if path == 0, return; end %if the user pressed cancel, exit this callback
handles.lastVideoPath = path;
fname = fullfile(path, name);

% Pop up calibration gui
%  Initial calibration values
handles.frameRate = 0;
handles.units = {'pixels', 'radians', 1};
guidata(hObject, handles);

%  The calibration GUI can overwrite the initial calibration values
fnamecell = {fname}; % to pass string arguments to a GUI they need to be 
                     %  in a cell array
calibration(fnamecell);
uiwait(calibration);
pause(0.01); % Give time for the savedialog to close
handles = guidata(hObject); % Gets Modified handles struct

if strcmp(handles.units{1}, 'pixels')
    warningmsg_line1 = 'Warning: no calibration performed. Pixel units will be used.';
    warningmsg_line2 = 'To perform calibration, reload the video.';
    warningmsg = sprintf('%s\n\n%s', warningmsg_line1, warningmsg_line2);
    warning = msgbox(warningmsg, 'Warning', 'warn');
    uiwait(warning)
end

% Extract video information (# frames, frame rate, etc.) from .avi file
info = VideoReader(fname);
num = info.NumberOfFrames;

% children = get(handles.preprocesspanel, 'Children');
% set(children, 'Enable', 'off');

% Image of first frame of video
firstFrameIm = frame2im(getFrame(fname, 1));

% Initializes the handles
MAX_FRAMES = 800;
if num < MAX_FRAMES
    handles.maxframes = num;
    handles.endframe = num;
else
    handles.maxframes = MAX_FRAMES;
    handles.endframe = handles.maxframes;
end
handles.currframe = 1;
handles.startframe = 1;
handles.endframe = handles.maxframes;

handles.no = handles.maxframes;
handles.currframeim = firstFrameIm;
handles.num = num; % total # frames in video
handles.name = name; 
handles.fname = fname;
handles.initcropdim = [1 1 info.Width info.Height];
handles.cropdim = [1 1 info.Width info.Height];

% Initialize GUI control values
setPanelState(handles.preprocesspanel, 'on');
setPanelState(handles.mucosalpanel, 'on');
% setPanelState(handles.fitsetuppanel, 'on');
setPanelState(handles.fitpanel, 'on');
set(handles.introtext, 'Visible', 'off'); % erase introduction text
set(handles.videoinfopanel, 'Visible', 'on');
set(handles.videonamelabel, 'Visible', 'on');
set(handles.picnum, 'Max', num); % Frame slider max value
set(handles.picnum, 'Value', 1); % Frame slider init value
set(handles.picnum, 'SliderStep', [1/num 0.05]); % Frame slider step value
set(handles.videonamelabel, 'String', name);
set(handles.numframeslabel, 'String', num);
set(handles.curframelabel, 'String', 1);
set(handles.startframelabel, 'String', 1);
set(handles.endframelabel, 'String', handles.maxframes);
set(handles.pixelindex, 'Max', info.Width); % Column slider max value
set(handles.pixelindex, 'Value', 0); % Column slider init value
set(handles.pixelindex, 'SliderStep', [1/info.Width 0.1]);
set(handles.rotate, 'Value', 120);

guidata(hObject, handles);

% Displays the first frame of the video
displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);


% --- Executes on button press in cut.
function cut_Callback(hObject, eventdata, handles)
% hObject    handle to cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function can be used to cut the frames to a smaller area.  It is
% really only necessary for the vertical cropping of the images.

if (~videoLoaded(handles)), return; end

currFramePrePr = displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);
imageSize = size(currFramePrePr);
try
    rect = getrect(handles.mainaxis);
catch
    return % if no rectangle selected
end

x = floor(rect(1));
y = floor(rect(2));
width = floor(rect(3));
height = floor(rect(4));

% Constrain rectangle to dimensions of current image
if x <= 0
    width = width + x;
    x = 1;
end
if y <= 0
    height = height + y;
    y = 1; 
end
if x + width > imageSize(2)
    width = imageSize(2) - x;
end
if y + height > imageSize(1)
    height = imageSize(1) - y;
end

if (width ~= 0 && height ~= 0)
    handles.cropdim = [x y width height];
    guidata(hObject, handles);
    displayPreprImage(handles.currframeim, handles.mainaxis,...
        handles.rotdeg, handles.cropdim, handles.ind);
end


% --- Executes during object creation, after setting all properties.
function picnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to picnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function picnum_Callback(hObject, eventdata, handles)
% hObject    handle to picnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This function allows the user to look through all frames of a video
picnum = floor(get(hObject, 'Value'));
if (picnum == 0), picnum = 1; end  % Frame 0 is undefined
handles.currframe = picnum;
handles.currframeim = frame2im(getFrame(handles.fname, picnum));
set(handles.curframelabel, 'String', picnum);
set(handles.videoinfopanel, 'Visible', 'on');
set(handles.videonamelabel, 'Visible', 'on');
guidata(hObject, handles);

displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);


% --- Executes during object creation, after setting all properties.
function pixelindex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
guidata(hObject, handles);


% --- Executes on slider movement.
function pixelindex_Callback(hObject, eventdata, handles)
% hObject    handle to pixelindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%This function allows the user to select the pixel column that will be used
%to create the kymographic image.
ind = floor(get(hObject, 'Value'));
handles.ind = ind;
guidata(hObject, handles);
displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);


% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function generates the kymographic image.

if ~videoLoaded(handles), return; end

handles.ruEdges = zeros(1,2);
handles.rlEdges = zeros(1,2);
handles.luEdges = zeros(1,2);
handles.llEdges = zeros(1,2);

ind = handles.ind; % column from which the kymopgraphic image is created.
if (ind == 0), 
    errordlg('Choose a column to analyze before pressing Generate.')
    return
end

V = [];

startframe = handles.startframe;
endframe = handles.endframe;

if (startframe > endframe)
    errordlg('Start frame cannot be greater than end frame.')
    return
end

rotation = handles.rotdeg;
cropdim = handles.cropdim;
fname = handles.fname;
newvid = cell(1, handles.num);

% Make sure column index is inside crop rectangle
cropind = ind - cropdim(1);
if cropind <= 0 || cropind >= cropdim(3)
    errordlg('Column index must be inside of crop rectangle.')
    return
end

% This loop creats the kymographic image by taking one column of pixels
% from each frame in the image series and putting them in a series.

% Progress bar stuff... only update progress bar every 5% or it's slow
waitbarmessage = sprintf('Generating kymographic image...\nWill be slow if the video needed to be rotated.\nClose this window to cancel (may take a few seconds).');
h = waitbar(0, waitbarmessage); % progress bar
nframes = endframe - startframe;
updatePoints = [0.05:0.05:1.05] * nframes;
updatePoints = floor(updatePoints);
j = 1;

%vidframes = aviread(fname, startframe:endframe);
vidframes = getFrame(fname, startframe:endframe);
for i = 1:length(vidframes)
    if ~ishandle(h), return; end     % exit if waitbar is closed
    tempim = frame2im(vidframes(i));
    tempim = imrotate(tempim, rotation, 'bilinear', 'loose'); % rotates the image
    tempim = imcrop(tempim, cropdim);
    newvid{i} = tempim;
    V = [V tempim(:, cropind)];
    if (i == updatePoints(j)) % only display update every 10%
        waitbar(i/nframes)    % update bar
        j = j + 1;
    end
end
close(h) % close the progress bar

imshow(V); % Display the kymographic image result
set(handles.videoinfopanel, 'Visible', 'off'); % Turn off video info panel

% Set crop left/right sliders to initial positions
numFrames = handles.endframe - handles.startframe;
halfNumFrames = floor(numFrames / 2);
set(handles.cycle_left, 'Max', halfNumFrames);
set(handles.cycle_right, 'Max', halfNumFrames);
set(handles.cycle_right, 'Value', halfNumFrames);
set(handles.cycle_left, 'Value', 0);
set(handles.cycle_left, 'SliderStep', [1/halfNumFrames 0.1]);
set(handles.cycle_right, 'SliderStep', [1/halfNumFrames 0.1]);
% Turn on other uipanels
% setPanelState(handles.fitsetuppanel, 'on');
% setPanelState(handles.fitpanel, 'on');

% Set and save handles
s = size(V);
handles.s2 = s(2);
handles.m1_wave = V;
handles.m_wave = V;
handles.newvid = newvid;
handles.newpic = 0; % image used for edge detection
guidata(hObject, handles);

% Display success message with mucosal wave details
% successmessage = 'Kymographic image of mucosal wave successfully generated.';
% successmessage2 = sprintf('\n\nFrames: %d to %d\nColumn: %d', ...
%     startframe, endframe, ind);
% successmessage = [successmessage successmessage2]; % concatenate
% msgbox(successmessage, 'Success', 'help');

  
% --- Executes during object creation, after setting all properties.
function threshslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

set(hObject, 'SliderStep', [1/255 0.1]);
guidata(hObject, handles);


% --- Executes on slider movement.
function threshslider_Callback(hObject, eventdata, handles)
% hObject    handle to threshslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This function allows the user to change the threshold for the upper vocal
% fold (not the left vocal fold).  

m_wave = handles.m_wave;

if m_wave == 0
    errordlg('Generate a mucosal wave image before setting threshold.')
    set(hObject, 'Value', 0); % Undo the change the user made
    set(handles.threshlabel, 'String', 0);
    return
end

thresh = floor(get(hObject, 'Value'));
set(handles.threshlabel, 'String', thresh);
handles.thresh = thresh;

% newpic will be a binary image created by thresholding
newpic = zeros(size(m_wave));


% Sets the values below the threshhold to be white
newpic(m_wave < thresh) = 1;

if (get(handles.smoothedges,'Value') == 1)
    bw = edge(newpic,'canny',[]);
else
    bw = extractEdgesLQ(newpic);
end

m_wave(find(bw)) = 255;

% Display image using full dynamic range of grayscale values
imshow(m_wave);  % show m_wave image but don't save changes
handles.newpic = newpic;
handles.bw = bw; % initialize edge image
guidata(hObject, handles);


% --- Executes on button press in ru.
function ru_Callback(hObject, eventdata, handles)
% hObject    handle to ru (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

getEdgesMain(hObject, eventdata, handles, 'ru');
% if allEdgesSelected(handles.ruEdges, handles.rlEdges, handles.luEdges, handles.llEdges)
%     dispresults_Callback(handles.dispresults, eventdata, handles);
% end

% --- Executes on button press in lu.
function lu_Callback(hObject, eventdata, handles)
% hObject    handle to ru (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function performs the sinusoidal curve fitting process on the left
% upper vocal fold.  The following three functions are exactly the same,
% but perform the analysis on the other vocal fold segments.  This function
% is the only one with comments, but the others are exactly the same.

getEdgesMain(hObject, eventdata, handles, 'lu');
% if allEdgesSelected(handles.ruEdges, handles.rlEdges, handles.luEdges, handles.llEdges)
%     dispresults_Callback(handles.dispresults, eventdata, handles);
% end

% --- Executes on button press in rl.
function rl_Callback(hObject, eventdata, handles)
% hObject    handle to rl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to rl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

getEdgesMain(hObject, eventdata, handles, 'rl');
% if allEdgesSelected(handles.ruEdges, handles.rlEdges, handles.luEdges, handles.llEdges)
%     dispresults_Callback(handles.dispresults, eventdata, handles);
% end

% --- Executes on button press in ll.
function ll_Callback(hObject, eventdata, handles)
% hObject    handle to lu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

getEdgesMain(hObject, eventdata, handles, 'll');
% if allEdgesSelected(handles.ruEdges, handles.rlEdges, handles.luEdges, handles.llEdges)
%     dispresults_Callback(handles.dispresults, eventdata, handles);
% end

% --- Executes during object creation, after setting all properties.
function cycle_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cycle_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject, 'Value', get(hObject, 'Max'));
guidata(hObject, handles);


% --- Executes on slider movement.
function cycle_right_Callback(hObject, eventdata, handles)
% hObject    handle to cycle_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This function is for cropping the kymographic image from the right.
% cycle_right = floor(get(hObject, 'Max') - get(hObject, 'Value'));
% handles.cycle_right = cycle_right;
% guidata(hObject, handles);
% %cycleapply is called to redisplay the image after the sliderbar is moved
% %by the user
cycleapply_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function cycleapply_Callback(hObject, eventdata, handles)
% hObject    handle to cycleapply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function redraws the kymograpic image when the user crops it with
% the slider bars.
cycle_right = floor(get(handles.cycle_right, 'Max') - ...
    get(handles.cycle_right, 'Value'));
cycle_left = floor(get(handles.cycle_left, 'Value'));
m_wave = handles.m1_wave;
if m_wave == 0
    errordlg('Generate mucosal wave first.')
    return
end
s2 = handles.s2;

%temp is the newly defined image
temp = m_wave(:, (1+cycle_left):(s2-cycle_right));

imshow(temp);
handles.m_wave = temp;
handles.bw = 0;
set(handles.videoinfopanel, 'Visible', 'off');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ncyclesedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ncyclesedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --------------------------------------------------------------------
function ncyclesedit_Callback(hObject, eventdata, handles)
% hObject    handle to ncyclesedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ncyclesedit as text
%        str2double(get(hObject,'String')) returns contents of ncyclesedit as a double

% This function records the number of cycles input by the user.

period = floor(str2double(get(hObject, 'String')));
if (period < 1)
    period = 1;
    set(hObject, 'String',sprintf('%d',period));
end
handles.ncycles = period;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function mwaveOrderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mwaveOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --------------------------------------------------------------------
function mwaveOrderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to mwaveOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of order as text
%        str2double(get(hObject,'String')) returns contents of order as a double

% This function records the number of harmonics input by the user.

mwaveOrder = floor(str2double(get(hObject, 'String')));
MIN_ORDER = 1;

if (mwaveOrder < MIN_ORDER)
    mwaveOrder = MIN_ORDER;
    set(hObject, 'String', sprintf('%d',mwaveOrder));
end

handles.mwaveOrder = mwaveOrder;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cycle_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cycle_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function cycle_left_Callback(hObject, eventdata, handles)
% hObject    handle to cycle_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This slider allows the user to crop the kymographic image from the left.

% cycle_left = floor(get(hObject, 'Value'));
% handles.cycle_left = cycle_left;
% guidata(hObject, handles);
%cycleapply is called to redisplay the newly cropped image
cycleapply_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function rotate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject, 'SliderStep', [1/240 0.05]);
set(hObject, 'Max', 240);
set(hObject, 'Value', 120);
guidata(hObject, handles);


% --- Executes on slider movement.
function rotate_Callback(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This function allows the user to rotate the images before the kymographic
% image is created, so that the glottis is oriented horizontally in the
% image frame.

rotdeg = get(hObject, 'Value');
% Slider ranges from 0 to 180, default value of 90... so subtract 90 in
% so that the default value corresponds to 0 degrees
rotdeg = -1*(rotdeg - 120); % so counter-clockwise: left arrow
handles.rotdeg = rotdeg;

% update crop rectangle
tempImage = imrotate(handles.currframeim, rotdeg, 'bilinear', 'loose');
handles.cropdim = [0 0 size(tempImage, 2) size(tempImage, 1)];

% Adjust Kymographic Column Maximum For Change in Dimensions
set(handles.pixelindex, 'Max', size(tempImage,2));

% Remove Temporary Image from Memory
clear('tempImage');

guidata(hObject, handles);
displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);


% --- Executes on slider movement.
function peakslidder_Callback(hObject, eventdata, handles)
% hObject    handle to peakslidder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

newpic = handles.newpic;
if newpic == 0
    errordlg('Set a threshold first.')
    set(hObject, 'Value', 0); % Undo the change the user made
    return
end
s = size(newpic);
set(hObject, 'Max', s(1));
ind = floor(get(hObject, 'Value'));
imshow(newpic, []);
line ([0,s(2)],[ind,ind]);
handles.me=ind;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function peakslidder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakslidder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

handles.me = 1;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function mainaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate mainaxis
axis off


% --- Executes on button press in dispresults.
function dispresults_Callback(hObject, eventdata, handles)
% hObject    handle to dispresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% curveFitMain(vocalFold, edgePoints, method, order,...
%     nCycles, imageSize, units, frameRate )

if any(handles.ruEdges)
    handles.ruresult = curveFitMain('ru',handles.ruEdges,...
        handles.ruMethod, handles.ruOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.ruGuesses);
    handles.ruresult.realamp = handles.ruAmp;
end

if any(handles.rlEdges)
    handles.rlresult = curveFitMain('rl',handles.rlEdges,...
        handles.rlMethod, handles.rlOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.rlGuesses);
    handles.rlresult.realamp = handles.rlAmp;
end

if any(handles.luEdges)
    handles.luresult = curveFitMain('lu',handles.luEdges,...
        handles.luMethod, handles.luOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.luGuesses);
    handles.luresult.realamp = handles.luAmp;
end

if any(handles.llEdges)
    handles.llresult = curveFitMain('ll',handles.llEdges,...
        handles.llMethod, handles.llOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.llGuesses);
    handles.llresult.realamp = handles.llAmp;
end

guidata(hObject, handles);

% if getNumResults(handles) == 0, errordlg('No results to display.'); return; end

results = [handles.luresult, handles.llresult, handles.ruresult, handles.rlresult];
displayFitResults(results, handles.m_wave)


% --------------------------------------------------------------------
function saveexcel_Callback(hObject, eventdata, handles)
% hObject    handle to saveexcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if there are any results to save
% if ~isfield(handles, 'ruresult') || ~isfield(handles, 'rlresult') ...
%         || ~isfield(handles, 'luresult') || ~isfield(handles, 'llresult')
%     errordlg('No results to save.')
%     return
% end
% Find #folds that wave was calculated for (should be an int 1-4) KSOCT
numResults = getNumResults(handles);
if numResults == 0, errordlg('No results to save.'); return; end

results = [handles.ruresult, handles.rlresult, handles.luresult, handles.llresult];

% Pop up figure for user to enter larynx, pressure, and elongation info
handles.figure = gcf;
savedialog;
uiwait(savedialog);
pause(0.01); % Give time for the savedialog to close
handles = guidata(hObject);

% Asks the user to enter the spreadsheet name.
[name, path] = uiputfile({'*.xls'}, 'Save Excel File As...');
if path == 0, return; end %if the user pressed cancel, exit this callback

units = handles.units;
freqUnits = units{2};
if strcmp(freqUnits, 'Hz')
    freqVariable = 'f';
    freqTerm = sprintf('2pi*%s',freqVariable);
else
    freqVariable = 'w';
    freqTerm = freqVariable;
end

% KSOCT - Modified Eqn for left crop issue 
row0 = {sprintf(['Fit equation form: y = a0 + a1*sin(%s * (t-delay) + p1)'...
    '+ a2*sin(%s * (t-leftCrop) + p2) + ...'],freqTerm,freqTerm)};

% KSOCT - Added Left Crop to column headers (10/28/09)
columnHeaders = {'Larynx','Pressure','Elongation','Fold','Video',...
    'Start Frame','End Frame','Kymographic Pixel Column','Fit method',...
    'Cycles','Amp Units','Freq Units','leftCrop','rightCrop','a0','freq'};

allRows = cell(3+numResults, 2*handles.MAX_ORDER + length(columnHeaders));
conf_allRows = cell(1+numResults, 2*handles.MAX_ORDER + length(columnHeaders) + 2);
% Creates the column titles for the spreadsheet

row1 = columnHeaders;

% Add column labels for sinusoid coefficients
for col = 1:handles.MAX_ORDER
    row1{end+1} = ['a' sprintf('%d',col)]; % e.g., 'a1'
    row1{end+1} = ['p' sprintf('%d',col)]; % e.g., 'p1'
end

row1{end+1} = 'SSE';
row1{end+1} = 'R-square';
row1{end+1} = 'Adjusted R-square';
row1{end+1} = 'RMSE';

allRows{1,1} = row0{1};
for i = 1:length(row1)
    allRows{3,i} = row1{i};
end

% Confidence intervals are placed in another worksheet
conf_row1 = columnHeaders(1:(length(columnHeaders)-2));
conf_row1{end+1} = 'a0';
conf_row1{end+1} = '';
conf_row1{end+1} = 'freq';
conf_row1{end+1} = '';
for col = 1:handles.MAX_ORDER
    conf_row1{end+1} = ['a' sprintf('%d',col)]; % e.g., 'a1'
    conf_row1{end+1} = '';
    conf_row1{end+1} = ['p' sprintf('%d',col)]; % e.g., 'p1'
    conf_row1{end+1} = '';
end

for i = 1:length(conf_row1)
    conf_allRows{1,i} = conf_row1{i};
end

nonEmptyFound = 0; % the number of non-empty results found, used for
                   % indexing in allRows arrays
% Create a row for each result
for i = 1:length(results)
    if (~isempty(results(i)))
        nonEmptyFound = nonEmptyFound + 1;
        currResult = results(i);
        currRow = {};
        currRow{end+1} = handles.larynx;
        currRow{end+1} = handles.pressure;
        currRow{end+1} = handles.elongation;
        currRow{end+1} = currResult.fold;
        currRow{end+1} = handles.name; % video file name
        currRow{end+1} = handles.startframe;
        currRow{end+1} = handles.endframe;
        currRow{end+1} = handles.ind; % kymographic column
        currRow{end+1} = currResult.model;
        currRow{end+1} = currResult.ncycles;
        currRow{end+1} = handles.units{1}; % amplitude units
        currRow{end+1} = freqUnits; % frequency units
        currRow{end+1} = floor(get(handles.cycle_left,'Value')); %l-crop
        currRow{end+1} = floor(get(handles.cycle_right,'Value')); %r-crop
        currRow{end+1} = ...
            convertAmpToRealUnits(currResult.a0, handles.units);

        % Sinusoid coefficients
        cfitObject = currResult.cfitObject;
        coeff = coeffvalues(cfitObject);
        coeff(1:end-1) = convertAmpToRealUnits(coeff(1:end-1), handles.units);
        coeff(end) = convertFreqToRealUnits(coeff(end), handles.frameRate);
        
        currRow{end+1} = coeff(end); % fundamental frequency value

        for k = 1:currResult.order
            [amp, phase] = convertSineFormat(coeff(2*k), coeff(2*k+1));
            currRow{end+1} = amp;
            currRow{end+1} = phase;
        end
        
        if ~isempty(currResult.goodness)
            goodness = currResult.goodness;
            currRow{length(row1)-3} = goodness.sse;
            currRow{length(row1)-2} = goodness.rsquare;
            currRow{length(row1)-1} = goodness.adjrsquare;
            currRow{length(row1)} = goodness.rmse;
        end
        
        for j = 1:length(currRow)
            allRows{3+nonEmptyFound,j} = currRow{j};
        end
        
        % Confidence intervals (only added if they exist)
        try
            confIntervals = confint(cfitObject);
            
            conf_currRow = {};
            conf_currRow{end+1} = handles.larynx;
            conf_currRow{end+1} = handles.pressure;
            conf_currRow{end+1} = handles.elongation;
            conf_currRow{end+1} = currResult.fold;
            conf_currRow{end+1} = handles.name; % video file name
            conf_currRow{end+1} = handles.startframe;
            conf_currRow{end+1} = handles.endframe;
            conf_currRow{end+1} = handles.ind; % kymographic column
            conf_currRow{end+1} = currResult.model;
            conf_currRow{end+1} = currResult.ncycles;
            conf_currRow{end+1} = handles.units{1}; % amplitude units
            conf_currRow{end+1} = freqUnits; % frequency units
            conf_currRow{end+1} = floor(get(handles.cycle_left,'Value'));
            conf_currRow{end+1} = floor(get(handles.cycle_right,'Value'));
            conf_currRow{end+1} = ...
                convertAmpToRealUnits(confIntervals(1,1), handles.units); % a0 low
            conf_currRow{end+1} = ...
                convertAmpToRealUnits(confIntervals(2,1), handles.units); % a0 high
            
            conf_currRow{end+1} = convertFreqToRealUnits(confIntervals(1,length(confIntervals)),handles.frameRate); % w low
            conf_currRow{end+1} = convertFreqToRealUnits(confIntervals(2,length(confIntervals)),handles.frameRate); % w high
            
            % Convert confidence intervals to a*sin(w+p) form
            for n = 1:currResult.order
                a_low = confIntervals(4*n-1);
                a_high = confIntervals(4*n);
                b_low = confIntervals(4*n+1);
                b_high = confIntervals(4*n+2);
                [ampRange, phaseRange] = ...
                    convertConfIntFormat([a_low a_high], [b_low b_high]);
                
                conf_currRow{end+1} = convertAmpToRealUnits(ampRange(1), handles.units);
                conf_currRow{end+1} = convertAmpToRealUnits(ampRange(2), handles.units);
                conf_currRow{end+1} = convertAmpToRealUnits(phaseRange(1), handles.units);
                conf_currRow{end+1} = convertAmpToRealUnits(phaseRange(2), handles.units);
            end
            
            for j = 1:length(conf_currRow)
                conf_allRows{1+nonEmptyFound,j} = conf_currRow{j};
            end
        catch
            % do nothing if confidence intervals don't exist
        end
    end
end

% Writes the Excel file
newWorkbookName = fullfile(path,name); % construct full path name
warning off MATLAB:xlswrite:AddSheet % disable new worksheet warning
xlswrite(newWorkbookName, allRows, 'Data');
xlswrite(newWorkbookName, conf_allRows, 'Confidence Intervals');

%writer={'Row' 'Column' 'Edge'};
ptSheet = {'Row' 'Column' 'Edge' ''};
edgeNames = {'ll' 'lu' 'rl' 'ru'};

% Iterate Through Folds and Place Points in ptSheet
for k = 1:4
    edgeName = edgeNames{1,k};
    edgePts = handles.([edgeName 'Edges']);
    % Check That Edge Points Exist
    numPts = size(edgePts,1);
    if numPts > 1
        % Append Points to Sheet Cell Array
        ptSheet = [ptSheet;...
            num2cell(edgePts) num2cell(repmat(edgeName,numPts,1))];
    end
end
xlswrite(newWorkbookName,ptSheet,'Points');
 
%writer=[];
% disp(points_matrix_nik);
% pause;
% disp(points_matrix_nik_edge);
%writer={{points_matrix_nik(:,1)} {points_matrix_nik(:,2)} {points_matrix_nik_edge}};
%disp(writer);

%xlswrite(newWorkbookName,points_matrix_nik(:,1) , 'Points','A2');    
%xlswrite(newWorkbookName,points_matrix_nik(:,2) , 'Points','B2');  
%warning off
%xlswrite(newWorkbookName,points_matrix_nik_edge, 'Points','C2');

%Update Information Sheet
infosht = {'This data was made with Mucosal Wave: Revision(03/08/2011) on' date};
xlswrite(newWorkbookName, infosht, 'Info');

% --------------------------------------------------------------------
function savematlab_Callback(hObject, eventdata, handles)
% hObject    handle to savematlab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if getNumResults(handles) == 0, errordlg('No results to save.'); return; end

[name, path] = uiputfile({'*.mat'}, 'Save results to MATLAB');
if path == 0, return; end %if the user pressed cancel, exit this callback

% Pull variables to be saved from handles structure
fname = fullfile(path,name);
ruresult = handles.ruresult;
rlresult = handles.rlresult;
luresult = handles.luresult;
llresult = handles.llresult;
m_wave = handles.m_wave;

% Save them to .mat file
save(fname,...
    'ruresult',...
    'rlresult',...
    'luresult',...
    'llresult',...
    'm_wave')


% --- Executes on button press in smoothedges.
function smoothedges_Callback(hObject, eventdata, handles)
% hObject    handle to smoothedges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smoothedges
threshslider_Callback(handles.threshslider, eventdata, handles);


% --------------------------------------------------------------------
function loadstate_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%allow the user to choose which settings to load
[filename, pathname] = ...
    uigetfile('*.fig', 'Choose the program state to load');
if pathname == 0, return; end %if user pressed cancel, exit this callback

loadDataName = fullfile(pathname,filename); %construct full path name
theCurrentGUI = gcf;  %this is the current gui that will be closed
hgload(loadDataName); %load the state, which creates a new gui
close(theCurrentGUI); %closes the old gui


% --------------------------------------------------------------------
function savestate_Callback(hObject, eventdata, handles)
% hObject    handle to savestate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%allow the user to specify where to save the settings file
[filename,pathname] = uiputfile('.fig','Save complete program state');
if pathname == 0, return; end %if user pressed cancel, exit this callback
if strcmp(filename, handles.programname)
    error('Invalid name. Cannot be the same as program name.')
end

saveDataName = fullfile(pathname,filename); %construct the full path
hgsave(saveDataName); %saves the gui data


% --------------------------------------------------------------------
function dispmatresults_Callback(hObject, eventdata, handles)
% hObject    handle to dispmatresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = ...
    uigetfile('*.mat', 'Choose the results to display');
if pathname == 0, return; end %if user pressed cancel, exit this callback

% This puts all existing results and m_wave image into workspace variables
load(fullfile(pathname,filename));

if exist('ruresult','var') && exist('rlresult','var')... 
    && exist('luresult','var') && exist('llresult','var')

    % Put vocal fold results into array
    results = [ruresult rlresult luresult llresult];

    % only display results if at least one result exists
    for i = 1:length(results)
        if (~isempty(results(i)))
            displayFitResults(results, m_wave) 
            break
        end
    end
else
    errordlg('File does not contain correctly formatted results')
    return
end


% --------------------------------------------------------------------
function foldid_Callback(hObject, eventdata, handles)
% hObject    handle to foldid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
imshow(imread('foldlabels.jpg'))


% --- Executes on button press in startframe.
function startframe_Callback(hObject, eventdata, handles)
% hObject    handle to startframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~videoLoaded(handles)), return; end

startframe = handles.currframe;
set(handles.startframelabel, 'String', startframe);
handles.startframe = startframe;
guidata(hObject, handles);


% --- Executes on button press in endframe.
function endframe_Callback(hObject, eventdata, handles)
% hObject    handle to endframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~videoLoaded(handles)), return; end

% Mark the ending frame for kymographic analysis
endframe = handles.currframe;
startframe = handles.startframe;
if (endframe <= startframe + 5)
    errordlg('The end frame must be at least 5 frames after the start frame.')
    return
elseif (endframe - startframe) > handles.maxframes
    errorstr = sprintf('This program cannot process more than %d frames.',...
        handles.maxframes);
    errordlg(errorstr)
    return
end

set(handles.endframelabel, 'String', endframe);
handles.endframe = endframe;
guidata(hObject, handles);


% --------------------------------------------------------------------
function quickinstructions_Callback(hObject, eventdata, handles)
% hObject    handle to quickinstructions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% currDirectory = cd;
% cd('documentation')
open('quick instructions.pdf')
% cd(currDirectory)


% --- Executes on button press in resetrotateslider.
function resetrotateslider_Callback(hObject, eventdata, handles)
% hObject    handle to resetrotateslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.rotate, 'Value', 120);
handles.rotdeg = 0;

% update crop rectangle
tempImage = imrotate(handles.currframeim, handles.rotdeg, 'bilinear', 'loose');
handles.cropdim = [0 0 size(tempImage, 2) size(tempImage, 1)];
clear('tempImage');

guidata(hObject, handles);
displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);






% --- Executes on button press in manualMode.
function manualMode_Callback(hObject, eventdata, handles)
% hObject    handle to manualMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manualMode




% --------------------------------------------------------------------
function savesin_Callback(hObject, eventdata, handles)
% hObject    handle to savesin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if getNumResults(handles) == 0, errordlg('No results to save.'); return; end

sinData = [handles.ruresult.xdata' -handles.ruresult.ydata'...
           handles.rlresult.xdata' -handles.rlresult.ydata'...
           handles.luresult.xdata' -handles.luresult.ydata'...
           handles.llresult.xdata' -handles.llresult.ydata'];

% indices of file types
CSV = 1; XLS = 2; ASCII = 3;
fileExtensions = {'.csv'; '.xls'; '.txt'};
[filename,pathname,extension] = uiputfile(fileExtensions, 'Save sin points to file');
if pathname == 0, return; end %if user pressed cancel, exit this callback
saveFileName = fullfile(pathname,filename);

if extension == CSV
    csvwrite([saveFileName char(fileExtensions(extension))], sinData);
elseif extension == XLS
    xlswrite(saveFileName, sinData);
elseif extension == ASCII
    dlmwrite([saveFileName char(fileExtensions(extension))], sinData);
end
    


% --- Executes on button press in showselections.
function showselections_Callback(hObject, eventdata, handles)
% hObject    handle to showselections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

edges = getSelectedEdges(handles);

numEdgesSelected = 0;
for i = 1:length(edges)
    if (edges{i} ~= 0)
        numEdgesSelected = numEdgesSelected + 1;
    end
end

if numEdgesSelected == 0
    errordlg('No edges selected yet.');
    return
else
    displayEdges(edges, handles.m_wave, false)
end


% --- Executes on selection change in ruMethodMenu.
function ruMethodMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ruMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ruMethodMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ruMethodMenu
methodChoices = get(hObject, 'String');
handles.ruMethod = methodChoices(get(hObject, 'Value'));
if strcmp(handles.ruMethod, 'Linear Least Squares')
    set(handles.ruTune,'Enable','off');
    set(handles.ruOrderEdit, 'String', 1);
    handles.ruOrder = 1;
else
    set(handles.ruTune,'Enable','on');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ruMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ruMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in rlMethodMenu.
function rlMethodMenu_Callback(hObject, eventdata, handles)
% hObject    handle to rlMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns rlMethodMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rlMethodMenu
methodChoices = get(hObject, 'String');
handles.rlMethod = methodChoices(get(hObject, 'Value'));
if strcmp(handles.rlMethod, 'Linear Least Squares')
    set(handles.rlTune,'Enable','off');
    set(handles.rlOrderEdit, 'String', 1);
    handles.rlOrder = 1;
else
    set(handles.rlTune,'Enable','on');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rlMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rlMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in luMethodMenu.
function luMethodMenu_Callback(hObject, eventdata, handles)
% hObject    handle to luMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns luMethodMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from luMethodMenu
methodChoices = get(hObject, 'String');
handles.luMethod = methodChoices(get(hObject, 'Value'));
if strcmp(handles.luMethod, 'Linear Least Squares')
    set(handles.luTune,'Enable','off');
    set(handles.luOrderEdit, 'String', 1);
    handles.luOrder = 1;
else
    set(handles.luTune,'Enable','on');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function luMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to luMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in llMethodMenu.
function llMethodMenu_Callback(hObject, eventdata, handles)
% hObject    handle to llMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns llMethodMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from llMethodMenu
methodChoices = get(hObject, 'String');
handles.llMethod = methodChoices(get(hObject, 'Value'));
if strcmp(handles.llMethod, 'Linear Least Squares')
    set(handles.llTune,'Enable','off');
    set(handles.llOrderEdit, 'String', 1);
    handles.llOrder = 1;
else
    set(handles.llTune,'Enable','on');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function llMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to llMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton46.
function pushbutton46_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rlTune.
function rlTune_Callback(hObject, eventdata, handles)
% hObject    handle to rlTune (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if any(handles.rlEdges)
    handles.rlresult = curveFitMain('rl',handles.rlEdges,...
        handles.rlMethod, handles.rlOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.rlGuesses);
    tune(handles.m_wave, handles.rlEdges, handles.rlresult, handles.rlGuesses);
    uiwait(tune);
    pause(0.01); % Give time for the savedialog to close
    handles = guidata(hObject);
    guidata(hObject, handles);
else
    errordlg('Select right lower edges first.')
    return;
end


% --- Executes on button press in luTune.
function luTune_Callback(hObject, eventdata, handles)
% hObject    handle to luTune (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if any(handles.luEdges)
    handles.luresult = curveFitMain('lu',handles.luEdges,...
        handles.luMethod, handles.luOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.luGuesses);
    tune(handles.m_wave, handles.luEdges, handles.luresult, handles.luGuesses);
    uiwait(tune);
    pause(0.01); % Give time for the savedialog to close
    handles = guidata(hObject);
    guidata(hObject, handles);
else
    errordlg('Select left upper edges first.')
    return;
end

% --- Executes on button press in llTune.
function llTune_Callback(hObject, eventdata, handles)
% hObject    handle to llTune (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if any(handles.llEdges)
    handles.llresult = curveFitMain('ll',handles.llEdges,...
        handles.llMethod, handles.llOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.llGuesses);
    tune(handles.m_wave, handles.llEdges, handles.llresult,handles.llGuesses);
    uiwait(tune);
    pause(0.01); % Give time for the savedialog to close
    handles = guidata(hObject);
    guidata(hObject, handles);
else
    errordlg('Select left lower edges first.')
    return;
end


function rlOrderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rlOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rlOrderEdit as text
%        str2double(get(hObject,'String')) returns contents of rlOrderEdit as a double
handles.rlOrder = validateOrder(hObject,handles.MAX_ORDER);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function rlOrderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rlOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function luOrderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to luOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of luOrderEdit as text
%        str2double(get(hObject,'String')) returns contents of luOrderEdit as a double
handles.luOrder = validateOrder(hObject,handles.MAX_ORDER);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function luOrderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to luOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function llOrderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to llOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of llOrderEdit as text
%        str2double(get(hObject,'String')) returns contents of llOrderEdit as a double
handles.llOrder = validateOrder(hObject,handles.MAX_ORDER);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function llOrderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to llOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ruOrderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ruOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ruOrderEdit as text
%        str2double(get(hObject,'String')) returns contents of ruOrderEdit as a double
handles.ruOrder = validateOrder(hObject,handles.MAX_ORDER);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ruOrderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ruOrderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton50.
function pushbutton50_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton51.
function pushbutton51_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton52.
function pushbutton52_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton53.
function pushbutton53_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on selection change in ruOrderEdit.
% function null_Callback(hObject, eventdata, handles)
% % hObject    handle to ruOrderEdit (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = get(hObject,'String') returns ruOrderEdit contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from ruOrderEdit


% % --- Executes during object creation, after setting all properties.
% function null_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to ruOrderEdit (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end




% --- Executes on button press in ruTune.
function ruTune_Callback(hObject, eventdata, handles)
% hObject    handle to ruTune (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if any(handles.ruEdges)
    handles.ruresult = curveFitMain('ru',handles.ruEdges,...
        handles.ruMethod, handles.ruOrder, handles.ncycles,...
        size(handles.m_wave),handles.units, handles.frameRate,...
        handles.ruGuesses);
    tune(handles.m_wave, handles.ruEdges, handles.ruresult, handles.ruGuesses);
    uiwait(tune);
    pause(0.01); % Give time for the savedialog to close
    handles = guidata(hObject);
    guidata(hObject, handles);
else
    errordlg('Select right upper edges first.')
    return;
end


% -----Executes on press of load image in file menu------------------
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Initialize Handles Structure
initHandles(hObject,handles);
handles = guidata(hObject);

% Set Cropping Dimensions
handles.cropdim = [0 0 500 200];
cropdim = handles.cropdim;
setPanelState(handles.mucosalpanel, 'on');
setPanelState(handles.preprocesspanel, 'on');
[file,path]=uigetfile('*.jpg','Select the Image');
if path == 0, return; end %if the user pressed cancel, exit this callback
full_file=fullfile(path,file);

% Load Image->Rotate->Crop to Fit Window
tempim=imread(full_file);
tempim=imrotate(tempim,90);
tempim = rgb2gray(tempim); % Make Image a Grayscale
tempim = imcrop(tempim, cropdim);
V = tempim; %Kymographic Image

i=1;
newvid{i} = tempim;

% Initial Calibration Values
handles.frameRate = 0;
handles.units = {'pixels', 'radians', 1};

% Kymograph Properties
handles.name = file;
handles.fname = full_file;

% Configure the GUI Window Prior to Displaying Kymograph
setPanelState(handles.preprocesspanel, 'off');
%setPanelState(handles.mucosalpanel, 'on');
setPanelState(handles.fitpanel, 'on');
set(handles.videoinfopanel, 'Visible', 'off');

set(handles.introtext, 'Visible', 'off'); % erase introduction textl

numFrames = size(V,2);
halfNumFrames = floor(numFrames / 2);
set(handles.cycle_left, 'Max', halfNumFrames);
set(handles.cycle_right, 'Max', halfNumFrames);
set(handles.cycle_right, 'Value', halfNumFrames);
set(handles.cycle_left, 'Value', 0);
set(handles.cycle_left, 'SliderStep', [1/halfNumFrames 0.1]);
set(handles.cycle_right, 'SliderStep', [1/halfNumFrames 0.1]);

imshow(V); % Display the kymographic image result

% Turn on other uipanels
% setPanelState(handles.fitsetuppanel, 'on');
% setPanelState(handles.fitpanel, 'on');

% Set and save handles
s = size(V);
handles.s2 = s(2);
handles.m1_wave = V;
handles.m_wave = V;
handles.newvid = newvid;
handles.newpic = 0; % image used for edge detection

%Make non-applicable functions invisible
set(handles.pixelindex, 'Enable', 'off')
set(handles.generate, 'Enable', 'off')

guidata(hObject, handles); % Save Changes to handles

% Initializes Several Variables in handles structure
function initHandles(hObject,handles)
handles.figure = gcf;
handles.programname = 'mucosal.fig';
handles.ind = 0; % Kymograph Column Index

% Used For Storing Kymograph and Parameters
handles.thresh = 0;
handles.m_wave = 0; 
handles.m1_wave = 0; 
    
% Edge points for each vocal fold
handles.ruEdges = zeros(1,2);
handles.rlEdges = zeros(1,2);
handles.luEdges = zeros(1,2);
handles.llEdges = zeros(1,2);

% Set fold amplitudes to zero
handles.ruAmp = 0;
handles.rlAmp = 0;
handles.luAmp = 0;
handles.llAmp = 0;

% Curve fitting method for each vocal fold
METHOD_CHOICES = get(handles.ruMethodMenu, 'String');
handles.ruMethod = METHOD_CHOICES(get(handles.ruMethodMenu, 'Value'));
handles.rlMethod = METHOD_CHOICES(get(handles.rlMethodMenu, 'Value'));
handles.luMethod = METHOD_CHOICES(get(handles.luMethodMenu, 'Value'));
handles.llMethod = METHOD_CHOICES(get(handles.llMethodMenu, 'Value'));

% Sinusoid order for each vocal fold
handles.MAX_ORDER = 8; % max mucosal wave order supported
handles.ruOrder = validateOrder(handles.ruOrderEdit, handles.MAX_ORDER);
handles.rlOrder = validateOrder(handles.rlOrderEdit, handles.MAX_ORDER);
handles.luOrder = validateOrder(handles.luOrderEdit, handles.MAX_ORDER);
handles.llOrder = validateOrder(handles.llOrderEdit, handles.MAX_ORDER);

% Used for curve fitting
handles.ruGuesses = ones(1,handles.MAX_ORDER)*Inf;
handles.rlGuesses = ones(1,handles.MAX_ORDER)*Inf;
handles.luGuesses = ones(1,handles.MAX_ORDER)*Inf;
handles.llGuesses = ones(1,handles.MAX_ORDER)*Inf;

% Results structures for curve fitting
handles.ruresult = struct([]);
handles.luresult = struct([]);
handles.rlresult = struct([]);
handles.llresult = struct([]);

handles.bw = 0; % INIT
handles.newpic = 0; % INIT
handles.ncycles = floor(str2double(get(handles.ncyclesedit, 'String'))); % INIT
handles.mwaveOrder = floor(str2double(get(handles.mwaveOrderEdit, 'String'))); % INIT
handles.rotdeg = 0; % INIT
handles.ind = 0; % kymographic column INIT

% Excel output stuff
handles.pressure = 0;
handles.larynx = 0;
handles.elongation = 0;

% Midline Variables
handles.midLineComPts = [];

guidata(hObject, handles);


% --- Executes on button press in amp.
function amp_Callback(hObject, eventdata, handles)
% hObject    handle to amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[RUamp RLamp LUamp LLamp] = ampFind(handles.bw, handles.units(3), handles.units(1));
handles.ruAmp = RUamp;
handles.luAmp = LUamp;
handles.rlAmp = RLamp;
handles.llAmp = LLamp;
guidata(hObject, handles);


% --- Executes on button press in pushbutton55.
function pushbutton55_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Saves the current kymographic image into the user specified file
try        
    %The kymogram image is being rotated -90 degrees and saved in an array
    %to avoid errors if it is reloaded in to the mucosal program.
    im(:,:,1) = imrotate(handles.m1_wave, -90);
    im(:,:,2) = imrotate(handles.m1_wave, -90);
    im(:,:,3) = imrotate(handles.m1_wave, -90);
    [fName pathName] = uiputfile('*.jpg','Save Kymograph Image');
    
    if isempty(fName), return; end;
    imfile = fullfile(pathName,fName);
    imwrite(im, char(imfile), 'jpg','Quality',100)
catch
    errordlg('Either you did not specify a file name or the kymograph has not been generated.', 'Image not saved')
end



% --- Executes on button press in drawMidlineButton.
function drawMidlineButton_Callback(hObject, eventdata, handles)
% hObject    handle to drawMidlineButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Redraw Screen
tempOriginal = displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);

%saving height, width, and angle for later;
[oldHeight, oldWidth] = size(tempOriginal);
oldAngle = handles.rotdeg;

[x1 y1] = ginput(1);
hold on;plot(x1,y1,'rx','MarkerSize',10); hold off;

[x2 y2] = ginput(1);
hold on;plot(x2,y2,'rx','MarkerSize',10); hold off;

% AUTO-ROTATION BASED ON MIDLINE
% 1stPoint = [x1 y1];
% 2ndPoint = [x2 y2];
horizontalDistance = x2-x1;
hypotenuse = sqrt((x2-x1)^2 + (y2-y1)^2);
rotationAngle = acosd(horizontalDistance/hypotenuse);
if y1>y2
    rotationAngle = -1 * rotationAngle;
end
% update the degree of rotation of the picture
   handles.rotdeg = rotationAngle + handles.rotdeg;   
    
%Set Rotate slider all the way to the right
    newRotatePosition = 120 - handles.rotdeg;
    if newRotatePosition > 240
        newRotatePosition = newRotatePosition - 360;
    elseif newRotatePosition < 0
            newRotatePosition = (newRotatePosition + 360);
    end
    set(handles.rotate, 'Value',newRotatePosition);
    
% update crop rectangle
tempImage = imrotate(handles.currframeim, handles.rotdeg, 'bilinear', 'loose');
handles.cropdim = [0 0 size(tempImage, 2) size(tempImage, 1)];

%update height, width, and angle for drawing midline
[newHeight, newWidth] = size(tempImage);
newAngle = handles.rotdeg;

% Adjust Kymographic Column Maximum For Change in Dimensions
set(handles.pixelindex, 'Max', size(tempImage,2));

% Remove Temporary Image from Memory
clear('tempImage');

displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);

%transforming and saving new coordinates
[x1, y1, x2, y2] = transformMidLine(x1, y1, x2, y2, oldAngle, oldWidth,...
    oldHeight, newAngle, newWidth, newHeight);
handles.midLineComPts = [x1, y1; x2, y2];
guidata(hObject, handles);


%Transforms the midline so it still lines up with the rotated image
function [x1, y1, x2, y2] = transformMidLine(x1, y1, x2, y2, oldAngle, oldWidth,...
    oldHeight,newAngle, newWidth, newHeight)
angle = oldAngle - newAngle;
rotationMatrix = [cosd(angle), -sind(angle); sind(angle), cosd(angle)];

xCenter = oldWidth/2;
yCenter = oldHeight/2;

temp1 = [x1-xCenter;y1-yCenter];
temp2 = [x2-xCenter;y2-yCenter];

newPoint1 = rotationMatrix * temp1;
newPoint2 = rotationMatrix * temp2;

x1 = newPoint1(1) + newWidth/2;
y1 = newPoint1(2) + newHeight/2;
x2 = newPoint2(1) + newWidth/2;
y2 = newPoint2(2) + newHeight/2;

line([x1 x2],[y1 y2]);



% --- Executes on button press in setPercentageButton.
function setPercentageButton_Callback(hObject, eventdata, handles)
% hObject    handle to setPercentageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Grab Com Points
comPts = handles.midLineComPts;

if isempty(comPts)
    % No Com Pts
    h_error = errordlg('Please Select Midline Pts First',...
        'Error Setting %','modal');
    return;
end

% Redraw Screen
displayPreprImage(handles.currframeim, handles.mainaxis, handles.rotdeg,...
    handles.cropdim, handles.ind);

% Display Com Points
hold on; plot(comPts(:,1),comPts(:,2),'rx','MarkerSize',10); hold off;

% Draw Regression Line
hold on; line(comPts(:,1),comPts(:,2));
hold off;

% Request Percentage
prompt = {'% of Midline: '};
dlg_title = 'Set Column By Percentage';
num_lines = 1;
def = {'50'};
perct = inputdlg(prompt,dlg_title,num_lines,def);
if ~isempty(perct)
    perct = str2double(cell2mat(perct));
    col = round((perct/100) * (max(comPts(:,1)) - min(comPts(:,1))) + ...
        min(comPts(:,1)));
    
    set(handles.pixelindex,'Value',col);
    pixelindex_Callback(handles.pixelindex,eventdata,handles);
end

function help_Callback(hObject, eventdata, handles)
% hObject    handle to setPercentageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function tools_Callback(hObject, eventdata, handles)
% hObject    handle to setPercentageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function useselection_Callback(hObject, eventdata, handles)
% hObject    handle to setPercentageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
