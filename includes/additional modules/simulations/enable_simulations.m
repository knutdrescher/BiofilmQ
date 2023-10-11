function handles = enable_simulations(handles)

% Enable simulation selection in popupmenu
handles.uicontrols.popupmenu.popupmenu_fileType.String{end+1} = 'Simulation-files';

