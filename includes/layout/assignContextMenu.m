%Reassining Context-Menues
function handles = assignContextMenu(handles, buttonHandles, parent)
buttonNames = get(buttonHandles, 'Tag');
if ~iscell(buttonNames)
    buttonNames = {buttonNames};
end

for j = 1:size(buttonNames, 1)
    contextMenuName = ['contextMenu_', buttonNames{j}];
    if ~isempty(findobj(parent, 'Tag', buttonNames{j})) && ~isempty(findobj(handles.mainWindow, 'Tag', contextMenuName))
        set(findobj(parent, 'Tag', buttonNames{j}),...
            'UIContextMenu', findobj(handles.mainWindow, 'Tag', contextMenuName));
    end
end
