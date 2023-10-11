function handles = addPanelToBoxPanel(handles, uipanel_name, boxpanel_name)

handles.layout.uipanels.(uipanel_name).Parent = handles.layout.boxPanels.(boxpanel_name);
handles.layout.uipanels.(uipanel_name).UserData = handles.layout.uipanels.(uipanel_name).Title;
handles.layout.uipanels.(uipanel_name).Title = '';
handles.layout.uipanels.(uipanel_name).BorderType = 'none';