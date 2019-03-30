function varargout = SimpleGUI(varargin)
% MATLAB Functions for Graphical User Interface (GUI)
% Initial Coding by R. Dalton Hicks for a MAE 311 pressure measurement project
% Modified to suit MAE 311 lab by Dr. Armentrout

% SimpleGUI MATLAB code for SimpleGUI.fig
%      SimpleGUI, by itself, creates a new SimpleGUI or raises the existing
%      singleton*.
%
%      H = SimpleGUI returns the handle to a new SimpleGUI or the handle to
%      the existing singleton*.
%
%      SimpleGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SimpleGUI.M with the given input arguments.
%
%      SimpleGUI('Property','Value',...) creates a new SimpleGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SimpleGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SimpleGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SimpleGUI

% Last Modified by GUIDE v2.5 22-Apr-2015 16:10:52

% Begin initialization code - DO NOT EDIT
% 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SimpleGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SimpleGUI_OutputFcn, ...
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

% --- Executes just before SimpleGUI is made visible.
function SimpleGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SimpleGUI (see VARARGIN)

% Choose default command line output for SimpleGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SimpleGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global Com STOP Clear
[~,res] = system('mode');
ix = strfind(res,'COM');
Com.List = regexp(res, 'COM\d+','match');

STOP = 0;
Clear = false;
set(handles.COM_Chooser,'string',Com.List)
set(handles.Indicator,'string','Stopped')
Com.num = get(handles.COM_Chooser,'value');
Com.Port = Com.List{Com.num};


% --- Outputs from this function are returned to the command line.
function varargout = SimpleGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Com Data STOP Clear SafeData Dtype
clc
format compact
clear Data
SerialPort = Com.Port;
Baud = 115200;
SerialA = serial(SerialPort, 'BaudRate', Baud);
fopen(SerialA);
iter = 1; count=1;
set(handles.Indicator,'string','WAIT')
pause(2);
set(handles.Indicator,'string','Collecting')
Big = 100000;
Status = get(handles.Indicator,'string');
%
% While Loop for getting data from the serial port
% Edit these commands if you have different data format
%
Instr=fscanf(SerialA,'%s');
if Instr == 'MAX6675degC' Dtype = 'C'; end  % Sensor ID text needs to be
if Instr == 'MAX6675degF' Dtype = 'F'; end  % same number of characters
if Instr == 'Omega300G5V' Dtype = 'P'; end
if Instr == 'LM335Temp10' Dtype = 'T'; end 
set(handles.Indicator,'string','Collecting')
while (iter <= Big && strcmp(Status,'Collecting') == true)
  Status = get(handles.Indicator,'string');
  d = str2double(strsplit(fscanf(SerialA,'%s'),','));
  % Calculations to convert time to second and voltage step to temperature
  if length(d)==2
    T1 = d(1)/1000;           % Convert time to seconds
    Data.Time(iter,1) = T1;   % Store time data
    count=count+1;            % Update display point counter
    if Dtype == 'C' || Dtype == 'F'   % if Thermocouple data
      T2 = d(2);              % Temp value
      Data.Out(iter,1)= T2;   % Store Thermocouple data
      if count == 2           % If time to display data
        count=0;
        if Dtype == 'C'
          fprintf('Number of points =%5d  Temp = %4.1f°C\n',iter+1,T2)
        else  
          fprintf('Number of points =%5d  Temp = %4.1f°F\n',iter,T2)
        end  
      end
    end
    if Dtype == 'P'           % if pressure data
      Psi = d(2)*300/1023;    % Convert value to pressure
      Data.Out(iter,1)= Psi;  % Store pressure values
      if count == 2           % If time to display data
        count=0;
        fprintf('Number of points =%5d  Pressure = %4.1f psi\n',iter+1,Psi)
      end
    end
    if Dtype == 'T'           % if LM335 Temperature data
      T2 = floor((d(2)*500/1023 - 273.2)*100)/100; % Convert DAQ step to Temp
      Data.Out(iter,1)= T2;   % Store temperature values
      if count == 10          % If time to display data
        count=0;
        fprintf('Number of points =%5d  Temp = %4.1f°C\n',iter+1,T2)
      end    
    end
    iter = iter+1;            % Update number of data point
    pause(0.001);
  end
end
fclose(SerialA);
delete(SerialA);
clear SerialA
set(handles.Indicator,'string','Stopped')
SafeData = Data;

% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Indicator,'string','Stopped')
% global STOP
% STOP = 1;
% disp(STOP)

function Filename_Callback(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Filename as text
%        str2double(get(hObject,'String')) returns contents of Filename as a double

% --- Executes during object creation, after setting all properties.
function Filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SafeData Dtype
File = get(handles.Filename,'string');
csvfile = strcat(File,'.csv');
if Dtype == 'C'
  T = table(SafeData.Time(:,1),SafeData.Out(:,1),...
    'VariableNames',{'Time_sec' 'Temperature_degC'});
  writetable(T,csvfile)
end
if Dtype == 'F'
  T = table(SafeData.Time(:,1),SafeData.Out(:,1),...
    'VariableNames',{'Time_sec' 'Temperature_degF'});
  writetable(T,csvfile)
end
if Dtype == 'P'
  T = table(SafeData.Time(:,1),SafeData.Out(:,1),...
    'VariableNames',{'Time_sec' 'Pressure_psi'});
  writetable(T,csvfile)
end  
if Dtype == 'T'
  T = table(SafeData.Time(:,1),SafeData.Out(:,1),...
    'VariableNames',{'Time_sec' 'Temperature_degC'});
  writetable(T,csvfile)
end


% --- Executes on selection change in COM_Chooser.
function COM_Chooser_Callback(hObject, eventdata, handles)
% hObject    handle to COM_Chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns COM_Chooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from COM_Chooser

global Com
Com.num = get(handles.COM_Chooser,'value');
Com.Port = Com.List{Com.num};

% --- Executes during object creation, after setting all properties.
function COM_Chooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COM_Chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Plot.
function Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SafeData Dtype
T = SafeData.Time(:,1);
Out = SafeData.Out(:,1);
figure(1)
plot(T,Out);
xlabel('Time [s]')
if Dtype == 'C' || Dtype == 'T'
  ylabel('Temperature [°C]'); end
if Dtype == 'F' 
    ylabel('Temperature [°F]'); end    
if Dtype == 'P'
  ylabel('Pressure [psi]'); end

% --- Executes on button press in Indicator.
function Indicator_Callback(hObject, eventdata, handles)
% hObject    handle to Indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Indicator