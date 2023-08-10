function changeFontSize(hObject, eventdata, handles, mode)

UIElements = findobj(handles.mainFig);

for i = 1:numel(UIElements)
    try
        UIElements(i).FontSize = UIElements(i).FontSize + mode;
    end
end