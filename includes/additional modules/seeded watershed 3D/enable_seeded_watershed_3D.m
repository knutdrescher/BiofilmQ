function handles = enable_seeded_watershed_3D(handles)

padding = handles.settings.padding;
spacing = handles.settings.spacing;
objectHeight = handles.settings.objectHeight;

handles.uicontrols.popupmenu.declumpingMethod.String{4} = 'seeded 3D Watershed';

handles = seeded_watershed_box_panel(handles);

handles.layout.uipanels.uipanel_workflow_segmentation_seededWatershed.Parent = ...
    handles.layout.boxes.declumping;

assert(isempty(handles.layout.boxes.declumping.Children(2).Children));

% Reorder new panel and and empty space
heights = handles.layout.boxes.declumping.Heights;

handles.layout.boxes.declumping.Children([1, 2]) = ...
    handles.layout.boxes.declumping.Children([2, 1]);

heights([1, 2]) = heights([2, 1]);

handles.layout.boxes.declumping.Heights = heights;


handles.layout.boxes.declumping.Heights(3) = 3*objectHeight+2*padding+2*spacing;


end

