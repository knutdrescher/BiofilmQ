function varargout = zSlicer_time(varargin)
% ZSLICER_TIME MATLAB code for zSlicer_time.fig
%      ZSLICER_TIME, by itself, creates a new ZSLICER_TIME or raises the existing
%      singleton*.
%
%      H = ZSLICER_TIME returns the handle to a new ZSLICER_TIME or the handle to
%      the existing singleton*.
%
%      ZSLICER_TIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZSLICER_TIME.M with the given input arguments.
%
%      ZSLICER_TIME('Property','Value',...) creates a new ZSLICER_TIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before zSlicer_time_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to zSlicer_time_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help zSlicer_time

% Last Modified by GUIDE v2.5 20-Jan-2019 10:43:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @zSlicer_time_OpeningFcn, ...
    'gui_OutputFcn',  @zSlicer_time_OutputFcn, ...
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


% --- Executes just before zSlicer_time is made visible.
function zSlicer_time_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to zSlicer_time (see VARARGIN)

% Choose default command line output for zSlicer_time
try
    addIcon(hObject);
end

handles.output = hObject;
handles.synced = 1;
scale = 1;
titleFig = ['zSlicer (by Raimo Hartmann)  |  ', varargin{5}, ' - ', char(varargin{4}{1})];
set(handles.text_threshold, 'Visible', 'off');
set(handles.edit_threshold, 'Visible', 'off');
set(handles.pushbutton_deleteCells, 'Visible', 'off');
set(handles.pushbutton_exportData, 'Visible', 'off');
im = varargin{1};
handles.cmap = parula(1000);

set(handles.edit_Imin, 'String', num2str(round(prctile(im(:),10))));
set(handles.edit_Imax, 'String', num2str(round(prctile(im(:),99.99))));

handles.maxZ = varargin{2};

im = padarray(im, [0 0 handles.maxZ-size(im, 3)], 'post');

[~, handles.z] = max(squeeze(sum(sum(im, 1), 2)));
handles.im = im;
handles.time = varargin{7};

data = cell(numel(varargin{3}), 1);
data{varargin{7}} = im;

handles.data = data;
handles.input = varargin;

set(handles.slider_z, 'Value', 1, 'Min', 1, 'Max', handles.maxZ, 'SliderStep', [1/(handles.maxZ-1), 1/(handles.maxZ-1)]);
sliderStep = 1/(numel(varargin{3})-1) * [1 1];
if ~sliderStep(1) || isinf(sliderStep(1))
    sliderStep = [1 1];
    visible = 'off';
else
    visible = 'on';
end
set(handles.slider_time, 'Value', handles.time, 'Min', 1, 'Max', numel(varargin{3}), 'SliderStep', sliderStep, 'Visible', visible);

set(handles.edit_time, 'String', num2str(varargin{7}));

%Create axes
size_im = round(size(handles.im)*0.5);
if numel(size_im) == 2
    size_im(3) = 1;
else
    size_im(3) = round(size_im(3) * varargin{6}.dz/varargin{6}.dxy);
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


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes zSlicer_time wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = zSlicer_time_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;



function edit_x_Callback(hObject, eventdata, handles)
zSlicer_time('pushbutton_goto_Callback', handles.pushbutton_goto, 0, handles);


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
zSlicer_time('pushbutton_goto_Callback', handles.pushbutton_goto, 0, handles);


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
set(handles.slider_z, 'Value', str2num(get(hObject, 'String')));
handles.z = str2num(get(hObject, 'String'));
init(hObject, eventdata, handles);


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
                imagesc(im_yz, 'Parent', y_ax, 'ButtonDownFcn', @clickYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
                set(y_ax,'xtick',[], 'ytick',[])
                colormap(y_ax, handles.cmap);
                set(handles.edit_x, 'String', num2str(handles.x));
            end
            
        case 2
            if handles.y + -UPDN <= size(im, 1) && handles.y + -UPDN > 0
                handles.y = handles.y + -UPDN;
                im_xz = squeeze(im(round(handles.y),:,:))';
                imagesc(im_xz, 'Parent', x_ax, 'ButtonDownFcn', @clickXView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
                set(x_ax, 'YDir', 'normal','xtick',[], 'ytick',[]);
                colormap(x_ax, handles.cmap);
                set(handles.edit_y, 'String', num2str(handles.y));
            end
            
        case 3
            if handles.z + -UPDN <= size(im, 3) && handles.z + -UPDN > 0
                handles.z = handles.z + -UPDN;
                im_xy = im(:,:,round(handles.z));
                imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
                set(xy_ax,'xtick',[], 'ytick',[])
                colormap(xy_ax, handles.cmap);
                set(handles.edit_z, 'String', num2str(handles.z));
                set(handles.slider_z, 'Value', handles.z);
            end
        case 4
            if handles.time + -UPDN <= numel(handles.input{3}) && handles.time + -UPDN > 0
                handles.time = handles.time + -UPDN;
                clickTimeView(hObject, eventdata, handles.time)
                set(handles.slider_time, 'Value', handles.time);
                set(handles.edit_time, 'String', num2str(handles.time));
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
handles.time = round(str2num(get(handles.edit_time, 'String')));

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
    
    handles.x = x;
else
    x = handles.x;
end

if ~isfield(handles, 'y')
    y = round(size(im, 1)/2);
    
    handles.y = y;
else
    y = handles.y;
end

if ~isfield(handles, 'z')
    z = round(size(im, 3)/2);
    
    handles.z = z;
else
    z = handles.z;
end

im_xy = im(:,:,z);

imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
colormap(xy_ax, handles.cmap);

set(xy_ax,'xtick',[], 'ytick',[])

z_im = squeeze(im(y,:,:));
z_im = z_im';

imagesc(z_im, 'Parent', x_ax, 'ButtonDownFcn', @clickXView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
colormap(x_ax, handles.cmap);

set(x_ax,'xtick',[], 'ytick',[])
set(x_ax,'YDir','normal')

z_im = squeeze(im(:,x,:));

imagesc(z_im, 'Parent', y_ax, 'ButtonDownFcn', @clickYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
colormap(y_ax, handles.cmap);

set(y_ax,'xtick',[], 'ytick',[])

set(handles.edit_x, 'String', num2str(x));
set(handles.edit_y, 'String', num2str(y));

set(handles.edit_z, 'String', num2str(z));
set(handles.slider_z, 'value', z);


guidata(hObject, handles)

plotOverlay(hObject, eventdata);

function clickTimeView(hObject, eventdata, coordinates)
handles = guidata(hObject);
handles.time = coordinates;

if isnumeric(handles.input{4}{handles.time})
    timeStr = num2str(handles.input{4}{handles.time});
else
    timeStr = char(handles.input{4}{handles.time});
end
titleFig = ['zSlicer (by Raimo Hartmann)  |  ', handles.input{5}, ' - ', timeStr];
set(handles.figure1, 'Name', titleFig)

if isempty(handles.data{handles.time})
    fprintf('Loading image "%s" ', handles.input{3}(handles.time).name);
    try
        text(handles.axes_xy, 0, 0, ['Loading image "', handles.input{3}(handles.time).name, '"...'], 'Color', 'w', 'VerticalAlignment', 'top', 'Interpreter', 'none'); drawnow;
    catch
        text(0, 0, ['Loading image "', handles.input{3}(handles.time).name, '"...'], 'Color', 'w', 'VerticalAlignment', 'top', 'Interpreter', 'none', 'parent', handles.axes_xy); drawnow;
    end
    im = imread3D(fullfile(handles.input{3}(handles.time).folder, handles.input{3}(handles.time).name));
    im = im(:,:,2:end);
    im = padarray(im, [0 0 handles.maxZ-size(im, 3)], 'post');
    
    handles.data{handles.time} = im;
else
    im = handles.data{handles.time};
end

handles.im = im;

x_ax = handles.axes_x;
y_ax = handles.axes_y;
xy_ax = handles.axes_xy;

im_xy = im(:,:,round(handles.z));
imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
set(xy_ax,'xtick',[], 'ytick',[])
colormap(xy_ax, handles.cmap);

z_im = squeeze(im(:,handles.x,:));
imagesc(z_im, 'Parent', y_ax, 'ButtonDownFcn', @clickYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
set(y_ax,'xtick',[], 'ytick',[])
colormap(y_ax, handles.cmap);

z_im = squeeze(im(handles.y,:,:));
z_im = z_im';
imagesc(z_im, 'Parent', x_ax, 'ButtonDownFcn', @clickXView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
set(x_ax,'xtick',[], 'ytick',[])
colormap(x_ax, handles.cmap);
set(x_ax,'YDir','normal')

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

imagesc(z_im, 'Parent', x_ax, 'ButtonDownFcn', @clickXView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
colormap(x_ax, handles.cmap);

set(x_ax,'xtick',[], 'ytick',[])
set(x_ax,'YDir','normal')

z_im = squeeze(im(:,round(coordinates(1,1)),:));

imagesc(z_im, 'Parent', y_ax, 'ButtonDownFcn', @clickYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);

set(y_ax,'xtick',[], 'ytick',[])

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

imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
set(xy_ax,'xtick',[], 'ytick',[])

colormap(xy_ax, handles.cmap);

z_im = squeeze(im(:,x,:));
imagesc(z_im, 'Parent', y_ax, 'ButtonDownFcn', @clickYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
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

imagesc(im_xy, 'Parent', xy_ax, 'ButtonDownFcn', @clickXYView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);
set(xy_ax,'xtick',[], 'ytick',[])
colormap(xy_ax, handles.cmap);

z_im = squeeze(im(y,:,:));
z_im = z_im';
imagesc(z_im, 'Parent', x_ax, 'ButtonDownFcn', @clickXView, [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))]);

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

x = handles.x;
y = handles.y;
z = handles.z;
time = handles.time;
folder = handles.input{5};

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
            
            % synchronize time only if not working in the same folder
            if ~strcmp(folder, sync_handles.input{5})
                if time ~= str2num(get(sync_handles.edit_time, 'String'))
                    set(sync_handles.edit_time, 'String', num2str(time));
                    zSlicer_time('edit_time_Callback', sync_handles.edit_time, 0, sync_handles)
                else
                    zSlicer_time('pushbutton_goto_Callback', sync_handles.pushbutton_goto, 0, sync_handles)
                end
            end
            zSlicer_time('pushbutton_goto_Callback', sync_handles.pushbutton_goto, 0, sync_handles);

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
value = str2num(get(hObject, 'String'));
cmap = gray(5000);
indBG = value/handles.threshold.max*5000;

cmap(1,:) = [0 0 1];
cmap(end,:) = [1 0 0];
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
    set(handles.parentGui.uicontrols.edit.manualThreshold, 'String',...
        str2num(get(handles.edit_threshold, 'String')));
end
delete(hObject);


% --- Executes on slider movement.
function slider_z_Callback(hObject, eventdata, handles)
handles.z = round(get(hObject, 'Value'));
init(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function slider_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_time_Callback(hObject, eventdata, handles)
set(handles.edit_time, 'String', num2str(round(get(hObject, 'value'))));
clickTimeView(hObject, eventdata, round(get(hObject, 'value')))

% --- Executes during object creation, after setting all properties.
function slider_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_buffer.
function pushbutton_buffer_Callback(hObject, eventdata, handles)
h = waitbar(0, 'Loading images...', 'Name', 'Please wait');
for i = 1:numel(handles.data)
    if isempty(handles.data{i})
        try
            waitbar(i/numel(handles.data), h, sprintf('Loading image %d of %d', i,numel(handles.data)));
            
            im = imread3D(fullfile(handles.input{3}(i).folder, handles.input{3}(i).name), [], 1);
            im = im(:,:,2:end);
            im = padarray(im, [0 0 handles.maxZ-size(im, 3)], 'post');

            handles.data{i} = im;
        end
    end
end
try
    delete(h);
end
guidata(hObject, handles);



function edit_time_Callback(hObject, eventdata, handles)
set(handles.slider_time, 'Value', str2num(get(hObject, 'String')));
clickTimeView(hObject, eventdata, str2num(get(hObject, 'String')));

% --- Executes during object creation, after setting all properties.
function edit_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Imin_Callback(hObject, eventdata, handles)
setCLIMs(handles)

function setCLIMs(handles)
clim = [str2double(get(handles.edit_Imin, 'String')) str2double(get(handles.edit_Imax, 'String'))];
set(handles.axes_x, 'clim', clim);
set(handles.axes_y, 'clim', clim);
set(handles.axes_xy, 'clim', clim);

% --- Executes during object creation, after setting all properties.
function edit_Imin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Imin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Imax_Callback(hObject, eventdata, handles)
setCLIMs(handles)

% --- Executes during object creation, after setting all properties.
function edit_Imax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Imax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uihisttool_ClickedCallback(hObject, eventdata, handles)
h = figure('Name', 'Histogram');
h_ax = axes('Parent', h);
hist(h_ax, double(handles.im(handles.im>0)), 255);
xlabel(h_ax, 'Intensity');
ylabel(h_ax, 'Counts');
xlim(h_ax, [0 max(handles.im(:))]);
