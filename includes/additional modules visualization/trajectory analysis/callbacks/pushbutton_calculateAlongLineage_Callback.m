% --- Executes on button press in pushbutton_calculateAlongLineage.
function pushbutton_calculateAlongLineage_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
fieldNameValue = get(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'Value');
fieldNameString = get(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String');
fieldName = fieldNameString{fieldNameValue};
biofilmData = getLoadedBiofilmFromWorkspace;

range = str2num(handles.uicontrols.edit.visualization_imageRange.String);
biofilmData.data = biofilmData.data(range);

%% Handle time intervals correctly
timepoints = biofilmData.timepoints;
timepoints = timepoints(range);
timeIntervals = [timepoints(1); diff(timepoints)];

% Note: use end-1 to find Track_ID with length > 1 <=> has to exist before
% final timeframe
validTracks = 1:max([biofilmData.data(end-1).stats.Track_ID]);

[parameterTree, nodes] = createNodes(handles, biofilmData, timeIntervals, validTracks);

smoothParameter(handles, biofilmData, nodes, parameterTree, fieldName);
handles = biofilmInfo(hObject, eventdata, handles);

biofilmAnalysis('updateListboxFieldNames', handles);
guidata(hObject, handles);  

@(hObject,eventdata)BiofilmQ('analysis_files_CellSelectionCallback', hObject, eventdata, guidata(hObject));
toggleBusyPointer(handles, false)