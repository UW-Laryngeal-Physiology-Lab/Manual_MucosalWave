function varargout = savedialog(varargin)
% SAVEDIALOG M-file for savedialog.fig
%      SAVEDIALOG, by itself, creates a new SAVEDIALOG or raises the existing
%      singleton*.
%
%      H = SAVEDIALOG returns the handle to a new SAVEDIALOG or the handle to
%      the existing singleton*.
%
%      SAVEDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVEDIALOG.M with the given input arguments.
%
%      SAVEDIALOG('Property','Value',...) creates a new SAVEDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before savedialog_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to savedialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help savedialog

% Last Modified by GUIDE v2.5 12-Mar-2009 13:22:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @savedialog_OpeningFcn, ...
                   'gui_OutputFcn',  @savedialog_OutputFcn, ...
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


% --- Executes just before savedialog is made visible.
function savedialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to savedialog (see VARARGIN)

% Choose default command line output for savedialog
handles.output = hObject;

% Initialize handles
handles.pressure = 0;
handles.larynx = 0;
handles.elongation = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes savedialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = savedialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function larynx_Callback(hObject, eventdata, handles)
% hObject    handle to larynx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of larynx as text
%        str2double(get(hObject,'String')) returns contents of larynx as a double

handles.larynx = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function larynx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to larynx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pressure_Callback(hObject, eventdata, handles)
% hObject    handle to pressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pressure as text
%        str2double(get(hObject,'String') returns contents of pressure as a double
handles.pressure = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pressure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function elongation_Callback(hObject, eventdata, handles)
% hObject    handle to elongation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of elongation as text
%        str2double(get(hObject,'String')) returns contents of elongation as a double

handles.elongation = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function elongation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elongation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainGUIhandles = guidata(mucosal);

% Set the handles of the main GUI to the subfigure inputs
mainGUIhandles.pressure = handles.pressure;
mainGUIhandles.larynx = handles.larynx;
mainGUIhandles.elongation = handles.elongation;

% Save the results back to main GUI and close subfigure
guidata(mucosal, mainGUIhandles);
close(savedialog)


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(savedialog)
