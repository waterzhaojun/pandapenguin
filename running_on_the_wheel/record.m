function varargout = record(varargin)
% RECORD MATLAB code for record.fig
%      RECORD, by itself, creates a new RECORD or raises the existing
%      singleton*.
%
%      H = RECORD returns the handle to a new RECORD or the handle to
%      the existing singleton*.
%
%      RECORD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORD.M with the given input arguments.
%
%      RECORD('Property','Value',...) creates a new RECORD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before record_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to record_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help record

% Last Modified by GUIDE v2.5 09-May-2018 11:39:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @record_OpeningFcn, ...
                   'gui_OutputFcn',  @record_OutputFcn, ...
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


% --- Executes just before record is made visible.
function record_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to record (see VARARGIN)

% Choose default command line output for record
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% setup global parameters
delete(instrfind({'Port'}, {'COM7'}));   % set the UNO port here
clear speed;
clear speed_array;
global speed;
global speed_array;
global flag_recording;
global animalID;
global expID;
global recordDuration;
global saveFolder;
global scanrate

saveFolder = 'C:\behavior';
speed = arduinoOpen(7); % and here
speed_array = [];

% UIWAIT makes record wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = record_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global speed;
global speed_array;
global flag_recording;
global recordDuration;
global animalID;
global expID;
global saveFolder;
global scanrate

scanrate = 10
x = 1:1:(recordDuration*60*scanrate);
sh = animatedline(handles.axes1);

lastValue = arduinoReadQuad(speed);
flag_recording = 1;
for k = 1:length(x)
%     b=a.readVoltage('A0');
%     addpoints(h,x(k), b);
%     drawnow limitrate
    if flag_recording == 1
        tic;
        tmp = arduinoReadQuad(speed);
        speed_array = [speed_array, tmp];
        b = abs(tmp-lastValue);
        lastValue = tmp;
        addpoints(sh,x(k), b);
        drawnow limitrate
        pause(1/scanrate-toc);
    end
end
flag_recording = 0;

if saveFolder(end) ~= '\'
    saveFolder = [saveFolder, '\'];
end

% saveName = [animalID, '_', expID];
saveName = 'A2020081803_201015_1'
save([saveFolder, saveName, '.mat'], 'speed_array');
speed_array = [];


% --- Executes on button press in stopRecording.
function stopRecording_Callback(hObject, eventdata, handles)
% hObject    handle to stopRecording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global speed_array;
global flag_recording;
global animalID;
global expID;
global saveFolder;

flag_recording = 0;

if saveFolder(end) ~= '\'
    saveFolder = [saveFolder, '\'];
end

% saveName = [animalID, '_', expID];
saveName = 'A2020081803_201015_1'
save([saveFolder, saveName, '.mat'], 'speed_array');
speed_array = [];



function animalID_Callback(hObject, eventdata, handles)
% hObject    handle to animalID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global animalID;
animalID = get(hObject,'String');


% Hints: get(hObject,'String') returns contents of animalID as text
%        str2double(get(hObject,'String')) returns contents of animalID as a double


% --- Executes during object creation, after setting all properties.
function animalID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animalID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expID_Callback(hObject, eventdata, handles)
% hObject    handle to expID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expID as text
%        str2double(get(hObject,'String')) returns contents of expID as a double
global expID;
expID = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function expID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function recordLen_Callback(hObject, eventdata, handles)
% hObject    handle to recordLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global recordDuration;
recordDuration = str2double(get(hObject,'String'));

% Hints: get(hObject,'String') returns contents of recordLen as text
%        str2double(get(hObject,'String')) returns contents of recordLen as a double


% --- Executes during object creation, after setting all properties.
function recordLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recordLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global recordDuration;
recordDuration = str2double(get(hObject,'String'));
