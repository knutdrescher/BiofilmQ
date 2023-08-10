function processAll(hObject, eventdata, handles)

if strcmp(get(handles.menuHandles.menues.menu_process_batch_allFolders, 'Checked'), 'on')
    
    inputFolder = get(handles.uicontrols.edit.inputFolder, 'String');
    folders = dir(fileparts(inputFolder));
    folders = folders([folders.isdir]);
    folders = folders(3:end);
    [~, ind] = sort_nat({folders.name});
    folders = folders(ind);
    
    answer = questdlg(['Continue processing the following folders?', '', 'Note: the settings associated with each individual folder will be used. If no settings are specified, the last used settings will be applied.', '', cellfun(@(x) ['  "', x, '"'], {folders.name}, 'UniformOutput', false)],...
        'Batch processing', ...
        'Continue','Cancel','Continue');
    % Handle response
    switch answer
        case 'Continue'
            
        case 'Cancel'
            return;
    end
    
    inputFolder_parent = fileparts(get(handles.uicontrols.edit.inputFolder, 'String'));
    
    folders = cellfun(@(x, y) fullfile(x, y), repmat({inputFolder_parent}, 1, numel(folders)), {folders.name}, 'UniformOutput', false);
else
    folders = {get(handles.uicontrols.edit.inputFolder, 'String')};
end

for i = 1:numel(folders)
    if strcmp(get(handles.menuHandles.menues.menu_process_batch_allFolders, 'Checked'), 'on')
        % Updating input directory
        set(handles.uicontrols.edit.inputFolder, 'String', folders{i})
        
        % Press refresh button
        BiofilmQ('pushbutton_refreshFolder_Callback', handles.uicontrols.pushbutton.pushbutton_refreshFolder, eventdata, guidata(hObject));
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_registerImages, 'Checked'), 'on')
        BiofilmQ('pushbutton_registerImages_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_masks , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_createMasks_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_cellParams , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_calculateCellParameters_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_trackCells , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_trackCells_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_visCells , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_visualize_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_exportFCS , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_exportToFCS_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    if strcmp(get(handles.menuHandles.menues.menu_process_all_select_exportCSV , 'Checked'), 'on')
        BiofilmQ('pushbutton_action_exportToCSV_Callback', hObject, eventdata, handles)
        handles = guidata(hObject);
    end
end