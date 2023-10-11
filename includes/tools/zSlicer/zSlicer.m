function varargout = zSlicer(varargin)
% ZSLICER MATLAB code for zSlicer.fig
%      ZSLICER, by itself, creates a new ZSLICER or raises the existing
%      singleton*.
%
%      H = ZSLICER returns the handle to a new ZSLICER or the handle to
%      the existing singleton*.
%
%      ZSLICER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZSLICER.M with the given input arguments.
%
%      ZSLICER('Property','Value',...) creates a new ZSLICER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before zSlicer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to zSlicer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help zSlicer

% Last Modified by GUIDE v2.5 19-Jan-2019 20:40:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @zSlicer_OpeningFcn, ...
    'gui_OutputFcn',  @zSlicer_OutputFcn, ...
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


% --- Executes just before zSlicer is made visible.
function zSlicer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to zSlicer (see VARARGIN)

% Choose default command line output for zSlicer
handles.output = hObject;
handles.synced = 1;

try
    addIcon(hObject);
end

handles.im = varargin{1};
if nargin == 4
    if isstruct(handles.im)
        handles.objects = handles.im;
        handles.im = labelmatrix(handles.im);
    else
        set(handles.pushbutton_deleteCells, 'Visible', 'off');
        set(handles.pushbutton_exportData, 'Visible', 'off');
        handles.im = double(handles.im);
    end
    
    cmap = rand(max(handles.im(:))+1,3);
    cmap(1,:) = [0 0 0];
    handles.cmap = cmap;
else
    handles.cmap = varargin{2};
    set(handles.pushbutton_deleteCells, 'Visible', 'off');
    set(handles.pushbutton_exportData, 'Visible', 'off');
end


titleFig = checkInput(varargin, 'title', 'zSlicer by Raimo Hartmann');
mode = checkInput(varargin, 'mode', '');
handles.cLimits = checkInput(varargin, 'clim', [min(handles.im(:)) max(handles.im(:))]);

if ~diff(handles.cLimits)
    handles.cLimits(1) = 0;
    if ~handles.cLimits(2)
        handles.cLimits(2) = 1;
    end
end

handles.parentGui = checkInput(varargin, 'parentGui', []);
scale = checkInput(varargin, 'scale', 1);
scaling = checkInput(varargin, 'scaling', struct('dxy', 1, 'dz', 1));


if strcmp(mode, 'threshold')
    handles.threshold = checkInput(varargin, 'sensitivity', struct.empty);
    
    if isempty(handles.threshold)
        handles.threshold = checkInput(varargin, 'threshold', struct('value', 0));
        if ~handles.threshold.value
            handles.threshold.value = multithresh(handles.im);
        end
        handles.factor = 1;
        handles.sensitivityValue = false;
        sliderLimits = handles.cLimits;
    else
        factor = checkInput(varargin, 'threshold', struct('value', 0));
        if ~factor.value
            factor.value = multithresh(handles.im);
        end
        if ~handles.threshold.value
            handles.threshold.value = 1;
        end
        handles.factor = factor.value/handles.threshold.value;
        handles.sensitivityValue = true;
        sliderLimits = handles.cLimits./handles.factor;
        handles.text_threshold.String = 'Sensitivity';
    end

    minValue = sliderLimits(1);
    maxValue = sliderLimits(2);
    set(handles.edit_threshold, 'String', num2str(handles.threshold.value));
    set(handles.slider_threshold, 'Value', handles.threshold.value, 'Min', minValue, 'Max', maxValue, 'SliderStep', [1/1000 0.05]);
else
    set(handles.text_threshold, 'Visible', 'off');
    set(handles.edit_threshold, 'Visible', 'off');
    set(handles.slider_threshold, 'Visible', 'off');
end


%Create axes
size_im = round(size(handles.im)*0.5);
if numel(size_im) == 2
    size_im(3) = 1;
else
    size_im(3) = round(size_im(3) * scaling.dz/scaling.dxy);
end


set(handles.figure1, 'units', 'pixels', 'position', [1 1 size_im(2)+size_im(3)+4 size_im(1)+size_im(3)+4])

handles.axes_x = axes('parent', handles.figure1, 'units', 'pixels', 'position', [1 size_im(1)+4 size_im(2) size_im(3)]);
handles.axes_y = axes('parent', handles.figure1, 'units', 'pixels', 'position', [size_im(2)+4 1 size_im(3) size_im(1)]);
handles.axes_xy = axes('parent', handles.figure1, 'units', 'pixels', 'position', [1 1 size_im(2) size_im(1)]);
set(handles.axes_x, 'units', 'normalized');
set(handles.axes_y, 'units', 'normalized');
set(handles.axes_xy, 'units', 'normalized');


set(handles.figure1, 'Name', titleFig)
pos = get(handles.figure1, 'position');

pos(3:4) = round(pos(3:4)*scale);
set(handles.figure1, 'position', pos)


init(hObject, eventdata, handles)
handles = guidata(hObject);

if isempty(getappdata(0, 'hMain1'))
    h = figure('Visible', 'off');
    delete(h);
    setappdata(0, 'hMain1', h)
    setappdata(0, 'hMain2', h)
    setappdata(0, 'hMain3', h)
    setappdata(0, 'hMain4', h)
end
  
if isvalid(getappdata(0, 'hMain1')) && isvalid(getappdata(0, 'hMain2')) && isvalid(getappdata(0, 'hMain3')) && isvalid(getappdata(0, 'hMain4'))
    uiwait(msgbox('Only 4 instances supported!', 'Please note!', 'warn'));
    disp('Starting unsynced instance');
end

if isvalid(getappdata(0, 'hMain3')) && ~isvalid(getappdata(0, 'hMain4'))
    setappdata(0, 'hMain4', handles.figure1);
    handles.thisApp = 4;
    disp('Starting instance #4');
end

if isvalid(getappdata(0, 'hMain2')) && ~isvalid(getappdata(0, 'hMain3'))
    setappdata(0, 'hMain3', handles.figure1);
    handles.thisApp = 3;
    disp('Starting instance #3');
end

if isvalid(getappdata(0, 'hMain1')) && ~isvalid(getappdata(0, 'hMain2'))
    setappdata(0, 'hMain2', handles.figure1);
    handles.thisApp = 2;
    disp('Starting instance #2');
end

if ~isvalid(getappdata(0, 'hMain1'))
    setappdata(0, 'hMain1', handles.figure1);
    handles.thisApp = 1;
    disp('Starting instance #1');
end

assignin('base', 'zhandles', handles);

try
    pos = handles.parentGui.mainFig.Position;
    pos(1) = pos(1) + pos(3)/4;
    pos(2) = pos(2) + pos(4)/4;
    pos(3) = pos(4)/2;
    pos(4) = pos(4)/2;
    set(handles.figure1, 'position', pos)
end
% Update handles structure
guidata(hObject, handles);
if strcmp(mode, 'threshold')
    applyTreshold(hObject, eventdata, handles)
end

% UIWAIT makes zSlicer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = zSlicer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_x as text
%        str2double(get(hObject,'String')) returns contents of edit_x as a double


% --- Executes during object creation, after setting all properties.
function edit_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_y as text
%        str2double(get(hObject,'String')) returns contents of edit_y as a double


% --- Executes during object creation, after setting all properties.
function edit_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_z as text
%        str2double(get(hObject,'String')) returns contents of edit_z as a double


% --- Executes during object creation, after setting all properties.
function edit_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mouseScroll(hObject, eventdata)

handles = guidata(hObject);

UPDN = eventdata.VerticalScrollCount;

try
    im = handles.im;
    x_ax = handles.axes_x;
    y_ax = handles.axes_y;
    xy_ax = handles.axes_xy;
    
    switch get(handles.popupmenu_mouseWheel, 'Value')
        case 1
            if handles.x + -UPDN <= size(im, 2) && handles.x + -UPDN > 0
                handles.x = handles.x + -UPDN;
                im_yz = squeeze(im(:,round(handles.x),:));
                imagesc(im_yz, 'Parent', y_ax, 'ButtonDownFcn', @clickYView);
                set(y_ax,'xtick',[], 'ytick',[])
                colormap(y_ax, handles.cmap);
                set(handles.edit_x, 'String', num2str(handles.x));
            end
            
        case 2
            if handles.y + -UPDN <= size(im, 1) && handles.y + -UPDN > 0
                handles.y = handles.y + -UPDN;
                im_xz = squeeze(im(round(handles.y),:,:))';
                imagesc(im_xz, 'Parent', x_ax, 'ButtonDownFcn', @clickXView);
                set(x_ax,'xtick',[], 'ytick',[])
                set(x_ax, 'YDir', 'normal')
                colormap(x_ax, handles.cmap);
                set(handles.edit_y, 'String', num2str(handles.y));
            end
            
        case 3
            if handles.z + -UPDN <= size(im, 3) && handles.z + -UPDN > 0
                handles.z = handles.z + -UPDN;
                im_xy = im(:,:,round(handles.z));
                imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView);
                set(xy_ax,'xtick',[], 'ytick',[])
                colormap(xy_ax, handles.cmap);
                set(handles.edit_z, 'String', num2str(handles.z));
            end
    end
    fprintf('Position: [x: %d, y: %d, z: %d]\n', handles.x, handles.y, handles.z);
    

    guidata(hObject, handles);
    
    plotOverlay(hObject, eventdata)
    
catch
    disp('Out of range');
end



% --- Executes on button press in pushbutton_goto.
function pushbutton_goto_Callback(hObject, eventdata, handles)
handles.x = round(str2num(get(handles.edit_x, 'String')));
handles.y = round(str2num(get(handles.edit_y, 'String')));
handles.z = round(str2num(get(handles.edit_z, 'String')));

init(hObject, eventdata, handles)


function init(hObject, eventdata, handles)

set (handles.figure1, 'WindowScrollWheelFcn', @mouseScroll);

guidata(hObject, handles)




x_ax = handles.axes_x;
y_ax = handles.axes_y;
xy_ax = handles.axes_xy;

if ~isfield(handles, 'im');
    handles.im = double(evalin('base', 'im'));
    % Create Colormap
    cmap = rand(10000,3);
    cmap(1,:) = [0 0 0];
    handles.cmap = cmap;
end
im = handles.im;

if ~isfield(handles, 'x')
    x = round(size(im, 2)/2);
    y = round(size(im, 1)/2);
    z = round(size(im, 3)/2);
    
    handles.x = x;
    handles.y = y;
    handles.z = z;
else
    x = handles.x;
    y = handles.y;
    z = handles.z;
end

im_xy = im(:,:,z);

imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView);
set(xy_ax,'xtick',[], 'ytick',[])
colormap(xy_ax, handles.cmap);

set(xy_ax,'xtick',[])
set(xy_ax,'ytick',[])

z_im = squeeze(im(y,:,:));
z_im = z_im';

imagesc(z_im, 'Parent', x_ax, 'ButtonDownFcn', @clickXView);
set(x_ax,'xtick',[], 'ytick',[])
colormap(x_ax, handles.cmap);

set(x_ax,'xtick',[])
set(x_ax,'ytick',[])
set(x_ax,'YDir','normal')

z_im = squeeze(im(:,x,:));

imagesc(z_im, 'Parent', y_ax, 'ButtonDownFcn', @clickYView);
set(y_ax,'xtick',[], 'ytick',[])
colormap(y_ax, handles.cmap);

set(handles.edit_x, 'String', num2str(x));
set(handles.edit_y, 'String', num2str(y));

set(handles.edit_z, 'String', num2str(z));

guidata(hObject, handles)

plotOverlay(hObject, eventdata);

function clickXYView(hObject, eventdata, coordinates)

handles = guidata(hObject);
im = handles.im;

x_ax = handles.axes_x;
y_ax = handles.axes_y;
xy_ax = handles.axes_xy;


if nargin == 2
    axesHandle  = get(hObject,'Parent');
    coordinates = get(axesHandle,'CurrentPoint');
end
z = handles.z;


z_im = squeeze(im(round(coordinates(1,2)),:,:));
z_im = z_im';

imagesc(z_im, 'Parent', x_ax, 'ButtonDownFcn', @clickXView);
colormap(x_ax, handles.cmap);

set(x_ax,'xtick',[], 'ytick',[])
set(x_ax,'YDir','normal')

z_im = squeeze(im(:,round(coordinates(1,1)),:));

imagesc(z_im, 'Parent', y_ax, 'ButtonDownFcn', @clickYView);
set(y_ax,'xtick',[], 'ytick',[]);

colormap(y_ax, handles.cmap);

set(handles.edit_x, 'String', num2str(round(coordinates(1,1))));
set(handles.edit_y, 'String', num2str(round(coordinates(1,2))));
im_size = size(handles.im);

handles.x = round(coordinates(1,1));
handles.y = round(coordinates(1,2));

guidata(hObject, handles);

plotOverlay(hObject, eventdata);

function edit_intScale_Callback(hObject, eventdata, handles)
pushbutton_Load_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_intScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clickXView(hObject, eventdata, coordinates)

handles = guidata(hObject);

x_ax = handles.axes_x;
y_ax = handles.axes_y;
xy_ax = handles.axes_xy;

if nargin == 2
    axesHandle  = get(hObject,'Parent');
    coordinates = get(axesHandle,'CurrentPoint');
end

z = round(coordinates(1,2));
x = round(coordinates(1,1));

im = handles.im;

im_xy = im(:,:,round(z));

imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView);
set(xy_ax,'xtick',[], 'ytick',[])

colormap(xy_ax, handles.cmap);

z_im = squeeze(im(:,x,:));
imagesc(z_im, 'Parent', y_ax, 'ButtonDownFcn', @clickYView);
set(y_ax,'xtick',[], 'ytick',[])
colormap(y_ax, handles.cmap);


set(handles.edit_z, 'String', num2str(z));
set(handles.edit_x, 'String', num2str(x));

handles.z = z;
handles.x = x;

guidata(hObject, handles);

plotOverlay(hObject, eventdata)

function clickYView(hObject, eventdata)
handles = guidata(hObject);

x_ax = handles.axes_x;
y_ax = handles.axes_y;
xy_ax = handles.axes_xy;

axesHandle  = get(hObject,'Parent');
coordinates = get(axesHandle,'CurrentPoint');

z = round(coordinates(1,1));
y = round(coordinates(1,2));

im = handles.im;

im_xy = im(:,:,round(z));

imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView);
set(xy_ax,'xtick',[], 'ytick',[])
colormap(xy_ax, handles.cmap);

z_im = squeeze(im(y,:,:));
z_im = z_im';
imagesc(z_im, 'Parent', x_ax, 'ButtonDownFcn', @clickXView);
set(x_ax,'xtick',[], 'ytick',[])

colormap(x_ax, handles.cmap);
set(x_ax,'YDir','normal')

set(handles.edit_z, 'String', num2str(z));
set(handles.edit_y, 'String', num2str(y));
handles.z = z;
handles.y = y;

guidata(hObject, handles);

plotOverlay(hObject, eventdata)



function plotOverlay(hObject, eventdata)
handles = guidata(hObject);

im = handles.im;
im_size = size(handles.im, 1);
im_size(2) = size(handles.im, 2);
im_size(3) = size(handles.im, 3);

x_ax = handles.axes_x;
y_ax = handles.axes_y;
xy_ax = handles.axes_xy;

if isfield(handles, 'cLimits')
    x_ax.CLim = handles.cLimits;
    y_ax.CLim = handles.cLimits;
    xy_ax.CLim = handles.cLimits;
end

x = handles.x;
y = handles.y;
z = handles.z;


children = get(xy_ax, 'Children');
if length(children)>1
    delete(children(1:end-1));
end

children = get(y_ax, 'Children');
if length(children)>2
    delete(children(1:end-1));
end

children = get(x_ax, 'Children');
if length(children)>2
    delete(children(1:end-1));
end

line([1 size(im,1)], [z z], 'Color', 'r', 'Parent', x_ax);
line([z z], [1 size(im,1)], 'Color', 'r', 'Parent', y_ax);

line([z z], [1 size(im,2)], 'Color', 'r', 'Parent', y_ax);
line([1 size(im,1)], [z z], 'Color', 'r', 'Parent', x_ax);

line([x x], [1 im_size(1)], 'Color', 'g', 'Parent', xy_ax);
line([x x], [1 im_size(3)], 'Color', 'g', 'Parent', x_ax);
line([1 im_size(2)], [y y], 'Color', 'g', 'Parent', xy_ax);
line([1 im_size(3)], [y y], 'Color', 'g', 'Parent', y_ax);

guidata(hObject, handles);

syncing = 1;

if handles.synced && syncing
    try
        App = zeros(1,4);
        for i = 1:4
            App(i) = eval(['isvalid(getappdata(0, ''hMain',num2str(i),'''));']);
        end
        
        disp(['-> Working in App #', num2str(handles.thisApp)]);
        
        App(handles.thisApp) = 0;
        
        for i = find(App)
            eval(['sync_app = getappdata(0, ''hMain',num2str(i),''');'])
            
            sync_handles = getappdata(sync_app, 'UsedByGUIData_m');
            
            sync_handles.synced = 0;
            set(sync_handles.edit_x, 'String', num2str(x));
            set(sync_handles.edit_y, 'String', num2str(y));
            set(sync_handles.edit_z, 'String', num2str(z));
            zSlicer('pushbutton_goto_Callback', sync_handles.pushbutton_goto, 0, sync_handles)
        end
        
    catch
        %disp('No syncing');
    end
else
    %disp('syncing set off');
    handles.synced = 1;
    
end

guidata(hObject, handles);


% --- Executes on selection change in popupmenu_mouseWheel.
function popupmenu_mouseWheel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_mouseWheel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_mouseWheel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_mouseWheel


% --- Executes during object creation, after setting all properties.
function popupmenu_mouseWheel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_mouseWheel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_deleteCells.
function pushbutton_deleteCells_Callback(hObject, eventdata, handles)

cropRange = round(getrect(handles.axes_xy));
cropRange(cropRange<1) = 1;

if cropRange(1)+cropRange(3) > size(handles.im,2)
    cropRange(3) = size(handles.im,2)-cropRange(1);
end

if cropRange(2)+cropRange(4) > size(handles.im,1)
    cropRange(4) = size(handles.im,1)-cropRange(2);
end

slice = handles.im(cropRange(2):cropRange(2)+cropRange(4), ...
            cropRange(1):cropRange(1)+cropRange(3),str2num(get(handles.edit_z, 'String')));
        
toDelete = unique(slice);
toDelete(toDelete == 0) = [];
handles.objects.PixelIdxList(toDelete) = [];
handles.objects.NumObjects = numel(handles.objects.PixelIdxList);
handles.objects.goodObjects(toDelete) = [];
handles.objects.stats(toDelete) = [];
handles.im = labelmatrix(handles.objects);

coordinates = [str2num(get(handles.edit_x, 'String')), str2num(get(handles.edit_y, 'String')), str2num(get(handles.edit_z, 'String'))];
guidata(hObject, handles);
clickXYView(hObject, eventdata, coordinates);
clickXView(hObject, eventdata, coordinates([1 3 2]));
guidata(hObject, handles);


% --- Executes on button press in pushbutton_exportData.
function pushbutton_exportData_Callback(hObject, eventdata, handles)
objects = handles.objects;
assignin('base', 'objects', objects);



function edit_threshold_Callback(hObject, eventdata, handles)
applyTreshold(hObject, eventdata, handles)
sliderVal = str2num(hObject.String);

if sliderVal < handles.slider_threshold.Min
    sliderVal = handles.slider_threshold.Min;
end

if sliderVal > handles.slider_threshold.Max
    sliderVal = handles.slider_threshold.Max;
end
handles.slider_threshold.Value = sliderVal;

function applyTreshold(hObject, eventdata, handles)

value = str2num(get(handles.edit_threshold, 'String'));
value = value*handles.factor - handles.threshold.min;
diff = handles.cLimits(2) - handles.cLimits(1);
nColormap = max(diff,1000);
cmap = gray(nColormap);
indBG = value*nColormap/diff; %/handles.threshold.max;

cmap(1,:) = [0 0 1];
%cmap(end,:) = [1 0 0];
cmap(1:ceil(indBG), 1) = 0;
cmap(1:ceil(indBG), 2) = 0;
cmap(1:ceil(indBG), 3) = 1;

colormap(handles.axes_x, cmap);
colormap(handles.axes_y, cmap);
colormap(handles.axes_xy, cmap);

handles.cmap = cmap;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
    if ~isempty(get(handles.edit_threshold, 'String'))
        if ~handles.sensitivityValue
            set(handles.parentGui.uicontrols.edit.manualThreshold, 'String',...
                str2num(get(handles.edit_threshold, 'String')));
        else
            set(handles.parentGui.uicontrols.edit.thresholdSensitivity, 'String',...
                str2num(get(handles.edit_threshold, 'String')));
        end
    end
end
delete(hObject);


% --- Executes on slider movement.
function slider_threshold_Callback(hObject, eventdata, handles)
handles.edit_threshold.String = num2str(hObject.Value);
applyTreshold(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function slider_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_showColormap.
function pushbutton_showColormap_Callback(hObject, eventdata, handles)
hb = colorbar(handles.axes_xy);
hb.Position(4) = 0.1;
hb.Position(2) = 0.05;
hb.Color = 'w';
