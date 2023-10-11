function createVisualization(hObject, eventdata, handles)
ticValueAll = displayTime;
range = str2num(get(handles.uicontrols.edit.action_imageRange, 'String'));

% Load parameters
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

if ~isempty(params.cellParametersStoreVTK)
    custom_fields_objects = params.cellParametersStoreVTK(:,1);
    selected = [params.cellParametersStoreVTK{:,2}];
    custom_fields_objects = custom_fields_objects(selected);

    custom_fields_objects = setdiff(custom_fields_objects, {'Centroid', 'BoundingBox', 'Cube_CenterCoord', 'Orientation_Matrix', 'Timepoint'});
else
    if handles.settings.showMsgs
        uiwait(msgbox('Only segmented files can be exported. Please select a segmented file.', 'Please note', 'help', 'modal'));
    else
        warning('Only segmented files can be exported. File will not be exported.');
    end
    return;  
end

if isempty(custom_fields_objects)
    uiwait(msgbox('Please select a valid parameter for export!', 'Please note', 'help', 'modal'));
    return;
end


disp(['=========== Creating visualization files ===========']);

if params.reducePolygons
    resolution = params.reducePolygonsTo;
else
    resolution = 1;
end

files = handles.settings.lists.files_cells;

if isempty(files(1).name)
    uiwait(msgbox('No segmented images found.', 'Please note', 'warn', 'modal'));
    return; 
end

fileRange = find(cellfun(@isempty, strfind({files.name}, 'missing')));

range_new = intersect(range, fileRange);

range_new = assembleImageRange(range_new);

if numel(range) ~= numel(str2num(range_new))
    warning('off','backtrace')
    warning('Image range was adapted to [%s]', range_new);
    warning('on','backtrace')
end
range = str2num(range_new);

enableCancelButton(handles);

for f = range
    % Select row in file table
    try
        handles.java.files_jtable.changeSelection(f-1, 0, false, false);
    end
    
    ticValueImage = displayTime;
    disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    % Update waitbar
    updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1)));
    
    % Load Image
    displayStatus(handles,['Creating visualization for cells ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    
    filename = fullfile(handles.settings.directory, 'data', files(f).name);
    objects = loadObjects(filename);
    
    w_mask_label = labelmatrix(objects);

    
    % Update waitbar
    displayStatus(handles, 'creating isosurfaces...', 'blue', 'add');
    updateWaitbar(handles, (f+0.3-range(1))/(1+range(end)-range(1)));
    
    % 3D Labelling
    if isfield(objects, 'isSimulation')
        isSimulation = objects.isSimulation;
    else
        isSimulation = false;
    end
    
    if isSimulation
        cells = isosurfaceLabelSim(objects, resolution, custom_fields_objects, params);
    else
        if isfield(params, 'ellipseRepresentation') && params.ellipseRepresentation
            cells = isosurfaceLabel(w_mask_label, objects, resolution, custom_fields_objects, params, 1);
        else
            cells = isosurfaceLabel(w_mask_label, objects, resolution, custom_fields_objects, params);
        end
    end
    
    % Writing vtk-file
    % Update waitbar
    displayStatus(handles, 'saving vtk-file...', 'blue', 'add');
    updateWaitbar(handles, (f+0.6-range(1))/(1+range(end)-range(1)));
    ticValue = displayTime;
    
    index = strfind(files(f).name(1:end-4), 'Nz');
    if isempty(index)
        index = strfind(files(f).name(1:end-4), '_data');
    end
    
    custom_fields = fieldnames(cells);
    fprintf(' - saving vtk-file');
    
    if params.visualization_rotation
        rot = sprintf('rot%d_%d_', params.visualization_rotation, params.visualization_rotation_axis);
    else
        rot = '';
    end
    
    if params.forceVTKSeries
        filenameVTK = [rot, 'frame_',num2str(f, '%06d'), '.vtk'];
    else
        filenameVTK = [rot, files(f).name(1:index-2), '.vtk'];
    end
    
    switch params.outputFormat3D
        case 1
            mvtk_write(cells,fullfile(handles.settings.directory, 'data', filenameVTK), 'legacy-binary', custom_fields(3:end));
        case 2
            stlwrite(fullfile(handles.settings.directory, 'data', [filenameVTK(1:end-4), '.stl']), cells.faces, cells.vertices);
    end
    
        
    % Prepare foci
    fnames = fieldnames(objects.stats);
    if sum(cellfun(@(x) ~isempty(x), strfind(lower(fnames), 'foci')))
        possibleFoci = find(cellfun(@(x) ~isempty(x), strfind(fnames, 'Foci_Idx')));
        for i = 1:numel(possibleFoci)
            foci_idx = vertcat(objects.stats.(fnames{possibleFoci(i)}));
            foci_intensity = vertcat(objects.stats.(strrep(fnames{possibleFoci(i)}, 'Idx', 'Intensity')));
            foci_quality = vertcat(objects.stats.(strrep(fnames{possibleFoci(i)}, 'Idx', 'Quality')));
            
            [Y, X, Z] = ind2sub(objects.ImageSize, foci_idx);
            foci = struct('vertices',[X Y Z], 'Foci_Intensity',foci_intensity);

            mvtk_write(foci, fullfile(handles.settings.directory, 'data', [filenameVTK(1:end-4), '_',fnames{possibleFoci(i)},'.vtk']) , 'legacy-binary', {'Foci_Intensity'});

        end
    end
    
    displayTime(ticValue);
    
    displayStatus(handles, 'Done', 'blue', 'add');
    
    fprintf('-> total elapsed time per image')
    displayTime(ticValueImage);
    
    if checkCancelButton(handles)
        return;
    end
end

if params.sendEmail
    email_to = get(handles.uicontrols.edit.email_to, 'String');
    email_from = get(handles.uicontrols.edit.email_from, 'String');
    email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
    
    setpref('Internet','E_mail',email_from);
    setpref('Internet','SMTP_Server',email_smtp);
    
    sendmail(email_to,['[Biofilm Toolbox] Cell visualization finished: "', handles.settings.directory, '"']', ...
        ['Cell visualization of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
end

updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);
