function handles = restylePanel(handles, uipanel_handle, panelColor, parent_handle, pos)

if nargin < 3
    panelColor = [0.7490 0.902 1];
end

if nargin < 4
    parent_handle = uipanel_handle.Parent;
end

uipanel_handle.Units = 'normalized';

if nargin < 5
    pos = uipanel_handle.Position;
end

boxPanelName = strrep(uipanel_handle.Tag, 'uipanel', 'boxpanel');
handles.layout.boxPanels.(boxPanelName) = uix.BoxPanel('Parent', parent_handle, 'Position', pos,...
    'Title', uipanel_handle.Title, 'Units', 'normalized', 'TitleColor', panelColor, 'ForegroundColor', [0 0 0]);

uipanel_handle.Parent = handles.layout.boxPanels.(boxPanelName);
uipanel_handle.Title = [];
uipanel_handle.BorderType = 'none';

handles.layout.boxPanels.(boxPanelName).Units = 'characters';