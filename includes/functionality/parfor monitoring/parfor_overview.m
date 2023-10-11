function varargout = parfor_overview(varargin)
% PARFOR_OVERVIEW MATLAB code for parfor_overview.fig
%      PARFOR_OVERVIEW, by itself, creates a new PARFOR_OVERVIEW or raises the existing
%      singleton*.
%
%      H = PARFOR_OVERVIEW returns the handle to a new PARFOR_OVERVIEW or the handle to
%      the existing singleton*.
%
%      PARFOR_OVERVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARFOR_OVERVIEW.M with the given input arguments.
%
%      PARFOR_OVERVIEW('Property','Value',...) creates a new PARFOR_OVERVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before parfor_overview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to parfor_overview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help parfor_overview

% Last Modified by GUIDE v2.5 08-Nov-2016 13:22:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @parfor_overview_OpeningFcn, ...
                   'gui_OutputFcn',  @parfor_overview_OutputFcn, ...
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


% --- Executes just before parfor_overview is made visible.
function parfor_overview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to parfor_overview (see VARARGIN)

% Choose default command line output for parfor_overview
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes parfor_overview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = parfor_overview_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_currentTask_Callback(hObject, eventdata, handles)
% hObject    handle to edit_currentTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_currentTask as text
%        str2double(get(hObject,'String')) returns contents of edit_currentTask as a double


% --- Executes during object creation, after setting all properties.
function edit_currentTask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_currentTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_errors_Callback(hObject, eventdata, handles)
% hObject    handle to edit_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_errors as text
%        str2double(get(hObject,'String')) returns contents of edit_errors as a double


% --- Executes during object creation, after setting all properties.
function edit_errors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
