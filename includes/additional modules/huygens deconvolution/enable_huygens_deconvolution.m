function handles = enable_huygens_deconvolution(handles)

huygensWavelengths = {488, 520, true; 550, 592, false; 514, 530, false};
handles.uitables.huygens_wavelengths.Data = huygensWavelengths;

%% Add elements to GUI
handles = populateTabs(handles, 'uipanel_workflow_imagePreparation_deconvolution','workflow_imagePreparationTabs');
handles = replaceUIPanel(handles, 'workflow_imagePreparation_deconvolution');

%% Sort image preparation tabs
sortTabs(handles.layout.tabs.workflow_imagePreparationTabs);