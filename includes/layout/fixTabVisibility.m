function fixTabVisibility(handles, scrollingPanelHandle)

try
    pos = handles.mainFig.Position;
    h_initial = scrollingPanelHandle.MinimumHeights;
    scrollingPanelHandle.MinimumHeights = pos(4) + 1;
    drawnow;
    scrollingPanelHandle.MinimumHeights = h_initial;
end



