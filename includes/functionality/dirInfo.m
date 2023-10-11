function dirInfo(handles)

try
    % Current working directory
    bytes_current_free = disk_free(handles.settings.directory)/(1024*1024*1024);
    bytes_current = folderSizeTree(handles.settings.directory);
    bytes_current = sum(cell2mat([bytes_current.size]))/(1024*1024*1024);

    experimentFolders = dir(fullfile(handles.settings.directory, '..'));
    experimentFoldersN = 0;
    try
        experimentFolders = experimentFolders(3:end);
        experimentFoldersN = sum([experimentFolders.isdir]); 
    end
    infoString = {sprintf('Size of current folder: %.2f Gb, Free disk space: %.1f Gb', bytes_current, bytes_current_free), sprintf('Number of similar experiment folders: %d', experimentFoldersN)};

    set(handles.uicontrols.text.text_folderProperties, 'String', infoString)
end