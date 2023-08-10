function handles = tidyGUIHandles(handles)

entries = sort(fieldnames(handles));
for i = 1:size(entries, 1)
    entry = entries{i};
    if strfind(entry, 'menu')
        if isempty(strfind(entry, 'popupmenu'))
            handles.menuHandles.menues.(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    if strfind(entry, 'context')
        handles.menuHandles.context.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'uitoolbar')
        handles.menuHandles.uitoolbars.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'Context')
        handles.menuHandles.context.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'colormap_')
        handles.menuHandles.context.colormaps.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'uitoggletool')
        handles.menuHandles.uitoggletools.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    try
        if strcmp(get(handles.(entry), 'Type'), 'uicontrol')
            handles.uicontrols.(get(handles.(entry), 'Style')).(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    try
        if strcmp(get(handles.(entry), 'Type'), 'uitable')
            handles.uitables.(entry) = handles.(entry);
            handles = rmfield(handles, entry);
        end
    end
    if strfind(entry, 'uipanel')
        handles.layout.uipanels.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
    if strfind(entry, 'axes')
        handles.axes.(entry) = handles.(entry);
        handles = rmfield(handles, entry);
    end
end