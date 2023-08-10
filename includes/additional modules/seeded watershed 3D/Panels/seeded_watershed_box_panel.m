function handles = seeded_watershed_box_panel(handles, debug)
%SEEDED_WATERSHED_BOX_PANEL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    debug = false;
end
        if debug
            padding = 8;
            spacing = 8;
            objectHeight = 22;
  
            f = figure();
            
        else
            padding = handles.settings.padding;
            spacing = handles.settings.spacing;
            objectHeight = handles.settings.objectHeight;
            f = handles.mainFig;
        end
        
        %% Interface definitions
        % UIPanels
        handles.layout.uipanels.uipanel_workflow_segmentation_seededWatershed = ...
            uipanel( ...
            'Parent', f, ... 
            'Tag', 'uipanel_workflow_segmentation_seededWatershed', ...
            'Title', 'Seeded watershed options');
        
        
        % Labels
        handles.uicontrols.text.text_seededWatershedCellThresh = ...
        uicontrol( ...
            'Tag', 'text_seededWatershedCellThresh', ...
            'Style', 'text', ...
            'HorizontalAlignment', 'right', ...
            'String', 'Minimal number of maxima for maxima clustering');
        
        handles.uicontrols.text.text_seededWatershedDebug = ...
        uicontrol( ...
            'Tag', 'text_seededWatershedDebug', ...
            'Style', 'text', ...
            'HorizontalAlignment', 'right', ...
            'String', 'Debug');
        
        % edits
        handles.uicontrols.edit.seededWatershedCellThresh = ...
        uicontrol( ...
            'Tag', 'seededWatershedCellThresh', ...
            'Style', 'edit', ...
            'String', '10');
        
        % checkboxes
        handles.uicontrols.checkbox.seededWatershedDebug = ...
        uicontrol( ...
            'Tag', 'seededWatershedDebug', ...
            'Style', 'checkbox');
        
        
        %% Interface Layout
        h = uix.VBox( ...
            'Parent', handles.layout.uipanels.uipanel_workflow_segmentation_seededWatershed, ...
            'Padding', 4*padding, ...
            'Spacing', spacing);
        
            h1a = uix.HBox( ...
                'Parent', h, ...
                'Padding', 0, ...
                'Spacing', spacing);
            
                h1a_v1a = uix.VBox( ...
                    'Parent', h1a, ...
                    'Padding', 0, ...
                    'Spacing', 0);
                    
                    % Add space for correct alingment between text box and
                    % edit field
                    uix.Empty('Parent', h1a_v1a); 
                    handles.uicontrols.text.text_seededWatershedCellThresh.Parent = h1a_v1a;
                    
                h1a_v1a.Heights = [0.5*spacing, -1];
                
                handles.uicontrols.edit.seededWatershedCellThresh.Parent = h1a;

            h1a.Widths = [250, 40];
            
            h1b = uix.HBox( ...
                'Parent', h, ...
                'Padding', 0, ...
                'Spacing', spacing);
            
                h1b_v1a = uix.VBox( ...
                    'Parent', h1b, ...
                    'Padding', 0, ...
                    'Spacing', 0);
                    
                    % Add space for correct alingment between text box and
                    % edit field
                    uix.Empty('Parent', h1b_v1a); 
                    handles.uicontrols.text.text_seededWatershedDebug.Parent = h1b_v1a;
                    
                h1b_v1a.Heights = [0.5*spacing, -1];
                
                handles.uicontrols.checkbox.seededWatershedDebug.Parent = h1b;

            h1b.Widths = [250, 40];
                
        h.Heights = [objectHeight, objectHeight];
        
        %% Callbacks
        if ~debug
            handles.uicontrols.edit.seededWatershedCellThresh.Callback = ...
                @(hObject,eventdata) seededWatershedCellThresh_Callback(hObject,eventdata,guidata(hObject));
            
            handles.uicontrols.checkbox.seededWatershedDebug.Callback = ...
                @(hObject,eventdata) seededWatershedDebug_Callback(hObject,eventdata,guidata(hObject));
        end
        
        
end

