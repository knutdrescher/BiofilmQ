function cancelled = checkCancelButton(handles, type)
cancelled = false;

if nargin == 1
    type = 'cancel';
end
try % if no user interface is present
    if get(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData')
        switch type
            case 'cancel'
                displayStatus(handles, 'Processing cancelled!', 'red', 'add');
                updateWaitbar(handles, 0);
                set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0, 'Enable', 'off', 'String', 'Cancel');
                cancelled = true;
                uiwait(msgbox('Task was cancelled!', 'Please note', 'warn', 'modal'))
            case 'continue'
                displayStatus(handles, 'Continuing', 'red', 'add');
                set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0, 'String', 'Cancel')
                cancelled = true;
        end
    end
end