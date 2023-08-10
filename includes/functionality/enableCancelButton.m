function enableCancelButton(handles)
try
    set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0, 'Enable', 'on');
end