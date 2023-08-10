function tempDirInfo(handles)

try
    % Current working directory
    bytes_current_free = disk_free(handles.settings.directory)/(1024*1024*1024);
    bytes_temp_free = disk_free(get(handles.uicontrols.edit.tempFolder, 'String'))/(1024*1024*1024);


    bytes_current = folderSizeTree(handles.settings.directory);
    bytes_current = sum(cell2mat([bytes_current.size]))/(1024*1024*1024);

    try
        bytes_temp = folderSizeTree(get(handles.uicontrols.edit.tempFolder, 'String'));
        bytes_temp = sum(cell2mat([bytes_temp.size]))/(1024*1024*1024);
    catch
        bytes_temp = 0;
    end

    try
        projectFolders = strsplit(handles.settings.directory, filesep);
        bytes_temp_current = folderSizeTree(fullfile(get(handles.uicontrols.edit.tempFolder, 'String'), projectFolders{end-1}, projectFolders{end}));
        bytes_temp_current = sum(cell2mat([bytes_temp_current.size]))/(1024*1024*1024);
    catch
        bytes_temp_current = 0;
    end

    infoString = {sprintf('Temporary files: %.1f / %.1f Gb', bytes_temp_current, bytes_temp_free), sprintf('Current files: %.1f / %.1f Gb', bytes_current,bytes_current_free)};

    set(handles.uicontrols.text.text_tempDirectoryStats, 'String', infoString)
end