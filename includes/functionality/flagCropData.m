function handles = flagCropData(hObject, eventdata, handles, appliesToRegisteredImage)

displayStatus(handles, 'Updating crop-ranges for all images...', 'green');

for i = 1:length(handles.settings.lists.files_metadata)
    if ~mod(i-1, 10)
        updateWaitbar(handles, i/length(handles.settings.lists.files_metadata))
    end
    
    metadata = load(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name));
    data = metadata.data;
    data.cropRange_appliesToRegisteredImage = appliesToRegisteredImage;
    
    handles.settings.metadataGlobal{i}.data = data;
    save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name), 'data');
    
    % Update crop range for other channels
    channelData = get(handles.uicontrols.popupmenu.channel, 'String');
    if numel(channelData) > 1
        channel = channelData{get(handles.uicontrols.popupmenu.channel, 'Value')};
        ch_toProcess = find(~cellfun(@(x) strcmp(x, channel), channelData));
        for c = 1:numel(ch_toProcess)
            filename_ch = fullfile(handles.settings.directory, ...
                strrep(handles.settings.lists.files_metadata(i).name, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
            
            data = load(filename_ch);
            data = data.data;
            data.cropRange_appliesToRegisteredImage = appliesToRegisteredImage;
            save(filename_ch, 'data');
        end
        
    end
    
    guidata(hObject, handles);
    if checkCancelButton(handles)
        return;
    end
end

displayStatus(handles, 'Done', 'black', 'add');
updateWaitbar(handles, 0);