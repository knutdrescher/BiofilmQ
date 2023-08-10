function handles = enable_ellipse_representation(handles)

    handles.uicontrols.checkbox.ellipseRepresentation = ...
        uicontrol( ...
            'Tag', 'ellipseRepresentation' ...
            ,'Style', 'checkbox' ...
            ,'String', 'Use ellipse representation' ...
            ,'Callback', @(hObject,eventdata)BiofilmQ('ellipseRepresentation_Callback',hObject,eventdata,guidata(hObject))...
            );

     h2_1_1 = handles.layout.tabs.workflow_dataExport_vtk.findobj('Tag', 'reducePolygonsTo').Parent;
     
     handles.uicontrols.checkbox.ellipseRepresentation.Parent = h2_1_1;
     
     h2_1_1.Widths = [230, 40, -1];
     
     h2_1_1.Parent.Parent.Parent.Widths = 450;
     