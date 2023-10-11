function handles = interpolateCropping(hObject, eventdata, handles)
enableCancelButton(handles);

displayStatus(handles, 'Reading crop-range of all images...', 'green');

cropRanges = zeros(length(handles.settings.lists.files_metadata), 5);

for i = 1:length(handles.settings.lists.files_metadata)
    data = handles.settings.metadataGlobal{i}.data;
    %data.cropRangeInterpolated
    if isfield(data, 'cropRange')
        if ~isempty(data.cropRange)
            cropRanges(i,:) = [data.cropRange sum(data.cropRange)];
            
            if i ~= str2num(get(handles.uicontrols.edit.registrationReferenceFrame, 'String'))
                if get(handles.uicontrols.checkbox.imageRegistration, 'Value')
                    %cropRanges(i,1:2) = cropRanges(i,1:2) + [data.registration.T(4,1) data.registration.T(4,2)];
                    try
                        if data.cropRangeInterpolated
                            cropRanges(i,:) = [0 0 0 0 0];
                        end
                    end
                else
                    if data.cropRangeInterpolated
                        cropRanges(i,:) = [0 0 0 0 0];
                    end
                end
            end
        end
    end
    if checkCancelButton(handles)
        return;
    end
end



validEntries = find(cropRanges(:,5));

%[~, ind] = unique(cropRanges(validEntries,5));

%validEntries = sort(validEntries(ind));
validEntries = sort(validEntries);

counter = 1;
nMax = validEntries(end);

for i = 1:numel(validEntries)-1
    range = [validEntries(i) validEntries(i+1)];
    Nvalues = range(2)-range(1)-1;
    % Interpolate values
    x = linspace(cropRanges(range(1), 1), cropRanges(range(2), 1), Nvalues);
    y = linspace(cropRanges(range(1), 2), cropRanges(range(2), 2), Nvalues);
    dx = linspace(cropRanges(range(1), 3), cropRanges(range(2), 3), Nvalues);
    dy = linspace(cropRanges(range(1), 4), cropRanges(range(2), 4), Nvalues);
    
    count = 1;
    for j = validEntries(i)+1:validEntries(i+1)-1
        
        if ~mod(counter, 10)
            updateWaitbar(handles, counter/nMax)
        end
        counter = counter + 1;
    
        data = handles.settings.metadataGlobal{j}.data;
        if isfield(data, 'registration')
            if get(handles.uicontrols.checkbox.imageRegistration, 'Value')
                %cropRange = round([x(count) y(count) dx(count) dy(count)] - [data.registration.T(4,1) data.registration.T(4,2) 0 0]);
                cropRange = round([x(count) y(count) dx(count) dy(count)]);
            else
                cropRange = round([x(count) y(count) dx(count) dy(count)]);
            end
        else
            cropRange = round([x(count) y(count) dx(count) dy(count)]);
        end
        data.cropRange = cropRange;
        data.cropRangeInterpolated = 1;
        
        handles.settings.metadataGlobal{j}.data = data;
        
        save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(j).name), 'data');
        
        % Save crop range for all channels
        channelData = get(handles.uicontrols.popupmenu.channel, 'String');
        if numel(channelData) > 1
            channel = channelData{get(handles.uicontrols.popupmenu.channel, 'Value')};
            ch_toProcess = find(~cellfun(@(x) strcmp(x, channel), channelData));
            for c = 1:numel(ch_toProcess)
                try
                    filename_ch = fullfile(handles.settings.directory, ...
                        strrep(handles.settings.lists.files_metadata(j).name, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
                    
                    data = load(filename_ch);
                    data = data.data;
                    data.cropRangeInterpolated = 1;
                    
                    data.cropRange = cropRange;
                    
                    save(filename_ch, 'data');
                end
            end
            
        end
        
        count = count + 1;
    end
    if checkCancelButton(handles)
        return;
    end
end


updateWaitbar(handles, 1);

displayStatus(handles, 'Done', 'black', 'add');
updateWaitbar(handles, 0);