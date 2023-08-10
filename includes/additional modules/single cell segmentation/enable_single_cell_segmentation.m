function handles = enable_single_cell_segmentation(handles)

handles = enable_single_cell_properties(handles);

handles = enable_seeded_watershed_3D(handles);

% Enable foci measurements
handles.uicontrols.popupmenu.intensity_task.String{end+1} = 'Number of fluorescence foci';
handles.uicontrols.popupmenu.segmentationMethod.String = {'Thresholding', 'Edge detection', 'Label image'};
handles.uicontrols.popupmenu.declumpingMethod.String{3} = 'Watershedding';


% %% Add elements to GUI
padding = handles.settings.padding;
spacing = handles.settings.spacing;
objectHeight = handles.settings.objectHeight;

handles = watershed_box_panel(handles);

handles.layout.uipanels.panel_declumpingOptions.Parent = ...
    handles.layout.boxes.declumping;

% Reorder new panel and and empty space
assert(isempty(handles.layout.boxes.declumping.Children(2).Children));

% reordering messes up the heights!
heights = handles.layout.boxes.declumping.Heights;

handles.layout.boxes.declumping.Children([1, 2]) = ...
    handles.layout.boxes.declumping.Children([2, 1]);

heights([1, 2]) = heights([2, 1]);

handles.layout.boxes.declumping.Heights = heights;

handles.layout.boxes.declumping.Heights(4) =  6*objectHeight+2*padding+6*spacing;


handles.layout.boxes.segmentationMethod.Heights = [objectHeight, -1, objectHeight, -1];
handles.layout.boxes.segmentation.Heights = [170, -1];

% modify menu bar
handles.menuHandles.menues.menu_process_all_select_cellParams.Text = ...
    'Calculate cell parameters';

