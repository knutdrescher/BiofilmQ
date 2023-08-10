function handles = enable_image_series_curation(handles)

%% Add elements to GUI
padding = handles.settings.padding;
spacing = handles.settings.spacing;
objectHeight = handles.settings.objectHeight;

handles.layout.boxes.imageSeriesCuration.Heights = [100+objectHeight+2*spacing+4*padding, 100+objectHeight+2*spacing+4*padding, -1];