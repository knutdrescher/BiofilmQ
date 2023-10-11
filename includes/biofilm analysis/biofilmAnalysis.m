function varargout = biofilmAnalysis(varargin)
% BIOFILMANALYSIS MATLAB code for biofilmAnalysis.fig
%      BIOFILMANALYSIS, by itself, creates a new BIOFILMANALYSIS or raises the existing
%      singleton*.
%
%      H = BIOFILMANALYSIS returns the handle to a new BIOFILMANALYSIS or the handle to
%      the existing singleton*.
%
%      BIOFILMANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIOFILMANALYSIS.M with the given input arguments.
%
%      BIOFILMANALYSIS('Property','Value',...) creates a new BIOFILMANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before biofilmAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to biofilmAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help biofilmAnalysis

% Last Modified by GUIDE v2.5 04-Apr-2019 15:47:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @biofilmAnalysis_OpeningFcn, ...
    'gui_OutputFcn',  @biofilmAnalysis_OutputFcn, ...
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


% --- Executes just before biofilmAnalysis is made visible.
function biofilmAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to biofilmAnalysis (see VARARGIN)

% Choose default command line output for biofilmAnalysis
handles.output = hObject;

try
    currentDir = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(currentDir, 'includes')));
    addpath(currentDir);
end

setappdata(0, 'hMain_analysis', gcf);
% Choose default command line output for particleAnalyzer
startProgram = 1;

%% Tidy up handles
handles = tidyGUIHandles(handles);

% should be part of the .fig as soon as possible:
handles.uicontrols.pushbutton.pushbutton_plotTree_selected.Enable = 'off';

assignin('base', 'handles', handles)
assignin('base', 'hObject', hObject)

try
    set(handles.uicontrols.edit.edit_path, 'String', varargin{1}.settings.directory)
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes biofilmAnalysis wait for user response (see UIRESUME)
% uiwait(handles.biofilmAnalysis);


% --- Outputs from this function are returned to the command line.
function varargout = biofilmAnalysis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
try
    toggleBusyPointer(handles, true)
    [handles, status] = loadFiles(hObject, eventdata, handles);
    if status
        handles = biofilmInfo(hObject, eventdata, handles);
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_database.Value = 1;
        handles.handles_analysis.flags.necessaryFields = [1, 2, 4];
        toggleUIElements(handles, 1, 'visualization');
        updateEnabledFields(hObject, eventdata, handles);
        checkInputFields(hObject, eventdata, handles)
        guidata(hObject, handles);
    end
catch err
    if handles.settings.showMsgs
        uiwait(msgbox(sprintf('Data could not be loaded! Reason: %s', err.message), 'Warning', 'warn', 'modal'));
    else
        warning(err.message);
    end
end
toggleBusyPointer(handles, false)

% --- Executes on selection change in listbox_fieldNames.
function listbox_fieldNames_Callback(hObject, eventdata, handles)
if get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value')==2
    globalFieldsReduced = handles.settings.measurementFieldsAnalysis_globalReduced;
    fieldNames = handles.handles_analysis.uicontrols.listbox.listbox_fieldNames.String;
    val = handles.handles_analysis.uicontrols.listbox.listbox_fieldNames.Value;
    name = fieldNames{val};
    
    if strcmp(name(1:3), '[-]')
        name = strrep(name, '[-]', '[+]');
        correspondingFields = handles.settings.measurementFieldAnalysis_correspondingFields;
        index = cellfun(@(x) strcmp(x, name), {correspondingFields.reduced});
        fieldNames{val} = name;
        fieldNames(val+1:val+length(correspondingFields(index).fields)) = [];
        
    elseif strcmp(name(1:3), '[+]')  
        correspondingFields = handles.settings.measurementFieldAnalysis_correspondingFields;
        index = cellfun(@(x) strcmp(x, name), {correspondingFields.reduced});
        if sum(index)
            toAdd = correspondingFields(index).fields;
            fieldNamesNew = cell(length(fieldNames)+length(toAdd),1);
            fieldNamesNew(1:val-1) = fieldNames(1:val-1);
            fieldNamesNew{val} = strrep(name, '[+]', '[-]');
            fieldNamesNew(val+1:val+length(toAdd)) = toAdd;
            fieldNamesNew(val+length(toAdd)+1:end) = fieldNames(val+1:end);
            fieldNames = fieldNamesNew;
        end
    
    end
    handles.handles_analysis.uicontrols.listbox.listbox_fieldNames.String = fieldNames;
    handles.handles_analysis.uicontrols.listbox.listbox_fieldNames.Value = val;
end




% --- Executes during object creation, after setting all properties.
function listbox_fieldNames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_averaging.
function popupmenu_averaging_Callback(hObject, eventdata, handles)
if handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging.Value < 4
    set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'on');
else
    set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'off', 'Value', 0);
end


% --- Executes during object creation, after setting all properties.
function popupmenu_averaging_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_kymograph_plot.
function pushbutton_kymograph_plot_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
biofilmData = getLoadedBiofilmFromWorkspace;
range = str2num(handles.uicontrols.edit.visualization_imageRange.String);
biofilmData.data = biofilmData.data(range);

%% Handle time intervals correctly
timepoints = biofilmData.timepoints;
timepoints = timepoints(range);
timeIntervals = [timepoints(1); diff(timepoints)];

biofilmData.timeIntervals = timeIntervals;

if handles.handles_analysis.uicontrols.checkbox.checkbox_applyCustom1.Value
    if ~isempty(handles.handles_analysis.uicontrols.edit.edit_custom1.String)
        pathScript = handles.handles_analysis.uicontrols.edit.edit_custom1.String;
        try
            run(pathScript);
        catch err
            warning('backtrace', 'off')
            warning('Custom script "%s" not valid! Error msg: %s', pathScript, err.message);
            warning('backtrace', 'on')
        end
    end
end

switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType, 'Value')
    case 1
        kymograph(handles, biofilmData)
    case 2
        plotXY(handles, biofilmData)
    case 3
        scatterPlotXY(handles, biofilmData)
    case 4
        scatterPlotXY(handles, biofilmData)
    case 5
        histogram1D(handles, biofilmData)
    case 6
        histogram1D(handles, biofilmData)
end
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_plotTree_selected.
function pushbutton_plotTree_selected_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
plotTree(hObject, eventdata, handles, 'selection')
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_plotTree_all.
function pushbutton_plotTree_all_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
plotTree(hObject, eventdata, handles, 'all')
toggleBusyPointer(handles, false)


function plotTree(hObject, eventdata, handles, mode)
t_max = str2num(get(handles.handles_analysis.uicontrols.edit.edit_maxFrame, 'String'));
selTrack = str2num(get(handles.handles_analysis.uicontrols.listbox.listbox_selTrack, 'String'));

trackTable = get(handles.handles_analysis.uitables.uitable_tracks, 'Data');
switch mode
    case 'all'
        validTracks = trackTable(:,1);
        Track_IDs = 'all';
    case 'selection'
        validTracks = selTrack;
        Track_IDs = num2str(selTrack');
end

biofilmData = getLoadedBiofilmFromWorkspace;
timeIntervals = [0; diff(biofilmData.timepoints)];
[parameterTree, nodes, divTimes, treeLabels] = createNodes(handles, biofilmData, timeIntervals, validTracks);

if numel(biofilmData.data) < t_max
    warning( ...
        'The given Max. Frame value "%d" is larger than "%d", which is the available number of frames!', ...
        t_max, numel(biofilmData.data));
end
[parameterTree, nodes, treeLabels, divTimes] = trimParameterTreeToMaxFrame(parameterTree, nodes, treeLabels, t_max);

[lineageTree, h] = createLineageTree(handles, nodes, treeLabels, divTimes, Track_IDs, min([t_max, numel(biofilmData.data)]));
addIcon(h);

assignin('base', 'parameterTree', parameterTree);
assignin('base', 'nodes', nodes);
assignin('base', 'lineageTree', lineageTree);


function listbox_selTrack_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function listbox_selTrack_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_minTrackLength_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_minTrackLength_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_maxFrame_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_maxFrame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_binsX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_binsX_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_binsY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_binsY_Callback(hObject, eventdata, handles)


function uitable_tracks_CellSelectionCallback(hObject, eventdata, handles)
tableData = get(hObject, 'Data');
set(handles.handles_analysis.uicontrols.listbox.listbox_selTrack, 'String', num2str(tableData(unique(eventdata.Indices(:,1)), 1)), 'Value', 1);

if ~isempty(handles.handles_analysis.uicontrols.listbox.listbox_selTrack.String)
    handles.handles_analysis.uicontrols.pushbutton.pushbutton_plotTree_selected.Enable = 'on';
else
    handles.handles_analysis.uicontrols.pushbutton.pushbutton_plotTree_selected.Enable = 'off';
end


% --- Executes on selection change in popupmenu_database.
function popupmenu_database_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
value = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');

if isfield(handles.handles_analysis.uicontrols.pushbutton, 'pushbutton_calculateAlongLineage')
    if value == 1 && any(strcmp('Track_ID', get(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String')))
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_calculateAlongLineage, 'Enable', 'on');
    else
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_calculateAlongLineage, 'Enable', 'off');
    end
end

set(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'Value', 1);
updateListboxFieldNames(handles);
updateEnabledFields(hObject, eventdata, handles);

if value == 1
    enableDisableChildren(handles.handles_analysis.uicontrols.edit.edit_filterField.Parent.Parent, 'on')
else
    handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType.Value = 2;
    handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging.Enable = 'off';
    handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars.Enable = 'off';  
    enableDisableChildren(handles.handles_analysis.uicontrols.edit.edit_filterField.Parent.Parent, 'off')
end

checkInputFields(hObject, eventdata, handles)
toggleBusyPointer(handles, false)


function updateListboxFieldNames(handles)

value = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');

databases = handles.settings.databases;
database = databases{value};

if strcmp(database(1:5), 'stats') 
    set(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String', handles.settings.measurementFieldsAnalysis_singleCell);
else
    set(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String', handles.settings.measurementFieldsAnalysis_globalReduced);
end


% --- Executes during object creation, after setting all properties.
function popupmenu_database_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_kymograph_yaxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_kymograph_coloraxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_addField_yaxis.
function pushbutton_addField_Callback(hObject, eventdata, handles, field, fieldName)
toggleBusyPointer(handles, true)
if nargin == 4
    fieldNameValue = get(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'Value');
    str = strtrim(get(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String'));
    fieldNameString = str;
    fieldName = fieldNameString{fieldNameValue};
end

if length(fieldName)>3 && (strcmp(fieldName(1:3), '[+]') || strcmp(fieldName(1:3), '[-]'))
    return;
end

database_val = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
database = handles.settings.databases;
database = database{database_val};

biofilmData = getLoadedBiofilmFromWorkspace;

switch lower(fieldName)
    
    case 'time'
        switch field
            case 1
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX.Value = 1;
                handles.handles_analysis.uicontrols.checkbox.checkbox_logX.Value = 0;
            case 2
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Value = 1;
                handles.handles_analysis.uicontrols.checkbox.checkbox_logY.Value = 0;
            case 3
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ.Value = 1;
                handles.handles_analysis.uicontrols.checkbox.checkbox_logZ.Value = 0;
            case 4
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ.Value = 1;
        end
        
    case 'cell_number'
        switch field
            case 1
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX.Value = 0;
                handles.handles_analysis.uicontrols.checkbox.checkbox_logX.Value = 1;
            case 2
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Value = 0;
                handles.handles_analysis.uicontrols.checkbox.checkbox_logY.Value = 1;
            case 3
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ.Value = 0;
                handles.handles_analysis.uicontrols.checkbox.checkbox_logZ.Value = 1;
            case 4
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Value = 2;
                handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ.Value = 0;
        end
end

if field == 1
    switch lower(fieldName)
        case 'distance_tobiofilmcenteratsubstrate'
            handles.handles_analysis.uicontrols.checkbox.checkbox_overlayBiofilmRadiusAsLine.Enable = 'on';
        case 'distance_tobiofilmcenter'
            handles.handles_analysis.uicontrols.checkbox.checkbox_overlayBiofilmRadiusAsLine.Enable = 'on';
            
        otherwise
            handles.handles_analysis.uicontrols.checkbox.checkbox_overlayBiofilmRadiusAsLine.Enable = 'off';
            handles.handles_analysis.uicontrols.checkbox.checkbox_overlayBiofilmRadiusAsLine.Value = 0;
            
    end
end

switch field
    case 1
        rangeMethod_h = handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX;
        rangeType_h = handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX;
    case 2
        rangeMethod_h = handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY;
        rangeType_h = handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY;
    case 3
        rangeMethod_h = handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ;
        rangeType_h = handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ;
    case 4
        rangeMethod_h = handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor;
        rangeType_h = handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor;
    case 5
        rangeMethod_h = handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX;
        rangeType_h = handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX;
end
[label, unit, range] = returnUnitLabel(fieldName, biofilmData, database, get(rangeMethod_h, 'Value'), get(rangeType_h, 'Value'));

range_str = '';
if range(1) < 100
    range_str = num2str(range(1), '%.3g');
elseif range(1) >= 100 && range(1) < 10000
    range_str = num2str(range(1), '%.f');
else
    range_str = num2str(range(1), '%.3g');
end
if range(2) < 100
    range_str = [range_str, ' ', num2str(range(2), '%.3g')];
elseif range(2) >= 100 && range(2) < 10000
    range_str = [range_str, ' ', num2str(range(2), '%.f')];
else
    range_str = [range_str, ' ', num2str(range(2), '%.3g')];
end

if strcmp(lower(fieldName), 'time')
    enable = 'Off';
else
    enable = 'On';
end

switch field
    case 1
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String', fieldName);
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'string', label);
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'string', unit);
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'string', range_str);
    case 2
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String', fieldName);
        set(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'string', label);
        set(handles.handles_analysis.uicontrols.edit.edit_yLabel_unit, 'string', unit);
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'string', range_str);
    case 3
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'String', fieldName);
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'string', label);
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'string', unit);
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'string', range_str);
    case 4
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'String', fieldName);
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'string', label);
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'string', unit);
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'string', range_str);
    case 5
        filterExpr = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');
        if isempty(filterExpr)
            set(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String', sprintf('{%s} > 0', fieldName));
        else
            set(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String', sprintf('%s & {%s} > 0', filterExpr, fieldName));
        end
end

checkInputFields(hObject, eventdata, handles)
toggleBusyPointer(handles, false)


% --- Executes on button press in checkbox_interpolate.
function checkbox_interpolate_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_invert.
function checkbox_invert_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_autoColorRange.
function checkbox_autoColorRange_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'value')
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'on');
    else
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'off');
    end
end


function edit_colorRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_colorRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_autoYRange.
function checkbox_autoYRange_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'value')
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'on');
    else
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off');
    end
end


function edit_yRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_yRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_colorLabel_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_colorLabel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_yLabel_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_yLabel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_colorLabel_unit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_colorLabel_unit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_yLabel_unit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_yLabel_unit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_yOffset_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_yOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel.
function channel_Callback(hObject, eventdata, handles)
BiofilmQ('channel_Callback', hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_plotType.
function popupmenu_plotType_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
if handles.handles_analysis.uicontrols.popupmenu.popupmenu_database.Value == 2 && hObject.Value ~= 2
    hObject.Value = 2;
    uiwait(msgbox('For global biofilm properties only XY-plots are possible!', 'Please note', 'help', 'modal'));
end

updateEnabledFields(hObject, eventdata, handles)
handles = guidata(hObject);
checkInputFields(hObject, eventdata, handles)

function updateEnabledFields(hObject, eventdata, handles)
switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType, 'Value')
    case 1
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_invert, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_binsY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'off');
        set(handles.handles_analysis.layout.uipanels.uipanel_heatmapOptions, 'Visible', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        handles.handles_analysis.flags.necessaryFields = [1, 2, 4];
        enableDisableChildren(handles.handles_analysis.layout.uipanels.panel_heatmapOptions, 'on');
    case 2
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_binsY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'on');
        set(handles.handles_analysis.layout.uipanels.uipanel_heatmapOptions, 'Visible', 'off');
        handles.handles_analysis.flags.necessaryFields = [1, 2];
        enableDisableChildren(handles.handles_analysis.layout.uipanels.panel_heatmapOptions, 'off');
        
    case 3
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_binsY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'off');
        set(handles.handles_analysis.layout.uipanels.uipanel_heatmapOptions, 'Visible', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        handles.handles_analysis.flags.necessaryFields = [1, 2];
        enableDisableChildren(handles.handles_analysis.layout.uipanels.panel_heatmapOptions, 'off');
        
    case 4
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_binsY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'off');
        set(handles.handles_analysis.layout.uipanels.uipanel_heatmapOptions, 'Visible', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_zaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'on');
        handles.handles_analysis.flags.necessaryFields = [1, 2, 3, 4];
        enableDisableChildren(handles.handles_analysis.layout.uipanels.panel_heatmapOptions, 'off');
     case 5
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_logY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_binsY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_yLabel, 'Enable', 'on', 'String', 'Counts');
        set(handles.handles_analysis.uicontrols.edit.edit_yLabel_unit, 'Enable', 'on', 'String', '');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Enable', 'on', 'Value', 5);
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'on');
        set(handles.handles_analysis.layout.uipanels.uipanel_heatmapOptions, 'Visible', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Enable', 'off');
        handles.handles_analysis.flags.necessaryFields = [1];
        enableDisableChildren(handles.handles_analysis.layout.uipanels.panel_heatmapOptions, 'off');
        
    case 6
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_binsX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_binsY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_yRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel_unit, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_xLabel, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Enable', 'on');
        set(handles.handles_analysis.layout.uipanels.uipanel_heatmapOptions, 'Visible', 'on');
        set(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_zaxis, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.edit.edit_zLabel_unit, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        handles.handles_analysis.flags.necessaryFields = [1, 2, 4];
        enableDisableChildren(handles.handles_analysis.layout.uipanels.panel_heatmapOptions, 'off');
end
guidata(hObject, handles);
checkbox_autoXRange_Callback(hObject, eventdata, handles)
checkbox_autoYRange_Callback(hObject, eventdata, handles)
checkbox_autoZRange_Callback(hObject, eventdata, handles)
checkbox_autoColorRange_Callback(hObject, eventdata, handles)
checkbox_returnTrueRangeX_Callback(hObject, eventdata, handles)
checkbox_returnTrueRangeY_Callback(hObject, eventdata, handles)
checkbox_returnTrueRangeZ_Callback(hObject, eventdata, handles)
checkbox_returnTrueRangeColor_Callback(hObject, eventdata, handles)
popupmenu_averaging_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)


% --- Executes during object creation, after setting all properties.
function popupmenu_plotType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_normalizeFactor_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_normalizeFactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_xLabel_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_xLabel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_xLabel_unit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_xLabel_unit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_kymograph_xaxis_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_kymograph_xaxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_autoXRange.
function checkbox_autoXRange_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'value')
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'on');
    else
        set(handles.handles_analysis.uicontrols.edit.edit_xRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off');
    end
end

function edit_xRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_xRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_returnTrueRange.
function checkbox_returnTrueRange_Callback(hObject, eventdata, handles)


% --- Executes on selection change in popupmenu_rangeMethodX.
function popupmenu_rangeMethodX_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_rangeMethodX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_binsXY_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_binsXY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_logX.
function checkbox_logX_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_logY.
function checkbox_logY_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_returnTrueRangeX.
function checkbox_returnTrueRangeX_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX, 'Value')
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'on')
    else
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Enable', 'off')
    end
end


% --- Executes on button press in checkbox_returnTrueRangeY.
function checkbox_returnTrueRangeY_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY, 'Value')
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'on')
    else
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY, 'Enable', 'off')
    end
end


% --- Executes on button press in checkbox_returnTrueRangeColor.
function checkbox_returnTrueRangeColor_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor, 'Value')
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'on')
    else
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor, 'Enable', 'off')
    end
end

% --- Executes on selection change in popupmenu_rangeMethodColor.
function popupmenu_rangeMethodColor_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_rangeMethodColor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_rangeMethodY.
function popupmenu_rangeMethodY_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_rangeMethodY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_fitCellNumber.
function checkbox_fitCellNumber_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_removeZOffset.
function checkbox_removeZOffset_Callback(hObject, eventdata, handles)


function edit_filterField_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_filterField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_savePlots.
function checkbox_savePlots_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_overwritePlots.
function checkbox_overwritePlots_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_errorbars.
function checkbox_errorbars_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_trackFeatures.
function pushbutton_trackFeatures_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
biofilmData = getLoadedBiofilmFromWorkspace;
t_max = numel(biofilmData.data);
% Generate array with all Track_IDs present in the loaded data
try
    allTracks  = [];
    for k = 1:t_max
        allTracks = [allTracks, [biofilmData.data(k).stats.Track_ID]];
    end
    allTrack_IDs = sort(unique(allTracks))';
    
    trackLength = [];
    for k = 1:allTrack_IDs(end)
        trackLength(k,1) = length(find(allTracks == k));
    end
catch
    uiwait(msgbox(sprintf('Cells were not tracked properly in all loaded frames! An error occurred obtaining the Track_IDs in frame %d.', k), 'Please note', 'warn', 'modal'));
    return;
end

% track info
if isfield(biofilmData.data(1).stats, 'Track_ID')
    minTrackLength = str2num(get(handles.handles_analysis.uicontrols.edit.edit_minTrackLength, 'String'));
    
    trackTable = [(1:numel(trackLength))', trackLength];
    
    validTracks = find(trackTable(:,2)>=minTrackLength);
    trackTable = trackTable(validTracks,:);
    
    set(handles.handles_analysis.uitables.uitable_tracks, 'Data', trackTable);
    set(handles.handles_analysis.uitables.uitable_tracks, 'ColumnName', {'track ID', 'track length [frames]'});
end
toggleBusyPointer(handles, false)


% --- Executes on button press in checkbox_clusterBiofilm.
function checkbox_clusterBiofilm_Callback(hObject, eventdata, handles)


function edit_scanRadius_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_scanRadius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_removeZOffsetHeatmapColumn.
function checkbox_removeZOffsetHeatmapColumn_Callback(hObject, eventdata, handles)


% --- Executes on button press in useRefTimepoint.
function useRefTimepoint_Callback(hObject, eventdata, handles)
if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    handles.handles_analysis.uicontrols.pushbutton.pushbutton_selectReferenceTimepoint.Enable = 'on';
    if isfield(handles.handles_analysis, 'refTimepointDir')
        directory = handles.handles_analysis.refTimepointDir;
    else
        directory = handles.settings.directory;
    end
    if ~isempty(directory)
        files = dir(fullfile(directory, '*_metadata.mat'));
        set(handles.handles_analysis.uicontrols.popupmenu.refTimepointFile, 'String', cellfun(@(x) fullfile(directory, x), {files.name}, 'UniformOutput', false), 'Enable', 'on', 'Value', 1);
    end
else
    set(handles.handles_analysis.uicontrols.popupmenu.refTimepointFile, 'String', ' ', 'Enable', 'off', 'Value', 1);
end


function refTimepointFile_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function refTimepointFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function context_popupmenu_refTimepoint_selectDir_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end
directory = uigetdir(directory, 'Please select directory containing metadata-files.');
if directory
    handles.handles_analysis.refTimepointDir = directory;
    guidata(hObject, handles);
    useRefTimepoint_Callback(hObject, eventdata, handles)
else
    disp('No folder selected');
    toggleBusyPointer(handles, false)
    return;
end
toggleBusyPointer(handles, false)


% --------------------------------------------------------------------
function context_popupmenu_refTimepoint_Callback(hObject, eventdata, handles)


% --- Executes on selection change in popupmenu_plotStyle.
function popupmenu_plotStyle_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_plotStyle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_applyCustom1.
function checkbox_applyCustom1_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_overlayBiofilmRadiusAsLine.
function checkbox_overlayBiofilmRadiusAsLine_Callback(hObject, eventdata, handles)


% --- Executes on button press in loadPixelIdxLists.
function loadPixelIdxLists_Callback(hObject, eventdata, handles)


function maxFrameToLoad_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function maxFrameToLoad_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadMaxFrame.
function loadMaxFrame_Callback(hObject, eventdata, handles)
if hObject.Value
    handles.handles_analysis.uicontrols.edit.maxFrameToLoad.Enable = 'on';
    handles.handles_analysis.uicontrols.edit.maxNCells.Enable = 'on';
    handles.handles_analysis.uicontrols.text.text_or.Enable = 'on';
    handles.handles_analysis.uicontrols.text.text_NCellsLoad.Enable = 'on';
else
    handles.handles_analysis.uicontrols.edit.maxFrameToLoad.Enable = 'off';
    handles.handles_analysis.uicontrols.edit.maxNCells.Enable = 'off';
    handles.handles_analysis.uicontrols.text.text_or.Enable = 'off';
    handles.handles_analysis.uicontrols.text.text_NCellsLoad.Enable = 'off';
end


function edit_custom1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_custom1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browseCustom1.
function pushbutton_browseCustom1_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_applyCustom2.
function checkbox_applyCustom2_Callback(hObject, eventdata, handles)


function edit_custom2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_custom2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browseCustom2.
function pushbutton_browseCustom_Callback(hObject, eventdata, handles, type)
toggleBusyPointer(handles, true)
if isdeployed
    path = fullfile(fullfile(fileparts(which('BiofilmQ')), '..', 'includes', 'biofilm analysis', 'custom scripts'), 'custom script.m');
else
    path = fullfile(fullfile(fileparts(which('BiofilmQ')), 'includes', 'biofilm analysis', 'custom scripts'), 'custom script.m');
end
[fname, directory] = uigetfile('*.m', 'Please select file with custom script', path);

if directory
    switch type
        case 1
            handles.handles_analysis.uicontrols.edit.edit_custom1.String = fullfile(directory, fname);
        case 2
            handles.handles_analysis.uicontrols.edit.edit_custom2.String = fullfile(directory, fname);
    end
end
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_selectReferenceTimepoint.
function pushbutton_selectReferenceTimepoint_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_loadData.
function pushbutton_loadData_Callback(hObject, eventdata, handles)


function maxNCells_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function maxNCells_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkInputFields(hObject, eventdata, handles)
enablePlotButton = true;

inputFieldEdits = {'edit_kymograph_xaxis', 'edit_kymograph_yaxis', 'edit_kymograph_zaxis', 'edit_kymograph_coloraxis'};
neededFields = handles.handles_analysis.flags.necessaryFields;

for i = 1:numel(inputFieldEdits)
    if strcmp(handles.handles_analysis.uicontrols.edit.(inputFieldEdits{i}).Enable, 'on')
        field = strtrim(handles.handles_analysis.uicontrols.edit.(inputFieldEdits{i}).String);
        
        if isempty(field)&& any(neededFields==i)
            enablePlotButton = false;
        end
        
        if i == 2 || i == 1
            fields = strtrim(strsplit(field, ','));
        else
            fields = {field};
        end
        
        databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
        databaseString = handles.settings.databases;
    
        if strcmp(databaseString{databaseValue}(1:5), 'stats')
            validFields = handles.settings.measurementFieldsAnalysis_singleCell;
        else
            validFields = handles.settings.measurementFieldsAnalysis_global;
        end        
         
        for f = 1:numel(fields)  
            if (isempty(fields{f}) || strcmp(fields{f}, '')) && ~any(neededFields == i)
                handles.handles_analysis.uicontrols.edit.(inputFieldEdits{i}).BackgroundColor = 'w';
            elseif ~sum(strcmp(validFields, fields{f}))
                enablePlotButton = false;
                handles.handles_analysis.uicontrols.edit.(inputFieldEdits{i}).BackgroundColor = [1 0.5 0.5];
                label = '';
                unit = '';
                range = [];
            else
                handles.handles_analysis.uicontrols.edit.(inputFieldEdits{i}).BackgroundColor = 'w';
                
                biofilmData = evalin('base', 'biofilmData');
                
                try
                    database_val = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
                    database = handles.settings.databases{database_val};
                    
                    [label, unit, range] = returnUnitLabel(field, biofilmData, database);
                end
            end
            try
                if strcmp(hObject.Tag, inputFieldEdits{i})
                    idx1 = strfind(hObject.Tag, '_');
                    idx2 = strfind(hObject.Tag, 'axis');
                    field_uicontrol = hObject.Tag(idx1(2)+1:idx2-1);
                    set(handles.handles_analysis.uicontrols.edit.(sprintf('edit_%sLabel', field_uicontrol)), 'string', label);
                    set(handles.handles_analysis.uicontrols.edit.(sprintf('edit_%sLabel_unit', field_uicontrol)), 'string', unit);
                    set(handles.handles_analysis.uicontrols.edit.(sprintf('edit_%sRange', field_uicontrol)), 'string', num2str(range, '%.2f %.2f'));
                end
            end
        end
    end
end

if enablePlotButton
    handles.handles_analysis.uicontrols.pushbutton.pushbutton_kymograph_plot.Enable = 'on';
else
    handles.handles_analysis.uicontrols.pushbutton.pushbutton_kymograph_plot.Enable = 'off';
end


function edit_zLabel_unit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_zLabel_unit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_zLabel_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_zLabel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_zRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_zRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_autoZRange.
function checkbox_autoZRange_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange, 'value')
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'on');
    else
        set(handles.handles_analysis.uicontrols.edit.edit_zRange, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off');
    end
end


% --- Executes on button press in pushbutton_addField_zaxis.
function pushbutton_addField_zaxis_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_kymograph_zaxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_returnTrueRangeZ.
function checkbox_returnTrueRangeZ_Callback(hObject, eventdata, handles)
if strcmp(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ.Enable, 'on')
    if get(handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ, 'Value')
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'on')
    else
        set(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ, 'Enable', 'off')
    end
end


% --- Executes on selection change in popupmenu_rangeMethodZ.
function popupmenu_rangeMethodZ_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_rangeMethodZ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_logZ.
function checkbox_logZ_Callback(hObject, eventdata, handles)


function edit_filterString_Callback(hObject, eventdata, handles)
filterString = get(hObject,'String'); 

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
    
if strcmp(databaseString{databaseValue}(1:5), 'stats')
    fields = handles.settings.measurementFieldsAnalysis_singleCell;
else
    fields = handles.settings.measurementFieldsAnalysis_globalReduced;
end

if ~isempty(filterString) && ~strcmp(filterString, '')
    containsFilter = @(x) any(strfind( lower(x), lower(filterString)));
    keepFields = cellfun(containsFilter, fields);
    fields = fields(keepFields);
end
set(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'Value', 1);
set(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String', fields);


% --- Executes during object creation, after setting all properties.
function edit_filterString_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_addPlotToCurrentFigure.
function checkbox_addPlotToCurrentFigure_Callback(hObject, eventdata, handles)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_filterString.
function edit_filterString_ButtonDownFcn(hObject, eventdata, handles)
edit_filterString_Callback(hObject, eventdata, handles)


function edit_filterString_Type(hObject, eventdata, handles)
edit_filterString_Callback(hObject, eventdata, handles);


% --- Executes on key press with focus on edit_filterString and none of its controls.
function edit_filterString_KeyPressFcn(hObject, eventdata, handles)
edit_filterString_Callback(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_filterHelp.
function pushbutton_filterHelp_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/visualization.html#filtering');
