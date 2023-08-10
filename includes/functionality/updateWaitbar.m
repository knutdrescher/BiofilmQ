function updateWaitbar(handles, value)
try
    if ~value
        disableCancelButton(handles)
    end
    
    delete(get(handles.axes.axes_status, 'Children'));
    h = area(handles.axes.axes_status, [0 value], [1 1]);
    h.FaceColor = [0.929,  0.694,  0.125];
    set(handles.axes.axes_status, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [], 'YTick', []);
    drawnow;
end