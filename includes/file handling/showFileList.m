function handles = showFileList(hObject, eventdata, handles, file)
file_list = [];

handles.uicontrols.pushbutton.pushbutton_files_export.Enable =  'off';
handles.uicontrols.checkbox.files_createPosFolder.Enable = 'off';
handles.uicontrols.pushbutton.pushbutton_files_export2.Enable =  'off';
handles.uicontrols.checkbox.files_createPosFolder2.Enable = 'off';

switch file
    case 'tif'
        
        if ~strcmp(handles.settings.displayMode, 'image_processing')
            showTabs(handles, 'image_processing')
            handles.settings.displayMode = 'image_processing';
        end
        
        if ~isempty(handles.settings.lists.files_tif)
            for i = 1:length(handles.settings.lists.files_tif)
                file_i = handles.settings.lists.files_tif(i).name;
                file_i = strrep(file_i, '_frame', '<font color="black">_frame<font color="green">');
                file_i = strrep(file_i, '_pos', '<font color="black">_pos<font color="yellow">');
                file_i = strrep(file_i, '_ch', '<font color="black">_ch<font color="blue">');
                file_i = strrep(file_i, '_Nz', '<font color="black">_Nz<font color="red">');
                file_i = strrep(file_i, '.tif', '<font color="black">.tif');
                
                file_list{i,1} = ['<html>', file_i];
            end
            handles = toggleUIElements(handles, 1, 'image_processing');
        else
            handles = toggleUIElements(handles, 0, 'image_processing');
            if handles.settings.showMsgs
                uiwait(msgbox('No TIF-stacks found. Switch directory or select different file type to display (i.e. microscope vendor files).', 'Please note', 'help', 'modal'));
            end
        end
        
    case 'metadata'
        
        if ~strcmp(handles.settings.displayMode, 'image_processing')
            showTabs(handles, 'image_processing')
            handles.settings.displayMode = 'image_processing';
        end
        
        handles = toggleUIElements(handles, 0, 'image_processing');
        
        if ~isempty(handles.settings.lists.files_tif)
            for i = 1:length(handles.settings.lists.files_metadata)
                file_i = handles.settings.lists.files_metadata(i).name;
                file_i = strrep(file_i, '_frame', '<font color="black">_frame<font color="green">');
                file_i = strrep(file_i, '_pos', '<font color="black">_pos<font color="yellow">');
                file_i = strrep(file_i, '_ch', '<font color="black">_ch<font color="blue">');
                file_i = strrep(file_i, '_Nz', '<font color="black">_Nz<font color="red">');
                file_i = strrep(file_i, '_metadata', '<font color="black">_metadata');
                
                if strcmp(handles.settings.lists.files_metadata(i).name, 'missing')
                    file_list{i,1} = ['<html><font color="gray"><i>', num2str(i), ') ', file_i];
                else
                    file_list{i,1} = ['<html>', file_i];
                end
            end
            handles = toggleUIElements(handles, 1, 'image_processing');
        else
            handles = toggleUIElements(handles, 0, 'image_processing');
            uiwait(msgbox('No metadata-files found.', 'Please note', 'warn', 'modal'));
        end
        
        
    case 'nd2'
        
        if ~strcmp(handles.settings.displayMode, 'nd2')
            showTabs(handles, 'nd2')
            handles.settings.displayMode = 'nd2';
        end
        
        handles = toggleUIElements(handles, 0, 'image_processing');
        if ~isempty(handles.settings.lists.files_nd2)
            for i = 1:length(handles.settings.lists.files_nd2)
                file_i = handles.settings.lists.files_nd2(i).name;
                file_list{i,1} = file_i;
            end
            handles.uicontrols.pushbutton.pushbutton_files_export.Enable = 'on';
            handles.uicontrols.pushbutton.pushbutton_files_export2.Enable = 'on';
            handles.uitables.files.Enable = 'on';
            handles.uicontrols.checkbox.files_createPosFolder.Enable = 'on';
            handles.uicontrols.checkbox.files_createPosFolder2.Enable = 'on';
            handles.uicontrols.pushbutton.pushbutton_files_delete.Enable = 'on';
            handles.uicontrols.pushbutton.pushbutton_action_imageRange_takeAll.Enable = 'on';
            handles.uicontrols.pushbutton.pushbutton_action_imageRange_takeSel.Enable = 'on';
            handles.uicontrols.edit.action_imageRange.Enable = 'on';
        else
            uiwait(msgbox('No files found.', 'Please note', 'help', 'modal'));
        end

    case 'importTif'
        
        if ~strcmp(handles.settings.displayMode, 'importTif')
            showTabs(handles, 'importTif')
            handles.settings.displayMode = 'importTif';
        end
        
        handles = toggleUIElements(handles, 0, 'image_processing');
        tif_files = dir(fullfile(handles.settings.directory, '*.tif'));
        if ~isempty(tif_files)
            for i = 1:numel(tif_files)
                file_i = tif_files(i).name;
                file_list{i,1} = file_i;
            end
            
            handles.uicontrols.edit.importPositionRegexp.Enable = 'on';
            handles.uicontrols.edit.importChannelRegexp.Enable = 'on';
            handles.uicontrols.edit.importTimeRegexp.Enable = 'on';
            handles.uicontrols.edit.importZPosRegexp.Enable = 'on';
            handles.uicontrols.edit.importValidationFilename.Enable = 'on';
            
            handles.uicontrols.pushbutton.importValidationPushbutton.Enable = 'on';
            handles.uicontrols.pushbutton.importValidationPushbuttonAll.Enable = 'on';
            handles.uicontrols.pushbutton.importCustomTiffPushbutton.Enable = 'off';
            
            handles.uitables.importResults.Enable = 'on';
            
        else
            uiwait(msgbox('No files found.', 'Please note', 'help', 'modal'));
        end
        
    case 'cells'
        
        if ~strcmp(handles.settings.displayMode, 'object_processing')
            showTabs(handles, 'object_processing')
            handles.settings.displayMode = 'object_processing';
        end
        
        if ~isempty(handles.settings.lists.files_cells) && handles.settings.dataFolder
            for i = 1:length(handles.settings.lists.files_cells)
                file_i = handles.settings.lists.files_cells(i).name;
                file_i = strrep(file_i, '_frame', '<font color="black">_frame<font color="green">');
                file_i = strrep(file_i, '_pos', '<font color="black">_pos<font color="yellow">');
                file_i = strrep(file_i, '_ch', '<font color="black">_ch<font color="blue">');
                file_i = strrep(file_i, '_Nz', '<font color="black">_Nz<font color="red">');
                file_i = strrep(file_i, '_data.mat', '<font color="black">_data.mat');
                
                if strcmp(handles.settings.lists.files_cells(i).name, 'missing')
                    file_list{i,1} = ['<html><font color="gray"><i>', num2str(i), ') ', file_i];
                else
                    file_list{i,1} = ['<html>', file_i];
                end
            end
            handles = toggleUIElements(handles, 1, 'image_processing');  
        else
            handles = toggleUIElements(handles, 0, 'image_processing');  
            uiwait(msgbox('Images were not segmented, yet.', 'Please note', 'warn', 'modal'));
        end
        
        
    case 'vtk'
        
        if ~strcmp(handles.settings.displayMode, 'visualization')
            showTabs(handles, 'visualization')
            handles.settings.displayMode = 'visualization';
        end
        
        showTabs(handles, 'vtk')
        if ~isempty(handles.settings.lists.files_vtk) && handles.settings.dataFolder
            for i = 1:length(handles.settings.lists.files_vtk)
                file_i = handles.settings.lists.files_vtk(i).name;
                file_i = strrep(file_i, '_frame', '<font color="black">_frame<font color="green">');
                file_i = strrep(file_i, '_pos', '<font color="black">_pos<font color="yellow">');
                file_i = strrep(file_i, '_ch', '<font color="black">_ch<font color="blue">');
                file_i = strrep(file_i, '_Nz', '<font color="black">_Nz<font color="red">');
                file_i = strrep(file_i, '.vtk', '<font color="black">.vtk');
                
                if strcmp(handles.settings.lists.files_vtk(i).name, 'missing')
                    file_list{i,1} = ['<html><font color="gray"><i>', num2str(i), ') ', file_i];
                else
                    file_list{i,1} = ['<html>', file_i];
                end
            end
            handles = toggleUIElements(handles, 1, 'image_processing');  
        else
            handles = toggleUIElements(handles, 0, 'image_processing');  
            uiwait(msgbox('Visualization files were not generated, yet.', 'Please note', 'warn', 'modal'));
        end

    case 'sim'
        
        if ~strcmp(handles.settings.displayMode, 'simulations')
            showTabs(handles, 'simulations')
            handles.settings.displayMode = 'simulations';
        end
        
        if ~isempty(handles.settings.lists.files_sim)
            for i = 1:length(handles.settings.lists.files_sim)
                file_i = handles.settings.lists.files_sim(i).name;
                file_i = strrep(file_i, '_timestep', '_timestep<font color="green">');
                file_i = strrep(file_i, '.txt', '<font color="black">.txt');

                file_list{i,1} = ['<html>', file_i];
            end
            handles = toggleUIElements(handles, 1, 'image_processing');
        else
            handles = toggleUIElements(handles, 0, 'image_processing');
            uiwait(msgbox('No simulation files found.', 'Please note', 'warn', 'modal'));
        end
        
        
        
end

try
    if ~isempty(file_list)
        if ~isempty(handles.settings.metadataTable)
            file_list = [file_list, handles.settings.metadataTable(:,2:end)];
        end
        % Check range
        checkFileRange(hObject, eventdata, handles);    
    else
        file_list = {'No files found'};
    end
end

set(handles.uitables.files, 'Data', file_list);

handles.uicontrols.popupmenu.popupmenu_fileType.Enable = 'on';

function showTabs(handles, type)
switch type
    case 'simulations'
        handles.layout.tabs.workflow_simulationInput.Title = '1. Simulation input';
        handles.layout.tabs.workflow_parameters.Title = '2. Parameter calculation';
        handles.layout.tabs.workflow_dataExport.Title = '3. Data export';
        
        handles.layout.tabs.workflow_customTiffImportPanel.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_exportNd2.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_simulationInput.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_imagePreparation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_segmentation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_parameters.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_cellTracking.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_dataExport.Parent = handles.layout.tabs.workflow;
        
    case 'image_processing'
        handles.layout.tabs.workflow_parameters.Title = '3. Parameter calculation';
        handles.layout.tabs.workflow_cellTracking.Title = '4. Time-series analysis';
        handles.layout.tabs.workflow_dataExport.Title = '5. Data export';
        
        handles.layout.tabs.workflow_customTiffImportPanel.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_exportNd2.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_simulationInput.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_imagePreparation.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_segmentation.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_parameters.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_cellTracking.Parent = handles.layout.tabs.workflow;       
        handles.layout.tabs.workflow_dataExport.Parent = handles.layout.tabs.workflow;
        
    case 'object_processing'
        handles.layout.tabs.workflow_parameters.Title = '1. Parameter calculation';
        handles.layout.tabs.workflow_cellTracking.Title = '2. Time-series analysis';
        handles.layout.tabs.workflow_dataExport.Title = '3. Data export';
        
        handles.layout.tabs.workflow_customTiffImportPanel.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_exportNd2.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_simulationInput.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_imagePreparation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_segmentation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_parameters.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_cellTracking.Parent = handles.layout.tabs.workflow;       
        handles.layout.tabs.workflow_dataExport.Parent = handles.layout.tabs.workflow;
        
    case 'nd2'
        handles.layout.tabs.workflow_exportNd2.Title = '1. Import to TIF';
        
        handles.layout.tabs.workflow_customTiffImportPanel.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_exportNd2.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_simulationInput.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_imagePreparation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_segmentation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_parameters.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_cellTracking.Parent = handles.layout.tabs.invisibleTabs;       
        handles.layout.tabs.workflow_dataExport.Parent = handles.layout.tabs.invisibleTabs;
        
    case 'visualization'
        handles.layout.tabs.workflow_dataExport.Title = '1. Data export';
        
        handles.layout.tabs.workflow_customTiffImportPanel.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_exportNd2.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_simulationInput.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_imagePreparation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_segmentation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_parameters.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_cellTracking.Parent = handles.layout.tabs.invisibleTabs;       
        handles.layout.tabs.workflow_dataExport.Parent = handles.layout.tabs.workflow;
        
    case 'importTif'
        handles.layout.tabs.workflow_customTiffImportPanel.Title ='1. Import custom TIF';
        
        handles.layout.tabs.workflow_customTiffImportPanel.Parent = handles.layout.tabs.workflow;
        handles.layout.tabs.workflow_exportNd2.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_simulationInput.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_imagePreparation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_segmentation.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_parameters.Parent = handles.layout.tabs.invisibleTabs;
        handles.layout.tabs.workflow_cellTracking.Parent = handles.layout.tabs.invisibleTabs;       
        handles.layout.tabs.workflow_dataExport.Parent = handles.layout.tabs.invisibleTabs;
end

sortTabs(handles.layout.tabs.workflow);

% Handle redraw bug
fixTabVisibility(handles, handles.layout.boxPanels.imageProcessing_workflow_slidePanel);

        