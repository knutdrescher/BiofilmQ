function handles = enable_trajectory_analysis(handles)
%% Add elements to GUI
handles.handles_analysis = populateTabs(handles.handles_analysis, 'uipanel_trackAnalysis','analysisTabs');
handles = replaceUIPanel(handles, 'uipanel_trackAnalysis');


padding = handles.settings.padding;
spacing = handles.settings.spacing;
objectHeight = handles.settings.objectHeight;

h1_1_1 = handles.handles_analysis.layout.tabs.plotting.findobj('Tag', 'listbox_fieldNames').Parent;
h_button = uix.HButtonBox('Parent', h1_1_1, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [250 objectHeight]);

handles.handles_analysis.uicontrols.pushbutton.pushbutton_calculateAlongLineage = ...
    uicontrol( ...
    'Parent', h_button, ...
    'Tag', 'pushbutton_calculateAlongLineage', ...
    'Style', 'pushbutton', ...
    'String', 'Smooth selected parameter along lineage', ...
    'Callback', @(hObject,eventdata)pushbutton_calculateAlongLineage_Callback(hObject,eventdata,guidata(hObject)) ...
    );
        
h1_1_1.Heights = 0.85*[objectHeight, -1 objectHeight];