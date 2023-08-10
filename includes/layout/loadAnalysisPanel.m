function handles = loadAnalysisPanel(handles)

loadedContent = biofilmAnalysis('Visible', 'off');

handles_analysis = guidata(loadedContent);

handles_analysis.layout.tabs.analysisTabs = uitabgroup('Parent', handles_analysis.layout.uipanels.uipanel_biofilmAnalysis,  'TabLocation', 'top', 'units', 'characters', 'Position', get(handles_analysis.layout.uipanels.uipanel_analysisContent, 'Position'));
delete(handles_analysis.layout.uipanels.uipanel_analysisContent)

handles_analysis = populateTabs(handles_analysis, 'uipanel_plotting','analysisTabs');
handles.handles_analysis = handles_analysis;


handles.layout.uipanels.uipanel_analysis_analysisTabs.Units = 'normalized';
handles = restylePanel(handles, handles_analysis.layout.uipanels.uipanel_biofilmAnalysis, [0.7490 0.902 1], handles.layout.tabs.visualization, handles.layout.uipanels.uipanel_analysis_analysisTabs.Position);
delete(handles.layout.uipanels.uipanel_analysis_analysisTabs);

handles.handles_analysis = handles_analysis;

handles = replaceUIPanel(handles, 'uipanel_biofilmAnalysis');
handles = replaceUIPanel(handles, 'uipanel_plotting');
handles = loadAdditionalModules_Visualization(handles);



delete(loadedContent);