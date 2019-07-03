function varargout = run_faceMovie(varargin)
% RUN_FACEMOVIE MATLAB code for run_faceMovie.fig
%      RUN_FACEMOVIE, by itself, creates a new RUN_FACEMOVIE or raises the existing
%      singleton*.
%
%      H = RUN_FACEMOVIE returns the handle to a new RUN_FACEMOVIE or the handle to
%      the existing singleton*.
%
%      RUN_FACEMOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUN_FACEMOVIE.M with the given input arguments.
%
%      RUN_FACEMOVIE('Property','Value',...) creates a new RUN_FACEMOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before run_faceMovie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to run_faceMovie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help run_faceMovie

% Last Modified by GUIDE v2.5 02-Mar-2018 10:52:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @run_faceMovie_OpeningFcn, ...
                   'gui_OutputFcn',  @run_faceMovie_OutputFcn, ...
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


% --- Executes just before run_faceMovie is made visible.
function run_faceMovie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to run_faceMovie (see VARARGIN)

% Choose default command line output for run_faceMovie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%===== unable all handles before initiation
set(handles.endButton,'Enable','off'); 
set(handles.startButton,'Enable','off'); 
set(handles.animalID,'Enable','off'); 
set(handles.runID,'Enable','off'); 


%===== other global parameters =============
global parameter; % only change this parameter for each exp.
parameter.duration = 60;
parameter.herz = 10;
parameter.savePath = 'C:\Project\behavior_running\';
parameter.animalID = '';
parameter.dateID = '';
parameter.run = '';
parameter.foldername = '';
parameter.expDataPath = '';
parameter.speed = '';
parameter.eye = '';
parameter.runPort = 6;   %change to the proper COM. 5 means 'COM5'
parameter.video_format = 'MJPG_1280x960';

global video_size;
tmp = strsplit(parameter.video_format, '_');
tmp = strsplit(tmp{2}, 'x');
video_size = struct('facevideo_width', str2num(tmp{1}), 'facevideo_height', str2num(tmp{2}));
clear tmp;

%====== flags ===============================
global flag;
flag.record = 0;
flag.camera1 = 0;


%===== Running =============================
delete(instrfind({'Port'}, {['COM', num2str(parameter.runPort)]})); % find instr with key words 'port', 'COM5'.
clear speed;
global speed; % claim a global variable.
speed = arduinoOpen(parameter.runPort);

%====== initiate buttons ====================
set(handles.startButton,'Enable','on') 
set(handles.animalID,'Enable','on'); 
set(handles.runID,'Enable','on'); 

% UIWAIT makes run_faceMovie wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = run_faceMovie_OutputFcn(hObject, eventdata, handles) 
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
global vid;
global parameter;
global video_size;

parameter.dateID = datestr(date, 'yymmdd');
parameter.animalID = get(handles.animalID, 'String');
parameter.run = get(handles.runID, 'String');
parameter.foldername = [parameter.savePath, parameter.dateID, '_', parameter.animalID, '_', parameter.run, '\'];
parameter.expDataPath = [parameter.foldername, 'expData.mat'];

global flag;
flag.record = 1;
flag.camera1 = get(handles.camera1, 'Value');

set(handles.endButton,'Enable','on');
set(handles.startButton,'Enable','off');

if exist(parameter.foldername, 'dir') == 0, mkdir(parameter.foldername);end

sh = animatedline(handles.axes1); % plot window for running

positionData = [];

if(flag.camera1 == 1)
global vid;
    axes(handles.axes_face);
    vid = videoinput('winvideo', 1,parameter.video_format); % change here if change the camera. 'winvideo' is the webcam's adaptor name. 
    himage = image(zeros(video_size.facevideo_height, video_size.facevideo_width, 3), 'parent', handles.axes_face); % if set a small size here, the frame will crop the original view to a small size. it is crop not resize. 
    % becareful the first para is height, second is width. it is a opposite
    % sequence to image size.
    preview(vid, himage);
end

triggerconfig(vid, 'manual'); % this is to connect the video manual, otherwise during the loop it will repeatedly connect the device.
start(vid);

aviObject = VideoWriter([parameter.foldername, 'face.avi']); 
aviObject.FrameRate = parameter.herz;
aviObject.Quality = 50;
open(aviObject);
% eyeData = uint8(zeros(video_size.facevideo_height, video_size.facevideo_width, 3,1));  % if record avi movie, this is not necessary

lastValue = arduinoReadQuad(speed);
for k = 1:(parameter.duration * parameter.herz)
    
    if (flag.record == 1)
        tic;

        tmp = arduinoReadQuad(speed);
        b = abs(tmp-lastValue);
        lastValue = tmp;
        addpoints(sh,k, b);
        positionData(k) = tmp;
        drawnow limitrate
        
        tmp=getsnapshot(vid);
        writeVideo(aviObject,tmp);
%         tmp_F = im2frame(tmp);                    % Convert I to a movie frame
%         aviObject = addframe(aviObject,tmp_F);  % Add the frame to the AVI file
        % eyeData(:,:,:,k) = getsnapshot(vid); % if record avi movie, this
        % is not necessary

        usedTime = toc;
        if(usedTime<(1/parameter.herz))
            pause(1/parameter.herz - usedTime);
        end
    end
    
end

clear tmp tmp_F;
stop(vid)
close(aviObject);

parameter.speed = positionData;
% parameter.eye = eyeData;

set(handles.runID,'string',str2num(parameter.run)+1);

save(parameter.expDataPath, 'parameter');
flag_record = 0;
set(handles.endButton,'Enable','off') 
set(handles.startButton,'Enable','on') 


% --- Executes on button press in endButton.
function endButton_Callback(hObject, eventdata, handles)
% hObject    handle to endButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global flag_record;
flag_record = 0;


% --- Executes on button press in cameraControl.
function cameraControl_Callback(hObject, eventdata, handles)
% hObject    handle to cameraControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cameraControl





function animalID_Callback(hObject, eventdata, handles)
% hObject    handle to animalID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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



function runID_Callback(hObject, eventdata, handles)
% hObject    handle to runID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of runID as text
%        str2double(get(hObject,'String')) returns contents of runID as a double


% --- Executes during object creation, after setting all properties.
function runID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in camera1.
function camera1_Callback(hObject, eventdata, handles)
% hObject    handle to camera1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of camera1

