function varargout = plotting(varargin)
% PLOTTING MATLAB code for plotting.fig
%      PLOTTING, by itself, creates a new PLOTTING or raises the existing
%      singleton*.
%
%      H = PLOTTING returns the handle to a new PLOTTING or the handle to
%      the existing singleton*.
%
%      PLOTTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTTING.M with the given input arguments.
%
%      PLOTTING('Property','Value',...) creates a new PLOTTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotting

% Last Modified by GUIDE v2.5 23-Mar-2019 16:49:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @plotting_OpeningFcn, ...
    'gui_OutputFcn',  @plotting_OutputFcn, ...
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


% --- Executes just before plotting is made visible.
function plotting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotting (see VARARGIN)

% Choose default command line output for plotting
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotting_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

clear all;
global a;
global sensor;
global go;
go = false;



% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = arduino('COM4', 'Uno', 'Libraries', 'JRodrigoTech/HCSR04');

% Create ultrasonic sensor object with trigger pin D12 and echo pin D13.
sensor = addon(a, 'JRodrigoTech/HCSR04', 'D12', 'D13');
x = 0;
time = 0;
go
fprintf('we in dere');
while(handles.stop)
    dist = readTravelTime(sensor)*340/2*100;
    disp(dist);
    x = [x dist];
    time = [time, time+0.25];
    plot(handles.axes1,x);
    grid on;
    xlabel('Time (sec)');
    ylabel('Distance (cm)');
    title('Real Time Distance Measurments');
    drawnow
    pause(.25)
    
end


% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('We in overhere');
go = false;


