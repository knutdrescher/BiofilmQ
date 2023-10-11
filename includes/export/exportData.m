function exportData(hObject, eventdata, handles, type)
ticValueAll = displayTime;

range = str2num(get(handles.uicontrols.edit.action_imageRange, 'String'));

% Load parameters
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

custom_fields_objects = params.cellParametersStoreVTK(:,1);
selected = [params.cellParametersStoreVTK{:,2}];
custom_fields_objects = custom_fields_objects(selected);

if isempty(custom_fields_objects)
    uiwait(msgbox('Please select a parameter for export!', 'Please note', 'help', 'modal'));
    return;
end



sprintf('=========== Exporting to %s ===========', upper(type));


files = handles.settings.lists.files_cells;

fileRange = find(cellfun(@isempty, strfind({files.name}, 'missing')));

range_new = intersect(range, fileRange);

range_new = assembleImageRange(range_new);

if numel(range) ~= numel(str2num(range_new))
    warning('off','backtrace')
    warning('Image range was adapted to [%s]', range_new);
    warning('on','backtrace')
end
range = str2num(range_new);
globalParamsCsv = {};
globalParamsNames = {'Filename'};

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
    displayStatus(handles,['Exporting data for file', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    
    filename = fullfile(handles.settings.directory, 'data', files(f).name);
    objects = loadObjects(filename, {'stats', 'globalMeasurements', 'metadata'});
    
    % Update waitbar
    displayStatus(handles, ['saving ',lower(type),'-file...'], 'blue', 'add');
    updateWaitbar(handles, (f+0.6-range(1))/(1+range(end)-range(1)));
    
    index = strfind(files(f).name(1:end-4), 'Nz');

    fprintf(' - saving %s-file', lower(type));
    
    if params.forceVTKSeries
        filename = ['frame_',num2str(f, '%06d'), '.', lower(type)];
    else
        filename = [files(f).name(1:index-2), '.', lower(type)];
    end
    
    switch lower(type)
        case 'fcs'
            handles = exportFCS(handles, objects, params, custom_fields_objects, filename);
        case 'csv'
            [~, globalParamsCsvTemp] = writeCSV(handles, objects, custom_fields_objects, params, filename);
            if ~isempty(globalParamsCsvTemp)
                globalParamsNamesTemp = globalParamsCsvTemp(2,:);
                globalParamsNames_new = unique([globalParamsNames, globalParamsNamesTemp], 'stable');
                globalParamsCsv_new = globalParamsNames_new;
    
                if ~isempty(globalParamsCsv)
                    inds_old = cellfun(@(x) find(cellfun(@(y) strcmp(x,y), globalParamsNames)), globalParamsNames_new, 'UniformOutput',false);
                    notFound = cellfun(@isempty, inds_old);
                    globalParamsCsv_new(2,~notFound)= globalParamsCsv(2,cell2mat(inds_old(~notFound)));
                    globalParamsCsv_new(3:size(globalParamsCsv,1), ~notFound) = globalParamsCsv(3:end,cell2mat(inds_old(~notFound)));
                end
                inds_new = cellfun(@(x) find(cellfun(@(y) strcmp(x,y), globalParamsNamesTemp)), globalParamsNames_new, 'UniformOutput',false);
                notFound = cellfun(@isempty, inds_new);
                globalParamsCsv_new(2,~notFound)= globalParamsCsvTemp(3,cell2mat(inds_new(~notFound)));
                globalParamsCsv_new(end+1,1) = globalParamsCsvTemp(1,1);
                globalParamsCsv_new(end, ~notFound) = globalParamsCsvTemp(4,cell2mat(inds_new(~notFound)));
    
                globalParamsCsv = globalParamsCsv_new;
                globalParamsNames = globalParamsNames_new;
            end
    end
    
    displayStatus(handles, 'Done', 'blue', 'add');
    
    fprintf('-> total elapsed time per image')
    displayTime(ticValueImage);
    
    if checkCancelButton(handles)
        return;
    end
end

if strcmpi(type, 'csv')
    filename_save = fullfile(handles.settings.directory, 'data', 'txt_output', ['Summary_global_variables_files_', num2str(min(range)), '_to_', num2str(max(range)), '.csv']);
    fprintf('    - writing "%s"\n', filename_save)
    try
        cell2csv(filename_save, globalParamsCsv)
    catch
        uiwait(msgbox(sprintf('Cannot write file "%s"! Is the file already in use?',filename_save), 'Error', 'error', 'modal'));
    end
end

% Reset FCS message (used in exportFCS.m)
if isfield(handles.settings, 'showedFCSError')
    handles.settings.showedFCSError = false;
end

if params.sendEmail
    email_to = get(handles.uicontrols.edit.email_to, 'String');
    email_from = get(handles.uicontrols.edit.email_from, 'String');
    email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
    
    setpref('Internet','E_mail',email_from);
    setpref('Internet','SMTP_Server',email_smtp);
    
    sendmail(email_to,[sprintf('[Biofilm Toolbox] %s export finished: "', upper(type)), handles.settings.directory, '"']', ...
        [sprintf('%s export finished of "', upper(type)), handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
end

updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);
