function varargout = behaviorRecord(varargin)
% BEHAVIORRECORD MATLAB code for behaviorRecord.fig
%      BEHAVIORRECORD, by itself, creates a new BEHAVIORRECORD or raises the existing
%      singleton*.
%
%      H = BEHAVIORRECORD returns the handle to a new BEHAVIORRECORD or the handle to
%      the existing singleton*.
%
%      BEHAVIORRECORD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEHAVIORRECORD.M with the given input arguments.
%
%      BEHAVIORRECORD('Property','Value',...) creates a new BEHAVIORRECORD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before behaviorRecord_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to behaviorRecord_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help behaviorRecord

% Last Modified by GUIDE v2.5 03-Aug-2017 16:28:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @behaviorRecord_OpeningFcn, ...
                   'gui_OutputFcn',  @behaviorRecord_OutputFcn, ...
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


% --- Executes just before behaviorRecord is made visible.
function behaviorRecord_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to behaviorRecord (see VARARGIN)

% Choose default command line output for behaviorRecord
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes behaviorRecord wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%===== analog input ========================
% delete(instrfind({'Port'}, {'COM7'}));
% clear a;
% global a;
% a = arduino('COM7', 'UNO');

%===== may delete ==========================
delete(instrfind({'Port'}, {'COM7'}));
clear speed;
clear speed_array;
global speed;
global speed_array;
global flag_recording;
speed = arduinoOpen(7);
speed_array = [];


%===== eye ===================================

% axes(handles.axes3);
% vid = videoinput('winvideo', 2);
% himage = image(zeros(160, 90, 3), 'parent', handles.axes3);
% preview(vid, himage);


% --- Outputs from this function are returned to the command line.
function varargout = behaviorRecord_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonRecord.
function buttonRecord_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%plot(1:100);
% global a;
% axes(handles.axes2);
% a.writeDigitalPin(8,1);
x = 1:1:1000;
% h = animatedline(handles.axes2);
sh = animatedline(handles.axes1);
% axis([0 length(x) 0 10])

global speed;
global speed_array;
global flag_recording;
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
        pause(0.1-toc);
    end
end


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global speed_array;
global flag_recording;
flag_recording = 0;
saveFolder = 'C:\behavior';
saveName = 'test';
save([saveFolder, '\', saveName, '.mat'], 'speed_array');
speed_array = [];
