function handles = enable_thresholding_by_slice(handles)

% Design panel
handles = thresholding_slice_panel(handles);

% Populate tab
handles = populateTabs(handles, 'uipanel_workflow_segmentation_thresholdBySlice','workflow_segmentationTabs');

% make entity parent to VBox
handles.layout.uipanels.uipanel_workflow_segmentation_thresholdBySlice.Children.Parent = ...
    handles.layout.uipanels.uipanel_workflow_segmentation_thresholdBySlice.Parent;

% add Thresholding by slice to segmentation menu
handles.uicontrols.popupmenu.segmentationMethod.String = {'Thresholding', 'Edge detection',  'Label image', 'Thresholding by Slice'};

% delete obsolete panel
delete(handles.layout.uipanels.uipanel_workflow_segmentation_thresholdBySlice);

