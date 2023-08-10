function clickAnalysisTable(hObject, eventdata, handles)

% handles are not the most recent version here (only use it to get handles to
% controls!)

% Get most recent handles
handles = guidata(handles.mainFig);

BiofilmQ('analysis_files_CellSelectionCallback', hObject, eventdata, handles);