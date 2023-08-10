function handles = additionalCallbacks(uielement, hObject, eventdata, handles, init)
if nargin == 4
    init = false;
else
    init = true;
end

switch uielement
    
    case 'segmentationMethod_Callback'
        tabs_visability = struct( ...
            'workflow_segmentation_thresholding', false, ...
            'workflow_segmentation_edgeDetection', false, ...
            'workflow_segmentation_generalSettings', false, ...
            'workflow_segmentation_labelImage_channel', false, ...
            'workflow_segmentation_thresholdBySlice', false, ...
            'workflow_segmentation_objectDeclumping', true);
        
        idx = handles.uicontrols.popupmenu.segmentationMethod.Value;
        segmentationMethod = handles.uicontrols.popupmenu.segmentationMethod.String{idx};
        
        switch segmentationMethod
            case 'Thresholding'
                tabs_visability.workflow_segmentation_thresholding = true;
                
                
                if ~init && handles.settings.showMsgs
                    answer = questdlg({'Do you want to switch to grid-based segmentation and load defaults?', '',...
                        'The defaults are:',...
                        '--------------------------------------------------------',...
                        'Grid-side-length: 20 vox',...
                        'Declumping method: grid',...
                        'Stop processing after certain number of objects is reached: false',...
                        '3D median filtering after segmentation: false',...
                        'Remove objects with less then 100 voxels: false',...
                        '--------------------------------------------------------'}, 'Load defaults?', 'Yes', 'No', 'No');
                    switch answer
                        case 'Yes'
                            handles.uicontrols.checkbox.median3D.Value = 0;
                            handles.uicontrols.popupmenu.declumpingMethod.Value = 1;
                            handles.uicontrols.edit.gridSpacing.String = '20';
                            handles.uicontrols.checkbox.stopProcessingNCellsMax.Value = 0;
                            handles.uicontrols.checkbox.removeVoxels.Value = 0;
                        case 'No'
                    end
                end

                handles = setGammaValueVisability(handles, 'off');
                
            case 'Edge detection'
                tabs_visability.workflow_segmentation_edgeDetection = true;
                tabs_visability.workflow_segmentation_generalSettings = true;
                
                if ~init && handles.settings.showMsgs
                    answer = questdlg({'Do you want to switch to watershedding-based cell declumping and load defaults?', '',...
                        'The defaults are:',...
                        '--------------------------------------------------------',...
                        'Gamma = 3',...
                        'Image denoising = true',...
                        'Declumping method: watershedding',...
                        '3D median filtering after segmentation = true',...
                        'Remove objects with less then 100 voxels = true',...
                        '--------------------------------------------------------'}, 'Load defaults?', 'Yes', 'No', 'No');
                    switch answer
                        case 'Yes'
                            handles.uicontrols.popupmenu.gamma.Value = 3;
                            handles.uicontrols.popupmenu.declumpingMethod.Value = 3;
                            handles.uicontrols.checkbox.median3D.Value = 1;
                            handles.uicontrols.edit.removeVoxelsOfSize.String = '100';
                            handles.uicontrols.checkbox.removeVoxels.Value = 1;
                            handles.uicontrols.checkbox.denoiseImages.Value = 1;
                        case 'No'
                    end
                end
                handles = setGammaValueVisability(handles, 'on');
            case  'Label image'
                tabs_visability.workflow_segmentation_labelImage_channel = true;
                tabs_visability.workflow_segmentation_objectDeclumping = false;
            case 'Thresholding by Slice'
                tabs_visability.workflow_segmentation_thresholdBySlice = true;
                handles = setGammaValueVisability(handles, 'off');
                
        end
        handles = setWorkflowTabVisability(handles, tabs_visability);
        
    case 'files_Callback'
        fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');
        if fileType == 6
            generateSimulationPreview(hObject, eventdata, handles);
        end
        
    case 'watershedding_size_unit_Callback'
        unit = get(hObject, 'Value');
        params = load(fullfile(handles.settings.directory, 'parameters.mat'));
        params = params.params;
        
        if unit ~= params.watershedding_size_unit
            if unit == 2
                params.minObjectSize = params.minObjectSize*(params.scaling_dxy*1e-9)^3/(1e-6)^3;
                params.maxObjectSize = params.maxObjectSize*(params.scaling_dxy*1e-9)^3/(1e-6)^3;
                
            end
            
            if unit == 1
                params.minObjectSize = round(params.minObjectSize/((params.scaling_dxy*1e-9)^3/(1e-6)^3));
                params.maxObjectSize = round(params.maxObjectSize/((params.scaling_dxy*1e-9)^3/(1e-6)^3));
                
            end
        end
        
        set(handles.uicontrols.edit.minObjectSize, 'String', num2str(params.minObjectSize));
        set(handles.uicontrols.edit.maxObjectSize, 'String', num2str(params.maxObjectSize));
        
        storeValues(hObject, eventdata, handles);
        
    case 'I_base_perStack_Callback'
        
        if get(handles.uicontrols.checkbox.I_base_perStack, 'value')
            set(handles.uicontrols.edit.I_base, 'Enable', 'off')
            set(handles.uicontrols.pushbutton.pushbutton_pre_detBackground, 'Enable', 'off')
            set(handles.uicontrols.pushbutton.pushbutton_ApplyBGAll, 'Enable', 'off')
        else
            set(handles.uicontrols.edit.I_base, 'Enable', 'on')
            set(handles.uicontrols.pushbutton.pushbutton_pre_detBackground, 'Enable', 'on')
            set(handles.uicontrols.pushbutton.pushbutton_ApplyBGAll, 'Enable', 'on')
        end
        storeValues(hObject, eventdata, handles);
        
        
    case 'pushbutton_determineManualThreshold_I_base_Callback'
        set(handles.uicontrols.pushbutton.pushbutton_determineManualThreshold_I_base, 'String', 'Please wait');
        I_base = get(handles.uicontrols.edit.I_base, 'String');
        thresh_manual_temp = get(handles.uicontrols.edit.manualThreshold, 'String');
        set(handles.uicontrols.edit.manualThreshold, 'String', I_base);
        
        set(handles.uicontrols.popupmenu.manualThresholdMethod, 'Value', 2)
        BiofilmQ('pushbutton_determineManualThreshold_Callback',hObject,eventdata,guidata(hObject))
        
        I_base = get(handles.uicontrols.edit.manualThreshold, 'String');
        set(handles.uicontrols.edit.manualThreshold, 'String', thresh_manual_temp);
        set(handles.uicontrols.edit.I_base, 'String', I_base);
        set(handles.uicontrols.pushbutton.pushbutton_determineManualThreshold_I_base, 'String', 'Determine visually');
        
        file = handles.java.files_jtable.getSelectedRow()+1;
        storeValues(hObject, eventdata, handles, file);
        
    case 'ellipseRepresentation_Callback'
        if get(hObject, 'value')
            set(handles.uicontrols.edit.reducePolygonsTo, 'String', '0.3')
        else
            set(handles.uicontrols.edit.reducePolygonsTo, 'String', '0.05')
        end
        storeValues(hObject, eventdata, handles);
        
    case 'skipDeclumpingFirstFrame_Callback'
        storeValues(hObject, eventdata, handles);
        

end
end

function handles = setGammaValueVisability(handles, value)
    handles.uicontrols.text.text_workflow_segmentation_preprocessing_gamma.Visible = value;
    handles.uicontrols.popupmenu.gamma.Visible = value;
    handles.uicontrols.text.text_workflow_segmentation_preprocessing_gammaDescr.Visible = value;
end

function handles = setWorkflowTabVisability(handles, tabs_visability)
    fnames = fieldnames(tabs_visability);
    for i = 1:numel(fnames)
        fieldname = fnames{i};
        if tabs_visability.(fieldname)
            handles.layout.tabs.(fieldname).Parent = handles.layout.tabs.workflow_segmentationTabs;
        else
            handles.layout.tabs.(fieldname).Parent = handles.layout.tabs.invisibleTabs;
        end
    end
    sortTabs(handles.layout.tabs.workflow_segmentationTabs);
end