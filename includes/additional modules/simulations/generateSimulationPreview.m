function generateSimulationPreview(hObject, eventdata, handles)
try
    file = eventdata.Indices(1);
catch
    return;
end

files = handles.settings.lists;
fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');

field = 'files_sim';

handles.axes.axes_preview.Parent = handles.layout.boxes.axes_preview_container;

try
    txt_data = readtable_fast(fullfile(handles.settings.directory, files.(field)(file).name));
    
    centroids = [txt_data.Centroid_1, txt_data.Centroid_2, txt_data.Centroid_3];
    
    vec = [txt_data.DirVector1_1 txt_data.DirVector1_2 txt_data.DirVector1_3];
    
    lengths = txt_data.SemiAxis1;
    
    delete(handles.axes.axes_preview.Children);
    handles.axes.axes_preview.NextPlot = 'add';
    for i = 1:size(centroids, 1)
        X = [centroids(i,:)-vec(i,:)*lengths(i); centroids(i,:)+vec(i,:)*lengths(i)];
        plot3(handles.axes.axes_preview, X(:,1), X(:,2), X(:,3), 'LineWidth', 2);
    end
    
    axis(handles.axes.axes_preview, 'off', 'equal');
    view(handles.axes.axes_preview, 45, 60)
    
catch err
    if fileType == 6
        if handles.settings.showMsgs
            try
                uiwait(msgbox(sprintf('Could not read simulation data for for file "%s"! Error: %s.', files.(field)(file).name, err.message), 'Warning', 'warn', 'modal'));
            end
        else
            warning('Could not read simulation data for for file "%s"! Error: %s.', files.(field)(file).name, err.message);
        end
    end
end