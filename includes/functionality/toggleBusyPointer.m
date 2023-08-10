function toggleBusyPointer(handles, busyMode)

if busyMode
    handles.settings.busy = true;
    set(handles.mainFig,'pointer','watch');
    %drawnow;
else
    handles.settings.busy = false;
    set(handles.mainFig,'pointer','arrow');
end