function varargout = tune(varargin)
% TUNE M-file for tune.fig
%      TUNE, by itself, creates a new TUNE or raises the existing
%      singleton*.
%
%      H = TUNE returns the handle to a new TUNE or the handle to
%      the existing singleton*.
%
%      TUNE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TUNE.M with the given input arguments.
%
%      TUNE('Property','Value',...) creates a new TUNE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tune_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tune_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% p6edit the above text to modify the response to help tune

% Last Modified by GUIDE v2.5 22-May-2009 08:39:59

% Begin initialization code - DO NOT P6EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tune_OpeningFcn, ...
                   'gui_OutputFcn',  @tune_OutputFcn, ...
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
% End initialization code - DO NOT P6EDIT


% --- Executes just before tune is made visible.
function tune_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tune (see VARARGIN)

% Choose default command line output for tune
handles.output = hObject;
if ~isfield(handles, 'initialized')
    if length(varargin) > 0
        handles.initialized = true;
        handles.mwaveImage = varargin{1};
        handles.edgePoints = varargin{2};
        handles.cfitResult = varargin{3};
        handles.order = handles.cfitResult.order;
        handles.MAX_ORDER = 8;
        % These are the original curve fit parameters input to the Tune GUI
        handles.guesses = varargin{4};
        for i = 1:handles.order
            guessLabel = sprintf('a%dedit',i);
            set(handles.(guessLabel),'String',handles.guesses(i)*sqrt(2));
        end
        handles.origGuesses = handles.guesses;
        handles.origcfitResult = handles.cfitResult;
        handles.originalOrder = handles.order;
        
        set(handles.orderedit,'String',handles.order);
        
        % Set amplitude result labels
        ampResults = getAmplitudeResults(handles.cfitResult.cfitObject,...
                                         handles.cfitResult.order);
        for i = 1:handles.cfitResult.order
            resultLabel = sprintf('a%dresult',i);
            set(handles.(resultLabel),'String',ampResults(i));
        end
        
        % Plot original, un-tuned result
        axes(handles.tuneaxis);
        hold on
        imshow(handles.mwaveImage);
        scatter(handles.edgePoints(:,2),handles.edgePoints(:,1),'y');
        plot(handles.cfitResult.xdata, handles.cfitResult.ydata, 'b');
        hold off
        
        % Plot original, un-tuned R-square value
        axes(handles.plotaxis);    
        rsquare = handles.cfitResult.goodness.rsquare;
        handles.rsquare = rsquare;
        set(handles.rsquareLabel,'String',rsquare);
        guidata(hObject, handles);
        plot(1, rsquare,'b.-');
        axis([1 20 0 1]);
    else
        errordlg('The tune GUI requires command line arguments.');
        close(tune)
    end
end

% Update handles structure
% guidata(hObject, handles);

% UIWAIT makes tune wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tune_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes whenever the callback to a max amplitude box is edited
function maxAmpCallback(hObject, handles)

% Validates user input and performs curve fitting if valid
inputValue = str2double(get(hObject,'String'));
if isnan(inputValue) || inputValue <= 0
    errordlg('Max Amplitude must be a number > 0, or "Inf" (infinity).');
    set(hObject, 'String', 'Inf');
    guidata(hObject, handles);
    return;
else
    tryNewGuess(hObject,handles);
end

function a1edit_Callback(hObject, eventdata, handles)
% hObject    handle to a1edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a1edit as text
%        str2double(get(hObject,'String')) returns contents of a1edit as a double

maxAmpCallback(hObject, handles);

% inputValue = str2double(get(hObject,'String'));
% if isnan(inputValue) || inputValue <= 0
%     errordlg('Max Amplitude must be a number > 0, or "Inf" (infinity).');
%     set(hObject, 'String', 'Inf');
%     guidata(hObject, handles);
%     return;
% else
%     tryNewGuess(hObject,handles);
% end

% --- Executes during object creation, after setting all properties.
function a1edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a1edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function a2edit_Callback(hObject, eventdata, handles)
% hObject    handle to a2edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a2edit as text
%        str2double(get(hObject,'String')) returns contents of a2edit as a double

maxAmpCallback(hObject, handles);

% --- Executes during object creation, after setting all properties.
function a2edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a2edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function a3edit_Callback(hObject, eventdata, handles)
% hObject    handle to a3edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a3edit as text
%        str2double(get(hObject,'String')) returns contents of a3edit as a double

maxAmpCallback(hObject, handles);

% --- Executes during object creation, after setting all properties.
function a3edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a3edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a4edit_Callback(hObject, eventdata, handles)
% hObject    handle to a4edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a4edit as text
%        str2double(get(hObject,'String')) returns contents of a4edit as a double

maxAmpCallback(hObject, handles);

% --- Executes during object creation, after setting all properties.
function a4edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a4edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function a5edit_Callback(hObject, eventdata, handles)
% hObject    handle to a5edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a5edit as text
%        str2double(get(hObject,'String')) returns contents of a5edit as a double

maxAmpCallback(hObject, handles);

% --- Executes during object creation, after setting all properties.
function a5edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a5edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function a6edit_Callback(hObject, eventdata, handles)
% hObject    handle to a6edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a6edit as text
%        str2double(get(hObject,'String')) returns contents of a6edit as a double

maxAmpCallback(hObject, handles);

% --- Executes during object creation, after setting all properties.
function a6edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a6edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function a7edit_Callback(hObject, eventdata, handles)
% hObject    handle to a7edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a7edit as text
%        str2double(get(hObject,'String')) returns contents of a7edit as a double

maxAmpCallback(hObject, handles);

% --- Executes during object creation, after setting all properties.
function a7edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a7edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function a8edit_Callback(hObject, eventdata, handles)
% hObject    handle to a8edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a8edit as text
%        str2double(get(hObject,'String')) returns contents of a8edit as a double

maxAmpCallback(hObject, handles);

% --- Executes during object creation, after setting all properties.
function a8edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a8edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: p6edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainGUIhandles = guidata(mucosal);
resultName = sprintf('%sresult',handles.cfitResult.fold);
mainGUIhandles.(resultName) = handles.cfitResult;

% Save the max amplitude values back to main GUI
guesses = sprintf('%sGuesses',handles.cfitResult.fold);
mainGUIhandles.(guesses) = handles.guesses;

% Save the sinusoid order back to main GUI
sinusoidOrder = sprintf('%sOrder',handles.cfitResult.fold);
mainGUIhandles.(sinusoidOrder) = handles.order;
sinusoidOrderEdit = sprintf('%sOrderEdit',handles.cfitResult.fold);
set(mainGUIhandles.(sinusoidOrderEdit),'String',handles.order);

% Save the results back to main GUI and close subfigure
guidata(mucosal, mainGUIhandles);

close(tune)

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
confirm = questdlg('Canceling will discard any tuning you performed.  Are you sure you want to cancel?','Confirm cancel','No','Yes','No');
if strcmp(confirm, 'Yes'), close(tune); end

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset all max amp edit boxes to Inf
for i = 1:length(handles.origGuesses)
    guessLabel = sprintf('a%dedit',i);
    set(handles.(guessLabel),'String',handles.origGuesses(i)*sqrt(2));
end

% Reset sinusoid order edit box to original order
set(handles.orderedit,'String',handles.originalOrder);
handles.order = handles.originalOrder;
    
guidata(hObject, handles);
tryNewGuess(hObject,handles);

function orderedit_Callback(hObject, eventdata, handles)
% hObject    handle to orderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orderedit as text
%        str2double(get(hObject,'String')) returns contents of orderedit as a double

handles.order = validateOrder(hObject, handles.MAX_ORDER);
guidata(hObject,handles);
tryNewGuess(hObject,handles);

% --- Executes during object creation, after setting all properties.
function orderedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in default.
function default_Callback(hObject, eventdata, handles)
% hObject    handle to default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset all max amp edit boxes to Inf
for i = 1:handles.MAX_ORDER
    maxAmpHandle = sprintf('a%dedit',i);
    set(handles.(maxAmpHandle),'String','Inf');
end

% Reset sinusoid order edit box to original order
set(handles.orderedit,'String',handles.originalOrder);
handles.order = handles.originalOrder;
    
guidata(hObject, handles);
tryNewGuess(hObject,handles);
