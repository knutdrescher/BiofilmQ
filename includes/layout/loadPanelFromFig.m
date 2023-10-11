function [panelTitles, handles] = loadPanelFromFig(handles, parent, contentName)
%Load File
eval(['loadedContent = ',contentName,'(''Visible'', ''off'');']);

%Load Menues
menues = findobj(loadedContent, 'Type', 'uicontextmenu');
if isempty(strfind(contentName, 'default'))
    set(menues, 'UserData', 'tempMenu');
end
copyobj(menues, handles.mainWindow);


%Load panels
panels = findobj(loadedContent, 'Type', 'uipanel');

if ~isempty(panels)
for i=1:size(panels,1)
    children = get(panels(i), 'Children');
    h = uipanel('Parent', parent);
    copyobj(children, h);
    if iscell(get(panels(i), 'Title'))
        temp = get(panels(i), 'Title');
        panelTitles{i} = temp{1};
    else
        panelTitles{i} = get(panels(i), 'Title');
    end
    
    handles = assignCallbacks(handles, children, h);
    handles = storeTagsInFields(handles, children, h);
    handles = assignContextMenu(handles, children, h);
end
else
    panelTitles = [];
end
delete(loadedContent);