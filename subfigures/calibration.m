function varargout = calibration(varargin)
% CALIBRATION M-file for calibration.fig
%      CALIBRATION, by itself, creates a new CALIBRATION or raises the existing
%      singleton*.
%
%      H = CALIBRATION returns the handle to a new CALIBRATION or the handle to
%      the existing singleton*.
%
%      CALIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATION.M with the given input arguments.
%
%      CALIBRATION('Property','Value',...) creates a new CALIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibration_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibration

% Last Modified by GUIDE v2.5 25-Mar-2009 12:04:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibration_OpeningFcn, ...
                   'gui_OutputFcn',  @calibration_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before calibration is made visible.
function calibration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calibration (see VARARGIN)

% Choose default command line output for calibration
handles.output = hObject;
if ~isfield(handles, 'initialized')
    if length(varargin) > 0
        handles.initialized = true;
        fname = varargin{1};
        handles.fname = fname{1};

        % Read video information from .avi file
        info = VideoReader(handles.fname);
        num = info.NumberOfFrames;

       % Initialize the figure and axis size
        %  Gather initial figure and axis sizes, resize axis to video size 
        currfigpos = get(hObject, 'Position');
        curraxispos = get(handles.axes1, 'Position');
        currcontrolpanelpos = get(handles.controlspanel,'Position');
        controlpanelwidth = currcontrolpanelpos(3);
        
        %setting the axis to the figures height and width
        minWidth = info.Width + 25;
        if minWidth < controlpanelwidth
            minWidth = controlpanelwidth;
        end
        newaxisPos = [curraxispos(1), curraxispos(2),minWidth,info.Height + 150];
        newpicPos = [curraxispos(1), curraxispos(2),minWidth,info.Height];
        set(hObject,'Position', newaxisPos);%axes1
        set(handles.axes1,'Position', newpicPos);%picture


       %  Resize figure if it's not big enough
%          addedWidth = info.Width - curraxispos(3)
%          addedHeight = info.Height - curraxispos(4)
% % 
% %          if addedWidth > 0 || addedHeight > 0
% %             set(hObject, 'Position',...
% %                 [currfigpos(1) currfigpos(2)...
% %                      (currfigpos(3)+addedWidth) (currfigpos(4)+addedHeight)]);
% %  
% %             newaxispos = [curraxispos(1) curraxispos(2) info.Width info.Height];
% %              set(handles.axes1, 'Position', newaxispos);
% %  
% % %             currpanelpos = get(handles.controlspanel, 'Position');
% % %             set(handles.controlspanel, 'Position',...
% % %                 [floor((currpanelpos(1)+addedWidth/2)) currpanelpos(2)...
% % %                     currpanelpos(3) currpanelpos(4)]);
% %         %  If video is smaller than initial axis size, center axis in figure
%          if addedWidth < 0 || addedHeight < 0
%             newaxispos = [(floor((currfigpos(3)-info.Width)/2))...
%                             floor(curraxispos(4)/2+curraxispos(2)-info.Height/4)...
%                                 info.Width info.Height];
%             set(handles.axes1, 'Position', newaxispos);%
%         end

        set(handles.frameslider, 'Max', num); % Frame slider max value
        set(handles.frameslider, 'Value', 1); % Frame slider init value
        set(handles.frameslider, 'SliderStep', [1/num 0.05]); % Frame slider step value

        % display 1st frame of video
        handles.currframe = 1;       
        axes(handles.axes1); % make this figures axes the current axes
        imshow(frame2im(getFrame(handles.fname, handles.currframe))); 
        title('Note: right click when done drawing line.')
                
        % Update handles structure
        handles.x = [0 0];
        handles.y = [0 0];
        handles.distance = str2double(get(handles.actualdistance, 'String'));
        handles.ampUnits = get(handles.units, 'String');
        handles.fps = str2double(get(handles.framerate, 'String'));
        guidata(hObject, handles);
    else
        errordlg('The calibration GUI requires a command line argument.');
        close(gcf) % GUI won't open if it is not passed an argument containing
                   % the filename of the video
    end
end

% UIWAIT makes calibration wait for user response (see UIRESUME)
% uiwait(handles.figure1)


% --- Outputs from this function are returned to the command line.
function varargout = calibration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output; 
end


% --- Executes on button press in linebutton.
function linebutton_Callback(hObject, eventdata, handles)
% hObject    handle to linebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% instr1 = '1. Find the calibration section in the video and';
% instr2 = sprintf('\ndraw a line between two points of known actualdistance.');
% instr3 = sprintf('\n\n2. Enter the actual actualdistance and units.');
% instr4 = sprintf('\n\n3. Enter the video frame rate.');
% instr = [instr1 instr2 instr3 instr4];
% helpdlg(instr, 'Instructions');

try
    [x,y] = getline;
    handles.x = x;
    handles.y = y;
catch
    return
end

guidata(hObject, handles);
displayFrame(handles);


function framerate_Callback(hObject, eventdata, handles)
% hObject    handle to framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framerate as text
%        str2double(get(hObject,'String')) returns contents of framerate as a double
fps = str2double(get(hObject,'String'));
MAX_ACCEPTABLE_FPS = 100000;
if fps < 0 || fps > MAX_ACCEPTABLE_FPS
    set(hObject,'String','4000');
    fps = 4000;
end
handles.fps = fps;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function framerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function frameslider_Callback(hObject, eventdata, handles)
% hObject    handle to frameslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderval = floor(get(hObject, 'Value'));
if sliderval < 1
    handles.currframe = 1;
else
    handles.currframe = sliderval;
end
guidata(hObject, handles);
displayFrame(handles)


% --- Executes during object creation, after setting all properties.
function frameslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function actualdistance_Callback(hObject, eventdata, handles)
% hObject    handle to actualdistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actualdistance as text
%        str2double(get(hObject,'String')) returns contents of actualdistance as a double
handles.distance = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function actualdistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actualdistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function units_Callback(hObject, eventdata, handles)
% hObject    handle to units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of units as text
%        str2double(get(hObject,'String')) returns contents of units as a double
handles.ampUnits = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if isnan(handles.distance)
%     set(handles.actualdistance, 'BackgroundColor', [1 1 0.5]);
%     return
% end

mainGUIhandles = guidata(mucosal);

if any(handles.distance)
    % Compute Euclidean length (in pixels) of calibration line
    xpoints = handles.x;
    ypoints = handles.y;
    eucdist = sqrt((max(xpoints)-min(xpoints))^2 + (max(ypoints)-min(ypoints))^2);
%else    
    handles.conversionfactor = handles.distance/eucdist;
    %handles.ampUnits = 'pixels';
%end
else
    handles.conversionfactor = 1;
end



% Set the handles of the main GUI to the subfigure inputs
if handles.fps ~= 0
    unitsArray = {handles.ampUnits 'Hz' handles.conversionfactor};
else  % 0 for framerate indicates that framerate is unknown so freq is in radians
    unitsArray = {handles.ampUnits 'radians' handles.conversionfactor};
end

mainGUIhandles.units = unitsArray;
mainGUIhandles.frameRate = handles.fps;
% Save the results back to main GUI and close subfigure
guidata(mucosal, mainGUIhandles);

close(calibration)


% --- Executes on button press in skip.
function skip_Callback(hObject, eventdata, handles)
% hObject    handle to skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(calibration)


% --- Displays the currently selected frame
function displayFrame(handles)

currframeim = frame2im(getFrame(handles.fname, handles.currframe));

hold on
% Display image at 100% magnfication (1 screen pixel per image pixel)
imshow(currframeim, 'InitialMagnification', 100);
if (length(handles.x) > 1)
    line(handles.x(1:2), handles.y(1:2))
end
hold off