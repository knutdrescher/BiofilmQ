function handles = replaceUIPanel(handles, panelName)

% GUI Toolbox Documentation: https://public.brain.mpg.de/Laurent/SheinIdelsonetal2017/NSKToolbox/timeSeriesViewer/GUILayout/layoutdoc/Function%20reference.html
padding = handles.settings.padding;
spacing = handles.settings.spacing;
objectHeight = handles.settings.objectHeight;

switch panelName
    case 'uipanel_experimentFolder'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.edit.inputFolder.Parent = h;
        handles.uicontrols.pushbutton.pushbutton_browseFolder.Parent = h;
        handles.uicontrols.pushbutton.pushbutton_refreshFolder.Parent = h;
        h.Widths = [-1, 60, 75];
        
    case 'uipanel_status'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.text.text_currentTask.Parent = h;
        % Create vertical grid to center axes
        h1 = uix.VBox('Parent', h);
        uix.Empty('Parent', h1);
        handles.axes.axes_status.Parent = h1;
        uix.Empty('Parent', h1);
        h1.Heights = [6, -1, 6];
        handles.uicontrols.pushbutton.pushbutton_cancel.Parent = h;
        h.Widths = [65, -1, 60];
        
    case 'uipanel_folderStats'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding-1, 'Spacing', spacing);
        handles.uicontrols.text.text_folderProperties.Parent = h;
        
    case 'uipanel_imageDetails'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.text.text_fileDetails.Parent = h;
        handles.layout.boxes.axes_preview_container = uix.HBox('Parent', h);
        handles.axes.axes_preview.Parent = handles.layout.boxes.axes_preview_container;
        handles.uicontrols.text.text_fileDetails.Parent = h;
        % Create horizontal grid
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        % Create vertical grid
        h1_1 = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        % Create horizontal grid
        h1_2 = uix.HBox('Parent', h1_1, 'Padding', 0, 'Spacing', spacing);
        h1_2_1 = uix.HBox('Parent', h1_2, 'Spacing', spacing);
        handles.uicontrols.checkbox.displayAlignedImage.Parent = h1_2_1;
        handles.uicontrols.checkbox.displayAllChannels.Parent = h1_2_1;
        
        % Create horizontal grid
        h1_3 = uix.HBox('Parent', h1_1, 'Padding', 0, 'Spacing', 0);
        % Create panel
        h1_3_1 = uix.Panel('Parent', h1_3, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_imageDetails_ch.Title);
        handles.uicontrols.popupmenu.channel.Parent = h1_3_1;
        delete(handles.layout.uipanels.uipanel_imageDetails_ch);
        
        uix.Empty('Parent', h1_3);
        h1_3.Widths = [150 -1];
        
        h1_1.Heights = [objectHeight objectHeight+4*padding];
        
        h1_4 = uix.VButtonBox('Parent', h1, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [85 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_files_showImage.Parent = h1_4;
        handles.uicontrols.pushbutton.pushbutton_files_showOrtho.Parent = h1_4;
        handles.uicontrols.pushbutton.pushbutton_files_overlay.Parent = h1_4;
        
        h1.Widths = [-1, 100];
        
        % Create panel
        h2 = uix.Panel('Parent', h, 'Padding', 0, 'Title', handles.layout.uipanels.uipanel_imageDetails_scaling.Title);
        
        % Create horizontal grid
        h2_1 = uix.HBox('Parent', h2, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.text.text_imageDetails_scaling_dxy.Parent = h2_1;
        handles.uicontrols.edit.scaling_dxy.Parent = h2_1;
        handles.uicontrols.text.text_imageDetails_scaling_dxyUnit.Parent = h2_1;
        uix.Empty('Parent', h2_1);
        handles.uicontrols.text.text_imageDetails_scaling_dz.Parent = h2_1;
        handles.uicontrols.edit.scaling_dz.Parent = h2_1;
        handles.uicontrols.text.text_imageDetails_scaling_dzUnit.Parent = h2_1;
        uix.Empty('Parent', h2_1);
        handles.uicontrols.pushbutton.pushbutton_updateScaling.Parent = h2_1;
        h2_1.Widths = [22 40 20 -1 20 40 20 -1 105];
        delete(handles.layout.uipanels.uipanel_imageDetails_scaling);
        
        h.Units = 'pixels';
        h.Heights = [50 -1 2*objectHeight+4*padding+spacing objectHeight+4*padding];
          
    case 'uipanel_plotCellParameters'
        % Create vertical grid, need five elements
        handles.layout.boxes.plotCellParameters_container = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        handles.layout.boxes.segmentationPreviewLoadButton = uix.HButtonBox('Parent', handles.layout.boxes.plotCellParameters_container, 'Spacing', 0, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_visCell_getParams.Parent = handles.layout.boxes.segmentationPreviewLoadButton;
        handles.layout.boxes.plotCellParameters = uix.VBox('Parent', handles.layout.boxes.plotCellParameters_container, 'Padding', 0, 'Spacing', spacing, 'Visible', 'on');
        
        % Create horizontal grid
        h1 = uix.HBox('Parent', handles.layout.boxes.plotCellParameters, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_visCell_availParams.Parent = h1;
        handles.uicontrols.text.text_visCell_N.Parent = h1;
        h1.Widths = [-1 -1];
        
        % Create horizontal grid
        h2 = uix.HBox('Parent', handles.layout.boxes.plotCellParameters, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.listbox.listbox_visCell_params.Parent = h2;
        h2_1 = uix.VButtonBox('Parent', h2, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [90 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_orthoViewLabelled.Parent = h2_1;
        handles.uicontrols.pushbutton.pushbutton_getColormap.Parent = h2_1;
        h2.Widths = [-1 90];
        
        % Create horizontal grid
        h3 = uix.HBox('Parent', handles.layout.boxes.plotCellParameters, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_visCell_bins.Parent = h3;
        handles.uicontrols.edit.cellVis_nBins.Parent = h3;
        handles.uicontrols.checkbox.checkbox_visCell_autoRange.Parent = h3;
        handles.uicontrols.checkbox.logScale.Parent = h3;
        handles.uicontrols.popupmenu.visCells_plotType.Parent = h3;
         h3.Widths = [40 -1 80 80 90-spacing];
        
        % Create horizontal grid
        h4 = uix.HBox('Parent', handles.layout.boxes.plotCellParameters, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_visCell_range.Parent = h4;
        handles.uicontrols.edit.visCell_range.Parent = h4;
        handles.uicontrols.pushbutton.pushbutton_visCell_histogram.Parent = h4;
        h4.Widths = [40 -1 90-spacing];
        
        handles.layout.boxes.plotCellParameters.Heights = [15 -1 objectHeight objectHeight];
        
        handles.layout.boxes.plotCellParameters.Parent = handles.layout.tabs.invisibleTab;
        
    case 'uipanel_imageRange'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.edit.action_imageRange.Parent = h;
        handles.uicontrols.pushbutton.pushbutton_action_imageRange_takeSel.Parent = h;
        handles.uicontrols.pushbutton.pushbutton_action_imageRange_takeAll.Parent = h;
        uix.Empty('Parent', h);
        handles.layout.uipanels.uipanel_invisibleTabs_placeholder.Parent = h;
        h.Widths = [100 110 80 -1, 0];
        
    case 'workflow_imagePreparation_imageSeriesCuration'
        % Create vertical grid
        handles.layout.boxes.imageSeriesCuration = uix.VBox('Parent', handles.layout.tabs.(panelName), 'Padding', padding, 'Spacing', spacing);
        h = handles.layout.boxes.imageSeriesCuration;
        
        handles.layout.uipanels.panel_workflow_imagePreparation_imageSeriesCuration_oofStacks = uix.Panel('Parent', h, 'Title', handles.layout.uipanels.uipanel_workflow_imagePreparation_imageSeriesCuration_oofStacks.Title, 'Padding', padding);
        % Create vertical grid
        h1 = uix.VBox('Parent', handles.layout.uipanels.panel_workflow_imagePreparation_imageSeriesCuration_oofStacks, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_imagePreparation_imageSeriesCuration_oofDescr.Parent = h1;
        h1_button = uix.HButtonBox('Parent', h1, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [170 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_findOutOfFocusStacks.Parent = h1_button;
        h1.Heights = [100 objectHeight];
        delete(handles.layout.uipanels.uipanel_workflow_imagePreparation_imageSeriesCuration_oofStacks);
        
        handles.layout.uipanels.panel_workflow_imagePreparation_imageSeriesCuration_corr = uix.Panel('Parent', h, 'Title', handles.layout.uipanels.uipanel_workflow_imagePreparation_imageSeriesCuration_corr.Title, 'Padding', padding);
        % Create vertical grid
        h2 = uix.VBox('Parent', handles.layout.uipanels.panel_workflow_imagePreparation_imageSeriesCuration_corr, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_imagePreparation_imageSeriesCuration_corrDescr.Parent = h2;
        h1_button = uix.HButtonBox('Parent', h2, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [170 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_files_checkFiles.Parent = h1_button;
        h2.Heights = [100 objectHeight];
        delete(handles.layout.uipanels.uipanel_workflow_imagePreparation_imageSeriesCuration_corr);
        
        uix.Empty('Parent', h);
        h.Heights = [100+objectHeight+2*spacing+4*padding, 0, -1];
        
    case 'workflow_imagePreparation_deconvolution'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.tabs.(panelName), 'Padding', 2*padding, 'Spacing', spacing);
        
        handles.uicontrols.text.text_workflow_imagePreparation_deconvolution_descr.Parent = h;
        % Create horizontal grid
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h1_1 = uix.Panel('Parent', h1, 'Title', handles.layout.uipanels.uipanel_workflow_imagePreparation_deconvolution_ch.Title, 'Padding', padding);
        handles.uitables.huygens_wavelengths.Parent = h1_1;
        delete(handles.layout.uipanels.uipanel_workflow_imagePreparation_deconvolution_ch)
        
        h1_2 = uix.Panel('Parent', h1, 'Title', handles.layout.uipanels.uipanel_workflow_imagePreparation_deconvolution_tpl.Title, 'Padding', padding);
        % Create vertical grid
        g = uix.Grid('Parent', h1_2, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_imagePreparation_deconvolution_obj.Parent = g;
        handles.uicontrols.text.text_workflow_imagePreparation_deconvolution_alg.Parent = g;
        handles.uicontrols.text.text_workflow_imagePreparation_deconvolution_it.Parent = g;
        handles.uicontrols.text.text_workflow_imagePreparation_deconvolution_qual.Parent = g;
        handles.uicontrols.text.text_workflow_imagePreparation_deconvolution_snr.Parent = g;
        
        handles.uicontrols.popupmenu.huygens_objTemplate.Parent = g;
        handles.uicontrols.edit.huygens_deconTemplate.Parent = g;
        handles.uicontrols.edit.huygens_Niterations.Parent = g;
        handles.uicontrols.edit.huygens_qualityThreshold.Parent = g;
        handles.uicontrols.edit.huygens_SNR.Parent = g;
        g.Widths = [-1 -1];
        g.Heights = [1 1 1 1 1] * objectHeight;
        delete(handles.layout.uipanels.uipanel_workflow_imagePreparation_deconvolution_tpl);
        
        
        h2_1 = uix.VButtonBox('Parent', h, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [255 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_files_deconvolve.Parent = h2_1;
        handles.uicontrols.pushbutton.pushbutton_huygens_convertImagesToChannel.Parent = h2_1;
        handles.uicontrols.pushbutton.pushbutton_huygens_files_remove.Parent = h2_1;
        
        h.Heights = [115 250 -1];
        
    case 'workflow_imagePreparation_colonySeparation'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.tabs.(panelName), 'Padding', 2*padding, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_imagePreparation_colonySeparation_descr.Parent = h;
        h_button = uix.HButtonBox('Parent', h, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_chooseBiofilm.Parent = h_button;
        
        h.Heights = [80, -1];
        
    case 'workflow_imagePreparation_registration'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.tabs.(panelName), 'Padding', 2*padding, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_imagePreparation_registration_descr.Parent = h;
        
        % Create horizontal grid
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1);
        handles.uicontrols.text.text_workflow_imagePreparation_registration_refFrame.Parent = h1;
        handles.uicontrols.edit.registrationReferenceFrame.Parent = h1;
        handles.uicontrols.pushbutton.pushbutton_setRegistrationReferenceFrame.Parent = h1;
        handles.uicontrols.checkbox.continueRegistration.Parent = h1;
        uix.Empty('Parent', h1);
        h1.Widths = [20, 100, 40, 100, 200, -1];
        
        % Create horizontal grid
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2);
        handles.uicontrols.text.text_workflow_imagePreparation_registration_method.Parent = h2;
        handles.uicontrols.popupmenu.registrationMethod.Parent = h2;
        uix.Empty('Parent', h2);
        handles.uicontrols.checkbox.alignZ.Parent = h2;
        uix.Empty('Parent', h2);
        h2.Widths = [20, 100, 100, 40, 170, -1];
        
        h_button = uix.HButtonBox('Parent', h, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_registerImages.Parent = h_button;
        
        h.Heights = [80, objectHeight, objectHeight, -1];
        
    case 'uipanel_workflow_imagePreparation'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding);
        h1 = uix.ScrollingPanel('Parent', h, 'Padding', 2*padding);
        handles.layout.tabs.workflow_imagePreparationTabs.Parent = h1;
        h1.MinimumHeights = 500;
        h.Heights = 500;
        
    case 'uipanel_workflow_exportNd2'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding);
        h1 = uix.ScrollingPanel('Parent', h, 'Padding', 2*padding);
        h2 = uix.Panel('Parent', h1, 'Padding', 2*padding, 'Title', handles.layout.uipanels.uipanel_workflow_exportNd2_export.Title);
        
        % Create vertical grid
        h2_1 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        
        % Create horizontal grid
        h2_1_1 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', 20);
        handles.uicontrols.text.text_workflow_exportNd2_descr.Parent = h2_1_1;
        h_button = uix.HButtonBox('Parent', h2_1_1, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_files_export2.Parent = h_button;
        h2_1_1.Widths = [-1, 150];
        
        handles.uicontrols.checkbox.files_createPosFolder2.Parent = h2_1;
        
        % Create horizontal grid
        h2_1_2 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2_1_2);
        handles.uicontrols.text.text_workflow_exportNd2_genExpFolder.Parent = h2_1_2;
        h2_1_2.Widths = [20, -1];
        
        h2_1.Heights = [50, objectHeight, -1];
        delete(handles.layout.uipanels.uipanel_workflow_exportNd2_export)
        
        h.Heights = 200;
        h1.MinimumHeights = 200;
        
    case 'uipanel_workflow_simulationInput'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding);
        h1 = uix.ScrollingPanel('Parent', h, 'Padding', 2*padding);
        h2 = uix.Panel('Parent', h1, 'Padding', 2*padding, 'Title', handles.layout.uipanels.uipanel_workflow_simulationInput_parameters.Title);
        
        % Create horizontal grid
        h3 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', 20);
        
        % Create vertical grid
        h4 = uix.VBox('Parent', h3, 'Padding', 0, 'Spacing', spacing);
        
        %--------- one element
        % Create horizontal grid
        h4_1a = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_simulationInput_lengthScale.Parent = h4_1a;
        handles.uicontrols.edit.simulation_lengthScale.Parent = h4_1a;
        handles.uicontrols.text.text_workflow_simulationInput_samplingUnit.Parent = h4_1a;
        h4_1a.Widths = [150, 60, -1];
        
        % Create horizontal grid
        h4_1b = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4_1b);
        handles.uicontrols.text.text_workflow_simulationInput_lengthScaleDescr.Parent = h4_1b;
        h4_1b.Widths = [20, -1];
        
        %--------- one element
        % Create horizontal grid
        h4_2a = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_simulationInput_sampling.Parent = h4_2a;
        handles.uicontrols.edit.simulation_sampling.Parent = h4_2a;
        handles.uicontrols.text.text_workflow_simulationInput_samplingUnit.Parent = h4_2a;
        h4_2a.Widths = [150, 60, -1];
        
        % Create horizontal grid
        h4_2b = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4_2b);
        handles.uicontrols.text.text_workflow_simulationInput_samplingDescr.Parent = h4_2b;
        h4_2b.Widths = [20, -1];
        
        %--------- one element
        % Create horizontal grid
        h4_3a = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_simulationInput_timescale.Parent = h4_3a;
        handles.uicontrols.edit.simulation_timescale.Parent = h4_3a;
        handles.uicontrols.text.text_workflow_simulationInput_timescaleUnit.Parent = h4_3a;
        h4_3a.Widths = [150, 60, -1];
        
        % Create horizontal grid
        h4_3b = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4_3b);
        handles.uicontrols.text.text_workflow_simulationInput_timescaleDescr.Parent = h4_3b;
        h4_3b.Widths = [20, -1];
        
        %--------- one element
        handles.uicontrols.checkbox.simulation_obtainPixelIdxLists.Parent = h4;
        
        % Create horizontal grid
        h4_4b = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4_4b);
        handles.uicontrols.text.text_workflow_simulationInput_binarizeCellsDescr.Parent = h4_4b;
        h4_4b.Widths = [20, -1];
        
        %--------- one element
        % Create horizontal grid
        h4_5a = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_simulationInput_cellExpansionFactor.Parent = h4_5a;
        handles.uicontrols.edit.simulation_expansionFactor.Parent = h4_5a;
        uix.Empty('Parent',h4_5a);
        h4_5a.Widths = [150, 60, -1];
        
        % Create horizontal grid
        h4_5b = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4_5b);
        handles.uicontrols.text.text_workflow_simulationInput_cellExpansionFactorDescr.Parent = h4_5b;
        h4_5b.Widths = [20, -1];
        
        h4.Heights = [objectHeight, -1, objectHeight, -1, objectHeight, -1, objectHeight, -1, objectHeight, -1];
        
        h_button = uix.HButtonBox('Parent', h3, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_importSimulations.Parent = h_button;
        
        h3.Widths = [-1, 150];
        
        h.Heights = 350;
        h1.MinimumHeights = 350;
        
    case 'uipanel_workflow_segmentation'
        % Create vertical grid
        handles.layout.boxes.segmentation = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', 2*spacing);
        h = handles.layout.boxes.segmentation;
        
        % Create horizontal grid
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        handles.layout.boxPanels.boxpanel_segmentationControl.Parent = h1;
        uix.Empty('Parent', h1);
        h1.Widths = [-1, 0];
        
        h2 = uix.ScrollingPanel('Parent', h, 'Padding', 0);
        handles.layout.tabs.workflow_segmentationTabs.Parent = h2;
        h2.MinimumHeights = 460;

        h.Heights = [75, -1];
        
    case 'uipanel_segmentationControl'
        % Create horizontal grid
        h1 = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', 20);
        
        % Create vertical grid
        handles.layout.boxes.segmentationMethod = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        h2 = handles.layout.boxes.segmentationMethod;
        
        %--------- one element
        % Create horizontal grid
        h2_1a = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_segmentationControl_ch.Parent = h2_1a;
        handles.uicontrols.popupmenu.channel_seg.Parent = h2_1a;
        h2_1a.Widths = [120, 60];
        
        % Create horizontal grid
        h2_1b = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2_1b);
        handles.uicontrols.text.text_segmentationControl_chDescr.Parent = h2_1b;
        h2_1b.Widths = [20, -1];
        
        %--------- one element
        % Create horizontal grid
        h2_2a = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_segmentationControl_method.Parent = h2_2a;
        handles.uicontrols.popupmenu.segmentationMethod.Parent = h2_2a;

        h2_2a.Widths = [120, -1];
        
        % Create horizontal grid
        h2_2b = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2_2b);
        handles.uicontrols.text.text_segmentationControl_methodDescr.Parent = h2_2b;
        h2_2b.Widths = [20, -1];
        
        h2.Heights = [objectHeight, -1, 0, 0];
        
        uix.Empty('Parent', h1);
        
        h_button = uix.HButtonBox('Parent', h1, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_action_createMasks.Parent = h_button;
        
        h1.Widths = [300, -1, 150];
        
    case 'uipanel_workflow_segmentation_generalSettings'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
                
        %--------- one element
        handles.uicontrols.checkbox.waitForMemory.Parent = h;
        h_2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h_2);
        handles.uicontrols.text.text_workflow_segmentation_generalSettings_waitMem.Parent = h_2;
        h_2.Widths = [20, -1];
        
        %--------- one element
        handles.uicontrols.checkbox.exportVTKafterEachProcessingStep.Parent = h;
        uix.Empty('Parent', h);
        h.Heights = [objectHeight, 1.5*objectHeight, objectHeight, -1];
        
    case 'uipanel_workflow_segmentation_imageSettings'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
        
        handles.uicontrols.checkbox.imageRegistration.Parent = h;
        
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        h1_1 = uix.Panel('Parent', h1, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_segmentation_imageSettings_refCrop.Title);
        % Create vertical grid
        h1_1_1 = uix.VBox('Parent', h1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.fixedOutputSize.Parent = h1_1_1;
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_refCrop.Parent = h1_1_1;
        h1_1_2 = uix.HBox('Parent', h1_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.edit.registrationReferenceCropping.Parent = h1_1_2;
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_refCropUnit.Parent = h1_1_2;
        handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping.Parent = h1_1_2;
        h1_1_2.Widths = [150, 20, 50];
        h1_1_1.Heights = [objectHeight, 15, objectHeight];
        uix.Empty('Parent', h1);
        
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        h2_1 = uix.Panel('Parent', h2, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_segmentation_imageSettings_crop.Title);
        % Create vertical grid
        h2_1_1 = uix.VBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_crop.Parent = h2_1_1;
        h2_1_2 = uix.HBox('Parent', h2_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.edit.cropRange.Parent = h2_1_2;
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_cropUnit.Parent = h2_1_2;
        handles.uicontrols.pushbutton.pushbutton_pre_selectCropRegion.Parent = h2_1_2;
        handles.uicontrols.pushbutton.pushbutton_applyCropAll.Parent = h2_1_2;
        h2_1_2.Widths = [150, 20, 50, 110];
        h2_1_3 = uix.HBox('Parent', h2_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.cropRangeInterpolated.Parent = h2_1_3;
        handles.uicontrols.pushbutton.pushbutton_interpolateCropping.Parent = h2_1_3;
        h2_1_3.Widths = [200, 146];
        uix.Empty('Parent', h2_1_1);
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_zCrop.Parent = h2_1_1;
        h2_1_4 = uix.HBox('Parent', h2_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_zCrop_maxHeight.Parent = h2_1_4;
        handles.uicontrols.edit.maxHeight.Parent = h2_1_4;
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_zCrop_maxHeightUnit.Parent = h2_1_4;
        uix.Empty('Parent', h2_1_4);
        h2_1_4.Widths = [60, 30, 20, -1];
        h2_1_1.Heights = [15, objectHeight, objectHeight, 10, 15, objectHeight];
        
        uix.Empty('Parent', h2);
        h2.Widths = [350+3*spacing+2*padding, -1];
        
        h3 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        h3_1 = uix.Panel('Parent', h3, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_segmentation_imageSettings_flow.Title);
        % Create vertical grid
        h3_1_1 = uix.HBox('Parent', h3_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.edit.flowDirection.Parent = h3_1_1;
        handles.uicontrols.text.text_workflow_segmentation_imageSettings_flowUnit.Parent = h3_1_1;
        h3_1_1.Widths = [40, 70];
        
        uix.Empty('Parent', h3);
        h3.Widths = [110+spacing+2*padding, -1];
        
        uix.Empty('Parent', h);
        h.Heights = [objectHeight, 2*objectHeight+15+2*padding+4*spacing+2, 3*objectHeight+50+2*padding+6*spacing, objectHeight+2*padding+2*spacing, -1];
        
    case 'uipanel_workflow_segmentation_preprocessing'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
        
        %--------- one element
        handles.uicontrols.checkbox.invertStack.Parent = h;
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1);
        handles.uicontrols.text.text_workflow_segmentation_preprocessing_invertZDescr.Parent = h1;
        h1.Widths = [20, -1];
        
        %--------- one element
        handles.uicontrols.checkbox.rotateImage.Parent = h;
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2);
        handles.uicontrols.text.text_workflow_segmentation_preprocessing_rotationDescr.Parent = h2;
        h2.Widths = [20, -1];
        
        %--------- one element
        h3a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.scaleUp.Parent = h3a;
        handles.uicontrols.edit.scaleFactor.Parent = h3a;
        handles.uicontrols.text.text_workflow_segmentation_preprocessing_scaleUnit.Parent = h3a;
        
        h3a.Widths = [100, 40, -1];
        h3b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h3b);
        handles.uicontrols.text.text_workflow_segmentation_preprocessing_scaleDescr.Parent = h3b;
        h3b.Widths = [20, -1];
        
        %--------- one element
        h4a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_preprocessing_gamma.Parent = h4a;
        handles.uicontrols.popupmenu.gamma.Parent = h4a;
        uix.Empty('Parent', h4a);
        
        h4a.Widths = [100, 40, -1];
        h4b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4b);
        handles.uicontrols.text.text_workflow_segmentation_preprocessing_gammaDescr.Parent = h4b;
        
        h4b.Widths = [20, -1];
        
        h.Heights = [objectHeight, 2*objectHeight, objectHeight, 1.2*objectHeight, objectHeight, 1.5*objectHeight, objectHeight, -1];
   case 'uipanel_workflow_segmentation_labelImage_channel'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        
        %--------- one element
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1);
        handles.uicontrols.text.text_labelImage.Parent = h1;
        %uix.Empty('Parent', h1);
        h1.Widths = [20, -1];
        
        %--------- one element
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2);
        handles.uicontrols.popupmenu.popupmenu_labelImage_Channel.Parent = h2;
        uix.Empty('Parent', h2);
        h2.Widths = [20, 50, -1];
        
        uix.Empty('Parent', h);
        
        h.Heights = [objectHeight, objectHeight, -1];
        
    case 'uipanel_workflow_segmentation_denoising'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
        
        %--------- one element
        h1a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.denoiseImages.Parent = h1a;
        handles.uicontrols.edit.noise_kernelSize.Parent = h1a;
        handles.uicontrols.pushbutton.pushbutton_checkNoise.Parent = h1a;
        h1a.Widths = [320, 40, 105];
        
        h1b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1b);
        handles.uicontrols.text.text_workflow_segmentation_denoising_denoiseImagesDescr.Parent = h1b;
        h1b.Widths = [20, -1];
        

        %--------- one element
        handles.uicontrols.checkbox.removeFloatingCells.Parent = h;
        h3 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h3);
        handles.uicontrols.text.text_workflow_segmentation_denoising_removeFloatingCellsDescr.Parent = h3;
        h3.Widths = [20, -1];
        
        %--------- one element
        h4a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.topHatFiltering.Parent = h4a;
        handles.uicontrols.edit.topHatSize.Parent = h4a;
        handles.uicontrols.text.text_workflow_segmentation_denoising_tophatUnit.Parent = h4a;
        h4a.Widths = [150, 40, -1];
        

        h4b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4b);
        handles.uicontrols.text.text_workflow_segmentation_denoising_tophatDescr.Parent = h4b;
        
        h4b.Widths = [20, -1];
        
        
        %--------- one element
        handles.uicontrols.checkbox.svd.Parent = h;
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2);
        handles.uicontrols.text.text_workflow_segmentation_denoising_scdDescr.Parent = h2;
        h2.Widths = [20, -1];
        
        h.Heights = [objectHeight, 1.5*objectHeight, objectHeight, 1.5*objectHeight, objectHeight, 1.5*objectHeight, objectHeight, -1];
%         h.Heights = [objectHeight, 1.5*objectHeight, objectHeight, 1.5*objectHeight, objectHeight, -1];
        
    case 'uipanel_workflow_segmentation_edgeDetection'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
        
        %--------- one element
        h1a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_edgeDetection_I_base_perStack.Parent = h1a;
        handles.uicontrols.edit.I_base.Parent = h1a;
        handles.uicontrols.pushbutton.pushbutton_pre_detBackground.Parent = h1a;
        handles.uicontrols.pushbutton.pushbutton_determineManualThreshold_I_base.Parent = h1a;
        handles.uicontrols.pushbutton.pushbutton_ApplyBGAll.Parent = h1a;
        uix.Empty('Parent', h1a);
        h1a.Widths = [100, 60, 40, 110, 110, -1];
        
        handles.uicontrols.checkbox.I_base_perStack.Parent = h;
        
        h1b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1b);
        handles.uicontrols.text.text_workflow_segmentation_edgeDetection_I_base_perStackDescr.Parent = h1b;
        h1b.Widths = [20, -1];
        
        %--------- one element
        h3a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.fadeBottom.Parent = h3a;
        handles.uicontrols.edit.fadeBottomLength.Parent = h3a;
        handles.uicontrols.text.text_workflow_segmentation_edgeDetection_fadeUnit.Parent = h3a;
        h3a.Widths = [90, 40, -1];
        
        h3b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h3b);
        handles.uicontrols.text.text_workflow_segmentation_edgeDetection_fadeBottomDescr.Parent = h3b;
        h3b.Widths = [20, -1];
        
        uix.Empty('Parent', h);
        
        %--------- one element
        h4a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_edgeDetection_kernelSizeDescr.Parent = h4a;
        handles.uicontrols.edit.kernelSize.Parent = h4a;
        handles.uicontrols.text.text_workflow_segmentation_edgeDetection_kernelSizeUnit.Parent = h4a;
        handles.uicontrols.pushbutton.pushbutton_detFilterSize.Parent = h4a;
        uix.Empty('Parent', h4a);
        h4a.Widths = [250, 40, 20, 150, -1];
        
        handles.uicontrols.checkbox.autoFilterSize.Parent = h;
        uix.Empty('Parent', h);
        
        h.Heights = [objectHeight, objectHeight, 2*objectHeight, objectHeight, objectHeight, 5, objectHeight, objectHeight, -1];
        
    case 'uipanel_workflow_segmentation_thresholding'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
        
        %--------- one element
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_thresholdingMethod.Parent = h1;
        handles.uicontrols.popupmenu.thresholdingMethod.Parent = h1;
        uix.Empty('Parent', h1);
        h1.Widths = [180, 170 + spacing, -1];
        
        %--------- one element
        handles.layout.boxes.thresholdClasses = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h2 = handles.layout.boxes.thresholdClasses;
        handles.uicontrols.text.text_otsu_classes.Parent = h2;
        handles.uicontrols.popupmenu.thresholdClasses.Parent = h2;
        uix.Empty('Parent', h2);
        h2.Widths = [180, 170 + spacing, -1];
        
        %--------- one element
        handles.layout.boxes.thresholdSensitivity = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h3 = handles.layout.boxes.thresholdSensitivity;
        handles.uicontrols.text.text_sensitivity.Parent = h3;
        handles.uicontrols.edit.thresholdSensitivity.Parent = h3;
        uix.Empty('Parent', h3);
        h3.Widths = [180, 70, -1];
        
        %--------- one element
        handles.layout.boxes.thresholdManual = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h4 = handles.layout.boxes.thresholdManual;
        handles.uicontrols.text.text_manualThreshold.Parent = h4;
        handles.uicontrols.edit.manualThreshold.Parent = h4;
        handles.uicontrols.pushbutton.pushbutton_ApplyTHAll.Parent = h4;
        uix.Empty('Parent', h4);
        h4.Widths = [180, 70, 100, -1];
        
        h4b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4b);
        handles.uicontrols.text.text_thresholdSensitivity2.Parent = h4b;
        h4b.Widths = [20, -1];
        
        uix.Empty('Parent', h);
        
        %--------- one element
        handles.layout.boxes.thresholdSensitivity = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h5 = handles.layout.boxes.thresholdSensitivity;
        handles.uicontrols.text.text_workflow_segmentation_thresholding_detVis.Parent = h5;
        handles.uicontrols.popupmenu.manualThresholdMethod.Parent = h5;
        uix.Empty('Parent', h5);
        h5.Widths = [180, 190 + spacing, -1];
        
        %--------- one element
        handles.layout.boxes.thresholdSensitivity = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h6 = handles.layout.boxes.thresholdSensitivity;
        uix.Empty('Parent', h6);
        handles.uicontrols.pushbutton.pushbutton_determineManualThreshold.Parent = h6;
        uix.Empty('Parent', h6);
        h6.Widths = [20, 350, -1];
        
        uix.Empty('Parent', h);
        h.Heights = [objectHeight, objectHeight, objectHeight, objectHeight, objectHeight, 5, objectHeight, objectHeight, -1];
        
    case 'uipanel_workflow_segmentation_objectDeclumping'
        % Create vertical grid
        handles.layout.boxes.declumping = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
        h = handles.layout.boxes.declumping;
        
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h1_1 = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_objectDeclumping_method.Parent = h1_1;
        h1_1_1 = uix.HBox('Parent', h1_1, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1_1_1);
        handles.uicontrols.popupmenu.declumpingMethod.Parent = h1_1_1;
        h1_1_1.Widths = [10, 120];
        uix.Empty('Parent', h1_1);
        h1_1.Heights = [objectHeight, objectHeight, -1];
        
        handles.axes.axes_declumpingMethod.Parent = h1;
        h1.Widths = [140, -1];
        
        handles.layout.uipanels.panel_declumping_gridOptions = uix.Panel('Parent', h, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_declumping_gridOptions.Title);
        h2 = uix.HBox('Parent', handles.layout.uipanels.panel_declumping_gridOptions, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_objectDeclumping_cubeSideLengthDescr.Parent = h2;
        handles.uicontrols.edit.gridSpacing.Parent = h2;
        handles.uicontrols.text.text_workflow_segmentation_objectDeclumping_cubeSideLengthUnit.Parent = h2;
        h2.Widths = [90, 40, 90];
        
        uix.Empty('Parent', h);
        
        h.Heights = [150, objectHeight+2*padding+2*spacing, -1];
        
        
    case 'uipanel_workflow_segmentation_postprocessing'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);
        
        %--------- one element
        handles.uicontrols.checkbox.median3D.Parent = h;
        
        %--------- one element
        h1a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.removeVoxels.Parent = h1a;
        handles.uicontrols.edit.removeVoxelsOfSize.Parent = h1a;
        handles.uicontrols.text.text_removeVoxelsOfSize.Parent = h1a;
        h1a.Widths = [310, 40, -1];
        
        h1b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1b);
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_removeVoxelsDescr.Parent = h1b;
        h1b.Widths = [20, -1];
        
        %--------- one element
        h2a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.stopProcessingNCellsMax.Parent = h2a;
        handles.uicontrols.edit.NCellsMax.Parent = h2a;
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_stopProcessingN.Parent = h2a;
        h2a.Widths = [310, 40, -1];
        
        uix.Empty('Parent', h);
        
        h3a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        handles.layout.uipanels.panel_workflow_segmentation_postprocessing_removeBottom = uix.Panel('Parent', h3a, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_segmentation_postprocessing_removeBottom.Title);
        h3 = uix.HBox('Parent', handles.layout.uipanels.panel_workflow_segmentation_postprocessing_removeBottom, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_removeBottomDescr.Parent = h3;
        handles.uicontrols.edit.removeBottomSlices.Parent = h3;
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_removeBottomUnit.Parent = h3;
        h3.Widths = [80, 40, -1];
        uix.Empty('Parent', h3a);
        h3a.Widths = [200, -1];
        
        uix.Empty('Parent', h);
        
        h.Heights = [objectHeight, objectHeight, 1.5*objectHeight, objectHeight, 5, objectHeight+2*padding+2*spacing, -1];
        
        
    case 'uipanel_workflow_segmentation_mergeAndTransfer'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 4*padding, 'Spacing', spacing);

        uix.Empty('Parent', h);
        
        %h1b = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        %uix.Empty('Parent', h1b);
        handles.uicontrols.text.text_workflow_segmentation_mergeAndTransfer_description.Parent = h;
        %h1b.Widths = [20, -1];
        
        uix.Empty('Parent', h);
        
        % merge channels
        h4a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        handles.layout.uipanels.panel_workflow_segmentation_postprocessing_mergeChannels = uix.Panel('Parent', h4a, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_segmentation_postprocessing_mergeChannels.Title);
        h4 = uix.VBox('Parent', handles.layout.uipanels.panel_workflow_segmentation_postprocessing_mergeChannels, 'Padding', 0, 'Spacing', spacing);
        h4_1a = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_mergeChDescr1.Parent = h4_1a;
        h4_1b = uix.VBox('Parent', h4_1a, 'Padding', 0, 'Spacing', 0);
        h4_1 = uix.HBox('Parent', h4_1b, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.edit.mergeChannel2.Parent = h4_1;
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_mergeChDescr2.Parent = h4_1;
        handles.uicontrols.edit.mergeChannel1.Parent = h4_1;
        handles.uicontrols.pushbutton.pushbutton_tools_mergeChannels.Parent = h4_1;
        uix.Empty('Parent', h4_1);
        h4_1.Widths = [40, 60, 40, 90, -1];
        uix.Empty('Parent', h4_1b);
        h4_1b.Heights = [objectHeight, -1];
        h4_1a.Widths = [200, -1];
        
        h4_2 = uix.HBox('Parent', h4, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4_2);
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_mergeChDescr3.Parent = h4_2;
        h4_2.Widths = [20, -1];
        uix.Empty('Parent', h4a);
        h4a.Widths = [500, -1];
        h4.Heights = [1.5*objectHeight, 2*objectHeight];

        uix.Empty('Parent', h);
        
        %%% transfer channels 
        h5a = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 0);
        handles.layout.uipanels.uipanel_workflow_segmentation_postprocessing_tranferSegmentaton = uix.Panel('Parent', h5a, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_segmentation_postprocessing_tranferSegmentaton.Title);
        h5 = uix.VBox('Parent', handles.layout.uipanels.uipanel_workflow_segmentation_postprocessing_tranferSegmentaton, 'Padding', 0, 'Spacing', spacing);
        h5_1a = uix.HBox('Parent', h5, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_transferChDescr1.Parent = h5_1a;
        h5_1b = uix.VBox('Parent', h5_1a, 'Padding', 0, 'Spacing', 0);
        h5_1 = uix.HBox('Parent', h5_1b, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.edit.transferChannel2.Parent = h5_1;
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_transferChDescr2.Parent = h5_1;
        handles.uicontrols.edit.transferChannel1.Parent = h5_1;
        handles.uicontrols.pushbutton.pushbutton_tools_transferChannels.Parent = h5_1;
        uix.Empty('Parent', h5_1);
        h5_1.Widths = [40, 60, 40, 90, -1];
        uix.Empty('Parent', h5_1b);
        h5_1b.Heights = [objectHeight, -1];
        h5_1a.Widths = [200, -1];
        
        h5_2 = uix.HBox('Parent', h5, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h5_2);
        handles.uicontrols.text.text_workflow_segmentation_postprocessing_transferChDescr3.Parent = h5_2;
        h5_2.Widths = [20, -1];
        uix.Empty('Parent', h5a);
        h5a.Widths = [500, -1];
        h5.Heights = [1.5*objectHeight, 2.5*objectHeight];

        uix.Empty('Parent', h);
        
        h.Heights = [5, 1.5*objectHeight, 5,  4*objectHeight+2*padding+2*spacing, 10, 4*objectHeight+3*padding+3*spacing, -1];
        
    case 'uipanel_workflow_parameters'
        ha = uix.ScrollingPanel('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 0);
        h = uix.VBoxFlex('Parent', ha, 'Padding', 2*padding, 'Spacing', spacing);
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.pushbutton.pushbutton_restoreParametersCalculate.Parent = h1;
        handles.uicontrols.checkbox.cellParametersNoSaving.Parent = h1;
        handles.uicontrols.pushbutton.pushbutton_action_calculateCellParameters.Parent = h1;
        h1.Widths = [100, -1, 200];
        
        handles.uitables.cellParametersCalculate.Parent = h;
        
        handles.layout.boxPanels.boxpanel_parameterDescription.Parent = h;
        
        handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Parent = h;
        
        h.Heights = [objectHeight, -2, -0.8, 250];
        h.MinimumHeights = [1, 80, 120, 200];
        ha.MinimumHeights = [570];

    case 'uipanel_parameterDescription'
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.text.parameterDescriptionJ.Parent = h;
        
    case 'uipanel_parameters_filtering'
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_filtering_filterBy.Parent = h1;
        handles.uicontrols.popupmenu.filter_parameter.Parent = h1;
        handles.uicontrols.checkbox.filterLogScale.Parent = h1;
        uix.Empty('Parent', h1);
        h1.Widths = [120, 250, 80, -1];
        
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_filtering_filterRange.Parent = h2;
        handles.uicontrols.edit.minCellInt.Parent = h2;
        handles.uicontrols.pushbutton.pushbutton_cells_detMinInt.Parent = h2;
        handles.uicontrols.pushbutton.pushbutton_cells_detMinInt_setAll.Parent = h2;
        uix.Empty('Parent', h2);
        h2.Widths = [120, 150-spacing, 100, 80, -1];
        
        uix.Empty('Parent', h);
        h.Heights = [objectHeight, objectHeight, -1];
        
    case 'uipanel_parameters_inputTemplate_file'
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        handles.uicontrols.text.parameterInputDescription_file.Parent = h;
        
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.edit.parameters_filePath.Parent = h1;
        handles.uicontrols.pushbutton.pushbutton_parameters_selectFile.Parent = h1;
        
        h1.Widths = [-1, 70];
        uix.Empty('Parent', h);
        h.Heights = [0.85*objectHeight, objectHeight, -1];
        
    case 'uipanel_parameterCombination'
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        handles.uicontrols.text.text_parameterCombination_explanation.Parent = h;
        
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h1);
        handles.uicontrols.popupmenu.popupmenu_parameterCombination_ParameterChoice.Parent = h1;
        handles.uicontrols.pushbutton.pushbutton_parameterCombination_add.Parent = h1;
        uix.Empty('Parent', h1);
        uix.Empty('Parent', h1);
        
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        
        h3 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h3);
        handles.uicontrols.edit.edit_parameterCombination_newParamName.Parent = h3;
        uix.Empty('Parent', h3);
        uix.Empty('Parent', h3);
        h3.Heights = [0.5*objectHeight, objectHeight,objectHeight, -1];
        
        h4 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h4);
        handles.uicontrols.text.text_ParameterCombination_Equals.Parent = h4;
        uix.Empty('Parent', h4);
        uix.Empty('Parent', h4);
        h4.Heights = [0.5*objectHeight, objectHeight,objectHeight, -1];
        
        h5 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.edit.edit_parameterCombination_formula.Parent = h5;
        uix.Empty('Parent', h5);
        h5.Heights = [3*objectHeight, -1];
        
        uix.Empty('Parent', h2);
        
        h6 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h6);
        handles.uicontrols.pushbutton.pushbutton_parameterCombination_testExpression.Parent = h6;
        uix.Empty('Parent', h6);
        uix.Empty('Parent', h6);
        h6.Heights = [0.5*objectHeight, objectHeight,objectHeight, -1];

        uix.Empty('Parent', h2);
        
        h1.Widths = [210, 250, 50, 200,-1];
        h2.Widths = [150, 50, 310, 50, 150,-1];
        uix.Empty('Parent', h);
        h.Heights = [3*objectHeight, objectHeight, 4*objectHeight, -1];
        
    case 'uipanel_parameters_inputTemplate'
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h1_1 = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', 0);
        h1_2 = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', 0);
        h1_3 = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', 0);
        handles.uicontrols.text.parameterInputDescription.Parent = h1_1;
        handles.uicontrols.edit.parameterInput.Parent = h1_2;
        handles.uicontrols.text.text_parameterUnitConversion.Parent = h1_3;
        uix.Empty('Parent', h1_2);
        h1_2.Heights = [objectHeight, -1];
        
        h1.Widths = [-1, 140, 120];
        uix.Empty('Parent', h);
        h.Heights = [2*objectHeight, -1];
        
    case 'uipanel_parameters_mergingSplitting'
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_mergingSplitting_strategy.Parent = h1;
        handles.uicontrols.popupmenu.mergingStrategy.Parent = h1;
        handles.uicontrols.checkbox.keepSmallCellWithNoNeighbor.Parent = h1;
        h1.Widths = [120, 200, 200];
        
        h2 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h2_1 = uix.Panel('Parent', h2, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_parameters_mergingSplitting_merging.Title);
        h2_1_1 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_mergingSplitting_mergingDescr1.Parent = h2_1_1;
        handles.uicontrols.edit.minMergeSize.Parent = h2_1_1;
        handles.uicontrols.text.text_parameters_mergingSplitting_mergingDescr2.Parent = h2_1_1;
        h2_1_1.Widths = [140-padding, 40, 160-spacing];
        uix.Empty('Parent', h2);
        h2.Widths = [320, -1];
        
        h3 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h3_1 = uix.Panel('Parent', h3, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_parameters_mergingSplitting_splitting.Title);
        h3_1_1 = uix.VBox('Parent', h3_1, 'Padding', 0, 'Spacing', spacing);
        
        %--------- one element
        h3_1_1a = uix.HBox('Parent', h3_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_mergingSplitting_splittingDescr1.Parent = h3_1_1a;
        handles.uicontrols.edit.splitVolume1.Parent = h3_1_1a;
        handles.uicontrols.text.text_parameters_mergingSplitting_splittingDescr2.Parent = h3_1_1a;
        handles.uicontrols.edit.splitConvexity.Parent = h3_1_1a;
        uix.Empty('Parent', h3_1_1a);
        h3_1_1a.Widths = [120-padding, 40, 250, 40, -1];
        
        %--------- one element
        h3_1_1b = uix.HBox('Parent', h3_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_mergingSplitting_splittingDescr3.Parent = h3_1_1b;
        handles.uicontrols.edit.splitVolume2.Parent = h3_1_1b;
        handles.uicontrols.text.text_parameters_mergingSplitting_splittingDescr4.Parent = h3_1_1b;
        h3_1_1b.Widths = [120-padding, 40, -1];
        
        %--------- one element
        h3_1_1c = uix.HBox('Parent', h3_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_mergingSplitting_splittingDescr5.Parent = h3_1_1c;
        handles.uicontrols.edit.splitVolume3.Parent = h3_1_1c;
        handles.uicontrols.text.text_parameters_mergingSplitting_splittingDescr6.Parent = h3_1_1c;
        handles.uicontrols.edit.splitAspectRatio.Parent = h3_1_1c;
        uix.Empty('Parent', h3_1_1c);
        h3_1_1c.Widths = [120-padding, 40, 250, 40, -1];
        
        h3_1_1.Heights = 0.9*objectHeight * [1 1 1];
        
        uix.Empty('Parent', h3);
        h3.Widths = [500, -1];
        
        uix.Empty('Parent', h);
        h.Heights = 0.9*[objectHeight, objectHeight+2*(padding+spacing), 3*objectHeight+2*padding+5*spacing, -1];
        
    case 'uipanel_parameters_intensityFeatures'
        
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        ha = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        
        h1 = uix.VBox('Parent', ha, 'Padding', 0, 'Spacing', spacing);
        h1_1 = uix.HBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_intensity_addTask.Parent = h1_1;
        handles.uicontrols.pushbutton.pushbutton_intensity_deleteRow.Parent = h1_1;
        handles.uicontrols.pushbutton.pushbutton_intensity_clear.Parent = h1_1;
        h1_1.Widths = [-1, 80, 50];
        handles.uitables.intensity_tasks.Parent = h1;
        h1.Heights = [objectHeight, -0.9];
        
        h2 = uix.VBox('Parent', ha, 'Padding', 0, 'Spacing', spacing);
        h2_1 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_intensity_summary.Parent = h2_1;
        handles.uicontrols.pushbutton.pushbutton_intensity_addTask.Parent = h2_1;
        h2_1.Widths = [-1, 50];
        h2_2 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_intensityFeatures_task.Parent = h2_2;
        handles.uicontrols.popupmenu.intensity_task.Parent = h2_2;
        h2_2.Widths = [60, -1];
        h2_3 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_intensityFeatures_ch.Parent = h2_3;
        handles.uicontrols.popupmenu.intensity_ch.Parent = h2_3;
        handles.uicontrols.text.text_channelDescription.Parent = h2_3;
        h2_3.Widths = [60, 40, -1];
        h2_4 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2_4);
        handles.uicontrols.checkbox.intensity_perStack.Parent = h2_4;
        h2_4.Widths = [60, -1];
        h2_5 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_intensityFeatures_range.Parent = h2_5;
        handles.uicontrols.edit.intensity_range.Parent = h2_5;
        uix.Empty('Parent', h2_5);
        h2_5.Widths = [60, 40, -1];
        h2_6 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h2_6);
        handles.uicontrols.text.text_intensity_rangeUnit.Parent = h2_6;
        h2_6.Widths = [60, -1];
        h2.Heights = [objectHeight, objectHeight, 0.85*objectHeight, objectHeight, objectHeight, -1];
        
        ha.Widths = [-1, 300];
        
    case 'uipanel_parameters_tagCells'
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        ha = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        
        h1 = uix.VBox('Parent', ha, 'Padding', 0, 'Spacing', spacing);
        h1_1 = uix.HBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_tagCells_rules.Parent = h1_1;
        handles.uicontrols.pushbutton.pushbutton_tagCells_deleteRow.Parent = h1_1;
        handles.uicontrols.pushbutton.pushbutton_tagCells_clear.Parent = h1_1;
        h1_1.Widths = [-1, 80, 50];
        handles.uitables.tagCells_rules.Parent = h1;
        h1.Heights = [objectHeight, -0.9];
        
        h2 = uix.VBox('Parent', ha, 'Padding', 0, 'Spacing', spacing);
        h2_1 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_tagCells_newRule.Parent = h2_1;
        handles.uicontrols.pushbutton.pushbutton_tagCells_addRule.Parent = h2_1;
        h2_1.Widths = [-1, 50];
        handles.uicontrols.text.text_parameters_tagCells_parameter.Parent = h2;
        h2_3 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.popupmenu.tagCells_parameter.Parent = h2_3;
        handles.uicontrols.popupmenu.tagCells_operator.Parent = h2_3;
        handles.uicontrols.edit.tagCells_value.Parent = h2_3;
        h2_3.Widths = [-1, 40, 40];
        h2_5 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_parameters_tagCells_tagname.Parent = h2_5;
        handles.uicontrols.edit.tagCells_name.Parent = h2_5;
        uix.Empty('Parent', h2_5);
        h2_5.Widths = [60, 150, -1];
        uix.Empty('Parent', h2);
        
        h2.Heights = [objectHeight, 0.85*objectHeight, objectHeight, objectHeight, -1];
        ha.Widths = [-1, 300];
        
    case 'uipanel_workflow_cellTracking'
        % Create vertical grid
        h = uix.VBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding);
        h1 = uix.ScrollingPanel('Parent', h, 'Padding', 2*padding);
        h2 = uix.Panel('Parent', h1, 'Padding', 2*padding, 'Title', handles.layout.uipanels.uipanel_workflow_cellTracking_main.Title);
        
        % Create vertical grid
        h2_1 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        
        % Create horizontal grid
        h2_1_1 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', 20);
        handles.uicontrols.text.text_workflow_cellTracking_descr.Parent = h2_1_1;
        h_button = uix.HButtonBox('Parent', h2_1_1, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_action_trackCells.Parent = h_button;
        h2_1_1.Widths = [-1, 150];
        
        h3 = uix.Panel('Parent', h2_1, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_cellTracking_options.Title);
        h3_1 = uix.HBox('Parent', h3, 'Padding', padding, 'Spacing', spacing);
        h3_1_1 = uix.VBox('Parent', h3_1, 'Padding', 0, 'Spacing', spacing);
        h3_1_1a = uix.HBox('Parent', h3_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_cellTracking_method.Parent = h3_1_1a;
        handles.uicontrols.popupmenu.trackMethod.Parent = h3_1_1a;
        h3_1_1a.Widths = [120, -1];
        h3_1_1b = uix.HBox('Parent', h3_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_cellTracking_searchRadius.Parent = h3_1_1b;
        handles.uicontrols.edit.searchRadius.Parent = h3_1_1b;
        handles.uicontrols.text.text_workflow_cellTracking_searchRadiusUnit.Parent = h3_1_1b;
        h3_1_1b.Widths = [225, 40, -1];
        h3_1_1c = uix.HBox('Parent', h3_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.trackCellsDilate.Parent = h3_1_1c;
        handles.uicontrols.edit.trackCellsDilatePx.Parent = h3_1_1c;
        handles.uicontrols.text.text_workflow_cellTracking_dilateUnit.Parent = h3_1_1c;
        h3_1_1c.Widths = [225, 40, -1];
        handles.uicontrols.checkbox.considerSiblings.Parent = h3_1_1;
        
        h3_1_2 = uix.VBox('Parent', h3_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.trackingStartNewSeries.Parent = h3_1_2;
        h3_1_2a = uix.HBox('Parent', h3_1_2, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', h3_1_2a);
        handles.uicontrols.text.text_workflow_cellTracking_startNewSeriesDescr.Parent = h3_1_2a;
        h3_1_2a.Widths = [10, -1];
        h3_1_2.Heights = [objectHeight, 2*objectHeight];
        h3_1.Widths = [-0.6, -0.4];
        
        uix.Empty('Parent', h2_1);
        h2_1.Heights = [140, 4*objectHeight + 2*padding + 6*spacing, -1];
        
        delete(handles.layout.uipanels.uipanel_workflow_cellTracking_options);
        
        h.Heights = 350;
        h1.MinimumHeights = 350;
        
    case 'uipanel_workflow_dataExport'
        % Create vertical grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding);
        
        h1 = uix.ScrollingPanel('Parent', h, 'Padding', 2*padding);
        
        h2 = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_dataExport_parameters.Parent = h2;
        handles.uitables.cellParametersStoreVTK.Parent = h2;
        handles.uicontrols.checkbox.forceVTKSeries.Parent = h2;
        handles.layout.tabs.workflow_exportTabs.Parent = h2;
        
        h2.Heights = [objectHeight, -1, objectHeight, 300];
        h1.MinimumHeights = 700;
        
    case 'uipanel_workflow_dataExport_vtk'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        h1 = uix.VBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        
        h1_1 = uix.HBox('Parent', h1, 'Padding', 0, 'Spacing', 0);
        
        h2 = uix.Panel('Parent', h1_1, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_dataExport_vtk_representation.Title);
        h2_1 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        h2_1_1 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.checkbox.reducePolygons.Parent = h2_1_1;
        handles.uicontrols.edit.reducePolygonsTo.Parent = h2_1_1;

        h2_1_1.Widths = [230, 40];
        
        h2_1_2 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_dataExport_vtk_representation_rot.Parent = h2_1_2;
        handles.uicontrols.edit.visualization_rotation.Parent = h2_1_2;
        handles.uicontrols.popupmenu.visualization_rotation_axis.Parent = h2_1_2;
        h2_1_2.Widths = [120, 40, 90];
        
        h1_1.Widths = 300;
        
        h1_2 = uix.HBox('Parent', h1, 'Padding', 0, 'Spacing', 0);
        
        h3 = uix.Panel('Parent', h1_2, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_dataExport_vtk_format.Title);
        h3_1 = uix.HBox('Parent', h3, 'Padding', 0, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_dataExport_vtk_format.Parent = h3_1;
        handles.uicontrols.popupmenu.outputFormat3D.Parent = h3_1;
        handles.uicontrols.checkbox.obtainConnectedStructure.Parent = h3_1;
        h3_1.Widths = [80, 150, 150];
        
        h1_2.Widths = 400;
        
        h1.Heights = [2*objectHeight+3*spacing+2*padding, objectHeight+2*spacing+2*padding];
        
        h_button = uix.HButtonBox('Parent', h, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_action_visualize.Parent = h_button;
        h.Widths = [-1, 150];
        
    case 'uipanel_workflow_dataExport_fcs'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_dataExport_fcs_descr.Parent = h;
        h_button = uix.HButtonBox('Parent', h, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_action_exportToFCS.Parent = h_button;
        h.Widths = [-1, 150];
        
    case 'uipanel_workflow_dataExport_csv'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
        handles.uicontrols.text.text_workflow_dataExport_csv_descr.Parent = h;
        h_button = uix.HButtonBox('Parent', h, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.uicontrols.pushbutton.pushbutton_action_exportToCSV.Parent = h_button;
        h.Widths = [-1, 150];
        
    case 'uipanel_imageRange_visualization'
        % Create horizontal grid
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        handles.uicontrols.edit.visualization_imageRange.Parent = h;
        handles.uicontrols.pushbutton.pushbutton_visualization_imageRange_takeSel.Parent = h;
        handles.uicontrols.pushbutton.pushbutton_visualization_imageRange_takeAll.Parent = h;
        uix.Empty('Parent', h);
        
        h.Widths = [100 110 80 -1];
        
    case 'uipanel_biofilmAnalysis'
        % Create vertical grid
        h = uix.VBox('Parent', handles.handles_analysis.layout.uipanels.(panelName).Parent, 'Padding', padding, 'Spacing', spacing);
        h1 = uix.Panel('Parent', h, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_analysis.Title);
        h2 = uix.HBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        h2_1 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        h2_1_1 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.checkbox.useRefTimepoint.Parent = h2_1_1;
        handles.handles_analysis.uicontrols.popupmenu.refTimepointFile.Parent = h2_1_1;
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_selectReferenceTimepoint.Parent = h2_1_1;
        h2_1_1.Widths = [300, -1, 160];
        
        h2_1_2 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_fluorescenceChannel.Parent = h2_1_2;
        handles.handles_analysis.uicontrols.popupmenu.channel.Parent = h2_1_2;
        uix.Empty('Parent', h2_1_2);
        h2_1_2.Widths = [300, 60, -1];
        
        h2_1_3 = uix.HBox('Parent', h2_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.checkbox.loadMaxFrame.Parent = h2_1_3;
        handles.handles_analysis.uicontrols.edit.maxFrameToLoad.Parent = h2_1_3;
        handles.handles_analysis.uicontrols.text.text_or.Parent = h2_1_3;
        handles.handles_analysis.uicontrols.edit.maxNCells.Parent = h2_1_3;
        handles.handles_analysis.uicontrols.text.text_NCellsLoad.Parent = h2_1_3;
        h2_1_3.Widths = [300, 60, 40, 60, -1];
        
        if isvalid(handles.handles_analysis.uitables.uitable_tracks)
            handles.handles_analysis.uicontrols.checkbox.loadPixelIdxLists.Parent = h2_1;
            handles.handles_analysis.uicontrols.checkbox.loadPixelIdxLists.Visible = 'on';
        end
        
        h2_2 = uix.VBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        h_button = uix.HButtonBox('Parent', h2_2, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [150 objectHeight]);
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_load.Parent = h_button;
        handles.handles_analysis.uicontrols.text.text_analysis_loadingDescr.Parent = h2_2;
        h2_2.Heights = [objectHeight, -1];
        
        h2.Widths = [-1 300];
        
        handles.handles_analysis.layout.tabs.analysisTabs.Parent = h;
        
        if isvalid(handles.handles_analysis.uitables.uitable_tracks)
            h.Heights = [0.81*4*objectHeight+5*spacing+2*padding, -1];
        else
            h.Heights = [0.81*3*objectHeight+5*spacing+2*padding, -1];
        end
        
    case 'uipanel_plotting'
        ha = uix.ScrollingPanel('Parent', handles.handles_analysis.layout.uipanels.(panelName).Parent, 'Padding', 0);
        % Create vertical grid
        h = uix.VBox('Parent', ha, 'Padding', 2*padding, 'Spacing', 2*spacing);
        h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', 2*spacing);
        % Parameter selection
        h1_1 = uix.Panel('Parent', h1, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_plotting_parameter.Title);
        h1_1_1 = uix.VBox('Parent', h1_1, 'Padding', 0, 'Spacing', spacing);
        h1_1_1a = uix.HBox('Parent', h1_1_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_database.Parent = h1_1_1a;
        handles.handles_analysis.uicontrols.text.text_search.Parent = h1_1_1a;
        handles.handles_analysis.uicontrols.edit.edit_filterString.Parent = h1_1_1a;
        h1_1_1a.Widths = [200, 70, -1];
        
        handles.handles_analysis.uicontrols.listbox.listbox_fieldNames.Parent = h1_1_1;

        h1_1_1.Heights = 0.85*[objectHeight, -1];
        
        h2 = uix.VBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        % Data details
        h2_1 = uix.Panel('Parent', h2, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_plotting_details.Title);
        handles.handles_analysis.uicontrols.text.text_dataDetails.Parent = h2_1;
        
        % Filtering
        h2_2 = uix.Panel('Parent', h2, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_plotting_filtering.Title);
        h2_2_1 = uix.VBox('Parent', h2_2, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_dataDetails.Parent = h2_1;
        
        h2_2_2 = uix.HBox('Parent', h2_2_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.edit.edit_filterField.Parent = h2_2_2;
        h_button = uix.VButtonBox('Parent', h2_2_2, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [30 objectHeight]);
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_addFilterField.Parent = h_button;
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_filterHelp.Parent = h_button;
        h2_2_2.Widths = [-1, 20];
        
        handles.handles_analysis.uicontrols.checkbox.checkbox_clusterBiofilm.Parent = h2_2_1;
        h2_2_3 = uix.HBox('Parent', h2_2_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_plotting_filtering_maxMovingDistance.Parent = h2_2_3;
        handles.handles_analysis.uicontrols.edit.edit_scanRadius.Parent = h2_2_3;
        h2_2_3.Widths = [230, 40];
        h2_2_1.Heights = [-1 0.85*objectHeight*[1 1]];
        h2.Heights = [90, -1];
        
        uix.Empty('Parent', h1);
        h1.Widths = [-2, 350, -1];
            
        g = uix.Grid('Parent', h, 'Padding', 0, 'Spacing', spacing);
        % Options
        p1 = uix.Panel('Parent', g, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_plotting_options.Title);
        p1_1 = uix.VBox('Parent', p1, 'Padding', 0, 'Spacing', spacing);
        
        p1_1a = uix.HBox('Parent', p1_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_plotting_options_type.Parent = p1_1a;
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType.Parent = p1_1a;
        handles.handles_analysis.uicontrols.text.text_plotting_options_method.Parent = p1_1a;
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging.Parent = p1_1a;
        p1_1a.Widths = [60, 350, -1, -3];
        
        p1_1b = uix.HBox('Parent', p1_1, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', p1_1b);
        handles.handles_analysis.uicontrols.checkbox.checkbox_fitCellNumber.Parent = p1_1b;
        handles.handles_analysis.uicontrols.text.text_plotting_options_style.Parent = p1_1b;
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle.Parent = p1_1b;
        handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars.Parent = p1_1b;
        p1_1b.Widths = [60, 350, -1, -1.8, -1.2];
        
        uix.Empty('Parent', p1_1);
        
        p1_1c = uix.HBox('Parent', p1_1, 'Padding', 0, 'Spacing', spacing);
        uix.Empty('Parent', p1_1c);
        handles.handles_analysis.uicontrols.text.text_plotting_options_parameter.Parent = p1_1c;
        uix.Empty('Parent', p1_1c);
        handles.handles_analysis.uicontrols.text.text_plotting_options_label.Parent = p1_1c;
        handles.handles_analysis.uicontrols.text.text_plotting_options_unit.Parent = p1_1c;
        handles.handles_analysis.uicontrols.text.text_plotting_options_autoRange.Parent = p1_1c;
        handles.handles_analysis.uicontrols.text.text_plotting_options_range.Parent = p1_1c;
        handles.handles_analysis.uicontrols.text.text_plotting_options_trueRange.Parent = p1_1c;
        handles.handles_analysis.uicontrols.text.text_plotting_options_trueRangeMethod.Parent = p1_1c;
        handles.handles_analysis.uicontrols.text.text_plotting_options_bins.Parent = p1_1c;
        handles.handles_analysis.uicontrols.text.text_plotting_options_logScale.Parent = p1_1c;
        p1_1c.Widths = [60, -1, 20, -0.7, 40, 20, 60, 20, 60, 30, 30];
        
        
        g1_1 = uix.Grid('Parent', p1_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_plotting_options_X.Parent = g1_1;
        handles.handles_analysis.uicontrols.text.text_plotting_options_Y.Parent = g1_1;
        handles.handles_analysis.uicontrols.text.text_plotting_options_Z.Parent = g1_1;
        handles.handles_analysis.uicontrols.text.text_plotting_options_Color.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis.Parent = g1_1;
               
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_xaxis.Parent = g1_1;
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_yaxis.Parent = g1_1;
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_zaxis.Parent = g1_1;
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_addField_coloraxis.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.edit.edit_xLabel.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_yLabel.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_zLabel.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_colorLabel.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.edit.edit_xLabel_unit.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_yLabel_unit.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_zLabel_unit.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_colorLabel_unit.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange.Parent = g1_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange.Parent = g1_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_autoZRange.Parent = g1_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_autoColorRange.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.edit.edit_xRange.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_yRange.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_zRange.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_colorRange.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX.Parent = g1_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Parent = g1_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeZ.Parent = g1_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeColor.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX.Parent = g1_1;
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY.Parent = g1_1;
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodZ.Parent = g1_1;
        handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodColor.Parent = g1_1;
        
        handles.handles_analysis.uicontrols.edit.edit_binsX.Parent = g1_1;
        handles.handles_analysis.uicontrols.edit.edit_binsY.Parent = g1_1;
        uix.Empty('Parent', g1_1);
        uix.Empty('Parent', g1_1);
        
        handles.handles_analysis.uicontrols.checkbox.checkbox_logX.Parent = g1_1;      
        handles.handles_analysis.uicontrols.checkbox.checkbox_logY.Parent = g1_1;      
        handles.handles_analysis.uicontrols.checkbox.checkbox_logZ.Parent = g1_1;
        uix.Empty('Parent', g1_1);
        
        g1_1.Widths = [60, -1, 20, -0.7, 40, 20, 60, 20, 60, 30, 30];
        g1_1.Heights = 0.85*objectHeight*[1 1 1 1];
        
        p1_1.Heights = [0.85*objectHeight, 0.85*objectHeight, 5, 0.7*objectHeight, 4*objectHeight+3*spacing];
        
        % Advanced options
        p2 = uix.Panel('Parent', g, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_plotting_advancedOptions.Title);
        g2_1 = uix.Grid('Parent', p2, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.checkbox.checkbox_applyCustom1.Parent = g2_1; 
        handles.handles_analysis.uicontrols.checkbox.checkbox_applyCustom2.Parent = g2_1; 
        handles.handles_analysis.uicontrols.edit.edit_custom1.Parent = g2_1; 
        handles.handles_analysis.uicontrols.edit.edit_custom2.Parent = g2_1; 
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_browseCustom1.Parent = g2_1; 
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_browseCustom2.Parent = g2_1; 
        g2_1.Widths = [200, -1, 70];
        g2_1.Heights = 0.85*objectHeight*[1 1];
        
        % Heatmap options
        handles.handles_analysis.layout.uipanels.panel_heatmapOptions = uix.Panel('Parent', g, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_heatmapOptions.Title);
        p3 = handles.handles_analysis.layout.uipanels.panel_heatmapOptions;
        p3_1 = uix.VBox('Parent', p3, 'Padding', 0, 'Spacing', spacing);
        g3_1 = uix.Grid('Parent', p3_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_plotting_heatmap_yOffset.Parent = g3_1; 
        handles.handles_analysis.uicontrols.text.text_plotting_heatmap_normalizeBy.Parent = g3_1; 
        handles.handles_analysis.uicontrols.edit.edit_yOffset.Parent = g3_1; 
        handles.handles_analysis.uicontrols.edit.edit_normalizeFactor.Parent = g3_1; 
        uix.Empty('Parent', g3_1);
        uix.Empty('Parent', g3_1);
        g3_1.Widths = [70, 40, -1];
        
        handles.handles_analysis.uicontrols.checkbox.checkbox_removeZOffset.Parent = p3_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_removeZOffsetHeatmapColumn.Parent = p3_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_invert.Parent = p3_1;
        handles.handles_analysis.uicontrols.checkbox.checkbox_overlayBiofilmRadiusAsLine.Parent = p3_1;
        uix.Empty('Parent', p3_1);
        
        p3_1.Heights = [2*0.85*objectHeight+spacing, 0.85*objectHeight*[1 1 1 1], -1];
        
        % Actions
        p4 = uix.Panel('Parent', g, 'Padding', padding, 'Title', handles.handles_analysis.layout.uipanels.uipanel_plotting_actions.Title);
        p4_1 = uix.HBox('Parent', p4, 'Padding', 0, 'Spacing', spacing);
        p4_2 = uix.VBox('Parent', p4_1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots.Parent = p4_2;
        handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots.Parent = p4_2;
        handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure.Parent = p4_2;
        p4_2.Heights = 0.85*objectHeight*[1 1 1];
        
        h_button = uix.HButtonBox('Parent', p4_1, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [70 2*objectHeight]);
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_kymograph_plot.Parent = h_button;
        p4_1.Widths = [180, -1];
        
        g.Widths = [-1, 270];
        g.Heights = [sum(p1_1.Heights) + 2*padding + 4*spacing, sum(p4_2.Heights)+2*padding+4*spacing];
        h.Heights = [-1 350];
        ha.MinimumHeights = 600;
        ha.MinimumWidths = 1000;  
        
    case 'uipanel_trackAnalysis'        
        % Create horizontal grid
        h = uix.HBox('Parent', handles.handles_analysis.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing); 
        h1 = uix.VBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
        h1_1 = uix.HBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_trackAnalysis_minTrackLength.Parent = h1_1;
        handles.handles_analysis.uicontrols.edit.edit_minTrackLength.Parent = h1_1;
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_trackFeatures.Parent = h1_1;
        h1_1.Widths = [90, 60, 120];
        handles.handles_analysis.uitables.uitable_tracks.Parent = h1;
        
        h2a = uix.HBox('Parent', h1, 'Padding', 0, 'Spacing', spacing);
        h2 = uix.VBox('Parent', h2a, 'Padding', 0, 'Spacing', spacing);
        h2_1 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_trackAnalysis_selTracks.Parent = h2_1;
        handles.handles_analysis.uicontrols.listbox.listbox_selTrack.Parent = h2_1;
        
        h2_2 = uix.HBox('Parent', h2, 'Padding', 0, 'Spacing', spacing);
        handles.handles_analysis.uicontrols.text.text_trackAnalysis_maxFrame.Parent = h2_2;
        handles.handles_analysis.uicontrols.edit.edit_maxFrame.Parent = h2_2;
        
        h2.Heights = [3*objectHeight, objectHeight];
            
        h_button = uix.HButtonBox('Parent', h2a, 'Spacing', spacing, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'ButtonSize', [100 2*objectHeight]);
        handles.handles_analysis.uicontrols.pushbutton.pushbutton_plotTree_selected.Parent = h_button;
        h2a.Widths = [-1, 110];
        h1.Heights = [objectHeight, -1, sum(h2.Heights)+2*padding];
        
        uix.Empty('Parent', h);
        h.Widths = [sum(h1_1.Widths) + 2+spacing, -1];
        
    case 'uipanel_workflow_customTiffImportPanel'
        
    test = false;

    if test
        padding = 8;
        spacing = 8;
        objectHeight = 22;

        f = figure(1);
        h = uix.HBox('Parent', f, 'Padding', 2*padding, 'Spacing', spacing);
    else
        h = uix.HBox('Parent', handles.layout.uipanels.(panelName).Parent, 'Padding', 2*padding, 'Spacing', spacing);
    end
    
        %% Interface definitions
        p = uix.HBox(); % dummy
        
        % UIPanels
        handles.layout.uipanels.uipanel_workflow_customTiffImportPanel_regexp = ...
            uipanel( ...
            'Parent', p,  ... % dummy
            'Tag', 'uipanel_workflow_customTiffImportPanel_regexp', ...
            'Title', 'Metadata regular expressions');
        
        handles.layout.uipanels.uipanel_workflow_customTiffImportPanel_validate = ...
            uipanel( ...
            'Parent', p, ... % dummy
            'Tag', 'uipanel_workflow_customTiffImportPanel_validate', ...
            'Title', 'Validate Filename');
        
        
        % Labels
        handles.uicontrols.text.text_importPositionRegexp = ...
        uicontrol( ...
            'Tag', 'text_importPositionRegexp', ...
            'Style', 'text', ...
            'String', 'Position');
        
        handles.uicontrols.text.text_importChannelRegexp = ...
        uicontrol( ...
            'Tag', 'text_importChannelRegexp', ...
            'Style', 'text', ...
            'String', 'Channel');
        
        handles.uicontrols.text.text_importTimeRegexp = ...
        uicontrol( ...
            'Tag', 'text_importTimeRegexp', ...
            'Style', 'text', ...
            'String', 'Time');
        
        handles.uicontrols.text.text_importZPosRegexp = ...
        uicontrol( ...
            'Tag', 'text_importZPosRegexp', ...
            'Style', 'text', ...
            'String', 'z-Pos');
        
        handles.uicontrols.text.text_importValidationFilename = ...
        uicontrol( ...
            'Tag', 'text_importValidationFilename', ...
            'Style', 'text', ...
            'String', 'Filename');
        
%         handles.uicontrols.text.text_importValidationResults = ...
%             uicontrol( ...
%             'Tag', 'text_importValidationResults', ...
%             'Style', 'text', ...
%             'String', '');
      
        % edits
        handles.uicontrols.edit.importPositionRegexp = ...
        uicontrol( ...
            'Tag', 'importPositionRegexp', ...
            'Style', 'edit', ...
            'String', '_pos');
        
        
        handles.uicontrols.edit.importChannelRegexp = ...
            uicontrol( ...
            'Tag', 'importChannelRegexp', ...
            'Style', 'edit', ...
            'String', '_ch');
        
        handles.uicontrols.edit.importTimeRegexp = ...
        uicontrol( ...
            'Tag', 'importTimeRegexp', ...
            'Style', 'edit', ...
            'String', '_time');
        
        handles.uicontrols.edit.importZPosRegexp = ...
        uicontrol( ...
            'Tag', 'importZPosRegexp', ...
            'Style', 'edit', ...
            'String', '_z');
        
        handles.uicontrols.edit.importValidationFilename = ...
        uicontrol( ...
            'Tag', 'importValidationFilename', ...
            'Style', 'edit', ...
            'String', 'label_pos1_ch2_z3_time4.tiff');
        
        
        % Pushbuttons
        handles.uicontrols.pushbutton.importValidationPushbutton = ...
            uicontrol( ...
            'Tag', 'importValidationPushbutton' ...
            ,'Style', 'pushbutton' ...
            ,'String', 'Validate' ...
            );
        
        handles.uicontrols.pushbutton.importValidationPushbuttonAll = ...
            uicontrol( ...
            'Tag', 'importValidationPushbuttonAll' ...
            ,'Style', 'pushbutton' ...
            ,'String', 'Validate Files' ...
            );
        
        handles.uicontrols.pushbutton.importCustomTiffPushbutton = ...
            uicontrol( ...
            'Tag', 'importCustomTiffPushbutton', ...
            'Style', 'pushbutton', ...
            'String', 'Import Custom Tiffs', ...
            'Enable', 'off' ...
            );
        
        
        % UiTables
        handles.uitables.importResults = ...
            uitable( ...
            'Parent', p, ... % dummy
            'Tag', 'importResults', ...
            'Data',{}, ...
            'ColumnName', {'Filename', 'Label', 'Position', 'Channel', 'Time', 'zPos'}, ...
            'ColumnEditable', logical([0, 1, 1, 1, 1, 1]) ...
            );
        
        
        %% Interface Layout
        
            h1 = uix.HBox('Parent', h, 'Padding', 0, 'Spacing', spacing);
                
                p1 = uix.Panel('Parent', h1, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_customTiffImportPanel_regexp.Title);
                    p1_h1_ = uix.VBox('Parent', p1, 'Padding', 0, 'Spacing', spacing);
                        p1_h1_v1 = uix.HBox('Parent', p1_h1_, 'Padding', 0, 'Spacing', spacing);
                            handles.uicontrols.text.text_importPositionRegexp.Parent = p1_h1_v1;
                            handles.uicontrols.edit.importPositionRegexp.Parent = p1_h1_v1;
                        p1_h1_v1.Widths = [50, -1];

                        
                        p1_h1_v2 = uix.HBox('Parent', p1_h1_, 'Padding', 0, 'Spacing', spacing);
                            handles.uicontrols.text.text_importChannelRegexp.Parent = p1_h1_v2;
                        	handles.uicontrols.edit.importChannelRegexp.Parent = p1_h1_v2;
                        p1_h1_v2.Widths = [50, -1];
                        
                        p1_h1_v3 = uix.HBox('Parent', p1_h1_, 'Padding', 0, 'Spacing', spacing);
                            handles.uicontrols.text.text_importTimeRegexp.Parent = p1_h1_v3;
                            handles.uicontrols.edit.importTimeRegexp.Parent = p1_h1_v3;
                        p1_h1_v3.Widths = [50, -1];
                        
                        p1_h1_v4 = uix.HBox('Parent', p1_h1_, 'Padding', 0, 'Spacing', spacing); 
                            handles.uicontrols.text.text_importZPosRegexp.Parent = p1_h1_v4;
                            handles.uicontrols.edit.importZPosRegexp.Parent = p1_h1_v4;
                        p1_h1_v4.Widths = [50, -1];
                        
                        handles.uicontrols.pushbutton.importCustomTiffPushbutton.Parent = p1_h1_;
                        
                    p1_h1_.Heights =  0.85*objectHeight*[1 1 1 1 1] ;

                p2 = uix.Panel('Parent', h1, 'Padding', padding, 'Title', handles.layout.uipanels.uipanel_workflow_customTiffImportPanel_validate.Title);
                    p2_v1 = uix.VBox('Parent', p2, 'Padding', 0, 'Spacing', spacing);
                        p2_v1_h1 = uix.HBox('Parent', p2_v1, 'Padding', 0, 'Spacing', spacing);
                            handles.uicontrols.text.text_importValidationFilename.Parent = p2_v1_h1;
                            handles.uicontrols.edit.importValidationFilename.Parent = p2_v1_h1;
                            
                        p2_v1_h1.Widths = [50, -1];
                        
                        
                        p2_v1_h2 = uix.HBox('Parent', p2_v1, 'Padding', 0, 'Spacing', spacing);
                        
                            handles.uicontrols.pushbutton.importValidationPushbutton.Parent = p2_v1_h2;
                            handles.uicontrols.pushbutton.importValidationPushbuttonAll.Parent = p2_v1_h2;
                            
                        p2_v1_h2.Widths = [50, 100];
                        
                        
                        
                        handles.uicontrols.text.text_importValidationResults.Parent = p2_v1;
                        
                        handles.uitables.importResults.Parent = p2_v1;

                    p2_v1.Heights = [objectHeight, objectHeight, -1];
                       
        h1.Widths = [-1, -1];
        
        %%% Set import custom tif to disbaled when files have not been
        %%% validated yet
        handles.uicontrols.pushbutton.importCustomTiffPushbutton.Enable = 'off';

        % Add Callbacks after handles Definitions to access all ellements
        if test
            handles.uicontrols.pushbutton.importValidationPushbutton.Callback = ...
                @(hObject, eventdata) importValidationPushbutton_Callback(hObject, eventdata, handles);
                  
            handles.uicontrols.pushbutton.importValidationPushbuttonAll.Callback = ...
                @(hObject, eventdata) importValidationPushbuttonAll_Callback(hObject, eventdata, handles);
            
            handles.uicontrols.pushbutton.importCustomTiffPushbutton.Callback = ...
                @(hObject, eventdata)importCustomTiffPushbutton_Callback(hObject, eventdata, handles);
        else
            handles.uicontrols.pushbutton.importValidationPushbutton.Callback = ...
                @(hObject,eventdata)BiofilmQ('importValidationPushbutton_Callback',hObject,eventdata,guidata(hObject));
            
            handles.uicontrols.pushbutton.importValidationPushbuttonAll.Callback = ...
                @(hObject,eventdata)BiofilmQ('importValidationPushbuttonAll_Callback',hObject,eventdata,guidata(hObject));
            
            handles.uicontrols.pushbutton.importCustomTiffPushbutton.Callback = ...
                @(hObject,eventdata)BiofilmQ('importCustomTiffPushbutton_Callback',hObject,eventdata,guidata(hObject));
        end
end

try
    delete(handles.layout.uipanels.(panelName));
catch
    try
        delete(handles.layout.uipanels.(panelName).Children);
    end
end
