function [range, handles] = checkFileRange(hObject, eventdata, handles)

% Check image range
range = str2num(handles.uicontrols.edit.action_imageRange.String);

switch handles.uicontrols.popupmenu.popupmenu_fileType.Value
    case 1 % Nd2-file
        files = handles.settings.lists.files_nd2;
    case 6
        files = handles.settings.lists.files_sim;
    case 4
        files = handles.settings.lists.files_cells;
    otherwise
        files = handles.settings.lists.files_tif; % Tif stacks
end
if isempty(range)
    range = cellfun(@(x) isempty(x), strfind({files.name}, 'missing'));
    if numel(range) > 1
        handles.uicontrols.edit.action_imageRange.String = assembleImageRange(find(range));
    else
        handles.uicontrols.edit.action_imageRange.String = '1';
        range = 1;
    end
end

range_new = intersect(range, 1:numel(files));

if numel(range) ~= numel(range_new)
    warning('backtrace', 'off')
    warning('The image range was adapted to match the existing file list.');
    warning('backtrace', 'on')
    handles.uicontrols.edit.action_imageRange.String = assembleImageRange(range_new);
    handles = storeValues(hObject, eventdata, handles);
end

range = range_new;
