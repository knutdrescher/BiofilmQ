function handles = analyzeDirectory(hObject, eventdata, handles)
set(handles.uicontrols.edit.cropRange, 'String', '');
set(handles.uicontrols.edit.registrationReferenceCropping, 'String', '');
set(handles.uicontrols.edit.registrationReferenceFrame, 'String', '1');

directory = get(handles.uicontrols.edit.inputFolder, 'String');

if isempty(directory) || ~isfolder(directory)
    uiwait(msgbox('No experiment folder selected.', 'Please note', 'help', 'modal'));
    displayStatus(handles, 'No folder selected!', 'red', 'add');
    return;
end

enableCancelButton(handles);
drawnow;

handles.settings.directory = directory;

testStruct = dir('test');
if isfield(testStruct, 'folder')
    init = struct('name', [], 'date', [], 'folder', [], 'bytes', [], 'isdir', [], 'datenum', []);
else
    init = struct('name', [], 'date', [], 'bytes', [], 'isdir', [], 'datenum', []);
end

lists.files_nd2 = init;
lists.files_tif = init;
lists.files_metadata = init;
lists.files_mask = init;
lists.files_cells = init;
lists.files_vtk = init;

% Check for nd2-files
lists.files_nd2 = dir(fullfile(directory, '*.nd2'));
otherFormats = dir(fullfile(directory, '*.czi'));
lists.files_nd2(end+1:end+numel(otherFormats)) = otherFormats;
otherFormats = dir(fullfile(directory, '*.lsm'));
lists.files_nd2(end+1:end+numel(otherFormats)) = otherFormats;
otherFormats = dir(fullfile(directory, '*.lif'));
lists.files_nd2(end+1:end+numel(otherFormats)) = otherFormats;
otherFormats = dir(fullfile(directory, '*.tiff'));
lists.files_nd2(end+1:end+numel(otherFormats)) = otherFormats;

filesNum(1) = length(lists.files_nd2);
lists.files_tif = dir(fullfile(directory, '*Nz*.tif'));
if ~isfield(lists.files_tif, 'folder')
    folder = repmat({directory}, numel(lists.files_tif), 1);
    if ~isempty(folder)
        [lists.files_tif.folder] = folder{:};
    end
end
filesNum(2) = length(lists.files_tif);

filesNum(3) = 0;
for i = 1:length(lists.files_tif)
    file = dir(fullfile(directory, [lists.files_tif(i).name(1:end-4), '_metadata.mat']));
    if ~isempty(file)
        lists.files_metadata(i) = file;
        filesNum(3) = filesNum(3) + 1;
    else
        lists.files_metadata(i).name = 'missing';
    end
end

if filesNum(2) ~= filesNum(3)
    uiwait(msgbox({'The directory is not valid!', '', '1. Make sure that the number of image stacks and metadata files is identical!', '2. Make sure that the same number of image stacks and metadata files exist for all fluorescence channels!'}, 'Error', 'error', 'modal'));
    handles.settings.metadataTable = [];
    handles.uitables.files.Data = {'Directory is not valid.'};
    return;
end
% Check for parameter-file
%if isdir(fullfile(directory, 'data'))


if isdir(fullfile(directory, 'data')) && ~isempty(dir(fullfile(directory, 'data', '*_data.mat')))
    handles.settings.dataFolder = 1;
    
    filesNum(4) = 0;
    filesNum(5) = 0;
    filesNum(6) = 0;
    
    filesAllCells = dir(fullfile(directory, 'data', '*.mat'));
    zeroEntry = num2cell(zeros(length(filesAllCells),1));
    try
        [filesAllCells.included] = zeroEntry{:};
    catch
        filesAllCells(1).included = [];
    end
    filesAllVTKs = dir(fullfile(directory, 'data', '*.vtk'));
    zeroEntry = num2cell(zeros(length(filesAllVTKs),1));
    try
        [filesAllVTKs.included] = zeroEntry{:};
    catch
        filesAllVTKs(1).included = [];
    end
    
    for i = 1:length(lists.files_tif)
        
        ch = strfind(lists.files_tif(i).name, '_ch');
            if ~isempty(ch)
                ch = lists.files_tif(i).name(ch:ch+3);
            else
                ch = '';
            end
            
        file = dir(fullfile(directory, 'data', [lists.files_tif(i).name(1:end-4), '_mask.tif']));
        if ~isempty(file)
            lists.files_mask(i) = file;
            filesNum(4) = filesNum(4) + 1;
        else
            lists.files_mask(i).name = ['missing', ch];
            lists.files_mask(i).date = datetime;
            lists.files_mask(i).bytes = 0;
            lists.files_mask(i).isdir = false;
            lists.files_mask(i).datenum = 0;
        end
        
        file = dir(fullfile(directory, 'data', [lists.files_tif(i).name(1:end-4), '_data.mat']));
        if ~isempty(file)
            lists.files_cells(i) = file;
            ind = find(strcmp(file.name, {filesAllCells.name}));
            if ~isempty(ind)
                filesAllCells(ind).included = 1;
            end
            filesNum(5) = filesNum(5) + 1;
        else
            lists.files_cells(i).name = ['missing', ch];
            lists.files_cells(i).date = datetime;
            lists.files_cells(i).bytes = 0;
            lists.files_cells(i).isdir = false;
            lists.files_cells(i).datenum = 0;
        end
        
        filebase_vtk_ind = strfind(lists.files_tif(i).name, '_Nz');
        filebase_vtk = lists.files_tif(i).name(1:filebase_vtk_ind-1);
        file = dir(fullfile(directory, 'data', [filebase_vtk, '.vtk']));
        
        if ~isempty(file)
            lists.files_vtk(i) = file;
            
            ind = find(strcmp(file.name, {filesAllVTKs.name}));
            if ~isempty(ind)
                filesAllVTKs(ind).included = 1;
            end
            filesNum(6) = filesNum(6) + 1;
        else
            lists.files_vtk(i).name = ['missing', ch];
            lists.files_vtk(i).date = datetime;
            lists.files_vtk(i).bytes = 0;
            lists.files_vtk(i).isdir = false;
            lists.files_vtk(i).datenum = 0;
        end
        
        if checkCancelButton(handles)
            return;
        end
    end
    
    remainingCells = find([filesAllCells.included] == 0);
    filesAllCells = rmfield(filesAllCells, 'included');
    if ~isempty(remainingCells)
        for i = 1:length(remainingCells)
            lists.files_cells(end+1) = filesAllCells(remainingCells(i));
            filesNum(5) = filesNum(5) + 1;
        end
    end
    
    remainingVTKs = find([filesAllVTKs.included] == 0);
    filesAllVTKs = rmfield(filesAllVTKs, 'included');
    if ~isempty(remainingVTKs)
        for i = 1:length(remainingVTKs)
            lists.files_vtk(end+1) = filesAllVTKs(remainingVTKs(i));
            filesNum(6) = filesNum(6) + 1;
        end
    end
    %lists.files_mask = dir(fullfile(directory, 'data', '*mask.tif'));
    %filesNum(4) = length(lists.files_mask);
    %lists.files_cells = dir(fullfile(directory, 'data', '*data.mat'));
    %filesNum(5) = length(lists.files_cells);
    %lists.files_vtk = dir(fullfile(directory, 'data', '*.vtk'));
    %filesNum(6) = length(lists.files_vtk);
end



% Update edits
if exist(fullfile(directory, 'parameters.mat'), 'file')
    params = load(fullfile(directory, 'parameters.mat'));
    try
        params = params.params;
    end
else
    %set(handles.uicontrols.edit.I_base, 'String', '0');
    %set(handles.uicontrols.edit.cropRange, 'String', '');
    params = [];
    params.action_imageRange = ['1:',num2str(numel(lists.files_tif))];
end
%end

listsAll = lists;

% Select channel
if ~isempty(lists.files_tif)
    ch = [];
    ch_ind = strfind(lists.files_tif(1).name, '_ch');
    if ~isempty(ch_ind)
        for i = 1:filesNum(2)
            ch_ind = strfind(lists.files_tif(i).name, '_ch');
            ch{i} = lists.files_tif(i).name(ch_ind+3);
        end
        channels = unique(ch);
        
        if isfield(params, 'channel')
            s = params.channel;
        else
            if numel(channels) > 1
                [s,v] = listdlg('PromptString','Select the channel containing the primary cell signal',...
                    'SelectionMode','single',...
                    'ListString',channels, 'ListSize', [300 50]);
                if ~v
                    return;
                end
            else
                s = 1;
            end
        end
        
        if sum(cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(x, 'Nz1.tif'), {lists.files_tif.name}, 'UniformOutput', false)))
            uiwait(msgbox('This directory is containing 2D images (stacks with only one single plane, Nz=1). This toolbox is not designed to support these files. While processing them, 5 identical slices are padded along z to obtain 3D image(s).', 'Warning', 'warn'));
        end
        
        params.ch = s;
        set(handles.uicontrols.popupmenu.intensity_ch, 'String', channels, 'value', s);
        set(handles.uicontrols.text.text_channelDescription, 'String', ['and ', num2str(s)]);
        
        for s2 = 1:length(channels)
            if s2 ~= str2num(channels{s})
                
                cellParameters = get(handles.uitables.cellParametersCalculate, 'Data');
                try
                    cellParameters{end, 3} = ['ch', channels{s2}];
                catch
                    cellParameters{end, 3} = '';
                end
                set(handles.uitables.cellParametersCalculate, 'Data', cellParameters);
                
                
                
                fileLists = fieldnames(lists);
                try
                    if strcmp(fileLists{1}, 'files_nd2')
                        fileLists(1) = [];
                    end
                end
                
                
                for i = 1:length(fileLists)
                    fileList = lists.(fileLists{i});
                    toDelete = [];
                    
                    for j = 1:length(fileList)
                        if isempty(strfind(fileList(j).name, ['ch', num2str(s)]))
                            toDelete(end+1) = j;
                            try
                                filesNum(i) = filesNum(i)-1;
                            end
                        end
                    end
                    fileList(toDelete) = [];
                    
                    lists.(fileLists{i}) = fileList;
                end
                
            end
        end
        
        
        
        set(handles.uicontrols.popupmenu.channel, 'String', channels, 'Value', s, 'Enable', 'on');
        set(handles.uicontrols.popupmenu.channel_seg, 'String', channels, 'Value', s, 'Enable', 'on');
    else
        set(handles.uicontrols.popupmenu.channel, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
        set(handles.uicontrols.popupmenu.channel_seg, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
    end
    
else
    set(handles.uicontrols.popupmenu.channel, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
    set(handles.uicontrols.popupmenu.channel_seg, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
end

if checkCancelButton(handles)
    return;
end

if length(filesNum) == 3
    lists.files_mask = [];
    lists.files_cells = [];
    lists.files_vtk = [];
end

handles.settings.lists = lists;
handles.settings.listsAll = listsAll;

popupmenu_fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'String');
for i = 1:length(popupmenu_fileType)
    space_index = strfind(popupmenu_fileType{i}, ' ');
    if isempty(space_index)
        space_index = length(popupmenu_fileType{i});
    end
    
    try
        switch i
            case 1
                nFiles = length(lists.files_nd2);
            case 2
                nFiles = length(lists.files_tif);
            case 3
                nFiles = length(lists.files_metadata);
                filesMissing = strfind({lists.files_metadata.name}, 'missing');
                nFiles = nFiles - sum([filesMissing{:}]);
            case 4
                nFiles = length(lists.files_cells);
                filesMissing = strfind({lists.files_cells.name}, 'missing');
                nFiles = nFiles - sum([filesMissing{:}]);
            case 5
                nFiles = length(lists.files_vtk);
                filesMissing = strfind({lists.files_vtk.name}, 'missing');
                nFiles = nFiles - sum([filesMissing{:}]);
        end
        popupmenu_fileType{i} = [popupmenu_fileType{i}(1:space_index), ' (',num2str(nFiles) ,' files)'];
    catch
        popupmenu_fileType{i} = [popupmenu_fileType{i}(1:space_index), ' (0 files)'];
    end
end

set(handles.uicontrols.popupmenu.popupmenu_fileType, 'String', popupmenu_fileType);

if max(filesNum)>0
    % do nothing
else
    uiwait(msgbox('No files found.', 'Please note', 'warn', 'modal'));
end



% Generate Metadata-list

times = cell(filesNum(2),1);
timesDur = cell(filesNum(2),1);
dates = cell(filesNum(2),1);
registrations = false(filesNum(2),1);
cells = false(filesNum(2),1);
vtks = false(filesNum(2),1);

% Store global metadata information
metadataGlobal = cell(filesNum(2), 1);
metadataFiles = dir(fullfile(handles.settings.directory,'*_metadata.mat'));
numMetadataFiles = numel(metadataFiles);
dateMetadataFiles = max([metadataFiles.datenum]);
usePreviousMetadata = false;

metadataGlobalFilename = fullfile(handles.settings.directory, 'metadata_global.mat');

if ~isempty(metadataFiles)
    if exist(metadataGlobalFilename, 'file')
        dateMetadataFiles_prev = load(metadataGlobalFilename, 'sizeMetadataFiles');
        
        if isfield(dateMetadataFiles_prev, 'dateMetadataFiles')
            if dateMetadataFiles_prev.dateMetadataFiles == dateMetadataFiles
                % Load previous metadata
                usePreviousMetadata = true;
                metadataGlobal = load(metadataGlobalFilename, 'metadataGlobal');
                metadataGlobal = metadataGlobal.metadataGlobal;
                
                handles.settings.metadataGlobal = metadataGlobal;
            end
        end
    end
end

if filesNum(2)
    for i = 1:filesNum(2)
        file_base = lists.files_tif(i).name(1:end-4);
        
        if ~usePreviousMetadata
            metadata_file = dir(fullfile(handles.settings.directory, [file_base, '*metadata.mat']));
            
            if length(metadata_file) > 1
                uiwait(msgbox(['The input file list is not distinct. For file "', file_base, '" ', num2str(length(metadata_file)), ' possible metadata-files were found!'], 'Please have a look!', 'warn'));
                metadata_file = metadata_file(1);
            end
        else
            metadata_file = metadataGlobal{i};
        end
        
        if ~isempty(metadata_file)
            
            if ~usePreviousMetadata
                metadata = load(fullfile(handles.settings.directory, metadata_file.name), 'data');
                removeFields = setdiff(fieldnames(metadata.data), {'cropRange', 'cropRangeInterpolated', 'minCellInt', 'I_base', 'manualThreshold', 'frameSkipped', 'scaling', 'date', 'detected', 'registration'});
                metadata.data = rmfield(metadata.data, removeFields);
                metadataGlobal{i} = metadata;
            else
                metadata = metadata_file;
            end
            
            try
                try 
                    times{i} = datestr(metadata.data.date, 'HH:MM:SS');
                    dates{i} = datestr(metadata.data.date, 'dd.mm.yyyy');
                catch
                    times{i} = ['00:00:',num2str(i, '%02d')];
                    dates{i} = '';
                end
                
                if i == 1
                    timesDur{i} = '00:00:00';
                else
                    timeDiff = datevec(datenum(times{i}, 'HH:MM:SS')-datenum(times{i-1}, 'HH:MM:SS'));
    
                    timestr = [num2str(timeDiff(4), '%02d'),':',num2str(timeDiff(5), '%02d'),':',num2str(timeDiff(6), '%02d')];
                 
                    timesDur{i} = timestr;
                end
                
            catch
                times{i} = '00:00:00';
                timesDur{i} = '00:00:00';
            end
            
            try
                if isfield(metadata.data, 'registration')
                    registrations(i) = 1;
                end
            end
        end
         
        cell_file = dir(fullfile(handles.settings.directory, 'data', [file_base, '*data.mat']));
        if ~isempty(cell_file)
            cells(i) = 1;
        end
        
        ind = strfind(file_base, 'Nz');
        vtk_file = dir(fullfile(handles.settings.directory, 'data', [file_base(1:ind-2), '*.vtk']));
        if ~isempty(vtk_file)
            vtks(i) = 1;
        end
        if ~mod(i, 20)
            updateWaitbar(handles, i/filesNum(2)/1.2)
        end
        
        if checkCancelButton(handles)
            return;
        end
    end
end
if ~usePreviousMetadata
    handles.settings.metadataGlobal = metadataGlobal;
    try
        save(metadataGlobalFilename, 'metadataGlobal', 'numMetadataFiles', 'sizeMetadataFiles');
    end
    updateWaitbar(handles, 0.9)
end

try
    handles.settings.metadataTable = [{lists.files_tif.name}', times, timesDur, dates, num2cell(registrations), num2cell(cells), num2cell(vtks)];
    %set(handles.uitables.uitable_metadata, 'Data', metadataTable)
catch
    handles.settings.metadataTable = {lists.files_tif.name}';
end
% Store java-handle of file list
if ~isfield(handles.java, 'files_javaHandle')
    try
        handles.java.files_javaHandle = findjobj(handles.uitables.files);
        jscrollpane = javaObjectEDT(handles.java.files_javaHandle);
        viewport    = javaObjectEDT(jscrollpane.getViewport);
        jtable      = javaObjectEDT(viewport.getView);
        handles.java.files_jtable = jtable;
    catch
        uiwait(msgbox('Could not retrieve underlying java object for file table!', 'Please note', 'error', 'modal'));
    end
end

% Generate file table
if max(filesNum)>0
    handles.uicontrols.popupmenu.popupmenu_fileType.Value = 2;
    handles = showFileList(hObject, eventdata, handles, 'tif');
%     switch get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value')
%         case 1
%             handles = showFileList(hObject, eventdata, handles, 'nd2');
%         case 2
%             handles = showFileList(hObject, eventdata, handles, 'tif');
%         case 3
%             handles = showFileList(hObject, eventdata, handles, 'metadata');
%         case 4
%             handles = showFileList(hObject, eventdata, handles, 'mask');
%         case 5
%             handles = showFileList(hObject, eventdata, handles, 'cells');
%         case 6
%             handles = showFileList(hObject, eventdata, handles, 'vtk');
%     end
end


if ~isempty(handles.settings.lists.files_cells)
    try
        if strcmp(handles.settings.lists.files_cells(1).name, 'missing')
            error('No processed files present');
        end
        % load first file
        if strfind(handles.settings.lists.files_cells(1).name, 'missing')
            error('File not processed');
        end
        objects = loadObjects(fullfile(handles.settings.directory, 'data', handles.settings.lists.files_cells(1).name), 'measurementFields');
        fNames = objects.measurementFields;
        
        set(handles.uicontrols.popupmenu.filter_parameter, 'String', fNames);
        % Intensity related fields:
        intFields = strfind(fNames, 'Intensity_Mean');
        
        for i = 1:length(intFields)
            if ~isempty(intFields{i})
                set(handles.uicontrols.popupmenu.filter_parameter, 'Value', i)
                break;
            end
        end
        
        deleteInd = strcmp(fNames, 'Centroid');
        fNames(find(deleteInd)) = [];
        deleteInd = strcmp(fNames, 'BoundingBox');
        fNames(find(deleteInd)) = [];
        deleteInd = strcmp(fNames, 'Orientation_Matrix');
        fNames(find(deleteInd)) = [];
        deleteInd = strcmp(fNames, 'Cube_CenterCoord');
        fNames(find(deleteInd)) = [];
        
        fNames = ['ID'; 'Distance_FromSubstrate'; 'RandomNumber'; fNames];
        
        tableData = [fNames num2cell(true(size(fNames)))];
        set(handles.uitables.cellParametersStoreVTK, 'Data', tableData);
        set(handles.uicontrols.popupmenu.renderParaview_parameter, 'String', tableData(:,1));
        
        if numel(tableData(:,1)) < handles.uicontrols.popupmenu.renderParaview_parameter.Value
            handles.uicontrols.popupmenu.renderParaview_parameter.Value = numel(tableData(:,1));
        end
        
    end 
    
end
updateWaitbar(handles, 0.95)
if isempty(get(handles.uicontrols.edit.I_base, 'String'))
    set(handles.uicontrols.edit.I_base, 'String', '0');
    params.I_base = str2num(get(handles.uicontrols.edit.I_base, 'String'));
end

% Revert all uielement states
% handles = toggleUIElements(handles, 1);
if numel(handles.uicontrols.popupmenu.channel.String) > 1
    handles.uicontrols.popupmenu.channel.Enable = 'on';
    handles.uicontrols.popupmenu.channel_seg.Enable = 'on';
end

% Updates fields
if ~isempty(params)
    edits = fieldnames(handles.uicontrols.edit);
    for i = 1:length(edits)
        try
            if get(handles.uicontrols.edit.(edits{i}), 'UserData')
            else
                editData = params.(get(handles.uicontrols.edit.(edits{i}), 'Tag'));
                if ~isempty(editData)
                    if isnumeric(editData)
                        set(handles.uicontrols.edit.(edits{i}), 'String', num2str(editData));
                    else
                        set(handles.uicontrols.edit.(edits{i}), 'String', editData);
                    end
                    if strcmp(edits{i}, 'maxHeight')
                        if ~isempty(editData)
                            set(handles.uicontrols.edit.(edits{i}), 'BackgroundColor', 'y');
                        else
                            set(handles.uicontrols.edit.(edits{i}), 'BackgroundColor', 'w');
                        end
                    end
                end
            end
        catch
            fprintf(['Settings for "', get(handles.uicontrols.edit.(edits{i}), 'Tag'), '" not found\n']);
            %displayStatus(handles, ['Settings for "', get(handles.uicontrols.edit.(edits{i}), 'Tag'), '" not found'], 'red');
        end
    end
    popupmenus = fieldnames(handles.uicontrols.popupmenu);
    for i = 1:length(popupmenus)
        try
            if get(handles.uicontrols.popupmenu.(popupmenus{i}), 'UserData')
            else
                %set(handles.uicontrols.popupmenu.(popupmenus{i}), 'String', num2str(params.(get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag'))));
                set(handles.uicontrols.popupmenu.(popupmenus{i}), 'Value', params.(get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag')));
            end
        catch
            fprintf(['Settings for "', get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag'), '" not found\n']);
            %displayStatus(handles, ['Settings for "', get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag'), '" not found'], 'red');
        end
    end
    checkboxes = fieldnames(handles.uicontrols.checkbox);
    for i = 1:length(checkboxes)
        try
            set(handles.uicontrols.checkbox.(checkboxes{i}), 'Value', params.(get(handles.uicontrols.checkbox.(checkboxes{i}), 'Tag')));
            
            if strcmp(checkboxes{i}, 'imageRegistration')
                if handles.uicontrols.checkbox.(checkboxes{i}).Value
                    
                    handles.uicontrols.checkbox.fixedOutputSize.Enable = 'on';
                    
                    if handles.uicontrols.checkbox.fixedOutputSize.Value
                        handles.uicontrols.edit.registrationReferenceCropping.Enable = 'on';
                        handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping.Enable = 'on';
                    else
                        handles.uicontrols.edit.registrationReferenceCropping.Enable = 'off';
                        handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping.Enable = 'off';
                    end
                    
                else
                    handles.uicontrols.checkbox.fixedOutputSize.Enable = 'off';
                    handles.uicontrols.edit.registrationReferenceCropping.Enable = 'off';
                    handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping.Enable = 'off';
                end
            end
            
        catch
            fprintf(['Settings for "', get(handles.uicontrols.checkbox.(checkboxes{i}), 'Tag'), '" not found\n']);
            %displayStatus(handles, ['Settings for "', get(handles.uicontrols.checkbox.(checkboxes{i}), 'Tag'), '" not found'], 'red');
        end
    end
    uitables = fieldnames(handles.uitables);
    for i = 1:length(uitables)
        try
            if get(handles.uitables.(uitables{i}), 'UserData')
            else %Add other tables
                % Compare data size
                table_loaded = params.(get(handles.uitables.(uitables{i}), 'Tag'));
                table_present = get(handles.uitables.(uitables{i}), 'Data');
                if strcmp([table_loaded{:,1}], [table_present{:,1}]) && strcmp([table_loaded{:,1}], [handles.tableData{:,1}])
                    set(handles.uitables.(uitables{i}), 'Data', params.(get(handles.uitables.(uitables{i}), 'Tag')));
                    handles.tableData = params.tableData;
                else
                    displayStatus(handles, ['Settings for "', get(handles.uitables.(uitables{i}), 'Tag'), '" are not compatible'], 'red');
                    fprintf(['Settings for "', get(handles.uitables.(uitables{i}), 'Tag'), '" not compatible\n']);
                end
            end
        catch
            fprintf(['Settings for "', get(handles.uitables.(uitables{i}), 'Tag'), '" not found\n']);
            %displayStatus(handles, ['Settings for "', get(handles.uitables.(uitables{i}), 'Tag'), '" not found'], 'red');
        end
    end
end

if isempty(get(handles.uicontrols.edit.action_imageRange, 'String'))
    set(handles.uicontrols.edit.action_imageRange, 'String', ['1:',num2str(filesNum(2))]);
    params.action_imageRange = ['1:',num2str(filesNum(2))];
end

updateWaitbar(handles, 1)

% Execute callbacks
BiofilmQ('intensity_task_Callback', handles.uicontrols.popupmenu.intensity_task, eventdata, handles)
BiofilmQ('segmentationMethod_Callback', handles.uicontrols.popupmenu.segmentationMethod, eventdata, handles, 'init');

% Check whether the value of the filter checkbox is larger than the number
% of entries
if get(handles.uicontrols.popupmenu.filter_parameter, 'Value') > size(get(handles.uicontrols.popupmenu.filter_parameter, 'String'),1)
    set(handles.uicontrols.popupmenu.filter_parameter, 'Value', 1);
end



%BiofilmQ('I_base_perStack_Callback', hObject, eventdata, handles)
%BiofilmQ('files_Callback', hObject, eventdata, handles)

try
    dirInfo(handles);
end

handles = checkMetadataOfSelectedFiles(hObject, eventdata, handles);

updateWaitbar(handles, 0)
