function varargout = mergeCells(varargin)
% MERGECELLS MATLAB code for mergeCells.fig
%      MERGECELLS, by itself, creates a new MERGECELLS or raises the existing
%      singleton*.
%
%      H = MERGECELLS returns the handle to a new MERGECELLS or the handle to
%      the existing singleton*.
%
%      MERGECELLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGECELLS.M with the given input arguments.
%
%      MERGECELLS('Property','Value',...) creates a new MERGECELLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mergeCells_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mergeCells_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mergeCells

% Last Modified by GUIDE v2.5 11-Mar-2016 15:51:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mergeCells_OpeningFcn, ...
    'gui_OutputFcn',  @mergeCells_OutputFcn, ...
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


% --- Executes just before mergeCells is made visible.
function mergeCells_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mergeCells (see VARARGIN)

% Choose default command line output for mergeCells
handles.output = hObject;

try
    addIcon(hObject);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mergeCells wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mergeCells_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_merge.
function pushbutton_merge_Callback(hObject, eventdata, handles)
files = get(handles.listbox_files, 'String');

data = [];
h = waitbar(0, 'Loading files...', 'Name', 'Please wait');

for i = 1:length(files)
    data{i} = loadObjects(files{i});
    waitbar(i/length(files), h);
end
delete(h);

goOn = 1;
differentFieldnames = 0;
for i = 2:length(files)
    % Check wether the files are compatible
    if (sum(data{i-1}.ImageSize == data{i}.ImageSize) ~= 3) && get(handles.checkbox_include3D, 'Value');
        disp('Image size is different!');
        goOn = 1;
    end
    if length(fieldnames(data{i-1}.stats)) ~= length(fieldnames(data{i}.stats))
        disp('Number of fieldnames is different!');
        goOn = 1;
        differentFieldnames = 1;
    else
        if sum(strcmp(sort(fieldnames(data{i-1}.stats)), sort(fieldnames(data{i}.stats)))) ~= length(strcmp(fieldnames(data{i-1}.stats), fieldnames(data{i}.stats)))
            disp('Fieldnames are different!');
            goOn = 1;
            differentFieldnames = 1;
        end
    end
end

if goOn
    h = waitbar(0, 'Merging files...', 'Name', 'Please wait');
    
    objects = [];
    
    Connectivity = data{1}.Connectivity;
    ImageSize = data{1}.ImageSize;
    
    for f = 2:length(files)
        
        NumObjects = data{f-1}.NumObjects+data{f}.NumObjects;
        
        if isfield(data{f}.stats, 'Grid_ID') % gridded

            % Merge the grid volumes grid by grid based on the global ID
            % This codes merges the gridded volume
            globalID1s = [data{f-1}.stats.Grid_ID];
            globalID2s = [data{f}.stats.Grid_ID];
            
            PixelIdxList = data{f-1}.PixelIdxList;
            
            for globalID2Ind = 1:numel(globalID2s)
                globalID2 = globalID2s(globalID2Ind);
                oldEntry = find(globalID2 == globalID1s);
                if ~isempty(oldEntry)
                    PixelIdxList{oldEntry} = union(PixelIdxList{oldEntry}, data{f}.PixelIdxList{globalID2Ind});
                else
                    PixelIdxList(end+1) = data{f}.PixelIdxList(globalID2Ind);
                end
            end
        end
        
        PixelIdxList = [data{f-1}.PixelIdxList data{f}.PixelIdxList];
        
        
        
        goodObjects = [data{f-1}.goodObjects; data{f}.goodObjects];
        
        if differentFieldnames
            fNames1 = fieldnames(data{i-1}.stats);
            fNames2 = fieldnames(data{i}.stats);
            fNames = intersect(fNames1, fNames2);
            
        else
            fNames = fieldnames(data{f-1}.stats);
        end
        
        waitbar(f/length(files), h);
        
        for i = 1:length(fNames)
            if size(data{f-1}.stats(1).(fNames{i}), 2) > 1 % -> cell structure
                data_temp = [{data{f-1}.stats.(fNames{i})}'; {data{f}.stats.(fNames{i})}'];
                for j = 1:length(data_temp)
                    stats(j).(fNames{i}) = data_temp{j};
                end
            else
                data_temp = [[data{f-1}.stats.(fNames{i})]'; [data{f}.stats.(fNames{i})]'];
                for j = 1:length(data_temp)
                    stats(j).(fNames{i}) = data_temp(j);
                end
            end
        end
    end
    
    objects = data{1};
    
    objects.NumObjects = NumObjects;
    objects.PixelIdxList = PixelIdxList;
    objects.goodObjects = goodObjects;
    objects.stats = stats;
    
    %% Average measurements
    objects = averageObjectParameters(objects);
    objects.stats = orderfields(objects.stats);
    objects.globalMeasurements = orderfields(objects.globalMeasurements);
    
    delete(h);
    
    
    if length(fNames) > 4
        uiwait(msgbox({'The files contain more than the basic measurements.',  'Please consider recalculating measurements which rely on the spatial distribution of the objects (e.g. "Distance to neared neighbor" or "Local density") as this has been changed.'}, 'Warning', 'warn', 'modal'));
    end
    if differentFieldnames
        uiwait(msgbox({'Files contained different measurements!',' Only measurements present in all files were taken.'}, 'Warning', 'warn', 'modal'));
    end
    
    
    
    if exist('directory.mat','file')
        load('directory.mat');
    else
        directory = '';
    end
    
    [filepath, filename, ext] = fileparts(files{1});
    
    
    [filename, directory] = uiputfile([filename, ext], 'Save merged objects', files{1});
    
    if directory
        h = waitbar(0.3, 'Saving files...', 'Name', 'Please wait');
        
        save('directory.mat', 'directory');
        
        saveObjects(fullfile(directory, filename), objects, 'all', 'init');

        disp('Cell files merged!');
        
        try
            waitbar(1, h);
            delete(h);
        end
        try
            delete(handles.figure1);
        end
        
    else
        disp('No file selected');
        return;
    end
    
else
    uiwait(msgbox('Cannot merge cell files.', 'Error', 'error'));
end

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
delete(handles.figure1);


% --- Executes on button press in pushbutton_fileSelect.
function pushbutton_fileSelect_Callback(hObject, eventdata, handles)
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end

[filename, directory] = uigetfile({'*.mat', 'Cell files'}, 'Please select all cell files you want to merge',  'MultiSelect','on', directory);
if directory
    save('directory.mat', 'directory');
    filepath = [];
    
    if ~iscell(filename)
        filepath = fullfile(directory, filename);
    else
        for i = 1:length(filename)
            filepath{i} = fullfile(directory, filename{i});
        end
    end
    set(handles.listbox_files, 'String', filepath);
    
    
else
    disp('No file selected');
    return;
end


% --- Executes on selection change in listbox_files.
function listbox_files_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_files


% --- Executes during object creation, after setting all properties.
function listbox_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_include3D.
function checkbox_include3D_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_include3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_include3D
