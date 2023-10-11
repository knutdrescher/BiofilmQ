function varargout = visualizeTree(varargin)
% VISUALIZETREE MATLAB code for visualizeTree.fig
%      VISUALIZETREE, by itself, creates a new VISUALIZETREE or raises the existing
%      singleton*.
%
%      H = VISUALIZETREE returns the handle to a new VISUALIZETREE or the handle to
%      the existing singleton*.
%
%      VISUALIZETREE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALIZETREE.M with the given input arguments.
%
%      VISUALIZETREE('Property','Value',...) creates a new VISUALIZETREE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visualizeTree_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visualizeTree_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualizeTree

% Last Modified by GUIDE v2.5 02-Jun-2016 14:55:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualizeTree_OpeningFcn, ...
                   'gui_OutputFcn',  @visualizeTree_OutputFcn, ...
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


% --- Executes just before visualizeTree is made visible.
function visualizeTree_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualizeTree (see VARARGIN)

% Choose default command line output for visualizeTree
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes visualizeTree wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = visualizeTree_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_zoom.
function pushbutton_zoom_Callback(hObject, eventdata, handles)
zoom
toggleState(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_pan.
function pushbutton_pan_Callback(hObject, eventdata, handles)
pan
toggleState(hObject, eventdata, handles)

% --- Executes on button press in pushbutton_rotate.
function pushbutton_rotate_Callback(hObject, eventdata, handles)
rotate3d
toggleState(hObject, eventdata, handles)

function toggleState(hObject, eventdata, handles)
if get(hObject, 'UserData') == 0
    set(hObject, 'UserData', 1, 'ForegroundColor', 'black')
else
    set(hObject, 'UserData', 0, 'ForegroundColor', 'red')
end


% --- Executes on button press in pushbutton_clear.
function pushbutton_clear_Callback(hObject, eventdata, handles)
delete(get(findobj('Tag', 'axes1'), 'Children'));
delete(get(findobj('Tag', 'axes2'), 'Children'));
delete(get(findobj('Tag', 'axes3'), 'Children'));
