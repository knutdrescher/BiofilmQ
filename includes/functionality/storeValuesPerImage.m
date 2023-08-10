function storeValuesPerImage(hObject, eventdata, handles)
edits = fieldnames(handles.uicontrols.edit);
for i = 1:length(edits)
    if strcmp(get(handles.uicontrols.edit.(edits{i}), 'Tag'), 'action_imageRange')...
            || strcmp(get(handles.uicontrols.edit.(edits{i}), 'Tag'), 'visCell_range')
        params.(get(handles.uicontrols.edit.(edits{i}), 'Tag')) = get(handles.uicontrols.edit.(edits{i}), 'String');
    else
        params.(get(handles.uicontrols.edit.(edits{i}), 'Tag')) = str2num(get(handles.uicontrols.edit.(edits{i}), 'String'));
        
    end
end
checkboxes = fieldnames(handles.uicontrols.checkbox);
for i = 1:length(checkboxes)
    params.(get(handles.uicontrols.checkbox.(checkboxes{i}), 'Tag')) = get(handles.uicontrols.checkbox.(checkboxes{i}), 'Value');
end
popupmenus = fieldnames(handles.uicontrols.popupmenu);
for i = 1:length(popupmenus)
    params.(get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Tag')) = get(handles.uicontrols.popupmenu.(popupmenus{i}), 'Value');
end
tables = fieldnames(handles.uitables);
for i = 1:length(tables)
    params.(get(handles.uitables.(tables{i}), 'Tag')) = get(handles.uitables.(tables{i}), 'Data');
end

%% Save parameters
save(fullfile(handles.settings.directory, 'parameters.mat'), 'params');

displayStatus(handles, 'Parameters updated', 'green')