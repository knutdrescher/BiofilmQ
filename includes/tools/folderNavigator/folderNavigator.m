function varargout = folderNavigator(varargin)
% FOLDERNAVIGATOR MATLAB code for folderNavigator.fig
%      FOLDERNAVIGATOR, by itself, creates a new FOLDERNAVIGATOR or raises the existing
%      singleton*.
%
%      H = FOLDERNAVIGATOR returns the handle to a new FOLDERNAVIGATOR or the handle to
%      the existing singleton*.
%
%      FOLDERNAVIGATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FOLDERNAVIGATOR.M with the given input arguments.
%
%      FOLDERNAVIGATOR('Property','Value',...) creates a new FOLDERNAVIGATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before folderNavigator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to folderNavigator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help folderNavigator

% Last Modified by GUIDE v2.5 19-Jul-2018 10:09:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @folderNavigator_OpeningFcn, ...
    'gui_OutputFcn',  @folderNavigator_OutputFcn, ...
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


% --- Executes just before folderNavigator is made visible.
function folderNavigator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to folderNavigator (see VARARGIN)
guiPath = mfilename('fullpath');
guiPath = fileparts(guiPath);
addpath(genpath(fullfile(guiPath, 'includes')));

try
    addIcon(hObject);
end
% Choose default command line output for folderNavigator
handles.output = hObject;

if ~isempty(varargin{2})
    handles.handles_GUI = varargin{2};
end


% Update handles structure
guidata(hObject, handles);

if ~isempty(varargin{1})
    set(handles.edit_inputFolder, 'String', fileparts(varargin{1}{1}))
    scanningInputFolder(hObject, eventdata, handles)
end

% UIWAIT makes folderNavigator wait for user response (see UIRESUME)
% uiwait(handles.folderNavigator);


% --- Outputs from this function are returned to the command line.
function varargout = folderNavigator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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



function edit_inputFolder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inputFolder as text
%        str2double(get(hObject,'String')) returns contents of edit_inputFolder as a double


% --- Executes during object creation, after setting all properties.
function edit_inputFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_selectFolder.
function pushbutton_selectFolder_Callback(hObject, eventdata, handles)
%% Select input directory
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end

directory = uigetdir(directory, 'Please select directory containing the subfolders of the experiment');
if directory
    save('directory.mat', 'directory');
else
    disp('No folder selected');
    return;
end

set(handles.edit_inputFolder, 'String', directory);
scanningInputFolder(hObject, eventdata, handles)

function scanningInputFolder(hObject, eventdata, handles)

inputFolder = get(handles.edit_inputFolder, 'String');
if isempty(inputFolder)
    return;
end
folders = strsplit(genpath(inputFolder), pathsep);

folders_name = cell(numel(folders, 1));
for i = 1:numel(folders)
    [~, folders_name{i}, ext] = fileparts(folders{i});
    % we only have folders, so there will be no extension. However, if
    % there is a "." in the folder name, it is not completely recognized.
    folders_name{i} = [folders_name{i}, ext];
end
dataFolders = strcmp(folders_name, 'data');
decovolutionFolders = strcmp(folders_name, 'deconvolved images');
emptyFoldersNames = cellfun(@isempty, {folders_name});

subfolders = struct('name', folders_name, 'folder', cellfun(@fileparts, folders, 'UniformOutput', false), 'isdir', repmat({true}, 1, numel(folders)));%dir(inputFolder);

%subfolders = subfolders([subfolders.isdir]);
%subfolders = subfolders(3:end);

%[~, sorted] = sort_nat({subfolders.name});
%subfolders = subfolders(sorted);

numFiles = cellfun(@(folder_base, subfolder) numel(dir(fullfile(folder_base, subfolder, '*.tif'))), {subfolders.folder}', {subfolders.name}');

validFormats = {'*.nd2', '*.lif', '*.czl', '*.lsm', '*.oif', '*.oib', '*.ome.tiff', '*.ome.tif'};

for j = 1:length(validFormats)
    numFiles = numFiles + cellfun(@(folder_base, subfolder) numel(dir(fullfile(folder_base, subfolder, validFormats{j}))), {subfolders.folder}', {subfolders.name}');
end

emptyFolders = numFiles == 0;

subfolders(emptyFolders | dataFolders' | decovolutionFolders' | emptyFoldersNames) = [];
numFiles(emptyFolders | dataFolders' | decovolutionFolders' | emptyFolders) = [];

folderProcessed = cellfun(@(folder_base, subfolder) exist(fullfile(folder_base, subfolder, 'data'), 'dir'), {subfolders.folder}', {subfolders.name}')>0;

files = cellfun(@(folder_base, subfolder) dir(fullfile(folder_base, subfolder, '*.tif')), {subfolders.folder}', {subfolders.name}', 'UniformOutput', false);
bytes = cellfun(@(files) sum([files.bytes])/1024/1024/1024, files);


colors = flip(autumn(256))+0.4;
colors(colors>1) = 1;
    
% Color bytes column according to size

colorIdx = round((bytes-min(bytes))/(max(bytes)-min(bytes))*255+1);
if isnan(colorIdx)
    colorIdx = repmat(1, 1, numel(colorIdx));
end

bytes_color = colors(colorIdx, :);
byte_str = cell(numel(bytes), 1);

spaces = cellfun(@(x) [repmat('&nbsp;', 1, x)], num2cell(round(colorIdx/20)), 'UniformOutput', false);
for i = 1:numel(bytes)
    try
        byte_str{i} = sprintf('<html><body bgcolor="%s">%.2f%s', rgb2hex(bytes_color(i,:)), bytes(i), spaces{i});
    catch
        byte_str{i} = '';
    end
end

try
    % Color size column according to nZ
    filenames = cellfun(@(filelist) {filelist.name}, files, 'un', 0);
    filename_features =  cellfun(@(x) getFeaturesFromName(x), filenames);
    
    numZMax = cellfun(@(x) max(x), {filename_features.Nz});
    
    colorIdx = round((numZMax-min(numZMax))/(max(numZMax)-min(numZMax))*255+1);
    
    colorIdx(isnan(colorIdx)) = 1;

    numZMax_color = colors(colorIdx, :);
    numZMax_str = cell(numel(numZMax), 1);
    
    spaces = cellfun(@(x) [repmat('&nbsp;', 1, x)], num2cell(round(colorIdx/20)), 'UniformOutput', false);
    for i = 1:numel(numZMax)
        try
            if numZMax(i)
                numZMax_str{i} = sprintf('<html><body bgcolor="%s">%d%s', rgb2hex(numZMax_color(i,:)), numZMax(i), spaces{i});
            else
                numZMax_str{i} = '';
            end
        catch
            numZMax_str{i} = '';
        end
    end
catch
   numZMax_str = repmat({''}, numel(byte_str), 1);
   numZMax = zeros(1, numel(byte_str));
end

% Color number of files-column according to size
colorIdx = round((numFiles-min(numFiles))/(max(numFiles)-min(numFiles))*255+1);
if isnan(colorIdx)
    colorIdx = repmat(1, 1, numel(colorIdx));
end
numFiles_color = colors(colorIdx, :);
numFiles_str = cell(numel(numFiles), 1);

spaces = cellfun(@(x) [repmat('&nbsp;', 1, x)], num2cell(round(colorIdx/20)), 'UniformOutput', false);
for i = 1:numel(numFiles)
    try
        numFiles_str{i} = sprintf('<html><body bgcolor="%s">%d%s', rgb2hex(numFiles_color(i,:)), numFiles(i), spaces{i});
    catch
        numFiles_str{i} = '';
    end
end


filesStr = [{subfolders.name}', numFiles_str, numZMax_str, byte_str, num2cell(folderProcessed), {subfolders.folder}'];
files = [{subfolders.name}', num2cell(numFiles), num2cell(numZMax'), num2cell(bytes), num2cell(folderProcessed), {subfolders.folder}'];

%[~, idx] = sort(bytes, 'descend');
idx = 1:numel(bytes);
set(handles.uitable_files, 'Data', filesStr(idx, :), 'UserData', files(idx, : ));

% --- Executes on button press in pushbutton_open.
function pushbutton_open_Callback(hObject, eventdata, handles)
cellSelection = get(handles.folderNavigator, 'UserData');
inputFolder = get(handles.edit_inputFolder, 'String');
filesTable = get(handles.uitable_files, 'UserData');

if isempty(cellSelection) || isempty(filesTable)
    msgbox('No files selected', 'Info', 'warn', 'modal')
    return;
end
for i = 1:size(cellSelection(:,1))
    folderToOpen = fullfile(inputFolder, filesTable{cellSelection(i,1),1});
    
    files = dir(fullfile(folderToOpen, '*.tif'));
    metadata_files = dir(fullfile(folderToOpen, '*_metadata.mat'));
    
    timepoints = cell(numel(files, 1));
    % Open metadata-files
    for i = 1:numel(metadata_files)
        metadata = load(fullfile(folderToOpen, metadata_files(i).name));
        timepoints{i} = metadata.data.date;
    end
    
    data = cell(numel(files, 1));
    % Open metadata-files
    data{1} = imread3D(fullfile(files(1).folder, files(1).name));
    
    im = data{1}(:,:,2:end);
    
    maxZ = filesTable{cellSelection(1),3};
    
    zSlicer_time(im, maxZ, files, timepoints, filesTable{cellSelection(1), 1}, metadata.data.scaling, 1);
end

% --- Executes when selected cell(s) is changed in uitable_files.
function uitable_files_CellSelectionCallback(hObject, eventdata, handles)
set(handles.folderNavigator, 'UserData', eventdata.Indices);


% --- Executes on button press in pushbutton_batchProcessing.
function pushbutton_batchProcessing_Callback(hObject, eventdata, handles)
parameterFile = get(handles.edit_parameterFile, 'String');
if ~exist(parameterFile, 'file')
    parameterFile = [];
end

batchFile = get(handles.edit_batchFile, 'String');

cellSelection = get(handles.folderNavigator, 'UserData');
inputFolder = get(handles.edit_inputFolder, 'String');
filesTable = get(handles.uitable_files, 'UserData');
folders = filesTable(unique(cellSelection(:,1)),1);
base = filesTable(cellSelection(:,1),6);
folders = cellfun(@(x, y) fullfile(x, y), base, folders, 'UniformOutput', false);

addpath(genpath(fullfile(fileparts(which('BiofilmQ')), 'batch processing', 'batchFiles')));

% Copy parameter file
for i = 1:numel(folders)
    if exist(fullfile(folders{i}), 'dir')
        % Copy parameters file
        if ~isempty(parameterFile)
            try
                copyfile(parameterFile, fullfile(folders{i}, 'parameters.mat'), 'f');
            catch
                warning('Cannot copy parameter-file');
            end
        end
    end
end
handles.handles_GUI.settings.showMsgs = 0;
run(batchFile);
handles.handles_GUI.settings.showMsgs = 1;


% --- Executes on button press in pushbutton_selectBatchFile.
function pushbutton_selectBatchFile_Callback(hObject, eventdata, handles)
[fname, directory] = uigetfile('*.m', 'Please select directory containing the subfolders of the experiment', fullfile(fullfile(fileparts(which('BiofilmQ')), 'batch processing', 'batchFiles'), 'batch.m'));

set(handles.edit_batchFile, 'String', fullfile(directory, fname));

function edit_batchFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_batchFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_batchFile as text
%        str2double(get(hObject,'String')) returns contents of edit_batchFile as a double


% --- Executes during object creation, after setting all properties.
function edit_batchFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_batchFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_selectParameterFile.
function pushbutton_selectParameterFile_Callback(hObject, eventdata, handles)
%% Select input directory
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end

[fname, directory] = uigetfile('*.mat', 'Please select directory containing the subfolders of the experiment', fullfile(directory, 'parameters.mat'));
if directory
    save('directory.mat', 'directory');
else
    disp('No folder selected');
    return;
end

set(handles.edit_parameterFile, 'String', fullfile(directory, fname));


function edit_parameterFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_parameterFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_parameterFile as text
%        str2double(get(hObject,'String')) returns contents of edit_parameterFile as a double


% --- Executes during object creation, after setting all properties.
function edit_parameterFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_parameterFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_openSegmentation.
function pushbutton_openSegmentation_Callback(hObject, eventdata, handles)
cellSelection = get(handles.folderNavigator, 'UserData');
inputFolder = get(handles.edit_inputFolder, 'String');
filesTable = get(handles.uitable_files, 'UserData');

if isempty(cellSelection) || isempty(filesTable)
    msgbox('No files selected', 'Info', 'warn', 'modal')
    return;
end
if size(cellSelection, 1) > 1
    msgbox('Multiple folders selected!', 'Info', 'warn', 'modal')
    return;
end

if isfield(handles, 'handles_GUI')
    figure(handles.handles_GUI.mainFig);
    handles.handles_GUI.settings.directory = fullfile(filesTable{cellSelection(1), 6}, filesTable{cellSelection(1), 1});
    set(handles.handles_GUI.uicontrols.edit.inputFolder, 'String', fullfile(filesTable{cellSelection(1), 6}, filesTable{cellSelection(1), 1}));
    BiofilmQ('pushbutton_refreshFolder_Callback', handles.handles_GUI.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, handles.handles_GUI)
else
    msgbox('Please call the folderNavigator from inside the Segmentation Toolbox.', 'Info', 'warn', 'modal')
    return;
end
