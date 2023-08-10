function handles = deleteEmptyPanels(handles)

panelNames = fieldnames(handles.layout.uipanels);
validHandles = structfun(@isvalid, [handles.layout.uipanels]);
handles.layout.uipanels = rmfield(handles.layout.uipanels, panelNames(~validHandles));

panelNames = fieldnames(handles.handles_analysis.layout.uipanels);
validHandles = structfun(@isvalid, [handles.handles_analysis.layout.uipanels]);
handles.handles_analysis.layout.uipanels = rmfield(handles.handles_analysis.layout.uipanels, panelNames(~validHandles));

