function handles = toggleUIElements(handles, state, type, init)

if nargin == 3
    init = false;
else
    init = true;
end


UIElements = num2cell([findobj(handles.layout.tabs.imageProcessing, 'Style', 'popupmenu') ...
        ; findobj(handles.layout.tabs.imageProcessing, 'Type', 'uitable') ...
        ; findobj(handles.layout.tabs.imageProcessing, 'Style', 'listbox') ...
        ; findobj(handles.layout.tabs.imageProcessing, 'Style', 'slider') ...
        ; findobj(handles.layout.tabs.imageProcessing, 'Style', 'edit') ...
        ; findobj(handles.layout.tabs.imageProcessing, 'Style', 'pushbutton') ...
        ; findobj(handles.layout.tabs.imageProcessing, 'Style', 'checkbox')]);
    
[~, ind] = sort(cellfun(@(x) x.Tag, UIElements, 'UniformOutput', false));
UIElements = UIElements(ind);
%fprintf('Found %d UIElements', numel(UIElements));

switch type
    case 'image_processing'
        switch state
            case 0
                if ~handles.settings.GUIDisabled
                    
                    handles.settings.elementStates = cellfun(@(x) x.Enable, UIElements, 'UniformOutput', false);
                    handles.settings.elementNames = cellfun(@(x) x.Tag, UIElements, 'UniformOutput', false);
                    handles.settings.GUIDisabled = true;
                    
                    % Disable all elements
                    for i = 1:numel(UIElements)
                        UIElements{i}.Enable = 'off';
                    end
                    
                    handles.uicontrols.edit.inputFolder.Enable = 'on';
                    handles.uicontrols.pushbutton.pushbutton_refreshFolder.Enable = 'on';
                    handles.uicontrols.pushbutton.pushbutton_browseFolder.Enable = 'on';
                    handles.uicontrols.listbox.listbox_status.Enable = 'on';
                    
                    if init
                        UIElements = num2cell(findobj(handles.mainFig, 'Type', 'uimenu'));
                        for i = 1:numel(UIElements)
                            UIElements{i}.Enable = 'off';
                        end
                        
                        handles.menuHandles.menues.menu_file.Enable = 'on';
                        handles.menuHandles.menues.menu_view_decreaseFontSize.Enable = 'on';
                        handles.menuHandles.menues.menu_view_increaseFontSize.Enable = 'on';
                        handles.menuHandles.menues.menu_file_close.Enable = 'on';
                        handles.menuHandles.menues.menu_file_selectDir.Enable = 'on';
                        handles.menuHandles.menues.menu_view.Enable = 'on';
                        handles.menuHandles.menues.menu_view_refresh.Enable = 'on';
                        handles.menuHandles.menues.menu_development.Enable = 'on';
                        handles.menuHandles.menues.menu_development_exportGuidata.Enable = 'on';
                        handles.menuHandles.menues.menu_help.Enable = 'on';
                        arrayfun(@(x) set(x, 'Enable', 'On'), handles.menuHandles.menues.menu_help.Children);
                        arrayfun(@(x) set(x, 'Enable', 'On'), handles.menuHandles.menues.menu_help_onlineHelp.Children);
                    else
                        
                    end
                    
                    
                end
            case 1
                handles.settings.GUIDisabled = false;
                for i = 1:numel(UIElements)
                    UIElements{i}.Enable = handles.settings.elementStates{i};
                end
                UIElements = num2cell(findobj(handles.mainFig, 'Type', 'uimenu'));
                for i = 1:numel(UIElements)
                    UIElements{i}.Enable = 'on';
                end
                
                % Always enable visualization loading options
                handles.handles_analysis.uicontrols.checkbox.loadPixelIdxLists.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.useRefTimepoint.Enable = 'on';
                handles.handles_analysis.uicontrols.checkbox.loadMaxFrame.Enable = 'on';
                handles.handles_analysis.uicontrols.pushbutton.pushbutton_load.Enable = 'on';
                handles.handles_analysis.uicontrols.popupmenu.channel.Enable = 'on';
                handles.handles_analysis.uicontrols.text.text_fluorescenceChannel.Enable = 'on';
        end
        
    case 'visualization'
        UIElements = num2cell([findobj(handles.layout.tabs.visualization, 'Style', 'popupmenu') ...
            ; findobj(handles.layout.tabs.visualization, 'Type', 'uitable') ...
            ; findobj(handles.layout.tabs.visualization, 'Style', 'text')...
            ; findobj(handles.layout.tabs.visualization, 'Style', 'listbox')...
            ; findobj(handles.layout.tabs.visualization, 'Style', 'slider')...
            ; findobj(handles.layout.tabs.visualization, 'Style', 'edit')...
            ; findobj(handles.layout.tabs.visualization, 'Style', 'pushbutton') ...
            ; findobj(handles.layout.tabs.visualization, 'Style', 'checkbox')]);
        
        [~, ind] = sort(cellfun(@(x) x.Tag, UIElements, 'UniformOutput', false));
        UIElements = UIElements(ind);

        
        switch state
            case 0
                if ~handles.settings.GUIDisabledVisualization
                    
                    handles.settings.elementStatesVisualization = cellfun(@(x) x.Enable, UIElements, 'UniformOutput', false);
                    handles.settings.GUIDisabledVisualization = true;
                    
                    % Disable all elements
                    for i = 1:numel(UIElements)
                        UIElements{i}.Enable = 'off';
                    end
                end
            case 1
                handles.settings.GUIDisabledVisualization = false;
                
                for i = 1:numel(UIElements)
                    if strcmp(handles.settings.elementStatesVisualization{i}, 'on')
                        UIElements{i}.Enable = handles.settings.elementStatesVisualization{i};
                    end
                end
        end
end

