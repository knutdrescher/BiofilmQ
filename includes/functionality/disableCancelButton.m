function disableCancelButton(handles)
set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0, 'Enable', 'off', 'String', 'Cancel');