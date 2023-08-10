function handles = populateTabs(handles, panel, tabgroup)

if nargin < 4
    align = '';
end

idx = strfind(panel, '_');

tabName = panel(idx(1)+1:end);

tabTitle = get(handles.layout.uipanels.(panel), 'Title');

handles.layout.tabs.(tabName) = uitab('Parent', handles.layout.tabs.(tabgroup), 'Title', tabTitle, 'units', 'characters');

handles.layout.uipanels.(panel).Parent = handles.layout.tabs.(tabName);
handles.layout.uipanels.(panel).BorderType = 'none';

% Reposition each panel to same location as panel 1
set(handles.layout.uipanels.(panel),'position',get(handles.layout.tabs.(tabName),'position'), 'Units', 'characters', 'Title', '');

handles.layout.tabs.(tabName).Units = 'Pixels';



