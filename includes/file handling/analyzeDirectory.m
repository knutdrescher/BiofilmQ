function [handles, status] = analyzeDirectory(hObject, eventdata, handles)

status = 0;

set(handles.uicontrols.edit.cropRange, 'String', '');
set(handles.uicontrols.edit.registrationReferenceCropping, 'String', '');
set(handles.uicontrols.edit.registrationReferenceFrame, 'String', '1');

directory = get(handles.uicontrols.edit.inputFolder, 'String');

if isempty(directory) || ~exist(directory, 'dir')
    if handles.settings.showMsgs
        uiwait(msgbox('No experiment folder selected.', 'Please note', 'help', 'modal'));
    else
        warning('No experiment folder selected.');
    end
    displayStatus(handles, 'No folder selected!', 'red', 'add');
    return;
end

enableCancelButton(handles);
drawnow;

if handles.settings.useDefaultSettingsOnDirectoryChange
    % Store current settings in handles;
    handles = storeValues(hObject, eventdata, handles, 0, 0, 1);
end

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
lists.files_sim = init;

filesNum = zeros(1,7);

% Check for files of other vendors
file_formats = { ...
    '*.nd2', ...    Nikon NIS-Elements ND2
    '*.czi', ...    Zeiss CZI
    '*.lsm', ...    Zeiss LSM (Laser Scanning Microscope) 510/710
    '*.lif', ...    Leica LAS AF LIF (Leica Image File Format)
    '*.tiff', ...   multiple
    '*.oif', ...    Olympus FluoView FV1000
    '*.oib' ...     Olympus FluoView FV1000
    };
lists.files_nd2 = dir(fullfile(directory, file_formats{1}));

for i = 2:numel(file_formats)
    filesWithFormat = dir(fullfile(directory, file_formats{i}));
    lists.files_nd2(end+1:end+numel(filesWithFormat)) = filesWithFormat;
end
[~, sortIdx] = sort_nat({lists.files_nd2.name});
lists.files_nd2 = lists.files_nd2(sortIdx);


% Check for simulations files
lists.files_sim = dir(fullfile(directory, '*_timestep*.txt'));
filesNum(7) = numel(lists.files_sim);

filesNum(1) = length(lists.files_nd2);

lists.files_tif = dir(fullfile(directory, '*_frame*_Nz*.tif'));
[~, sortIdx] = sort_nat({lists.files_tif.name});
lists.files_tif = lists.files_tif(sortIdx);

if ~isfield(lists.files_tif, 'folder')
    folder = repmat({directory}, numel(lists.files_tif), 1);
    if ~isempty(folder)
        [lists.files_tif.folder] = folder{:};
    end
end
filesNum(2) = length(lists.files_tif);

allTifFiles = dir(fullfile(directory, '*.tif'));

% Check if tifs are custom tifs
if filesNum(2) ~= numel(allTifFiles)
    lists.files_tif = allTifFiles;
    
    if numel(lists.files_tif) > 0
        fprintf('=== Custom tif-Files detected ===\n')
        
        %         error('Here we need to insert the 2D tif file import somehow')
        
        handles = showFileList(hObject, eventdata, handles, 'importTif');
        toggleBusyPointer(handles, false);
        
        try
            delete(handles.uicontrols.text.htmlBrowser);
        end
        
        updateWaitbar(handles, 0)
        
        status = 1;
        
        return
        
        
        
        % TODO: Best switch in one of these 2 cases:
        % 2D files
        % test for automatic import, if not manual annotation is needed
        % 3D files
        % test for automatic import, if not manual annotation is needed to
        % extract metadata
        
        
        
        
        if false
            answer = questdlg({'Custom tif-files were found which do not have the right format to continue. In order to proceed these files need to be modified.', '', '', ...
                'Do you want to continue and import these files now?'}, ...
                'Convert files', ...
                'Continue','Cancel','Continue');
            % Handle response
            switch answer
                case 'Continue'
                    % Update tif files and create metadata files
                    %% open view for file import
                    
                    
                    
                    %
                    wb = waitbar(0, sprintf('Converting image %d/%d...', 1, numel(lists.files_tif)), 'Name', 'Image conversion');
                    
                    % Group files by channel
                    try
                        frameNumbers = zeros(1, numel(lists.files_tif));
                        for i = 1:numel(lists.files_tif)
                            chIdx1 = strfind(lists.files_tif(i).name, '_ch');
                            ch = str2num(lists.files_tif(i).name(chIdx1+3));
                            if ch > 1
                                frameNumbers(i) = frameNumbers(i-1);
                            else
                                frameNumbers(i) = max(frameNumbers)+1;
                            end
                        end
                    catch
                        frameNumbers = 1:numel(lists.files_tif);
                        fprintf(' - cannot group stacks by channel\n');
                    end
                    
                    for i = 1:numel(lists.files_tif)
                        if ~exist(fullfile(handles.settings.directory, [lists.files_tif(i).name(1:end-4), '_metadata.mat']), 'file')
                            % Assume that tif stack has no projection and no
                            % metadata file
                            
                            fprintf('Converting image "%s"\n', lists.files_tif(i).name);
                            fprintf(' - loading image');
                            img = double(imread3D(fullfile(handles.settings.directory, lists.files_tif(i).name)));
                            if max(img(:)) <= 255
                                bits = 8;
                            else
                                bits = 16;
                            end
                            
                            % Padding projection
                            img_proj = sum(img,3)/size(img, 3);
                            img_proj = img_proj/max(img_proj(:))*(2^bits-1);
                            img(:,:,2:end+1) = img;
                            img(:,:,1) = img_proj;
                            
                            if bits == 8
                                img = uint8(img);
                            else
                                img = uint16(img);
                            end
                            
                            try
                                waitbar((i-0.5)/numel(lists.files_tif), wb, sprintf('Converting image %d/%d...', i, numel(lists.files_tif)));
                            catch
                                handles.settings.metadataTable = [];
                                handles.uitables.files.Data = {'Image conversion cancelled!'};
                                return;
                            end
                            
                            filenameNew = fullfile(handles.settings.directory, generateValidFileName(lists.files_tif(i).name, frameNumbers(i), num2str(size(img, 3)-1)));
                            
                            fprintf(' - saving image');
                            imwrite3D(img, [filenameNew '.tif']);
                            data = struct('scaling', struct('dxy', 0.12, 'dz', 0.5), 'data', lists.files_tif(i).date);
                            fprintf(' - creating metadata-file for image\n');
                            
                            save([filenameNew, '_metadata.mat'], 'data');
                            
                            
                            if ~exist(fullfile(handles.settings.directory, 'backup'))
                                mkdir(fullfile(handles.settings.directory, 'backup'));
                            end
                            try
                                fprintf(' - creating backup\n');
                                movefile(fullfile(handles.settings.directory, lists.files_tif(i).name), fullfile(handles.settings.directory, 'backup', lists.files_tif(i).name));
                            catch err
                                msgbox(sprintf('Cannot move file "%s" to folder "backup"! Error: %s', lists.files_tif(i).name, err.message), 'Error', 'error', 'modal');
                            end
                        end
                        try
                            waitbar(i/numel(lists.files_tif), wb, sprintf('Converting image %d/%d...', i, numel(lists.files_tif)));
                        catch
                            handles.settings.metadataTable = [];
                            handles.uitables.files.Data = {'Image conversion cancelled!'};
                            return;
                        end
                    end
                    
                    try
                        delete(wb);
                    end
                    
                    lists.files_tif = dir(fullfile(directory, '*frame*Nz*.tif'));
                    if ~isfield(lists.files_tif, 'folder')
                        folder = repmat({directory}, numel(lists.files_tif), 1);
                        if ~isempty(folder)
                            [lists.files_tif.folder] = folder{:};
                        end
                    end
                    filesNum(2) = length(lists.files_tif);
                    
                    
                    
                    
                case 'Cancel'
                    handles.settings.metadataTable = [];
                    handles.uitables.files.Data = {sprintf('%d tif-files found, which are not in the right format.', numel(lists.files_tif))};
                    return;
            end
        end
    end
end


% Check metadata files
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

% More tif files than metadata files
if filesNum(2) > filesNum(3)
    if filesNum(2)
        answer = questdlg({'The directory is not valid!', '', 'Some images are missing metadata files. Shall these be automatically created with default pixel scaling entries?'}, ...
            'Metadata-files missing!', ...
            'Create missing metadata-files','Cancel','Create missing metadata-files');
        % Handle response
        switch answer
            case 'Create missing metadata-files'
                for i = 1:numel(lists.files_tif)
                    metadataFilename = fullfile(handles.settings.directory, [lists.files_tif(i).name(1:end-4), '_metadata.mat']);
                    if ~exist(metadataFilename, 'file')
                        data = struct('scaling', struct('dxy', 0.12, 'dz', 0.5), 'date', lists.files_tif(i).date);
                        save(metadataFilename, 'data');
                    end
                end
                lists.files_metadata = init;
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
                
            otherwise
                handles.settings.metadataTable = [];
                handles.uitables.files.Data = {'Directory is not valid.'};
                return;
        end
    end
end

% Check for segmentation results
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
    
    if ~isempty(lists.files_tif)
        fileListBase = lists.files_tif;
    elseif ~isempty(lists.files_sim)
        fileListBase = lists.files_sim;
    else
        uiwait(msgbox('The selected directory is not valid.', 'Error', 'error', 'modal'));
        return;
    end
    
    for i = 1:length(fileListBase)
        
        ch = strfind(fileListBase(i).name, '_ch');
        if ~isempty(ch)
            ch = fileListBase(i).name(ch:ch+3);
        else
            ch = '';
        end
        
        file = dir(fullfile(directory, 'data', [fileListBase(i).name(1:end-4), '_mask.tif']));
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
        
        file = dir(fullfile(directory, 'data', [fileListBase(i).name(1:end-4), '_data.mat']));
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
        
        filebase_vtk_ind = strfind(fileListBase(i).name, '_Nz');
        filebase_vtk = fileListBase(i).name(1:filebase_vtk_ind-1);
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
else
    handles.settings.dataFolder = 0;
end

% Update edits
if exist(fullfile(directory, 'parameters.mat'), 'file')
    firstStart = false;
    params = load(fullfile(directory, 'parameters.mat'));
    try
        params = params.params;
    end
else
    firstStart = true;
    
    if handles.settings.useDefaultSettingsOnDirectoryChange
        % Restore default parameters
        fprintf(' - This is and unprocessed folder (no file "parameters.mat" present) -> initializing directory with DEFAULT settings and creating parameter-file\n');
        handles = storeValues(hObject, eventdata, handles, 0, 0, 0);
        params = handles.settings.defaultParams;
    else
        fprintf(' - This is and unprocessed folder (no file "parameters.mat" present) -> initializing directory with CURRENT settings and creating parameter-file\n');
        params = [];
    end
end

listsAll = lists;

set(handles.uicontrols.popupmenu.intensity_ch, 'String', {'1'}, 'value', 1);
set(handles.handles_analysis.uicontrols.popupmenu.channel, 'String', {'1'}, 'value', 1);

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
        channelText = channels;
        
        % Load first metadata and check if file was deconvolved
        for j = 1:length(channels)
            compare = @(x) strcmp(x, channels{j});
            index = find(cellfun(compare, ch),1);
            metadata = load(fullfile(directory, [lists.files_tif(index).name(1:end-4),  '_metadata.mat']));
            data = metadata.data;
            if isfield(data, 'originalChannel')
                channelText{j} = [channelText{j}, ' (deconvolved from ', num2str(data.originalChannel), ')'];
            end
        end
        
        if isfield(params, 'channel')
            s = params.channel;
        else
            if numel(channels) > 1 && handles.settings.showMsgs
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
        
        if s>length(channels)
            s = 1;
        end
        
        params.ch = s;
        set(handles.uicontrols.popupmenu.intensity_ch, 'String', channelText, 'value', s);
        set(handles.handles_analysis.uicontrols.popupmenu.channel, 'String', channelText, 'value', s);
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
                        if isempty(strfind(fileList(j).name, ['_ch', num2str(s)]))
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
        
        
        
        set(handles.uicontrols.popupmenu.channel, 'String', channelText, 'Value', s, 'Enable', 'on');
        set(handles.uicontrols.popupmenu.channel_seg, 'String', channelText, 'Value', s, 'Enable', 'on');
        set(handles.uicontrols.popupmenu.popupmenu_labelImage_Channel, 'String', channelText, 'Value', s, 'Enable', 'on');
        set(handles.handles_analysis.uicontrols.popupmenu.channel, 'String', channelText, 'Value', s, 'Enable', 'on');
        ind = cellfun(@(x) strcmp(x, handles.uicontrols.popupmenu.channel.Tag), handles.settings.elementNames);
        handles.settings.elementStates{ind} = 'on';
        ind = cellfun(@(x) strcmp(x, handles.uicontrols.popupmenu.channel_seg.Tag), handles.settings.elementNames);
        handles.settings.elementStates{ind} = 'on';
    else
        set(handles.uicontrols.popupmenu.channel, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
        set(handles.uicontrols.popupmenu.channel_seg, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
        set(handles.handles_analysis.uicontrols.popupmenu.channel, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
        
        ind = cellfun(@(x) strcmp(x, handles.uicontrols.popupmenu.channel.Tag), handles.settings.elementNames);
        handles.settings.elementStates{ind} = 'on';
        ind = cellfun(@(x) strcmp(x, handles.uicontrols.popupmenu.channel_seg.Tag), handles.settings.elementNames);
        handles.settings.elementStates{ind} = 'on';
    end
    
else
    set(handles.uicontrols.popupmenu.channel, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
    set(handles.uicontrols.popupmenu.channel_seg, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
    set(handles.uicontrols.popupmenu.channel_seg, 'String', {'1'}, 'Value', 1, 'Enable', 'off');
end

if checkCancelButton(handles)
    return;
end

handles.handles_analysis.uicontrols.edit.maxFrameToLoad.String = num2str(numel(lists.files_tif));

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
            case 6
                nFiles = length(lists.files_sim);
        end
        popupmenu_fileType{i} = [popupmenu_fileType{i}(1:space_index), ' (',num2str(nFiles) ,' files)'];
    catch
        popupmenu_fileType{i} = [popupmenu_fileType{i}(1:space_index), ' (0 files)'];
    end
end

set(handles.uicontrols.popupmenu.popupmenu_fileType, 'String', popupmenu_fileType);

if max(filesNum)>0
    handles.settings.inputFolder_previous = handles.uicontrols.edit.inputFolder.String;
else
    if handles.settings.showMsgs
        uiwait(msgbox('No files found.', 'Please note', 'warn', 'modal'));
    else
        warning('No files found.');
    end
    if isfield(handles.settings, 'inputFolder_previous')
        handles.uicontrols.edit.inputFolder.String = handles.settings.inputFolder_previous;
        [handles, status] = analyzeDirectory(hObject, eventdata, handles);
    end
    return;
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
metadataFiles = lists.files_metadata;
numMetadataFiles = numel(metadataFiles);
dateMetadataFiles = max([metadataFiles.datenum]);
usePreviousMetadata = false;

if isfield(params, 'ch')
    metadataGlobalFilename = fullfile(handles.settings.directory, sprintf('metadata_global_ch%d.mat', params.ch));
else
    metadataGlobalFilename = fullfile(handles.settings.directory, 'metadata_global.mat');
end

if ~isempty(metadataFiles)
    if exist(metadataGlobalFilename, 'file')
        dateMetadataFiles_prev = load(metadataGlobalFilename);
        
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
                    timeNum{i} = datenum(metadata.data.date);
                catch
                    times{i} = datestr(lists.files_tif(i).datenum ,'HH:MM:SS');
                    dates{i} = datestr(lists.files_tif(i).datenum ,'dd.mm.yyyy');
                    timeNum{i} = lists.files_tif(i).datenum;
                end
                
                if i == 1
                    timesDur{i} = '00:00:00';
                else
                    timeDiff = datevec(timeNum{i}-timeNum{i-1});
                    
                    timestr = [num2str(timeDiff(4)+timeDiff(3)*24, '%02d'),':',num2str(timeDiff(5), '%02d'),':',num2str(timeDiff(6), '%02d')];
                    
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
        save(metadataGlobalFilename, 'metadataGlobal', 'numMetadataFiles');
    end
    updateWaitbar(handles, 0.9)
end

try
    handles.settings.metadataTable = [{lists.files_tif.name}', times, timesDur, dates, num2cell(registrations), num2cell(cells), num2cell(vtks)];
catch
    handles.settings.metadataTable = {lists.files_tif.name}';
end

handles.settings.GUIDisabledVisualization = false;
toggleUIElements(handles, 0, 'visualization');

% Generate file table
if firstStart
    params.action_imageRange = '1';
end

if max(filesNum)>0
    selFileType = handles.uicontrols.popupmenu.popupmenu_fileType.Value;
    if selFileType == 6
        selFileType2 = selFileType + 1;
    else
        selFileType2 = selFileType;
    end
    
    if filesNum(selFileType2) <= 0 % No files for the current type selection
        filesNumFindMax = filesNum;
        filesNumFindMax(3:6) = 0;
        
        [~, switchToFileType] = max(filesNumFindMax);
        
        if switchToFileType < 3
            handles.uicontrols.popupmenu.popupmenu_fileType.Value = switchToFileType;
        end
        
        if switchToFileType == 7
            handles.uicontrols.popupmenu.popupmenu_fileType.Value = 6;
        end
    else
        switchToFileType = selFileType;
    end
    
    switch switchToFileType
        case 1
            handles = showFileList(hObject, eventdata, handles, 'nd2');
        case 2
            handles = showFileList(hObject, eventdata, handles, 'tif');
            if firstStart
                params.action_imageRange = ['1:',num2str(numel(lists.files_tif))];
            end
        case 3
            handles = showFileList(hObject, eventdata, handles, 'metadata');
        case 4
            handles = showFileList(hObject, eventdata, handles, 'cells');
        case 5
            handles = showFileList(hObject, eventdata, handles, 'vtk');
        case 6
            handles = showFileList(hObject, eventdata, handles, 'sim');
            if firstStart
                params.action_imageRange = ['1:',num2str(numel(lists.files_sim))];
            end
    end
end


if ~isempty(handles.settings.lists.files_cells) && ~isempty(handles.settings.lists.files_cells(1).name)
    try
        
        % create a list of measurementFields which are present in all files
        % in the current image range
        
        range = 1:length(handles.settings.lists.files_cells);
        
        i = range(1);
        range(1) = [];
        
        basename = fullfile(handles.settings.directory, 'data');
        filename = fullfile( ...
            basename, handles.settings.lists.files_cells(i).name);
        
        if ~strcmp(handles.settings.lists.files_cells(i).name(1:7), 'missing')
            objects = loadObjects(filename, 'measurementFields', true);
            fNames = objects.measurementFields;
            combinedNames = fNames;
        else
            fNames = {};
            combinedNames = {};
        end
        
        % iterate
        for i = range
            filename = fullfile( ...
                basename, handles.settings.lists.files_cells(i).name);
            if ~strcmp(handles.settings.lists.files_cells(i).name(1:7), 'missing')
                objects= loadObjects(filename, 'measurementFields', true);
                combinedNames = {combinedNames{:}, objects.measurementFields{:}};
                fNames = intersect(fNames, objects.measurementFields);
                
            else
                fNames = {};
            end
        end
        
        combinedNames = unique(combinedNames);
        combinedNames_sub = setdiff(combinedNames, {'Centroid', 'BoundingBox', 'Cube_CenterCoord', 'Orientation_Matrix', 'MinBoundBox_Cornerpoints'});
        combinedNames = union({'ID', 'CentroidCoordinate_x', 'CentroidCoordinate_y', 'CentroidCoordinate_z'}, combinedNames_sub);
        
        fNames = setdiff(fNames, {'Centroid', 'BoundingBox', 'Cube_CenterCoord', 'Orientation_Matrix', 'MinBoundBox_Cornerpoints'});
        
        if ~isempty(fNames)
            fNames = {'ID', 'Distance_FromSubstrate', 'RandomNumber', fNames{:}}';
        else
            fNames = {'ID', 'Distance_FromSubstrate', 'RandomNumber', 'Timepoint', combinedNames{:}}';
        end
        
        
        if ~isempty(combinedNames)
            set(handles.uicontrols.popupmenu.filter_parameter, 'String', combinedNames);
            set(handles.uicontrols.popupmenu.tagCells_parameter, 'String', combinedNames);
            set(handles.uicontrols.popupmenu.popupmenu_parameterCombination_ParameterChoice, 'String', combinedNames_sub);
        else
            set(handles.uicontrols.popupmenu.popupmenu_parameterCombination_ParameterChoice, 'String', 'no parameters present');
            set(handles.uicontrols.popupmenu.filter_parameter, 'String', 'no parameters present');
        end
        
        % Intensity related fields:
        intFields = strfind(fNames, 'Intensity_Mean');
        
        for i = 1:length(intFields)
            if ~isempty(intFields{i})
                set(handles.uicontrols.popupmenu.filter_parameter, 'Value', i);
                set(handles.uicontrols.popupmenu.tagCells_parameter, 'Value', i);
                break;
            end
        end
        
        
        tableData = [fNames num2cell(true(size(fNames)))];
        set(handles.uitables.cellParametersStoreVTK, 'Data', tableData);
        
        if ~isempty(tableData)
            set(handles.uicontrols.popupmenu.renderParaview_parameter, 'String', tableData(:,1));
            if numel(tableData(:,1)) < handles.uicontrols.popupmenu.renderParaview_parameter.Value
                handles.uicontrols.popupmenu.renderParaview_parameter.Value = numel(tableData(:,1));
            end
        else
            set(handles.uicontrols.popupmenu.renderParaview_parameter, 'String', 'no parameters present');
            
        end
        
        
        
    catch err
        warning(err.message);
        
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
            if numel(get(handles.uicontrols.edit.(edits{i}), 'UserData'))
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
            if ~firstStart
                fprintf(['Settings for "', edits{i}, '" not found\n']);
                displayStatus(handles, ['Settings for "', edits{i}, '" not found'], 'red');
            end
        end
    end
    popupmenus = fieldnames(handles.uicontrols.popupmenu);
    for i = 1:length(popupmenus)
        try
            if get(handles.uicontrols.popupmenu.(popupmenus{i}), 'UserData')
            else
                %set(handles.uicontrols.popupmenu.(popupmenus{i}), 'String', num2str(params.(get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag'))));
                popIdx = params.(get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag'));
                if popIdx <= numel(handles.uicontrols.popupmenu.(popupmenus{i}).String)
                    set(handles.uicontrols.popupmenu.(popupmenus{i}), 'Value', popIdx);
                else % only the case if manually modified image data/ parameter files
                    set(handles.uicontrols.popupmenu.(popupmenus{i}), 'Value', 1);
                end
            end
        catch
            if ~firstStart
                fprintf(['Settings for "', popupmenus{i}, '" not found\n']);
                displayStatus(handles, ['Settings for "', popupmenus{i}, '" not found'], 'red');
            end
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
            if ~firstStart
                fprintf(['Settings for "', checkboxes{i}, '" not found\n']);
                displayStatus(handles, ['Settings for "', checkboxes{i}, '" not found'], 'red');
            end
        end
    end
    uitables = fieldnames(handles.uitables);
    for i = 1:length(uitables)
        try
            if get(handles.uitables.(uitables{i}), 'UserData')
            else %Add other tables
                % Compare data size
                
                if strcmp(uitables{i}, 'cellParametersCalculate')
                    table_loaded = params.(get(handles.uitables.(uitables{i}), 'Tag'));
                    table_present = get(handles.uitables.(uitables{i}), 'Data');
                    if strcmp([table_loaded{:,1}], [table_present{:,1}]) && strcmp([table_loaded{:,1}], [handles.tableData{:,1}])
                        set(handles.uitables.(uitables{i}), 'Data', params.(get(handles.uitables.(uitables{i}), 'Tag')));
                        handles.tableData = params.tableData;
                    else
                        displayStatus(handles, ['Settings for "', get(handles.uitables.(uitables{i}), 'Tag'), '" are not compatible'], 'red');
                        fprintf(['Settings for "', get(handles.uitables.(uitables{i}), 'Tag'), '" not compatible\n']);
                    end
                else
                    set(handles.uitables.(uitables{i}), 'Data', params.(get(handles.uitables.(uitables{i}), 'Tag')));
                end
            end
        catch
            if ~firstStart
                try
                    fprintf(['Settings for "', uitables{i}, '" not found\n']);
                    displayStatus(handles, ['Settings for "', uitables{i}, '" not found'], 'red');
                end
            end
        end
    end
end

% At first start, registration frame should be the last frame, not the
% first
if ~isfield(params,'registrationReferenceFrame')
    handles.uicontrols.edit.registrationReferenceFrame.String = num2str(filesNum(2));
end

% Check whether the value of the filter checkbox is larger than the number
% of entries
if get(handles.uicontrols.popupmenu.filter_parameter, 'Value') > size(get(handles.uicontrols.popupmenu.filter_parameter, 'String'),1)
    set(handles.uicontrols.popupmenu.filter_parameter, 'Value', 1);
end


if isempty(get(handles.uicontrols.edit.action_imageRange, 'String'))
    set(handles.uicontrols.edit.action_imageRange, 'String', ['1:',num2str(filesNum(2))]);
    params.action_imageRange = ['1:',num2str(filesNum(2))];
end


if isfield(params, 'ch')
    set(handles.uicontrols.checkbox.displayAllChannels, 'Enable', 'on');
else
    set(handles.uicontrols.checkbox.displayAllChannels, 'Enable', 'off', 'Value', 0);
end

% Execute callbacks
if sum(filesNum(2:end))
    status = handles.uicontrols.listbox.listbox_status.String;
    BiofilmQ('intensity_task_Callback', handles.uicontrols.popupmenu.intensity_task, eventdata, handles)
    BiofilmQ('segmentationMethod_Callback', handles.uicontrols.popupmenu.segmentationMethod, eventdata, handles, 'init');
    BiofilmQ('declumpingMethod_Callback', handles.uicontrols.popupmenu.declumpingMethod, eventdata, handles);
    BiofilmQ('thresholdingMethod_Callback', handles.uicontrols.popupmenu.thresholdingMethod, eventdata, handles);
    BiofilmQ('reducePolygons_Callback', handles.uicontrols.checkbox.reducePolygons, eventdata, handles);
    biofilmAnalysis('loadMaxFrame_Callback', handles.handles_analysis.uicontrols.checkbox.loadMaxFrame, eventdata, handles);
    handles.uicontrols.listbox.listbox_status.String = status;
end

% Check if deconvolved image folder is present
handles.uicontrols.pushbutton.pushbutton_huygens_convertImagesToChannel.Enable = 'off';
handles.uicontrols.pushbutton.pushbutton_huygens_files_remove.Enable = 'off';
if exist(fullfile(handles.settings.directory, 'deconvolved images'), 'dir')
    if ~isempty(dir(fullfile(handles.settings.directory, 'deconvolved images')))
        handles.uicontrols.pushbutton.pushbutton_huygens_convertImagesToChannel.Enable = 'on';
        handles.uicontrols.pushbutton.pushbutton_huygens_files_remove.Enable = 'on';
    end
end

try
    delete(handles.uicontrols.text.htmlBrowser);
end

updateWaitbar(handles, 1)

try
    dirInfo(handles);
end
try
    handles = checkMetadataOfSelectedFiles(hObject, eventdata, handles);
end

updateWaitbar(handles, 0)

status = 1;