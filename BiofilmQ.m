% Copyright (c) 2016-2019 by Raimo Hartmann
% Copyright (c) 2018-2023 by Hannah Jeckel
% Copyright (c) 2018-2021 by Eric Jelli
% Copyright (c) 2022-2023 by Niklas Netter
% Max-Planck Institute for terrestrial Microbiology, Marburg
% Philipps-University, Marburg


function varargout = BiofilmQ(varargin)
% BIOFILMQ MATLAB code for BiofilmQ.fig
%      BIOFILMQ, by itself, creates a new BIOFILMQ or raises the existing
%      singleton*.
%
%      H = BIOFILMQ returns the handle to a new BIOFILMQ or the handle to
%      the existing singleton*.
%
%      BIOFILMQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIOFILMQ.M with the given input arguments.
%
%      BIOFILMQ('Property','Value',...) creates a new BIOFILMQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BiofilmQ_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BiofilmQ_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows onlesizey one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text_workflow_simulationInput_cellExpansionFactorDescr to modify the response to help BiofilmQ

% Last Modified by GUIDE v2.5 09-Oct-2022 17:00:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BiofilmQ_OpeningFcn, ...
    'gui_OutputFcn',  @BiofilmQ_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% This function controls the splash screen
function goOn = triggerSplashScreen(instance)
try
    % Open splash screen
    s = getappdata(0,'aeSplashHandle');
    
    goOn = 1;
    
    create_s = 0;
    try
        if isempty(s)
            create_s = 1;
        end
    end
    
    if (create_s && instance == 0) || instance == 1
        if isdeployed
            aniSeq = arrayfun(@(x) sprintf('splash%02d.png', x), 1:24, 'UniformOutput', false);
        else
            animation = dir(fullfile(pwd, 'includes', 'layout', 'splashScreen', 'animation', '*.png'));
            aniSeq = cellfun(@(x, y) fullfile(x, y), repmat({fullfile(pwd, 'includes', 'layout', 'splashScreen', 'animation')}, 1, numel({animation.name})), {animation.name}, 'UniformOutput', false);
        end
        
        s = SplashScreen('BiofilmQ', aniSeq,...
            'ProgressBar', 'on', ...
            'ProgressPosition', 62, ...
            'ProgressRatio', 0.0 );
        %s.addText( 300, 375, 'Loading...', 'FontSize', 18, 'Color', 'white' )
        
        setappdata(0,'aeSplashHandle',s) % Point to splashScreen handle in order to delete it when GUI opens
    end
end

% --- Executes just before BiofilmQ is made visible.
function BiofilmQ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to mainFig
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BiofilmQ (see VARARGIN)

%% Add folder 'includes' and change directory to right path
currentDir = fileparts(mfilename('fullpath'));
chdir(currentDir);

if isdeployed
    versions = textscan(fopen('biofilmQ_version.txt'), '%s');
else
    versions = textscan(fopen(fullfile('includes', 'biofilmQ_version.txt')), '%s');
end
version = versions{1}{1};

fprintf('=== BiofilmQ - The Biofilm Segmentation Toolbox (%s) ===\n', version)
fprintf('Copyright (c) 2016-2019 by Raimo Hartmann\n');
fprintf('Copyright (c) 2018-2023 by Hannah Jeckel\n');
fprintf('Copyright (c) 2018-2021 by Eric Jelli\n');
fprintf('Copyright (c) 2022-2023 by Niklas Netter\n');
fprintf('Loading... ');

% Choose default command line output for BiofilmQ
handles.output = hObject;



if ~isdeployed
    addpath(genpath(fullfile(currentDir, 'includes')));
    addpath(currentDir);
else
   if ~exist(fullfile(currentDir, 'includes'), 'dir')
       mkdir(fullfile(currentDir, 'includes'));
   end
   
   if ~exist(fullfile(currentDir, 'includes', 'temp'), 'dir')
       mkdir(fullfile(currentDir, 'includes', 'temp'));
   end
end

toggleBusyPointer(handles, true)


%% Check for toolboxes
if ~isToolboxAvailable('Image Processing Toolbox')
    msgbox('"Image Processing Toolbox" is required.', 'Toolbox missing', 'error', 'modal');
    delete(f);
end

if ~isToolboxAvailable('Parallel Computing Toolbox')
    msgbox('No "Parallel Computing Toolbox" found. Processing will be very slow.', 'Toolbox missing', 'warn', 'modal');
end

if ~isToolboxAvailable('Curve Fitting Toolbox')
    msgbox('No "Curve Fitting Toolbox" found. Some tasks might not work.', 'Toolbox missing', 'warn', 'modal');
end

%% Settings
handles.java = [];
handles.settings.selectedFile = [];
handles.settings.GUIDisabled = false;
handles.settings.GUIDisabledVisualization = false;
handles.settings.databases = {'stats', 'globalMeasurements'};
handles.settings.databaseNames = {'singleObject', 'global'};
handles.settings.showMsgs = 1;
handles.settings.figureSize = [1715 1100];
handles.settings.channelColors = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1];
handles.settings.padding = 8;
handles.settings.spacing = 8;
handles.settings.objectHeight = 22;
handles.settings.pathGUI = currentDir;
handles.settings.displayMode = '';
handles.settings.useDefaultSettingsOnDirectoryChange = true;

if ismac
    handles.settings.tabLocations = 'top';
else
    handles.settings.tabLocations = 'left';
end

%% Start splash screen
triggerSplashScreen(1);
handles.splashScreenHandle = getappdata(0,'aeSplashHandle');
set(handles.splashScreenHandle,'ProgressRatio', 0.05)



%% Initialize Appdata
setappdata(0, 'hMain', gcf);

%% Clear /includes/temp
try delete(fullfile(currentDir, 'includes', 'temp', '*')); end

%% Tidy up handles
handles = tidyGUIHandles(handles);

%% Load images
if isdeployed
    handles.settings.declumpingMethodImages = { ...
        imread('gridding.png'), ...
        imread('none.png'),...
        imread('labels.png')};
else
    handles.settings.declumpingMethodImages = { ...
        imread(fullfile(currentDir, 'includes', 'help', 'gridding.png')), ...
        imread(fullfile(currentDir, 'includes', 'help', 'none.png')),...
        imread(fullfile(currentDir, 'includes', 'help', 'labels.png'))};
end


if isdeployed
    % Binary only contains gridding and none
    handles.settings.declumpingMethodImages = { ...
        imread('gridding.png'), ...
        imread('labels.png'), ...
        imread('none.png')};
else
    handles.settings.declumpingMethodImages = { ...
        imread(fullfile(currentDir, 'includes', 'help', 'gridding.png')), ...
        imread(fullfile(currentDir, 'includes', 'help', 'none.png')), ...
        imread(fullfile(currentDir, 'includes', 'help', 'labels.png')), ...
        imread(fullfile(currentDir, 'includes', 'additional modules', ...
            'single cell segmentation', 'image processing', 'help', ...
            'watershedding.png')), ...
        imread(fullfile(currentDir, 'includes', 'additional modules', ...
            'seeded watershed 3D', 'image processing', 'help', ...
            'seeded_watershedding.png'))};
end


imagesc(handles.settings.declumpingMethodImages{1}, 'Parent', handles.axes.axes_declumpingMethod);
box(handles.axes.axes_declumpingMethod, 'off');

try
    axis(handles.axes.axes_declumpingMethod, 'tight', 'equal', 'off')
end

%% Initialize default parameter list
% Syntax: {Parameter name, parameter state [boolean], default options, datatype [numeric, char, boolean, file], message for parameter input, yielding fields, required module, description}
cellParametersCalculate =...
    {'Filter objects', false, 'Click to see options', [], [], 'None', [],...
    'Use the filter option to flag objects, which shall be excluded from the data (for instance background objects). After filtering, objects not within the indicated range are excluded from further analysis, but only deleted, if you perform the task <i>"Remove objects which did not pass filtering"</i>. To perform this second step is highly recommended to reduce file sizes. Only those parameters are available for filtering which have been calculated, yet. To extend the list of available filtering parameters, execute "Calculate object parameters" twice.', ...
    'usage/parameter_calculation.html#filter-objects';...
    'Remove objects which did not pass filtering', false, '', [], [], 'None', [],...
    'Delete objects from the dataset, which have been flagged by the filtering module <i>"Filter objects"</i>.', ...
    'usage/parameter_calculation.html#remove-objects-which-did-not-pass-filtering';...
    'Remove objects on the image border', false, '', [], [], 'None', [],...
    'Remove objects which are intersecting with the crop rectangle (in case the image was cropped) or the image border.', ...
    'usage/parameter_calculation.html#remove-objects-on-the-image-border';...
    'Remove object parameters, option: parameters', false, '', 'char', 'Please enter the parameters (separated by comma) which shall no longer be associated with each object.', 'None', [],...
    'Remove unused/unwanted parameters from the dataset for instance to decrease the file size.', ...
    'usage/parameter_calculation.html#remove-object-parameters';...
    'Surface properties, option: range [vox]', false, 3, 'numeric', 'Enter a range value [in vox].',  'Surface_LocalRoughness, Surface_PerSubstrateArea, Surface_LocalThickness, Biofilm_MeanThickness (global), Biofilm_Roughness (global), Biofilm_OuterSurface (global)', [],...
    'Calculate surface properties per cube object. For the local roughness the amount of surface area around the centroid in a specified range is calculated (local roughness in terms of surface per volume). In addition cubes with identical x and y center positions are merged into a pillar. For each pillar the surface area per pillar base area and the local thickness in terms of local height [in um] is calculated.', ...
    'usage/parameter_calculation.html#surface-properties';...
    'Substrate area', false, '', 'numeric', 'Please enter the index at which the substrate is located in your tif stack.','Architecture_LocalSubstrateArea, Biofilm_SubstrateArea', [],...
    'Calculate area at which the biofilm is attached to the substrate. The substrate is assumed to be the brightest layer of cells in the field of view. If you wish to specify a different substrate index, please insert it in the text field.', ...
    'usage/parameter_calculation.html#substrate-area';...
    'Global biofilm properties', false, '', [], [], 'Biofilm_AspectRatio_HeightToLength Biofilm_AspectRatio_HeightToWidth, Biofilm_AspectRatio_LengthToWidth, Biofilm_BaseEccentricity, Biofilm_BaseArea [in um^2], Biofilm_Volume [in um^3]', [],...
    'Calculate global biofilm properties: aspect ratios, base area, base eccentricity (based on ellipsoidal fit) and total biofilm volume.', ...
    'usage/parameter_calculation.html#global-biofilm-properties';...
    'Convexity', false, '', [], [], 'Shape_Convexity', [],...
    'Calculate the convexity of each object. The convexity can be slightly above one for convex objects due to interpolation.', ...
    'usage/parameter_calculation.html';... %TODO!
    'Distance to center biofilm', false, '', [], [], 'Distance_ToBiofilmCenterOfMass [in um], Distance_ToBiofilmCenterAtSubstrate [in um] </b>(distance to the center at the bottom of the biofilm)', [],...
    'Calculate the distance to the center of mass of the biofilm and the distance to the center of the biofilm (which is the center of mass projected to the bottom of the biofilm).', ...
    'usage/parameter_calculation.html#distance-to-center-of-biofilm';...
    'Distance to surface, option: resolution [vox]', false, 2, 'numeric', 'Enter the smoothing range [in vox] to estimate the global biofilm shape.', 'distanceToSurface [in um]', [],...
    'Estimate the distance to the <i>upper</i> biofilm outer surface for each object.', ...
    'usage/parameter_calculation.html#distance-to-surface';...
    'Distance to nearest neighbor, option: channel', false, 1, 'numeric', 'Please enter the channel number containing the objects you want to measure the closest distance to. Note the the image has to be segmented.', 'Distance_ToNearestNeighbor [in um]', [],...
    'Calculate the centroid-to-centroid distance to the nearest neighbor in a specific channel.', ...
    'usage/parameter_calculation.html#distance-to-nearest-neighbor';...
    'Distance to specific object, option: object ID', false, '', 'numeric', 'Enter the ID of the specific object the centroid-to-centroid distance shall be measured to.', 'distanceToCell_(ID) [in um]', [],...
    'Calculate the distance to a specific object.', ...
    'usage/parameter_calculation.html#distance-to-specific-object';...
    'Local density, option: range [vox]', false, 3, 'numeric', 'Enter the range for the calculation of the local density [in um].', 'Architecture_LocalNumberDensity_(range), Architecture_LocalDensity_(range)', [],...
    'Calculate the local number density (number of cells/sphere of indicated diameter) and the local density (occupied volume fraction). Please note that the local number density is not corrected for image edge effects, whereas the local density is corrected.', ...
    'usage/parameter_calculation.html#local-density';...
    'Fluorescence properties', false, 'Click to see options', [], [], 'This module can measure a vast amount of different parameters (see below)', [],...
    'Calculate fluorescence properties, perform correlations between different fluorescence channels, and extract the Haralick texture features.', ...
    'usage/parameter_calculation.html#fluorescence-properties';...
    'Tag cells', false, 'Click to see options', [], [], 'Name of tagged cells can be freely choosen', [],...
    'Tag cells following certain criteria with user-defined tag names.', ...
    'usage/parameter_calculation.html#id7';...
    'Custom parameter', false, 'Click to see options', [], [], 'Name of new Parameter can be freely choosen', [],...
    'Calculate custom parameter from a combination of already calculated parameters.', ...
    'usage/parameter_calculation.html#id7';...
    'Parameter based on user-defined Matlab script', false, '', 'file', 'Please choose a Matlab script.', 'User_defined', [],...
    'Use the script "includes/cell processing/actions/user-defined parameters/template.m" as template for creating further models', ...
    'usage/parameter_calculation.html#custom-parameters'};

set(handles.splashScreenHandle,'ProgressRatio', 0.1)

%% Create layout
%handles.layout.grids.mainGrid = uix.Grid('Parent', handles.mainFig, 'Padding', 10, 'Spacing', 10);
handles.layout.boxPanels.mainVBox = uix.VBox('Parent', handles.mainFig, 'Padding', 10, 'Spacing', 10);

%% Header
handles.layout.boxPanels.mainHeader = uix.HBox('Parent', handles.layout.boxPanels.mainVBox, 'Spacing', 10);

handles.layout.uipanels.uipanel_experimentFolder.Parent = handles.layout.boxPanels.mainHeader;
handles.layout.uipanels.uipanel_folderStats.Parent = handles.layout.boxPanels.mainHeader;
handles.layout.uipanels.uipanel_status.Parent = handles.layout.boxPanels.mainHeader;

%% Create tabs
%% Main tabs
handles.layout.mainLayout = uix.CardPanel('Parent', handles.layout.boxPanels.mainVBox, 'Padding', 0);

% HTML area start screen
if isdeployed
    welcomeMsg = fileread('welcome.html');
    logoPath = which('logo_large.png');
else
    welcomeMsg = fileread(fullfile(currentDir, 'includes', 'layout', 'welcome.html'));
    logoPath = fullfile(currentDir, 'includes', 'layout', 'logo_large.png');
end
logoPath = ['file:///', strrep(logoPath, filesep, '/')];
welcomeMsg = strrep(welcomeMsg, '{{logo}}', logoPath);
welcomeMsg = strrep(welcomeMsg, '{{background_color}}', rgb2hex(get(0,'defaultUicontrolBackgroundColor')));

browserJ = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
handles.uicontrols.text.htmlBrowser = javacomponent(browserJ, [], handles.layout.mainLayout);
handles.uicontrols.text.htmlBrowser.setHtmlText(welcomeMsg);

handles.uicontrols.pushbutton.pushbutton_cancel.Enable = 'off';

handles.layout.tabs.mainTabs = uitabgroup('Parent', handles.layout.mainLayout, 'TabLocation', 'top', 'units', 'characters', 'Position', get(handles.layout.uipanels.uipanel_content, 'Position'));
handles.layout.mainLayout.Selection = 1;
handles.layout.boxPanels.mainVBox.Heights = [65 -1];
delete(handles.layout.uipanels.uipanel_content);

handles = populateTabs(handles, 'uipanel_imageProcessing','mainTabs');
handles = populateTabs(handles, 'uipanel_visualization','mainTabs');

%% Create Layout inside tabs
%% Image processing
handles.layout.boxPanels.imageProcessing = uix.HBox('Parent', handles.layout.tabs.imageProcessing, 'Spacing', 10, 'Padding', 10);

%% Files
handles.layout.boxPanels.imageProcessing_filesBoxPanel = uix.BoxPanel('Parent', handles.layout.boxPanels.imageProcessing, 'padding', 10,...
    'Title', handles.layout.uipanels.uipanel_files.Title, 'TitleColor', [0.7490 0.902 1], 'ForegroundColor', [0 0 0]);
handles.layout.boxPanels.imageProcessing_files = uix.VBox('Parent', handles.layout.boxPanels.imageProcessing_filesBoxPanel, 'Spacing', 10);

% Assing children
handles.uicontrols.popupmenu.popupmenu_fileType.Parent = handles.layout.boxPanels.imageProcessing_files;
handles.uitables.files.Parent = handles.layout.boxPanels.imageProcessing_files;
handles.layout.boxPanels.imageProcessing_files_buttonsGrid = uix.VBox('Parent', handles.layout.boxPanels.imageProcessing_files, 'Spacing', handles.settings.spacing);
handles.layout.boxPanels.imageProcessing_files_buttonsGridTop = uix.HBox('Parent', handles.layout.boxPanels.imageProcessing_files_buttonsGrid, 'Spacing', handles.settings.spacing);
handles.uicontrols.pushbutton.pushbutton_files_export.Parent = handles.layout.boxPanels.imageProcessing_files_buttonsGridTop;
uix.Empty('Parent', handles.layout.boxPanels.imageProcessing_files_buttonsGridTop);
handles.uicontrols.pushbutton.pushbutton_files_delete.Parent = handles.layout.boxPanels.imageProcessing_files_buttonsGridTop;
handles.uicontrols.checkbox.files_createPosFolder.Parent = handles.layout.boxPanels.imageProcessing_files_buttonsGrid;
handles.layout.boxPanels.imageProcessing_files_buttonsGrid.Heights = handles.settings.objectHeight*[1, 1];
handles.layout.boxPanels.imageProcessing_files_buttonsGridTop.Widths = [80, -1, 70];
handles.layout.boxPanels.imageProcessing_files.Heights = [handles.settings.objectHeight, -1, 2*handles.settings.objectHeight+handles.settings.spacing];

% Delete parent uipanel
delete(handles.layout.uipanels.uipanel_files);

%% Preview
handles.layout.boxPanels.imageProcessing_preview_slidePanel = uix.ScrollingPanel('Parent', handles.layout.boxPanels.imageProcessing);
handles.layout.boxPanels.imageProcessing_preview = uix.VBox('Parent', handles.layout.boxPanels.imageProcessing_preview_slidePanel, 'Spacing', 10);

% Assing children
handles.layout.uipanels.uipanel_imageDetails.Parent = handles.layout.boxPanels.imageProcessing_preview;
handles.layout.uipanels.uipanel_plotCellParameters.Parent = handles.layout.boxPanels.imageProcessing_preview;
handles.layout.boxPanels.boxpanel_commandHistory = uix.BoxPanel('Parent', handles.layout.boxPanels.imageProcessing_preview, 'padding', 10,...
    'Title', handles.layout.uipanels.uipanel_commandHistory.Title, 'TitleColor', [0.7490 0.902 1], 'ForegroundColor', [0 0 0]);
handles.uicontrols.listbox.listbox_status.Parent = handles.layout.boxPanels.boxpanel_commandHistory;
delete(handles.layout.uipanels.uipanel_commandHistory);

%% Workflow
handles.layout.boxPanels.imageProcessing_workflow = uix.VBox('Parent', handles.layout.boxPanels.imageProcessing, 'Spacing', 10);

% Assing children
handles.layout.uipanels.uipanel_imageRange.Parent = handles.layout.boxPanels.imageProcessing_workflow;

%% Analysis
handles.layout.boxPanels.analysis = uix.HBox('Parent', handles.layout.tabs.visualization, 'Spacing', 0, 'Padding', 10);

set(handles.splashScreenHandle,'ProgressRatio', 0.15)

%% Files
handles.layout.boxPanels.analysis_files = uix.VBox('Parent', handles.layout.boxPanels.analysis, 'Spacing', 10, 'Padding', handles.settings.padding);
handles.layout.boxPanels.analysis_filesBoxPanel = uix.BoxPanel('Parent', handles.layout.boxPanels.analysis_files, 'padding', 10,...
    'Title', handles.layout.uipanels.uipanel_analysis_files.Title, 'TitleColor', [0.7490 0.902 1], 'ForegroundColor', [0 0 0]);

% Assing children
handles.layout.uipanels.uipanel_imageRange_visualization.Parent = handles.layout.boxPanels.analysis_files;


%handles.uitables.analysis_files.Parent = handles.layout.boxPanels.analysis_filesBoxPanel;
delete(handles.layout.uipanels.uipanel_analysis_files);

handles.layout.boxPanels.analysis_biofilmPreviewBoxPanel = uix.BoxPanel('Parent', handles.layout.boxPanels.analysis_files, 'padding', 10,...
    'Title', handles.layout.uipanels.uipanel_analysis_biofilmPreview.Title, 'TitleColor', [0.7490 0.902 1], 'ForegroundColor', [0 0 0]);

% Assing children
handles.axes.axes_analysis_overview.Parent = handles.layout.boxPanels.analysis_biofilmPreviewBoxPanel;
delete(handles.layout.uipanels.uipanel_analysis_biofilmPreview);

%% Visualization
handles.layout.boxPanels.analysis_visualization = uix.VBox('Parent', handles.layout.boxPanels.analysis, 'Padding', 5);
handles.layout.boxPanels.analysis_analysisTabs_slidePanel = uix.ScrollingPanel('Parent', handles.layout.boxPanels.analysis_visualization);
uix.Empty('Parent', handles.layout.boxPanels.analysis_visualization);



% Assign callbacks
handles.layout.tabs.mainTabs.SelectionChangedFcn = @(hObject,eventdata)BiofilmQ('mainTabSelection_Callback',handles.layout.tabs.mainTabs,eventdata,guidata(handles.layout.tabs.mainTabs));

%% Invisible tabs placeholder
handles.layout.tabs.invisibleTabs = uitabgroup('Parent', handles.layout.uipanels.uipanel_invisibleTabs_placeholder, 'TabLocation', 'top', 'units', 'characters');
handles.layout.tabs.invisibleTabs.Visible = 'off';
handles.layout.tabs.invisibleTab = uitab('Parent', handles.layout.tabs.invisibleTabs);

%% Workflow
handles.layout.tabs.workflow = uitabgroup('Parent', handles.layout.tabs.imageProcessing, 'TabLocation', 'top', 'units', 'characters', 'Position', get(handles.layout.uipanels.uipanel_workflow, 'Position'));
delete(handles.layout.uipanels.uipanel_workflow);
handles = populateTabs(handles, 'uipanel_workflow_simulationInput','workflow');
handles = populateTabs(handles, 'uipanel_workflow_customTiffImportPanel', 'workflow');
handles = populateTabs(handles, 'uipanel_workflow_exportNd2','workflow');
handles = populateTabs(handles, 'uipanel_workflow_imagePreparation','workflow');
handles = populateTabs(handles, 'uipanel_workflow_segmentation','workflow');
handles = populateTabs(handles, 'uipanel_workflow_parameters','workflow');
handles = populateTabs(handles, 'uipanel_workflow_cellTracking','workflow');
handles = populateTabs(handles, 'uipanel_workflow_dataExport','workflow');
handles.layout.tabs.workflow.SelectedTab = handles.layout.tabs.workflow.Children(2);

handles.layout.boxPanels.imageProcessing_workflow_slidePanel = uix.ScrollingPanel('Parent', handles.layout.boxPanels.imageProcessing_workflow);
handles.layout.tabs.workflow.Parent = handles.layout.boxPanels.imageProcessing_workflow_slidePanel;

set(handles.splashScreenHandle,'ProgressRatio', 0.2)

%% Image preparation
handles.layout.tabs.workflow_imagePreparationTabs = uitabgroup('Parent', handles.layout.uipanels.uipanel_workflow_imagePreparationTabs.Parent, 'TabLocation', handles.settings.tabLocations, 'units', 'characters', 'Position', get(handles.layout.uipanels.uipanel_workflow_imagePreparationTabs, 'Position'));
delete(handles.layout.uipanels.uipanel_workflow_imagePreparationTabs);

handles = populateTabs(handles, 'uipanel_workflow_imagePreparation_imageSeriesCuration','workflow_imagePreparationTabs');
handles = populateTabs(handles, 'uipanel_workflow_imagePreparation_colonySeparation','workflow_imagePreparationTabs');
handles = populateTabs(handles, 'uipanel_workflow_imagePreparation_registration','workflow_imagePreparationTabs');

%% Segmentation
handles.layout.tabs.workflow_segmentationTabs = uitabgroup('Parent', handles.layout.uipanels.uipanel_workflow_segmentationTabs.Parent, 'TabLocation', handles.settings.tabLocations, 'units', 'characters', 'Position', get(handles.layout.uipanels.uipanel_workflow_segmentationTabs, 'Position'));
delete(handles.layout.uipanels.uipanel_workflow_segmentationTabs);

handles = populateTabs(handles, 'uipanel_workflow_segmentation_generalSettings','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_imageSettings','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_preprocessing','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_denoising','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_edgeDetection','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_thresholding','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_objectDeclumping','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_postprocessing','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_mergeAndTransfer','workflow_segmentationTabs');
handles = populateTabs(handles, 'uipanel_workflow_segmentation_labelImage_channel','workflow_segmentationTabs');

set(handles.splashScreenHandle,'ProgressRatio', 0.25)

%% Tracking
% No sub tabs available

%% Export
handles.layout.tabs.workflow_exportTabs = uitabgroup('Parent', handles.layout.uipanels.uipanel_workflow_dataExport_methodTabs.Parent, 'TabLocation', 'top', 'units', 'characters', 'Position', get(handles.layout.uipanels.uipanel_workflow_dataExport_methodTabs, 'Position'));
delete(handles.layout.uipanels.uipanel_workflow_dataExport_methodTabs)

handles = populateTabs(handles, 'uipanel_workflow_dataExport_vtk','workflow_exportTabs');
% Rendering panel is not implemented, yet.
% handles = populateTabs(handles,'uipanel_workflow_dataExport_render','workflow_exportTabs'); 
handles = populateTabs(handles, 'uipanel_workflow_dataExport_fcs','workflow_exportTabs');
handles = populateTabs(handles, 'uipanel_workflow_dataExport_csv','workflow_exportTabs');

set(handles.splashScreenHandle,'ProgressRatio', 0.3)


%% Add icon to window
handles.mainFig = addIcon(handles.mainFig);

set(handles.splashScreenHandle,'ProgressRatio', 0.35)

%% Parameters
handles = restylePanel(handles, handles.layout.uipanels.uipanel_cellParameters_parameterTabs, [1.0000 0.6784 0.64310]);

handles = addPanelToBoxPanel(handles, 'uipanel_parameters_filtering', 'boxpanel_cellParameters_parameterTabs');
handles = addPanelToBoxPanel(handles, 'uipanel_parameters_intensityFeatures', 'boxpanel_cellParameters_parameterTabs');
handles = addPanelToBoxPanel(handles, 'uipanel_parameters_tagCells', 'boxpanel_cellParameters_parameterTabs');
handles = addPanelToBoxPanel(handles, 'uipanel_parameters_inputTemplate', 'boxpanel_cellParameters_parameterTabs');
handles = addPanelToBoxPanel(handles, 'uipanel_parameters_inputTemplate_file', 'boxpanel_cellParameters_parameterTabs');
handles = addPanelToBoxPanel(handles, 'uipanel_parameters_mergingSplitting', 'boxpanel_cellParameters_parameterTabs');
handles = addPanelToBoxPanel(handles, 'uipanel_parameterCombination', 'boxpanel_cellParameters_parameterTabs');

%% Style
handles = restylePanel(handles, handles.layout.uipanels.uipanel_experimentFolder);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_imageRange_visualization);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_status);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_imageDetails);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_imageRange);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_segmentationControl);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_parameterDescription);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_plotCellParameters);
handles = restylePanel(handles, handles.layout.uipanels.uipanel_folderStats);

set(handles.splashScreenHandle,'ProgressRatio', 0.4)

%% Replace parameter description which html capable JLabel
handles.uicontrols.text.parameterDescriptionJ = uicomponent('style', 'javax.swing.JTextPane', ...
    'parent', handles.uicontrols.text.parameterDescription.Parent, 'ContentType', 'text/html', 'Editable', false,...
    'Opaque', false);
handles.uicontrols.text.parameterDescriptionJ.Units = 'characters';
handles.uicontrols.text.parameterDescriptionJ.Position = handles.uicontrols.text.parameterDescription.Position;
delete(handles.uicontrols.text.parameterDescription);
%delete(handles.uicontrols.text_workflow_simulationInput_cellExpansionFactorDescr.parameterDescription);

%% Replacing uipanels with dynamic elements
handles = replaceUIPanel(handles, 'uipanel_experimentFolder');
handles = replaceUIPanel(handles, 'uipanel_status');
handles = replaceUIPanel(handles, 'uipanel_folderStats');
handles = replaceUIPanel(handles, 'uipanel_imageDetails');

set(handles.splashScreenHandle,'ProgressRatio', 0.45)

handles = replaceUIPanel(handles, 'uipanel_plotCellParameters');
handles = replaceUIPanel(handles, 'uipanel_imageRange');
handles = replaceUIPanel(handles, 'workflow_imagePreparation_imageSeriesCuration');

set(handles.splashScreenHandle,'ProgressRatio', 0.46)

handles = replaceUIPanel(handles, 'workflow_imagePreparation_colonySeparation');
handles = replaceUIPanel(handles, 'workflow_imagePreparation_registration');
handles = replaceUIPanel(handles, 'uipanel_workflow_imagePreparation');
handles = replaceUIPanel(handles, 'uipanel_workflow_exportNd2');
handles = replaceUIPanel(handles, 'uipanel_workflow_simulationInput');
handles = replaceUIPanel(handles, 'uipanel_workflow_customTiffImportPanel');

set(handles.splashScreenHandle,'ProgressRatio', 0.47)

handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation');
handles = replaceUIPanel(handles, 'uipanel_segmentationControl');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_generalSettings');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_imageSettings');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_preprocessing');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_labelImage_channel');


set(handles.splashScreenHandle,'ProgressRatio', 0.50)

handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_denoising');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_edgeDetection');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_thresholding');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_objectDeclumping');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_postprocessing');
handles = replaceUIPanel(handles, 'uipanel_workflow_segmentation_mergeAndTransfer');

set(handles.splashScreenHandle,'ProgressRatio', 0.53)

handles = replaceUIPanel(handles, 'uipanel_workflow_parameters');
handles = replaceUIPanel(handles, 'uipanel_parameterDescription');
handles = replaceUIPanel(handles, 'uipanel_parameters_filtering');
handles = replaceUIPanel(handles, 'uipanel_parameters_mergingSplitting');
handles = replaceUIPanel(handles, 'uipanel_parameterCombination');
handles = replaceUIPanel(handles, 'uipanel_parameters_inputTemplate_file');

set(handles.splashScreenHandle,'ProgressRatio', 0.58)

handles = replaceUIPanel(handles, 'uipanel_parameters_inputTemplate');

handles = replaceUIPanel(handles, 'uipanel_parameters_intensityFeatures');
handles = replaceUIPanel(handles, 'uipanel_parameters_tagCells');
handles = replaceUIPanel(handles, 'uipanel_workflow_cellTracking');

set(handles.splashScreenHandle,'ProgressRatio', 0.6)

handles = replaceUIPanel(handles, 'uipanel_workflow_dataExport');
handles = replaceUIPanel(handles, 'uipanel_workflow_dataExport_vtk');
handles = replaceUIPanel(handles, 'uipanel_workflow_dataExport_fcs');

set(handles.splashScreenHandle,'ProgressRatio', 0.65)

handles = replaceUIPanel(handles, 'uipanel_workflow_dataExport_csv');
handles = replaceUIPanel(handles, 'uipanel_imageRange_visualization');

set(handles.splashScreenHandle,'ProgressRatio', 0.7)


%% Load defaults for cube segmentation
handles.layout.tabs.workflow_segmentation_generalSettings.Parent = handles.layout.tabs.invisibleTabs;
handles.layout.tabs.workflow_segmentation_thresholding.Parent = handles.layout.tabs.workflow_segmentationTabs;
handles.layout.tabs.workflow_segmentation_edgeDetection.Parent = handles.layout.tabs.invisibleTabs;
handles.layout.tabs.workflow_segmentation_labelImage_channel.Parent = handles.layout.tabs.invisibleTabs;
sortTabs(handles.layout.tabs.workflow_segmentationTabs);
handles.uicontrols.checkbox.median3D.Value = 0;
handles.uicontrols.popupmenu.declumpingMethod.Value = 1;
handles.uicontrols.edit.gridSpacing.String = '20';
handles.uicontrols.checkbox.stopProcessingNCellsMax.Value = 0;
handles.uicontrols.checkbox.removeVoxels.Value = 0;
handles.uicontrols.text.text_workflow_segmentation_preprocessing_gamma.Visible = 'off';
handles.uicontrols.popupmenu.gamma.Visible = 'off';
handles.uicontrols.text.text_workflow_segmentation_preprocessing_gammaDescr.Visible = 'off';

%% Clear tables on startup
handles.uitables.cellParametersCalculate.Data = cellParametersCalculate(:, 1:3);
handles.tableData = cellParametersCalculate;

handles.uitables.files.Data = {'No images loaded'};

handles.uitables.intensity_tasks.Data = [];
handles.uitables.tagCells_rules.Data = [];

%% Import analysis GUI
handles = loadAnalysisPanel(handles);
handles.layout.boxPanels.boxpanel_biofilmAnalysis.Parent = handles.layout.boxPanels.analysis_analysisTabs_slidePanel;

%% Check for additional modules
handles = loadAdditionalModules(handles);


%% Sort image preparation tabs
sortTabs(handles.layout.tabs.workflow_imagePreparationTabs, true);

handles = centerTexts(handles);

%% Change window size and resize behaviour
set(handles.splashScreenHandle,'ProgressRatio', 0.75)

%% Change order of children and set container sizes
handles.layout.boxPanels.imageProcessing_preview.Children = [...
    handles.layout.boxPanels.boxpanel_commandHistory,...
    handles.layout.boxPanels.boxpanel_plotCellParameters,...
    handles.layout.boxPanels.boxpanel_imageDetails];
handles.layout.boxPanels.imageProcessing_preview.Heights = [605, -3, -1];
handles.layout.boxPanels.imageProcessing_preview.MinimumHeights = [605, 200, 70];
handles.layout.boxPanels.imageProcessing_preview_slidePanel.MinimumHeights = 895;

handles.layout.boxPanels.imageProcessing_workflow.Children = [...
    handles.layout.boxPanels.imageProcessing_workflow_slidePanel,...
    handles.layout.boxPanels.boxpanel_imageRange];

handles.layout.boxPanels.imageProcessing_workflow.Heights = [handles.settings.objectHeight+2*handles.settings.padding+3*handles.settings.spacing, -1];
handles.layout.boxPanels.imageProcessing_workflow_slidePanel.MinimumHeights = 1;
handles.layout.boxPanels.imageProcessing_workflow_slidePanel.MinimumWidths = 720;

handles.layout.boxPanels.analysis_files.Children = [...
    handles.layout.boxPanels.analysis_biofilmPreviewBoxPanel,...
    handles.layout.boxPanels.analysis_filesBoxPanel,...
    handles.layout.boxPanels.boxpanel_imageRange_visualization];

handles.layout.boxPanels.analysis_files.Heights = [60 -1 200];

set(handles.splashScreenHandle,'ProgressRatio', 0.80)

handles.layout.boxPanels.analysis_visualization.Heights = [-1, 0];
handles.layout.boxPanels.analysis_analysisTabs_slidePanel.MinimumHeights = 500;
handles.layout.boxPanels.analysis_analysisTabs_slidePanel.MinimumWidths = 1;
%handles.layout.boxPanels.analysis.Widths = [-1 1180];
handles.layout.boxPanels.analysis.Widths = [490 -1];

handles.layout.boxPanels.mainHeader.Widths = [-2 -1.3 -1];
handles.layout.boxPanels.mainHeader.MinimumWidths = [300 300 0];
handles.layout.boxPanels.imageProcessing.Widths = [430, 390, -1];
set(handles.splashScreenHandle,'ProgressRatio', 0.85)

%% Retrieve jave-handles of tables
% Store java-handle of file list
try
    drawnow;
    handles.java.files_javaHandle = findjobj(handles.uitables.files);
    jscrollpane = javaObjectEDT(handles.java.files_javaHandle);
    viewport    = javaObjectEDT(jscrollpane.getViewport);
    jtable      = javaObjectEDT(viewport.getView);
    handles.java.files_jtable = jtable;
    
    [jtable, jscrollpane] = createJavaTable(uix.VBox('Parent', handles.layout.boxPanels.analysis_filesBoxPanel), {@analysis_files_CellSelectionCallback, handles});
    handles.java.tableAnalysis = {jtable, jscrollpane};
    set(handle(jtable.getModel, 'CallbackProperties'));%, 'IndexChangedCallback', @calculateStatistics)
    
catch
    uiwait(msgbox('Could not retrieve underlying java object for file table!', 'Please note', 'error', 'modal'));
end

set(handles.splashScreenHandle,'ProgressRatio', 0.90)

%% Disable non-required elements
handles = toggleUIElements(handles, 0, 'image_processing', 'init');
handles = toggleUIElements(handles, 0, 'visualization', 'init');

set(handles.splashScreenHandle,'ProgressRatio', 0.95)

set(handles.axes.axes_status, 'XTick', [], 'YTick', []);

% Resize figure
set(handles.mainFig, 'units', 'pixels');
pos = get(handles.mainFig, 'Position');
pos(3) = handles.settings.figureSize(1);
pos(4) = handles.settings.figureSize(2);
screenSize = get(0,'screensize');

if screenSize(3) >= pos(3)
    pos(1) = (screenSize(3)-pos(3))/2;
else
    pos(1) = 0;
    pos(3) = screenSize(3);
end
if screenSize(4) >= pos(4)
    pos(2) = (screenSize(4)-pos(4))/2;
else
    pos(2) = 0;
    pos(4) = screenSize(4);
end

handles = centerTexts(handles);

set(handles.splashScreenHandle,'ProgressRatio', 1)

set(handles.mainFig, 'Position', pos, 'Resize', 'on');

%% Assign help icons
handles.layout.boxPanels.imageProcessing_filesBoxPanel.HelpFcn = {@openHelp, 'usage/fileInput.html'};
handles.layout.boxPanels.boxpanel_experimentFolder.HelpFcn = {@openHelp, 'usage/fileInput.html'};
handles.layout.boxPanels.boxpanel_biofilmAnalysis.HelpFcn = {@openHelp, 'usage/visualization.html'};
handles.layout.boxPanels.boxpanel_segmentationControl.HelpFcn = {@openHelp, 'usage/segmentation.html'};
handles.layout.boxPanels.boxpanel_parameterDescription.HelpFcn = {@openHelp, 'usage/parameter_calculation.html'};
handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.HelpFcn = {@openHelp, 'usage/parameter_calculation.html'};

%% Remove unused uipanel handles
handles = deleteEmptyPanels(handles);

%% Update handles structure
assignin('base', 'handles', handles)
assignin('base', 'hObject', hObject)

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = BiofilmQ_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to mainFig
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

fprintf('Done.\n');
deleteSplashScreen(handles.splashScreenHandle)
toggleBusyPointer(handles, false)

% --- Executes when mainFig is resized.
function mainFig_SizeChangedFcn(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
try
    if handles.mainFig.Position(3) < 1570
        handles.layout.boxPanels.imageProcessing.Widths = [300, 390, -1];
        handles.layout.boxPanels.imageProcessing.Children(3).Position(3) = 300;
    else
        handles.layout.boxPanels.imageProcessing.Widths = [-1, 390, 840];
    end
    
    if handles.mainFig.Position(3) < 1500
        handles.layout.boxPanels.analysis.Widths = [365, -1];
        handles.layout.boxPanels.analysis.Children(2).Position(3) = 365;
    else
        handles.layout.boxPanels.analysis.Widths = [-1, 1200];
    end
    
    if handles.mainFig.Position(4) < handles.settings.figureSize(2)
        handles.layout.boxPanels.analysis_visualization.Heights = [-1, 1];
        
    else
        handles.layout.boxPanels.analysis_visualization.Heights = [990, -1];
    end
    
end
toggleBusyPointer(handles, false)

% --- Executes when user attempts to close mainFig.
function mainFig_CloseRequestFcn(hObject, eventdata, handles)
delete(handles.mainFig);


function mainTabSelection_Callback(hObject, eventdata, handles)
% --- Executes on selection change in files table.


function files_Callback(hObject, eventdata, handles)

set(handles.uicontrols.edit.manualThreshold, 'String', '0');
set(handles.uicontrols.edit.cropRange, 'String', '');
set(handles.uicontrols.edit.I_base, 'String', '0');

try
    file = eventdata.Indices(1);
catch
    return;
end

if file > size(handles.uitables.files.Data,1)
    file = size(handles.uitables.files.Data,1);
end
handles.settings.selectedFile = file;
guidata(hObject, handles);


handles.layout.boxes.segmentationPreviewLoadButton.Parent = handles.layout.boxes.plotCellParameters_container;
handles.layout.boxes.plotCellParameters.Parent = handles.layout.tabs.invisibleTab;

if ~isfield(handles, 'settings')
    fprintf('No files loaded\n');
    displayStatus(handles, ['No files loaded...'], 'red');
    return;
end

if ~isfield(handles.settings, 'lists')
    fprintf('No files loaded\n');
    displayStatus(handles, ['No files loaded...'], 'red');
    return;
end
files = handles.settings.lists;

fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');

switch fileType
    case 1
        field = 'files_nd2';
    case 2
        field = 'files_tif';
    case 3
        field = 'files_metadata';
    case 4
        field = 'files_cells';
    case 5
        field = 'files_vtk';
    case 6
        field = 'files_sim';
end

toggleBusyPointer(handles, true)

if fileType>1 && fileType<6
    
    try
        handles.axes.axes_preview.Parent = handles.layout.boxes.axes_preview_container;
        
        % Read metadata and update edits for scaling/thresholds/etc...
        try
            metadata = handles.settings.metadataGlobal{file};
        catch
            try
                metadata_file = dir(fullfile(handles.settings.directory, files.files_metadata(file).name));
            catch
                metadata_file = [];
            end
            if ~isempty(metadata_file)
                metadata = load(fullfile(handles.settings.directory,metadata_file.name));
            elseif handles.settings.showMsgs && (fileType == 2 || fileType == 3)
                uiwait(msgbox('Metadata file does not exist!', 'Warning', 'warn', 'modal'));
            end
        end
        
        try
            set(handles.uicontrols.checkbox.cropRangeInterpolated, 'Value', metadata.data.cropRangeInterpolated);
        end
        
        warning('backtrace', 'off');
        try
            set(handles.uicontrols.edit.scaling_dxy, 'String', num2str(metadata.data.scaling.dxy*1000));
        catch
            warning('Scaling information (dxy) not found in metadata!');
        end
        try
            set(handles.uicontrols.edit.scaling_dz, 'String', num2str(metadata.data.scaling.dz*1000));
        catch
            warning('Scaling information (dz) not found in metadata!');
        end
        warning('backtrace', 'on');
        
        try
            set(handles.uicontrols.edit.I_base, 'String', num2str(metadata.data.I_base));
        end
        try
            set(handles.uicontrols.edit.cropRange, 'String', num2str(metadata.data.cropRange));
        end
        try
            set(handles.uicontrols.edit.minCellInt, 'String', num2str(metadata.data.minCellInt));
        catch
            set(handles.uicontrols.edit.minCellInt, 'String', '[-Inf, Inf]');
        end
        try
            set(handles.uicontrols.edit.manualThreshold, 'String', num2str(metadata.data.manualThreshold));
        end
        try
            % Update filter parameters
            if length(files.files_cells)>=file
                cell_file = fullfile(handles.settings.directory, 'data', files.files_cells(file).name);

                if ~strcmp(files.files_cells(file).name(1:7), 'missing')
                    fieldNames = load(cell_file, 'measurementFields');
                    fNames = setdiff(fieldNames.measurementFields, {'Centroid', 'BoundingBox', 'Cube_CenterCoord', 'Orientation_Matrix', 'MinBoundBox_Cornerpoints'});
                    fNames = sort(union(fNames, {'ID', 'CentroidCoordinate_x', 'CentroidCoordinate_y', 'CentroidCoordinate_z'}));
                else
                    fNames = {};
                end


                intFields = strfind(fNames, 'Intensity_Mean');
                fieldID = 1;
                for i = 1:length(intFields)
                    if ~isempty(intFields{i})
                        fieldID = i;
                        break;
                    end
                end

                if get(handles.uicontrols.popupmenu.filter_parameter, 'Value') > numel(fNames)
                    set(handles.uicontrols.popupmenu.filter_parameter, 'Value', fieldID);
                end

                if get(handles.uicontrols.popupmenu.tagCells_parameter, 'Value') > numel(fNames)
                    set(handles.uicontrols.popupmenu.tagCells_parameter, 'Value', fieldID);
                end

                set(handles.uicontrols.popupmenu.tagCells_parameter, 'Value', 1);

                % Update export fields
                % fNames = setdiff(fieldNames.measurementFields, {'Centroid', 'BoundingBox', 'Cube_CenterCoord', 'Orientation_Matrix'});
                if ~isempty(fNames)
                    fNames = sort(union(fieldNames.measurementFields, {'ID', 'RandomNumber', 'Distance_FromSubstrate', 'Timepoint'}));
                end

                tableData = [fNames num2cell(true(size(fNames)))];
                set(handles.uitables.cellParametersStoreVTK, 'Data', tableData);
                if ~isempty(tableData)
                    set(handles.uicontrols.popupmenu.renderParaview_parameter, 'String', tableData(:,1));
                end
                if get(handles.uicontrols.popupmenu.renderParaview_parameter, 'Value') > numel(fNames)
                    set(handles.uicontrols.popupmenu.renderParaview_parameter, 'Value', fieldID);
                end


                handles = storeValues(hObject, eventdata, handles);
            end
        catch err
            warning(err.message);
        end
        
        im_initial = imread(fullfile(handles.settings.directory, files.files_tif(file).name), 1);
        
        if handles.uicontrols.checkbox.displayAllChannels.Value
            cmap = handles.settings.channelColors;
            imRGB = zeros(size(im_initial, 1), size(im_initial, 2), 3);
            
            for j = 1:size(cmap, 1)
                filename = fullfile(handles.settings.directory, strrep(files.files_tif(file).name, sprintf('_ch%d', handles.uicontrols.popupmenu.channel.Value), sprintf('_ch%d', j)));
                if exist(filename, 'file')
                    if j == handles.uicontrols.popupmenu.channel.Value
                        im = double(im_initial);
                    else
                        im = double(imread(filename, 1));
                    end
                    intRange = [prctile(im(:), 5) prctile(im(:), 99.9)];
                    im = (im - intRange(1))/(intRange(2)-intRange(1));
                    
                    for c = 1:3
                        imRGB(:,:,c) = imRGB(:,:,c) + im * cmap(j, c);
                    end
                end
            end
            imRGB(imRGB>1) = 1;
            im = uint8(255*imRGB);
        else
            im = im_initial;
        end
        
        
        % Apply crop
        try
            cropRange = handles.settings.metadataGlobal{file}.data.cropRange;
        catch
            cropRange = [];
        end
        
        x_shift = 0;
        y_shift = 0;
        
        if get(handles.uicontrols.checkbox.displayAlignedImage, 'Value')
            try
                im2 = performImageAlignment2D(im, metadata);
            catch
                set(handles.uicontrols.checkbox.displayAlignedImage, 'Value', 0);
                storeValues(hObject, eventdata, handles);
                if handles.settings.showMsgs
                    uiwait(msgbox('Image stack is not registered! "Display aligned image" was disabled.', 'Please note', 'warn', 'modal'));
                else
                    warning('Image stack is not registered! "Display aligned image" was disabled.');
                end
                im2 = im;
            end
        else
            im2 = im;
        end
        
        delete(get(handles.axes.axes_preview, 'Children'));
        
        if size(im, 3) == 1
            try
                intRange = [prctile(im(:), 5) prctile(im(:), 99.9)];
            catch
                im_sorted = sort(im(:));
                intRange = im_sorted([round(0.05*numel(im_sorted)) round(0.99*numel(im_sorted))]);
            end
            if ~diff(intRange)
                intRange(1) = 0;
                if ~intRange(2)
                    intRange(2) = 1;
                end
            end
            imagesc(im2, 'Parent', handles.axes.axes_preview, intRange);
        else
            imagesc(im2, 'Parent', handles.axes.axes_preview);
        end
        
        axis(handles.axes.axes_preview, 'off', 'tight', 'equal');
        colormap(handles.axes.axes_preview, gray(256));
        
        try
            x_shift = metadata.data.registration.T(4,1);
            y_shift = metadata.data.registration.T(4,2);
        end
        
        if get(handles.uicontrols.checkbox.imageRegistration, 'Value')
            
            
            % Get registration of reference frame
            if get(handles.uicontrols.checkbox.fixedOutputSize, 'Value')
                cropRange_ref = str2num(get(handles.uicontrols.edit.registrationReferenceCropping, 'String'));
                if ~isempty(cropRange_ref)
                    
                    if ~get(handles.uicontrols.checkbox.displayAlignedImage, 'Value')
                        cropRange_ref = cropRange_ref-[x_shift y_shift 0 0];
                    end
                    
                    rectangle('Position',cropRange_ref, 'Parent', handles.axes.axes_preview, 'LineWidth',1.5, 'LineStyle', ':',...
                        'EdgeColor', [0.929,  0.694,  0.125])
                end
                
            else
                cropRange_ref = [];
            end
            
            
            
            if ~isempty(cropRange_ref)
                text(cropRange_ref(1), cropRange_ref(2), 'Reference frame', 'Parent', handles.axes.axes_preview, 'Color', [0.929,  0.694,  0.125], 'BackgroundColor', 'black', 'FontSize', 6)
            end
        else
            cropRange_ref = [1 1 size(im, 2), size(im, 1)];
        end
        
        if ~isempty(cropRange)
            if get(handles.uicontrols.checkbox.imageRegistration, 'Value')
                if ~get(handles.uicontrols.checkbox.displayAlignedImage, 'Value')
                    cropRange_shifted = cropRange-[x_shift y_shift 0 0];
                    cropRange_shifted(cropRange_shifted<1)=1;
                    cropRange_shifted(3) = min(cropRange_shifted(3), size(im2, 2)-cropRange_shifted(1));
                    cropRange_shifted(4) = min(cropRange_shifted(4), size(im2, 1)-cropRange_shifted(2));
                else
                    cropRange_shifted = cropRange;
                end
            else
                if ~get(handles.uicontrols.checkbox.displayAlignedImage, 'Value')
                    cropRange_shifted = cropRange;
                else
                    cropRange_shifted = cropRange+[x_shift y_shift 0 0];
                    cropRange_shifted(cropRange_shifted<1)=1;
                    cropRange_shifted(3) = min(cropRange_shifted(3), size(im2, 2)-cropRange_shifted(1));
                    cropRange_shifted(4) = min(cropRange_shifted(4), size(im2, 1)-cropRange_shifted(2));
                end
            end
            
            try
                edgeColor = [0.929,  0.694,  0.125];
                if (cropRange_shifted(1) < cropRange_ref(1)) || (cropRange_shifted(2) < cropRange_ref(2)) || ...
                        (cropRange_shifted(1) + cropRange_shifted(3) > cropRange_ref(1) + cropRange_ref(3)) ||...
                        (cropRange_shifted(2) + cropRange_shifted(4) > cropRange_ref(2) + cropRange_ref(4))
                    edgeColor = 'r';
                end
                
                try
                    rectangle('Position',cropRange_shifted, 'Parent', handles.axes.axes_preview,  'LineWidth',1.5, ...
                        'EdgeColor', edgeColor)
                catch
                    text(10,10, 'Crop rectangle does not fit!', 'Color', 'r', 'FontWeight', 'bold', 'Parent', handles.axes.axes_preview);
                end
            catch
                rectangle('Position',cropRange_shifted, 'Parent', handles.axes.axes_preview,  'LineWidth',1.5, ...
                    'EdgeColor', edgeColor)
            end
        end
        
        
        flowDirection = str2num(get(handles.uicontrols.edit.flowDirection, 'String'));
        if ~isempty(flowDirection)
            try
                set(handles.axes.axes_preview, 'NextPlot', 'add');
                x = 0.2*size(im2,1);
                y = 0.2*size(im2,2);
                arrowLength = 0.1*size(im2,1);
                
                quiver(handles.axes.axes_preview, x,y,flowDirection(1)*arrowLength, flowDirection(2)*arrowLength, 1, 'Color', [0.929,  0.694,  0.125], 'LineWidth', 1, 'MaxHeadSIze', 10);
                text(x,y, ' Flow', 'Color', [0.929,  0.694,  0.125], 'Parent', handles.axes.axes_preview);
                set(handles.axes.axes_preview, 'NextPlot', 'replace');
            end
        end     
        
        % update conversion to um
        pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.topHatSize.String),1);
        handles.uicontrols.text.text_workflow_segmentation_denoising_tophatUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);
        
        pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.trackCellsDilatePx.String),1);
        handles.uicontrols.text.text_workflow_cellTracking_dilateUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);
        
        pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.removeVoxelsOfSize.String),3);
        handles.uicontrols.text.text_removeVoxelsOfSize.String = sprintf('vox (%.2f \x03BCm\x00B3)', pxSize);
        
        pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.gridSpacing.String),1);
        handles.uicontrols.text.text_workflow_segmentation_objectDeclumping_cubeSideLengthUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);
        
        if any(strfind(handles.uicontrols.text.text_parameterUnitConversion.String, 'vox'))
            pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.parameterInput.String),1);
            handles.uicontrols.text.text_parameterUnitConversion.String = sprintf('vox (%.2f \x03BCm)', pxSize);
        end
        
    catch err
        delete(handles.axes.axes_preview.Children);
        warning('backtrace', 'off')
        warning(sprintf('Could not load associated tif-stack! Reason: %s.', err.message));
        warning('backtrace', 'on')
    end
end

try
    fileDetails = {'File details:', files.(field)(file).name, sprintf('Size: %.2f Mb', files.(field)(file).bytes/1024/1024)};
catch
    fileDetails = '';
end

handles.uicontrols.text.text_fileDetails.Parent.Heights(1) = 40;
handles.uicontrols.text.text_fileDetails.Parent.Heights(2) = -1;

if fileType == 1
    try
        metadataReader = bfGetReader(fullfile(handles.settings.directory, files.(field)(file).name));
        sPos = metadataReader.getSeriesCount();
        omeMeta = metadataReader.getMetadataStore();
        sX = omeMeta.getPixelsSizeX(0).getValue();
        sY = omeMeta.getPixelsSizeY(0).getValue();
        sZ = omeMeta.getPixelsSizeZ(0).getValue();
        sCh = omeMeta.getPixelsSizeC(0).getValue();
        sT = omeMeta.getPixelsSizeT(0).getValue();
        
        fileDetails = [fileDetails, {'', '------------------', 'Metadata:', '------------------', sprintf('Positions: %d', sPos), '', 'Data of position 1:', sprintf('Dimensions [X, Y, Z]: [%d, %d, %d]', sX, sY, sZ), sprintf('Channels: %d', sCh), sprintf('Timepoints: %d', sT)}];
        
        handles.uicontrols.text.text_fileDetails.Parent.Heights(1) = -1;
        handles.uicontrols.text.text_fileDetails.Parent.Heights(2) = 0;
        handles.axes.axes_preview.Parent = [];
        
    catch err
        if handles.settings.showMsgs
            try
                uiwait(msgbox(sprintf('Could not read metadata information for file "%s"! Error: %s.', files.(field)(file).name, err.message), 'Warning', 'warn', 'modal'));
            end
        else
            warning('Could not read metadata information for file "%s"! Error: %s.', files.(field)(file).name, err.message);
        end
    end
end

if exist('additionalCallbacks', 'file')
    handles = additionalCallbacks('files_Callback', hObject, eventdata, handles);
end

set(handles.uicontrols.text.text_fileDetails, 'String', fileDetails);
handles = storeValues(hObject, eventdata, handles);
toggleBusyPointer(handles, false)

function inputFolder_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function inputFolder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browseFolder.
function pushbutton_browseFolder_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
%% Select input directory
if exist('directory.mat','file')
    load('directory.mat');
else
    directory = '';
end

directory = uigetdir(directory, 'Please select directory containing the imaging files');
if directory
    try
        save('directory.mat', 'directory', '-append');
    catch
        save('directory.mat', 'directory');
    end
else
    uiwait(msgbox('No experiment folder selected.', 'Please note', 'help', 'modal'));
    toggleBusyPointer(handles, false)
    return;
end

displayStatus(handles, ['Input directory: ', directory], 'green');

set(handles.uicontrols.edit.inputFolder, 'String', directory);
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)

% --- Executes on button press in pushbutton_refreshFolder.
function pushbutton_refreshFolder_Callback(hObject, eventdata, handles)

switch handles.layout.tabs.mainTabs.SelectedTab.Title
    case 'I. Image processing'
        loadFolderForImageProcessing(hObject, eventdata, handles);
    case 'II. Visualization'
        loadFolderForImageProcessing(hObject, eventdata, handles);
end


function loadFolderForImageProcessing(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
displayStatus(handles, 'Scanning experiment folder...', 'black');
[handles, status] = analyzeDirectory(hObject, eventdata, handles);

displayStatus(handles, 'Done', 'black', 'add');

if ~isfield(handles.settings, 'directory') || ~status
    toggleBusyPointer(handles, false)
    return;
end

guidata(hObject, handles);

% Update file list selection
if isempty(handles.settings.selectedFile)
    range = str2num(handles.uicontrols.edit.action_imageRange.String);
    if ~isempty(range)
        handles.settings.selectedFile = range(1);
    end
end

try
    handles.java.files_jtable.changeSelection(handles.settings.selectedFile - 1,0,0,0);
catch
    try
        handles.settings.selectedFile = length(file_list);
        handles.java.files_jtable.changeSelection(handles.settings.selectedFile - 1,0,0,0);
    end
end
toggleBusyPointer(handles, false)

% --- Executes on selection change in popupmenu_fileType.
function popupmenu_fileType_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
switch get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value')
    case 1
        file = 'nd2';
    case 2
        file = 'tif';
    case 3
        file = 'metadata';
    case 4
        file = 'cells';
    case 5
        file = 'vtk';
    case 6
        file = 'sim';
end
handles = showFileList(hObject, eventdata, handles, file);
guidata(hObject, handles);
toggleBusyPointer(handles, false)

% --- Executes during object creation, after setting all properties.
function popupmenu_fileType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function field = switchFileType(fileType)
switch fileType
    case 1
        field = 'files_nd2';
    case 2
        field = 'files_tif';
    case 3
        field = 'files_metadata';
    case 4
        field = 'files_mask';
    case 5
        field = 'files_cells';
    case 6
        field = 'files_vtk';
end


% --- Executes on button press in pushbutton_files_showImage.
function pushbutton_files_showImage_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
if ~isfield(handles, 'settings')
    fprintf('No files loaded!\n');
    displayStatus(handles, 'No files loaded!', 'red');
    return;
end


toggleBusyPointer(handles, true)

files = handles.settings.lists;

fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');

switch fileType
    case 1
        field = 'files_nd2';
        displayStatus(handles, ['Loading data: "', fullfile(handles.settings.directory, files.(field)(file).name), '"...'], 'black');
        open(fullfile(handles.settings.directory, files.(field)(file).name))
        displayStatus(handles, 'Done', 'black', 'add');
    case 2
        field = 'files_tif';
        displayStatus(handles, ['Loading data: "', fullfile(handles.settings.directory, files.(field)(file).name), '"...'], 'black');
        im = imread3D(fullfile(handles.settings.directory, files.(field)(file).name));
        prepareFigure(hObject, handles, files.(field)(file).name);
        imshow3D(im(:,:,2:end));
        displayStatus(handles, 'Done', 'black', 'add');
    case 3
        field = 'files_metadata';
        uiwait(msgbox('File cannot be displayed.', 'Please note', 'warn', 'modal'));
    case 4
        field = 'files_cells';
        displayStatus(handles, ['Loading data: "', fullfile(handles.settings.directory, files.(field)(file).name), '"...'], 'black');
        objects = loadObjects(fullfile(handles.settings.directory, 'data', files.(field)(file).name));
        prepareFigure(hObject,handles, files.(field)(file).name);
        imshow3D(labelmatrix(objects));
        displayStatus(handles, 'Done', 'black', 'add');
    case 5
        field = 'files_vtk';
        uiwait(msgbox('File cannot be displayed.', 'Please note', 'warn', 'modal'));
end
toggleBusyPointer(handles, false)

function h = prepareFigure(hObject,handles, title)
if isfield(handles, 'externalFig')
    if isvalid(handles.externalFig)
    else
        handles.externalFig = figure('Name', title);
        addIcon(handles.externalFig);
    end
else
    handles.externalFig = figure('Name', title);
    addIcon(handles.externalFig);
end
delete(get(handles.externalFig, 'Children'));
h = figure(handles.externalFig);
h.Position = positionExternalFigure(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_files_showOrtho.
function pushbutton_files_showOrtho_Callback(hObject, eventdata, handles)

file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
if ~isfield(handles, 'settings')
    fprintf('No files loaded!\n');
    displayStatus(handles, 'No files loaded!', 'red');
    return;
end

toggleBusyPointer(handles, true)
files = handles.settings.lists;

fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');

switch fileType
    case 2
        field = 'files_tif';
        displayStatus(handles, ['Loading data: "', fullfile(handles.settings.directory, files.(field)(file).name), '"...'], 'black');
        
        folderToOpen = handles.settings.directory;
        
        numZ = cellfun(@getStackSize, {handles.settings.lists.files_tif.name});
        maxZ = max(numZ);
        
        timepoints = cell(numel(handles.settings.metadataGlobal, 1));
        
        % Open metadata-files
        for i = 1:numel(handles.settings.metadataGlobal)
            metadata = handles.settings.metadataGlobal{i};
            try
                timepoints{i} = metadata.data.date;
            catch
                timepoints{i} = i;
            end
        end
        
        % Open metadata-files
        im = imread3D(fullfile(folderToOpen, handles.settings.lists.files_tif(file).name));
        
        im = im(:,:,2:end);
        
        [~, workingDir] = fileparts(handles.settings.directory);
        
        h = zSlicer_time(im, maxZ, handles.settings.lists.files_tif, timepoints, workingDir, metadata.data.scaling, file);
        h.figure1.Position = positionExternalFigure(handles);
        
        displayStatus(handles, 'Done', 'black', 'add');
    case 4
        field = 'files_cells';
        displayStatus(handles, ['Loading data: "', fullfile(handles.settings.directory, files.(field)(file).name), '"...'], 'black');
        
        objects = loadObjects(fullfile(handles.settings.directory, 'data', files.(field)(file).name));
        objects.PixelIdxList = objects.PixelIdxList(objects.goodObjects);
        objects.NumObjects = sum(objects.goodObjects);
        
        im = labelmatrix(objects);
        cmap = rand(objects.NumObjects, 3);
        cmap(1,:) = 0;
        h = zSlicer(im, cmap, 'parentGui', handles, 'title', sprintf('zSlicer %s', files.(field)(file).name));
        h.Position = positionExternalFigure(handles);
        
        displayStatus(handles, 'Done', 'black', 'add');
        
    otherwise
        if handles.settings.showMsgs
            uiwait(msgbox('File cannot be displayed.', 'Please note', 'warn', 'modal'));
        else
            warning('File cannot be displayed.');
        end
end
toggleBusyPointer(handles, false)

function stackSize = getStackSize(name)
indexOfNumZ = strfind(name, '_Nz');
if any(strfind(name, 'cmle'))
    indexOfTif = strfind(name, '_cmle.tif');
else
    indexOfTif = strfind(name, '.tif');
end
stackSize = str2num(name(indexOfNumZ+3:indexOfTif-1));


% --- Executes on selection change in listbox_visCell_params.
function listbox_visCell_params_Callback(hObject, eventdata, handles, nBins)
toggleBusyPointer(handles, true)
selectedField = get(handles.uicontrols.listbox.listbox_visCell_params, 'Value');

fNames = fieldnames(handles.data.objects.stats);

if get(handles.uicontrols.checkbox.checkbox_visCell_autoRange, 'Value')
    try
        
        values = [handles.data.objects.stats.(fNames{selectedField})];
        goodObjects = [handles.data.objects.goodObjects];
        values = values(goodObjects);
        
        minValue = min(values);
        maxValue = max(values);
        
        if nargin == 3
            if numel(unique(values)) <= 10
                set(handles.uicontrols.edit.cellVis_nBins, 'String', numel(unique(values)));
            else
                set(handles.uicontrols.edit.cellVis_nBins, 'String', '50');
            end
            nBins = str2num(get(handles.uicontrols.edit.cellVis_nBins, 'String'));
        end
        
        hist_str = [num2str(minValue, '%.2f'), ':',num2str((maxValue-minValue)/nBins, '%.2g'),':', num2str(maxValue, '%.2f')];
        
        set(handles.uicontrols.edit.visCell_range, 'String', hist_str);
        set(handles.uicontrols.pushbutton.pushbutton_visCell_histogram, 'Enable', 'on');
        set(handles.uicontrols.pushbutton.pushbutton_getColormap, 'Enable', 'on');
        set(handles.uicontrols.pushbutton.pushbutton_orthoViewLabelled, 'Enable', 'on');
    catch
        set(handles.uicontrols.edit.visCell_range, 'String', 'data cannot be displayed as histogram');
        set(handles.uicontrols.pushbutton.pushbutton_visCell_histogram, 'Enable', 'off');
        set(handles.uicontrols.pushbutton.pushbutton_getColormap, 'Enable', 'off');
        set(handles.uicontrols.pushbutton.pushbutton_orthoViewLabelled, 'Enable', 'off');
    end
end
toggleBusyPointer(handles, false)

% --- Executes during object creation, after setting all properties.
function listbox_visCell_params_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_visCell_autoRange.
function checkbox_visCell_autoRange_Callback(hObject, eventdata, handles)


function visCell_range_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function visCell_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_visCell_histogram.
function pushbutton_visCell_histogram_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
if sum(handles.data.objects.goodObjects) == 0
    uiwait(msgbox('Cannot plot data. No valid objects found!', 'Warning', 'warn', 'modal'));
    return;
end

selectedField = get(handles.uicontrols.listbox.listbox_visCell_params, 'Value');
fNames = fieldnames(handles.data.objects.stats);

logScale = get(handles.uicontrols.checkbox.logScale, 'Value');


h = figure('Name', fNames{selectedField});
addIcon(h);
h_ax = axes('Parent', h);


switch fNames{selectedField}
    case 'Centroid'
        centroid = [handles.data.objects.stats([handles.data.objects.goodObjects]).(fNames{selectedField})];
        x = centroid(1:3:end);
        y = centroid(2:3:end);
        z = centroid(3:3:end);
        
        plot3(h_ax, x,y,z, 'o');
        
        [x_label, x_unit] = returnUnitLabel('x', handles.data.objects);
        [y_label, y_unit] = returnUnitLabel('y', handles.data.objects);
        [z_label, z_unit] = returnUnitLabel('z', handles.data.objects);
        
        xlabel(h_ax, sprintf('%s %s', x_label, x_unit));
        ylabel(h_ax, sprintf('%s %s', y_label, y_unit));
        zlabel(h_ax, sprintf('%s %s', z_label, z_unit));
        
    case 'Cube_CenterCoord'
        centroid = [handles.data.objects.stats([handles.data.objects.goodObjects]).(fNames{selectedField})];
        x = centroid(1:3:end);
        y = centroid(2:3:end);
        z = centroid(3:3:end);
        
        plot3(h_ax, x,y,z, 'o');
        
        [x_label, x_unit] = returnUnitLabel('x', handles.data.objects);
        [y_label, y_unit] = returnUnitLabel('y', handles.data.objects);
        [z_label, z_unit] = returnUnitLabel('z', handles.data.objects);
        
        xlabel(h_ax, sprintf('%s %s', x_label, x_unit));
        ylabel(h_ax, sprintf('%s %s', y_label, y_unit));
        zlabel(h_ax, sprintf('%s %s', z_label, z_unit));
        
    case 'Orientation_Matrix'
        centroid = [handles.data.objects.stats([handles.data.objects.goodObjects]).Centroid];
        x = centroid(1:3:end);
        y = centroid(2:3:end);
        z = centroid(3:3:end);
        
        evecs = {handles.data.objects.stats([handles.data.objects.goodObjects]).Orientation_Matrix};
        
        scaling_dxy = str2num(get(handles.uicontrols.edit.scaling_dxy, 'String'))/1000;
        
        length = [handles.data.objects.stats([handles.data.objects.goodObjects]).Shape_Length]/scaling_dxy;
        width = [handles.data.objects.stats([handles.data.objects.goodObjects]).Shape_Width]/scaling_dxy;
        height = [handles.data.objects.stats([handles.data.objects.goodObjects]).Shape_Height]/scaling_dxy;
        
        %u = evecs(1, 1:3:end).*length/2;
        %v = evecs(2, 1:3:end).*length/2;
        %w = evecs(3, 1:3:end).*length/2;
        
        
        plot3(h_ax, x,y,z, 'o');
        for k = 1:numel(x)
            line([x(k)-length(k)/2*evecs{k}(1,1) x(k)+length(k)/2*evecs{k}(1,1)],...
                [y(k)-length(k)/2*evecs{k}(2,1) y(k)+length(k)/2*evecs{k}(2,1)],...
                [z(k)-length(k)/2*evecs{k}(3,1) z(k)+length(k)/2*evecs{k}(3,1)]);
        end
        
        %quiver3(x,y,z, u,v,w);
        
        axis(h_ax, 'equal');
        
        [x_label, x_unit] = returnUnitLabel('x', handles.data.objects);
        [y_label, y_unit] = returnUnitLabel('y', handles.data.objects);
        [z_label, z_unit] = returnUnitLabel('z', handles.data.objects);
        
        xlabel(h_ax, sprintf('%s %s', x_label, x_unit));
        ylabel(h_ax, sprintf('%s %s', y_label, y_unit));
        zlabel(h_ax, sprintf('%s %s', z_label, z_unit));
    case 'BoundingBox'
        BB = [handles.data.objects.stats([handles.data.objects.goodObjects]).(fNames{selectedField})];
        
        X = BB(1:6:end);
        Y = BB(2:6:end);
        Z = BB(3:6:end);
        W = BB(4:6:end);
        H = BB(5:6:end);
        D = BB(6:6:end);
        
        set(h_ax, 'NextPlot', 'add');
        colors = rand(numel(X), 3);
        for i = 1:numel(X)
            x = X(i);
            y = Y(i);
            z = Z(i);
            w = W(i);
            h = H(i);
            d = D(i);
            
            face1 = [x y z; x+w y z; x+w y+h z; x y+h z; x y z];
            face2 = [x y z+d; x+w y z+d; x+w y+h z+d; x y+h z+d; x y z+d];
            con1 = [x y z; x y z+d];
            con2 = [x+w y z; x+w y z+d];
            con3 = [x y+h z; x y+h z+d];
            con4 = [x+w y+h z; x+w y+h z+d];
            
            plot3(h_ax, face1(:,1), face1(:,2), face1(:,3), 'Color', colors(i,:));
            plot3(h_ax, face2(:,1), face2(:,2), face2(:,3), 'Color', colors(i,:));
            plot3(h_ax, con1(:,1), con1(:,2), con1(:,3), 'Color', colors(i,:));
            plot3(h_ax, con2(:,1), con2(:,2), con2(:,3), 'Color', colors(i,:));
            plot3(h_ax, con3(:,1), con3(:,2), con3(:,3), 'Color', colors(i,:));
            plot3(h_ax, con4(:,1), con4(:,2), con4(:,3), 'Color', colors(i,:));
        end
        
        [x_label, x_unit] = returnUnitLabel('x', handles.data.objects);
        [y_label, y_unit] = returnUnitLabel('y', handles.data.objects);
        [z_label, z_unit] = returnUnitLabel('z', handles.data.objects);
        
        xlabel(h_ax, sprintf('%s %s', x_label, x_unit));
        ylabel(h_ax, sprintf('%s %s', y_label, y_unit));
        zlabel(h_ax, sprintf('%s %s', z_label, z_unit));
        
        view(h_ax, 135, 20);
        
    otherwise
        values = [handles.data.objects.stats.(fNames{selectedField})];
        values = values(logical(handles.data.objects.goodObjects));
        
        N = get(handles.uicontrols.edit.visCell_range, 'String');
        Ndiv = strfind(N, ':');
        
        x_start = str2num(N(1:Ndiv(1)-1));
        x_step = str2num(N(Ndiv(1)+1:Ndiv(2)-1));
        x_end = str2num(N(Ndiv(2)+1:end));
        
        
        values(isnan(values)) = [];
        
        if logScale
            if x_start == 0
                x_start = 0.01;
            end
            N = logspace(log10(x_start), log10(x_end), ((x_end-x_start)/(x_step)+1));
        else
            N = linspace(x_start, x_end, ((x_end-x_start)/(x_step)+1));
        end
        
        if islogical(values)
            hist(double(values));
        else
            counts = histc(values, N);
            if handles.uicontrols.popupmenu.visCells_plotType.Value == 1
                bar(h_ax, N, counts);
            else
                plot(h_ax, N, counts);
            end
        end
        
        [x_label, x_unit] = returnUnitLabel(fNames{selectedField}, handles.data.objects);
        
        xlabel(h_ax, sprintf('%s %s', x_label, x_unit));
        ylabel(h_ax, 'Counts');
        
        plotted_data.N = N;
        plotted_data.counts = counts;
        plotted_data.data = values;
        
        if logScale
            set(gca, 'XScale', 'log');
        end
        
        assignin('base', 'plotted_data', plotted_data);
end
toggleBusyPointer(handles, false)

% --- Executes on button press in pushbutton_files_delete.
function pushbutton_files_delete_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
selectedFiles = handles.java.files_jtable.getSelectedRows()+1;

if ~isfield(handles, 'settings')
    fprintf('No files loaded!\n');
    displayStatus(handles, 'No files loaded!', 'red');
    return;
end

files = handles.settings.lists;

fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');
field = switchFileType(fileType);

if fileType > 1
    choice = questdlg('Delete all associated files?', ...
        'Delete file', ...
        'Yes','No','No');
    switch choice
        case 'Yes'
            for f = 1:numel(selectedFiles)
                file = selectedFiles(f);
                file_base_idx = strfind(files.(field)(file).name, 'Nz');
                file_base_ori = files.(field)(file).name(1:file_base_idx+1);
                
                for ch = 1:numel(handles.uicontrols.popupmenu.channel.String)
                    
                    if numel(handles.uicontrols.popupmenu.channel.String) > 1
                        file_base = strrep(file_base_ori, 'ch1', ['ch', getChannelName(handles.uicontrols.popupmenu.channel.String{ch})]);
                    else
                        file_base = file_base_ori;
                    end
                    
                    delete(fullfile(handles.settings.directory, [file_base, '*.tif']));
                    displayStatus(handles, ['Deleted: ', fullfile(handles.settings.directory, files.(field)(file).name)], 'red');
                    
                    file_tif_metadata = dir(fullfile(handles.settings.directory, [file_base, '*_metadata.mat']));
                    
                    ind = strfind(file_base, 'Nz');
                    file_mask_cells_vtk = dir(fullfile(handles.settings.directory, 'data', [file_base(1:ind-2), '*']));
                    
                    for i = 1:length(file_tif_metadata)
                        delete(fullfile(handles.settings.directory, file_tif_metadata(i).name));
                        displayStatus(handles, ['Deleted: ', fullfile(handles.settings.directory, file_tif_metadata(i).name)], 'red');
                    end
                    for i = 1:length(file_mask_cells_vtk)
                        delete(fullfile(handles.settings.directory, 'data', file_mask_cells_vtk(i).name));
                        displayStatus(handles, ['Deleted: ', fullfile(handles.settings.directory, 'data', file_mask_cells_vtk(i).name)], 'red');
                    end
                end
            end

            
    end
else
    choice = questdlg('Are you sure you want to delete this file?', ...
        'Delete file', ...
        'Yes','No','Yes');
    switch choice
        case 'Yes'
            delete(fullfile(directory, files.(field)(file).name));
            displayStatus(handles, ['Deleted: ', fullfile(handles.settings.directory, files.(field)(file).name)], 'red');
    end
end
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)

function kernelSize_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'odd', 'range', [3 Inf]);


% --- Executes during object creation, after setting all properties.
function kernelSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function reducePolygonsTo_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0.0001 1]);


% --- Executes during object creation, after setting all properties.
function reducePolygonsTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reducePolygons.
function reducePolygons_Callback(hObject, eventdata, handles)
if handles.uicontrols.checkbox.reducePolygons.Value
    handles.uicontrols.edit.reducePolygonsTo.Enable = 'on';
else
    handles.uicontrols.edit.reducePolygonsTo.Enable = 'off';
end

storeValues(hObject, eventdata, handles);


function pushbutton_processing_compileFFT_Callback(hObject, eventdata, handles)
cd(fullfile(pwd, 'includes', 'image processing', 'convfft'));
uiwait(msgbox({'Please use the file "convnfft_install.m" in the directory which will be opened in MATLAB to compile the required files.'...
    'Afterwards change the working directory back to "GUI"', 'Press "OK" to change the directory'}, 'Please Note', 'help', 'modal'));


% --- Executes on button press in pushbutton_vtk_compile.
function pushbutton_vtk_compile_Callback(hObject, eventdata, handles)
cd(fullfile(fileparts(mfilename('fullpath')), 'includes', 'export', 'visualization', 'paraview', 'mtVTK library'));
uiwait(msgbox({'Please compile the c-files in the directory which will be opened in MATLAB now.'...
    'Afterwards change the working directory back to the main folder of the program!', 'Press "OK" to change the directory'}, 'Please Note', 'help', 'modal'));


function watersheddingConn_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function watersheddingConn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxObjectSize_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [1 Inf]);


% --- Executes during object creation, after setting all properties.
function maxObjectSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function minObjectSize_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [1 Inf]);


% --- Executes during object creation, after setting all properties.
function minObjectSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scaling_dxy_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [1e-99 1e99], 'file', file);

% update conversion to um
pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.topHatSize.String),1);
handles.uicontrols.text.text_workflow_segmentation_denoising_tophatUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);

pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.trackCellsDilatePx.String),1);
handles.uicontrols.text.text_workflow_cellTracking_dilateUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);

pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.removeVoxelsOfSize.String),3);
handles.uicontrols.text.text_removeVoxelsOfSize.String = sprintf('vox (%.2f \x03BCm\x00B3)', pxSize);

pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.gridSpacing.String),1);
handles.uicontrols.text.text_workflow_segmentation_objectDeclumping_cubeSideLengthUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);

if any(strfind(handles.uicontrols.text.text_parameterUnitConversion.String, 'vox'))
    pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.parameterInput.String),1);
    handles.uicontrols.text.text_parameterUnitConversion.String = sprintf('vox (%.2f \x03BCm)', pxSize);
end


% --- Executes during object creation, after setting all properties.
function scaling_dxy_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scaling_dz_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [1e-99 1e99], 'file', file);


% --- Executes during object creation, after setting all properties.
function scaling_dz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function I_base_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'file', file);


% --- Executes during object creation, after setting all properties.
function I_base_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_pre_detBackground.
function pushbutton_pre_detBackground_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
determineBackground(hObject, eventdata, handles);
storeValues(hObject, eventdata, handles, file);


function cropRange_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;
handles = checkAndStoreInput(handles, hObject, 'inputType', 'array', 'condition', 'cropping', 'file', file);
eventdata = struct('Indices', file);
files_Callback(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cropRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_pre_selectCropRegion.
function pushbutton_pre_selectCropRegion_Callback(hObject, eventdata, handles)
%% Crop image
file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
displayStatus(handles, ['Cropping image "',handles.settings.lists.files_tif(file).name, '"'], 'black');


try
    metadata = handles.settings.metadataGlobal{file};
catch
    metadata_file = dir(fullfile(handles.settings.directory, files.files_metadata(file).name));
    if ~isempty(metadata_file)
        metadata = load(fullfile(handles.settings.directory,metadata_file.name));
    else
        if handles.settings.showMsgs
            uiwait(msgbox('Metadata file does not exist!', 'Warning', 'warn', 'modal'));
        else
            warning('Metadata file does not exist!');
        end
    end
end

projection = imread(fullfile(handles.settings.directory, handles.settings.lists.files_tif(file).name), 1);

if get(handles.uicontrols.checkbox.imageRegistration, 'Value')
    projection = performImageAlignment2D(projection, metadata);
end

h = figure('Name', handles.settings.lists.files_tif(file).name);
addIcon(h);

try
    intRange = [prctile(projection(:), 5) prctile(projection(:), 99.9)];
catch
    im_sorted = sort(projection(:));
    intRange = im_sorted([round(0.05*numel(im_sorted)) round(0.99*numel(im_sorted))]);
end

if ~diff(intRange)
    intRange(1) = 0;
    if ~intRange(2)
        intRange(2) = 1;
    end
end

h_ax = axes('Parent', h);
imagesc(projection,'Parent', h_ax);
set(h_ax, 'cLim', intRange);
colormap(h_ax, gray(255));
axis(h_ax, 'tight', 'equal', 'off');

if get(handles.uicontrols.checkbox.fixedOutputSize, 'Value') && get(handles.uicontrols.checkbox.imageRegistration, 'Value')
    cropRange_ref = str2num(get(handles.uicontrols.edit.registrationReferenceCropping, 'String'));
    if ~isempty(cropRange_ref)
        rectangle('Position',cropRange_ref, 'Parent', h_ax, 'LineWidth',1.5, 'LineStyle', ':',...
            'EdgeColor', [0.929,  0.694,  0.125])
    end
    
    try
        text(cropRange_ref(1), cropRange_ref(2), 'Reference frame', 'Parent', h_ax, 'Color', [0.929,  0.694,  0.125], 'BackgroundColor', 'black', 'FontSize', 8)
    end
end

currentCropRange = str2num(handles.uicontrols.edit.cropRange.String);
if ~isempty(currentCropRange)
    rectangle('Position',currentCropRange, 'Parent', h_ax, 'LineWidth',0.5, 'LineStyle', '-.',...
        'EdgeColor', [0.929,  0.694,  0.125])
end

title('Please draw rectangle to crop biofilm');
try
    cropRange = round(getrect);
catch
    cropRange = [];
end

if ~isempty(cropRange)
    cropRange(cropRange<1) = 1;
    
    if cropRange(1)+cropRange(3) > size(projection,2)
        cropRange(3) = size(projection,2)-cropRange(1);
    end
    
    if cropRange(2)+cropRange(4) > size(projection,1)
        cropRange(4) = size(projection,1)-cropRange(2);
    end
    
    if (cropRange(1) > size(projection,2)) || (cropRange(2) > size(projection,1))
        uiwait(msgbox('The crop rectangle has to be confined by the image dimensions!', 'Error', 'error', 'modal'));
        try
            delete(h);
        end
        return;
    end
    
    
    set(handles.uicontrols.edit.cropRange, 'String', num2str(cropRange));
    displayStatus(handles, [' -> Cropped range = [', num2str(cropRange),']'], 'black', 'add');
    
    
    set(handles.uicontrols.checkbox.cropRangeInterpolated, 'Value', 0);
    
    handles = storeValues(hObject, eventdata, handles, file);
    
    eventdata = struct('Indices', file);
    files_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);
end

try
    delete(h);
end


function minCellInt_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;

value = get(hObject, 'String');
value = strrep(value, ' ', '');
ind = strfind(value, ',');
num1 = value(2:ind-1);
num2 = value(ind+1:end-1);

if strcmp(num1, '-Inf') || strcmp(num1, 'Inf')
    
else
    if isempty(str2num(num1))
        set(hObject, 'String', '');
        return;
    end
end
if strcmp(num2, 'Inf')
    if isempty(str2num(num2))
        set(hObject, 'String', '');
        return;
    end
end

storeValues(hObject, eventdata, handles, file);


% --- Executes during object creation, after setting all properties.
function minCellInt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_cells_detMinInt.
function pushbutton_cells_detMinInt_Callback(hObject, eventdata, handles)
%% Load actual cells for thresholding
toggleBusyPointer(handles, true)
filterFieldValue = get(handles.uicontrols.popupmenu.filter_parameter, 'Value');
filterFieldStr = get(handles.uicontrols.popupmenu.filter_parameter, 'String');
logScale = get(handles.uicontrols.checkbox.filterLogScale, 'Value');

filterField = filterFieldStr{filterFieldValue};

file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
filename = fullfile(handles.settings.directory, 'data', handles.settings.lists.files_cells(file).name);
objects = loadObjects(filename, 'stats');
toggleBusyPointer(handles, false)
filterCellsByIntensity(objects, filterField, logScale);
try
    x1 = ginput(1);
    delete(gcf);
    set(handles.uicontrols.edit.minCellInt, 'String', sprintf('[%.03e, Inf]', x1(1)));
    
catch ME
    if strcmp(ME.identifier, 'MATLAB:ginput:FigureDeletionPause')
        % pass
    else
        rethrow(ME);
    end
end

minCellInt_Callback(handles.uicontrols.edit.minCellInt, eventdata, handles)


% --- Executes on button press in graduallyIncreaseInt.
function graduallyIncreaseInt_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function graduallyIncreaseIntTo_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric');


% --- Executes during object creation, after setting all properties.
function graduallyIncreaseIntTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_action_createMasks.
function pushbutton_action_createMasks_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
storeValues(hObject, eventdata, handles);
processImages(hObject, eventdata, handles)
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)

% --- Executes on button press in pushbutton_action_calculateCellParameters.
function pushbutton_action_calculateCellParameters_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
storeValues(hObject, eventdata, handles);
processObjects(hObject, eventdata, handles)
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)

% --- Executes on button press in pushbutton_action_visualize.
function pushbutton_action_visualize_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
storeValues(hObject, eventdata, handles);
createVisualization(hObject, eventdata, handles);
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)


% --- Executes on selection change in listbox_status.
function listbox_status_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function listbox_status_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_files_export.
function pushbutton_files_export_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
selectedFiles = str2num(handles.uicontrols.edit.action_imageRange.String);
files = handles.settings.lists;

fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');
if fileType == 1
    filenames = {files.files_nd2(selectedFiles).name};
    convertNdToTiff(handles, filenames);
    pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
else
    if handles.settings.showMsgs
        uiwait(msgbox('File cannot be exported to tiff-stack!', 'Warning', 'warn', 'modal'));
    else
        warning('File cannot be exported to tiff-stack!');
    end
end
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles, msg)
if nargin == 3
    displayStatus(handles, '<processing will be cancelled>', 'red', 'add');
    warning('off','backtrace')
    warning('Processing will be cancelled after this step!');
    warning('on','backtrace')
end
set(hObject, 'UserData', 1, 'String', 'Please wait...')


function action_imageRange_Callback(hObject, eventdata, handles)
[range_new, handles] = checkFileRange(hObject, eventdata, handles);

% Return if no files found
if isempty(range_new)
    storeValues(hObject, eventdata, handles);
    return;
end

% Only check metadata for tif stacks
if handles.uicontrols.popupmenu.popupmenu_fileType.Value > 1
    handles = checkMetadataOfSelectedFiles(hObject, eventdata, handles);
end
storeValues(hObject, eventdata, handles);

% TODO: Update Export list according to selection (c.f. analyzeDirector.m)


% --- Executes during object creation, after setting all properties.
function action_imageRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_visCell_getParams.
function pushbutton_visCell_getParams_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
try
    try
        if numel(handles.java.files_jtable.getSelectedRows) > 1
            uiwait(msgbox('Please select only one individual file.', 'Please note', 'help', 'modal'));
            return;
        end
        file = handles.java.files_jtable.getSelectedRow+1;
    catch
        uiwait(msgbox('Cannot read selected row from file list!', 'Please note', 'error', 'modal'));
        return;
    end
    
    files = handles.settings.lists;
    
    field = 'files_cells';
    objects = loadObjects(fullfile(handles.settings.directory, 'data', files.(field)(file).name));
    
    fnames = fieldnames(objects.stats);
    
    set(handles.uicontrols.listbox.listbox_visCell_params, 'String', fnames, 'Value', 1)
    set(handles.uicontrols.text.text_visCell_N, 'String', ['N = ', num2str(sum(objects.goodObjects)), '/', num2str(objects.NumObjects), ' cells']);
    
    handles.data.objects = objects;
    guidata(hObject, handles);
    
    assignin('base', 'objects', objects);
    
    handles.layout.boxes.segmentationPreviewLoadButton.Parent = handles.layout.tabs.invisibleTab;
    handles.layout.boxes.plotCellParameters.Parent = handles.layout.boxes.plotCellParameters_container;
catch err
    %warning(err.message);
    uiwait(msgbox(sprintf('Cannot proceed. Is there an associated "cell"-file present? Error: %s', err.message), 'Please note', 'error', 'modal'));
end
toggleBusyPointer(handles, false)


function cellVis_nBins_Callback(hObject, eventdata, handles)
listbox_visCell_params_Callback(hObject, eventdata, handles, str2num(handles.uicontrols.edit.cellVis_nBins.String))


% --- Executes during object creation, after setting all properties.
function cellVis_nBins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_cells_detMinIntEnd.
function pushbutton_cells_detMinIntEnd_Callback(hObject, eventdata, handles)
filterFieldValue = get(handles.uicontrols.popupmenu.filter_parameter, 'Value');
filterFieldStr = get(handles.uicontrols.popupmenu.filter_parameter, 'String');
logScale = get(handles.uicontrols.checkbox.filterLogScale, 'Value');

filterField = filterFieldStr{filterFieldValue};

f = length(handles.settings.lists.files_cells);

file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
filename = fullfile(handles.settings.directory, 'data', handles.settings.lists.files_cells(file).name);
objects = loadObjects(filename, 'stats');
filterCellsByIntensity(objects,  filterField, logScale);
x2 = ginput(1);
delete(gcf);
set(handles.uicontrols.edit.graduallyIncreaseIntTo, 'String', num2str(x2));
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_action_imageRange_takeSel.
function pushbutton_action_imageRange_takeSel_Callback(hObject, eventdata, handles)
switch handles.uicontrols.popupmenu.popupmenu_fileType.Value
    case 1 % Nd2-file
        files = handles.settings.lists.files_nd2;
    case 4
        files = handles.settings.lists.files_cells;
    case 6
        files = handles.settings.lists.files_sim;
    otherwise
        files = handles.settings.lists.files_tif; % Tif stacks
end
validFiles = find(cellfun(@(x) isempty(x), strfind({files.name}, 'missing')));

selectedImages = handles.java.files_jtable.getSelectedRows()+1;
range = assembleImageRange(intersect(selectedImages, validFiles));

handles.uicontrols.edit.action_imageRange.String = range;
action_imageRange_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_action_imageRange_takeAll.
function pushbutton_action_imageRange_takeAll_Callback(hObject, eventdata, handles)
switch handles.uicontrols.popupmenu.popupmenu_fileType.Value
    case 1 % Nd2-file
        files = handles.settings.lists.files_nd2;
    case 4
        files = handles.settings.lists.files_cells;
    case 6
        files = handles.settings.lists.files_sim;
    otherwise
        files = handles.settings.lists.files_tif; % Tif stacks
end
range = assembleImageRange(find(cellfun(@(x) isempty(x), strfind({files.name}, 'missing'))));
set(handles.uicontrols.edit.action_imageRange, 'String', range);
action_imageRange_Callback(hObject, eventdata, handles)


% --- Executes on selection change in channel.
function channel_Callback(hObject, eventdata, handles)
ch = hObject.Value;
ch_str = hObject.String;

handles.uicontrols.popupmenu.channel.Value = ch;
handles.uicontrols.popupmenu.channel_seg.Value = ch;

set(handles.uicontrols.text.text_channelDescription, 'String', ['and ', ch_str{ch}]);

storeValues(hObject, eventdata, handles);
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_action_trackCells.
function pushbutton_action_trackCells_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);
trackCells(handles)
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)


% --- Executes on selection change in watershedding_size_unit.
function watershedding_size_unit_Callback(hObject, eventdata, handles)
if exist('additionalCallbacks', 'file')
    handles = additionalCallbacks('watershedding_size_unit_Callback', hObject, eventdata, handles);
end


% --- Executes during object creation, after setting all properties.
function watershedding_size_unit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in I_base_perStack.
function I_base_perStack_Callback(hObject, eventdata, handles)
if exist('additionalCallbacks', 'file')
    handles = additionalCallbacks('I_base_perStack_Callback', hObject, eventdata, handles);
end


% --- Executes on button press in pushbutton_getColormap.
function pushbutton_getColormap_Callback(hObject, eventdata, handles)
makeColormapParaview


% --- Executes on selection change in trackMethod.
function trackMethod_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function trackMethod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function searchRadius_Callback(hObject, eventdata, handles)
if handles.uicontrols.popupmenu.declumpingMethod.Value==1
    radius = str2num(hObject.String);
    data = load(fullfile(handles.settings.directory, 'parameters.mat'));
    params = data.params;
    neededRadius = (str2double(handles.uicontrols.edit.gridSpacing.String)*params.scaling_dxy+1)/1000;
    if radius < neededRadius
        msgbox(sprintf('This radius is smaller than the cube edge length. If you continue with this value, only identical cubes will be related in the lineage tree. To avoid this, please enter a value greater or equal %.2f', neededRadius), 'Warning', 'warn');
    end
end

handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1e99]);


% --- Executes during object creation, after setting all properties.
function searchRadius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_registerImages.
function pushbutton_registerImages_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
storeValues(hObject, eventdata, handles);
registerImages(hObject, eventdata, handles);
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
set(handles.uicontrols.checkbox.imageRegistration, 'Value', 1)
imageRegistration_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)

% --- Executes on button press in imageRegistration.
function imageRegistration_Callback(hObject, eventdata, handles)
[~, handles] = checkFileRange(hObject, eventdata, handles);
handles = checkMetadataOfSelectedFiles(hObject, eventdata, handles);

if handles.uicontrols.checkbox.imageRegistration.Value
    set(handles.uicontrols.edit.registrationReferenceCropping, 'Enable', 'on');
    set(handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping, 'Enable', 'on');
    set(handles.uicontrols.checkbox.fixedOutputSize, 'Enable', 'on');
    set(handles.uicontrols.checkbox.displayAlignedImage, 'Value', 1);
else
    set(handles.uicontrols.edit.registrationReferenceCropping, 'Enable', 'off');
    set(handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping, 'Enable', 'off');
    set(handles.uicontrols.checkbox.fixedOutputSize, 'Enable', 'off');
    set(handles.uicontrols.checkbox.displayAlignedImage, 'Value', 0);
end

handles = storeValues(hObject, eventdata, handles);
eventdata = struct('Indices', handles.java.files_jtable.getSelectedRow+1);
files_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in cellParametersStoreVTK.
function cellParametersStoreVTK_CellEditCallback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes when entered data in editable cell(s) in cellParametersCalculate.
function cellParametersCalculate_CellEditCallback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in text_parameters_filtering_filterBy.
function filterCellsByIntensity_Callback(hObject, eventdata, handles)


% --- Executes on button press in trackCellsDilate.
function trackCellsDilate_Callback(hObject, eventdata, handles)
if ~get(hObject, 'Value')
    set(handles.uicontrols.edit.trackCellsDilatePx, 'Enable', 'off')
else
    set(handles.uicontrols.edit.trackCellsDilatePx, 'Enable', 'on')
end
storeValues(hObject, eventdata, handles);


function trackCellsDilatePx_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 500]);
pxSize = convertToUm(handles, str2double(handles.uicontrols.edit.trackCellsDilatePx.String),1);
handles.uicontrols.text.text_workflow_cellTracking_dilateUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);


% --- Executes during object creation, after setting all properties.
function trackCellsDilatePx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in denoiseImages.
function denoiseImages_Callback(hObject, eventdata, handles)
questionChangeBG(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_checkNoise.
function pushbutton_checkNoise_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
%% Load last file to extract background
displayStatus(handles, ['Extracting noise of the last image (',handles.settings.lists.files_tif(end).name,')'], 'black');
NSlices = str2num(handles.settings.lists.files_tif(end).name(strfind(handles.settings.lists.files_tif(end).name, 'Nz')+2:strfind(handles.settings.lists.files_tif(end).name, '.tif')-1));
lastSlice = imread(fullfile(handles.settings.directory, handles.settings.lists.files_tif(end).name), NSlices);
nlevel = NoiseLevel(double(lastSlice));
if nlevel < 20
    set(handles.uicontrols.checkbox.denoiseImages, 'Value', 0);
    uiwait(msgbox({['The images do NOT seem to be affected by shot noise (N=',num2str(nlevel),'). Denoising will be disabled.'],...
        'Recommended size for top-hat filtering: 14.', 'Re-determine the background!'}, 'Info', 'help', 'modal'));
else
    set(handles.uicontrols.checkbox.denoiseImages, 'Value', 1);
    uiwait(msgbox({['The images seem to be very noisy (N=',num2str(nlevel),'). Denoising will be enabled.'],...
        'Consider, that Top-Hat filtering with a small structuring element might destroy image information afterwards.',...
        'Recommended size for top-hat filtering: 30.', 'Re-determine the background!'}, 'Info', 'help', 'modal'));
end

displayStatus(handles, [' -> Noise: N=', num2str(nlevel)], 'black', 'add');
questionChangeBG(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);
toggleBusyPointer(handles, false)

% --- Executes on button press in topHatFiltering.
function topHatFiltering_Callback(hObject, eventdata, handles)
if ~get(hObject, 'Value')
    set(handles.uicontrols.edit.topHatSize, 'Enable', 'off')
else
    set(handles.uicontrols.edit.topHatSize, 'Enable', 'on')
end
questionChangeBG(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function topHatSize_Callback(hObject, eventdata, handles)
questionChangeBG(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'odd', 'range', [3 501]);
pxSize = convertToUm(handles, str2double(handles.uicontrols.edit.topHatSize.String),1);
handles.uicontrols.text.text_workflow_segmentation_denoising_tophatUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'odd', 'range', [1 501]);

function questionChangeBG(hObject, eventdata, handles)
if ~get(handles.uicontrols.checkbox.I_base_perStack, 'Value') && handles.uicontrols.popupmenu.thresholdingMethod.Value == 5
    choice = questdlg({'This operation has influences on the image background.',...
        'Recalculate image background?'}, ...
        'Image background', ...
        'Yes','No','Yes');
    switch choice
        case 'Yes'
            storeValues(hObject, eventdata, handles);
            toggleBusyPointer(handles, true)
            determineBackground(hObject, eventdata, handles);
            toggleBusyPointer(handles, false)
    end
end


% --- Executes during object creation, after setting all properties.
function topHatSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function context_background_visualize_Callback(hObject, eventdata, handles)
visualizeBackground(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_view_refresh_Callback(hObject, eventdata, handles)
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_file_selectDir_Callback(hObject, eventdata, handles)
pushbutton_browseFolder_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_file_close_Callback(hObject, eventdata, handles)
mainFig_CloseRequestFcn(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_process_all_Callback(hObject, eventdata, handles)
processAll(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_process_registerImages_Callback(hObject, eventdata, handles)
pushbutton_registerImages_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_process_masks_Callback(hObject, eventdata, handles)
pushbutton_action_createMasks_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_process_cellParams_Callback(hObject, eventdata, handles)
pushbutton_action_calculateCellParameters_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_process_trackCells_Callback(hObject, eventdata, handles)
pushbutton_action_trackCells_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_process_visCells_Callback(hObject, eventdata, handles)
pushbutton_action_visualize_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_process_all_select_Callback(hObject, eventdata, handles)
if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off');
else
    set(hObject, 'Checked', 'on')
end

% --------------------------------------------------------------------
function menu_process_all_select_all_Callback(hObject, eventdata, handles)
set(findobj('UserData',  2), 'Checked', 'on');

% --------------------------------------------------------------------
function menu_process_all_select_none_Callback(hObject, eventdata, handles)
set(findobj('UserData',  2), 'Checked', 'off');

% --------------------------------------------------------------------
function menu_cells_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_cells_merge_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_development_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_development_exportGuidata_Callback(hObject, eventdata, handles)
assignin('base', 'handles', handles)
assignin('base', 'hObject', hObject)
assignin('base', 'eventdata', 0)


function gamma_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function gamma_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_detBGforAll.
function pushbutton_detBGforAll_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);
determineBackgroundForAll(hObject, eventdata, handles);
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)


% --- Executes on selection change in filter_parameter.
function filter_parameter_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function filter_parameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filterLogScale.
function filterLogScale_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in logScale.
function logScale_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_cells_detMinInt_setAll.
function pushbutton_cells_detMinInt_setAll_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
minCellInt = get(handles.uicontrols.edit.minCellInt, 'String');
displayStatus(handles, 'Applying cell-filter-value to all images...', 'green');
for i = 1:length(handles.settings.lists.files_metadata)
    metadata = load(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name));
    data = metadata.data;
    data.minCellInt = minCellInt;
    handles.settings.metadataGlobal{i}.data = data;
    save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name), 'data');
end
guidata(hObject, handles);
displayStatus(handles, 'Done', 'black', 'add');
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_files_overlay.
function pushbutton_files_overlay_Callback(hObject, eventdata, handles)
fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');

if fileType == 6
    uiwait(msgbox('No overlay view possible', 'Please note', 'warn', 'modal'))
    return;
end

enableCancelButton(handles);

fprintf(' Preparing overlay, loading image ');
displayStatus(handles, 'Preparing overlay... please wait 1-5 min', 'black');

updateWaitbar(handles, 0.05)
file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
if ~isfield(handles, 'settings')
    fprintf('No files loaded!\n');
    displayStatus(handles, 'No files loaded!', 'red');
    return;
end

files = handles.settings.lists;

if isempty(files.files_cells)
    uiwait(msgbox('Image was not processed, yet!', 'Error', 'error', 'modal'));
    updateWaitbar(handles, 0)
    return
end

toggleBusyPointer(handles, true)
displayStatus(handles, ['Loading cells: "', fullfile(handles.settings.directory, files.files_cells(file).name), '"...'], 'black');
if isempty(strfind(files.files_cells(file).name, 'missing'))
    objects = loadObjects(fullfile(handles.settings.directory, 'data', files.files_cells(file).name));
else
    uiwait(msgbox('Image was not processed, yet!', 'Error', 'error', 'modal'));
    updateWaitbar(handles, 0)
    return
end

displayStatus(handles, 'Done', 'black', 'add');
updateWaitbar(handles, 0.1)

if isfield(objects, 'params')
    params = objects.params;
else
    params = load(fullfile(handles.settings.directory, 'parameters.mat'));
    params = params.params;
    warning('backtrace', 'off');
    warning('Load params from GUI instead of segmentation ressults');
    warning('backtrace', 'on');
end

try 
    metadata_seg = objects.metadata;
catch err
    warning('backtrace', 'off');
    warning(['Could not load segmentation metadata use raw metadata instead.\n', ...
         'Please double-check the correct scaling settings!']);
    warning('backtrace', 'on');
    metadata_seg = load(fullfile(handles.settings.directory, [files.files_tif(file).name(1:end-4), '_metadata.mat']));
end

metadata_raw = load(fullfile(handles.settings.directory, [files.files_tif(file).name(1:end-4), '_metadata.mat']));




if checkCancelButton(handles)
    toggleBusyPointer(handles, false)
    return;
end

updateWaitbar(handles, 0.2)
displayStatus(handles, ['Loading image: "', fullfile(handles.settings.directory, files.files_tif(file).name), '"...'], 'black');
img1raw = imread3D(fullfile(handles.settings.directory, files.files_tif(file).name));

% Dischard first plane
img1raw = img1raw(:,:,2:end);


if strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Edge detection") % Edge Detection
    if size(img1raw, 3) == 1
        img1raw(:,:,2) = img1raw(:,:,1);
        img1raw(:,:,3) = img1raw(:,:,1);
        img1raw(:,:,4) = img1raw(:,:,1);
        img1raw(:,:,5) = img1raw(:,:,1);
    end
end

updateWaitbar(handles, 0.3)

% Inverting stack
if isfield(params, 'invertStack')
    if params.invertStack
        img1raw = img1raw(:,:,linspace(size(img1raw,3),1,size(img1raw,3)));
    end
end

displayStatus(handles, 'Done', 'black', 'add');

if checkCancelButton(handles)
    toggleBusyPointer(handles, false)
    return;
end

isLabelImage = strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Label image") || (params.channel~=params.popupmenu_labelImage_Channel);

if ~isLabelImage
    method = 'linear'; 
else
    method = 'nearest';
end

updateWaitbar(handles, 0.4)
img1raw = registerAndCropImage(img1raw, params, method, metadata_seg);


if checkCancelButton(handles) || isempty(img1raw)
    toggleBusyPointer(handles, false)
    updateWaitbar(handles, 0)
    return;
end


updateWaitbar(handles, 0.5)

% Removing non-good cells
objects.PixelIdxList = objects.PixelIdxList(objects.goodObjects);
objects.NumObjects = length(objects.PixelIdxList);
w_mask_label = labelmatrix(objects);
cells = max(w_mask_label(:));

if checkCancelButton(handles)
    toggleBusyPointer(handles, false)
    return;
end

outlines = perim3D(w_mask_label);
%outlines = bwperim(data.w);


fnames = fieldnames(objects.stats);

if sum(cellfun(@(x) ~isempty(x), strfind(lower(fnames), 'foci')))
    answer = questdlg('Plot fluorescent foci?', ...
        'Foci', ...
        'Yes','No','Yes');
    useFoci = false;
    switch answer
        case 'Yes'
            useFoci = true;
            possibleFoci = find(cellfun(@(x) ~isempty(x), strfind(lower(fnames), 'foci_idx')));
            if numel(possibleFoci) > 1
                [indx,useFoci] = listdlg('PromptString', 'Select a foci measurement','SelectionMode','single', 'ListString', fnames(possibleFoci));
            else
                indx = 1;
            end
            fociField = fnames{possibleFoci(indx)};
    end
else
    useFoci = false;
end

if useFoci
    foci = {objects.stats.(fociField)};
    foci = vertcat(foci{:});
end


if checkCancelButton(handles)
    toggleBusyPointer(handles, false)
    return;
end

updateWaitbar(handles, 0.6)

% Preparing image
params.denoiseImages = 0;
params.svd = 0;
displayStatus(handles, 'Processing image', 'black');


if ~isLabelImage
    [imgfilter, params] = resizingAndDenoising(double(img1raw), metadata_raw, params);
else
    imgfilter = zInterpolation_nearest(double(img1raw), metadata_raw.data.scaling.dxy, metadata_raw.data.scaling.dz, params);
end

updateWaitbar(handles, 0.8)
% Remove bottom
if params.removeBottomSlices
    imgfilter(:,:,1:params.removeBottomSlices) = [];
end
updateWaitbar(handles, 0.85)

if checkCancelButton(handles)
    toggleBusyPointer(handles, false)
    return;
end

% Pad image
if params.imageRegistration && params.fixedOutputSize
    imgfilter = applyReferencePadding(params, imgfilter);
end

updateWaitbar(handles, 0.9)
thres1 = prctile(imgfilter(:), 99.9);
if checkCancelButton(handles)
    toggleBusyPointer(handles, false)
    return;
end

thres2 = prctile(imgfilter(:), 5);
if checkCancelButton(handles)
    toggleBusyPointer(handles, false)
    return;
end
updateWaitbar(handles, 0.92)

% gray part of colomap
cmap = [linspace(0,1,1000)' linspace(0,1,1000)' linspace(0,1,1000)'];
% outlines in gray and foci in green
cmap = [cmap; 0.9 0 0; 0 1 0];
% cells
%cmap = [cmap; rand(cells, 1) rand(cells, 1) rand(cells, 1)];

imgfilter(imgfilter>thres1) = thres1;
imgfilter(imgfilter<thres2) = thres2;
imgfilter = imgfilter-thres2;
imgfilter = imgfilter/(thres1-thres2)*1000;

image2dispay = imgfilter;
try
    outlines = outlines(:,:,1:size(image2dispay, 3));
end

image2dispay(outlines) = 1001;

if useFoci
    image2dispay(neighbourND(foci,  size(image2dispay))) = 1002;
end

updateWaitbar(handles, 0.95)
h = zSlicer(image2dispay, cmap, 'parentGui', handles, 'title', sprintf('zSlicer overlay'), 'clim', [0 1003]);
updateWaitbar(handles, 1)
updateWaitbar(handles, 0)
displayStatus(handles, 'Done', 'black', 'add');
toggleBusyPointer(handles, false)

% --- Executes on button press in text_parameters_mergingSplitting_strategy.
function mergeCells_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on selection change in mergingStrategy.
function mergingStrategy_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function mergingStrategy_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_cutIndentions_Callback(hObject, eventdata, handles)
set(handles.uicontrols.edit.cutIndentions, 'String', num2str(round(get(hObject, 'Value')*10)/10));
storeValues(hObject, eventdata, handles);


function cutIndentions_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1]);
set(handles.uicontrols.slider.slider_cutIndentions, 'Value', str2num(get(hObject, 'String')));


% --- Executes on button press in pushbutton_applyCropAll.
function handles = pushbutton_applyCropAll_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
cropRange = str2num(get(handles.uicontrols.edit.cropRange, 'String'));
displayStatus(handles, 'Applying crop-range to all images...', 'green');
enableCancelButton(handles)

for i = 1:length(handles.settings.lists.files_metadata)
    if ~mod(i-1, 10)
        updateWaitbar(handles, i/length(handles.settings.lists.files_metadata))
    end
    
    metadata = load(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name));
    data = metadata.data;
    data.cropRange = cropRange;
    cropRange_appliesToRegisteredImage = get(handles.uicontrols.checkbox.imageRegistration, 'Value');
    data.cropRange_appliesToRegisteredImage = get(handles.uicontrols.checkbox.imageRegistration, 'Value');
    
    handles.settings.metadataGlobal{i}.data = data;
    save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name), 'data');
    
    % Update crop range for other channels
    channelData = get(handles.uicontrols.popupmenu.channel, 'String');
    if numel(channelData) > 1
        channel = channelData{get(handles.uicontrols.popupmenu.channel, 'Value')};
        ch_toProcess = find(~cellfun(@(x) strcmp(x, channel), channelData));
        for c = 1:numel(ch_toProcess)
            filename_ch = fullfile(handles.settings.directory, ...
                strrep(handles.settings.lists.files_metadata(i).name, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
            
            try
                data = load(filename_ch);
                data = data.data;
                data.cropRange = cropRange;
                data.cropRange_appliesToRegisteredImage = cropRange_appliesToRegisteredImage;
                save(filename_ch, 'data');
            catch err
                warning('backtrace', 'off');
                warning(err.message);
                warning('backtrace', 'on');
            end
        end
    end
    
    guidata(hObject, handles);
    if checkCancelButton(handles)
        toggleBusyPointer(handles, false)
        return;
    end
    
    %displayStatus(handles, [num2str(i), ' '], 'black', 'add');
end
displayStatus(handles, 'Done', 'black', 'add');
updateWaitbar(handles, 0);
eventdata = struct.empty;
eventdata(1).Indices(1) = handles.java.files_jtable.getSelectedRow+1;
files_Callback(hObject, eventdata, handles);
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_ApplyBGAll.
function pushbutton_ApplyBGAll_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
I_base = str2num(get(handles.uicontrols.edit.I_base, 'String'));
displayStatus(handles, 'Applying background to all images...', 'green');
for i = 1:length(handles.settings.lists.files_metadata)
    metadata = handles.settings.metadataGlobal{i};
    data = metadata.data;
    data.I_base = I_base;
    handles.settings.metadataGlobal{i}.data = data;
    save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name), 'data');
end
guidata(hObject, handles);
displayStatus(handles, 'Done', 'black', 'add');
toggleBusyPointer(handles, false)


% --- Executes on button press in median3D.
function median3D_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function removeVoxelsOfSize_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1e99]);
pxSize = convertToUm(handles, str2double(handles.uicontrols.edit.removeVoxelsOfSize.String),3);
handles.uicontrols.text.text_removeVoxelsOfSize.String = sprintf('vox (%.2f \x03BCm\x00B3)', pxSize);

% --- Executes during object creation, after setting all properties.
function removeVoxelsOfSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in removeVoxels.
function removeVoxels_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);
if ~get(handles.uicontrols.checkbox.removeVoxels, 'Value')
    set(handles.uicontrols.edit.removeVoxelsOfSize, 'Enable', 'off')
    set(handles.uicontrols.text.text_removeVoxelsOfSize, 'Enable', 'off')
else
    set(handles.uicontrols.edit.removeVoxelsOfSize, 'Enable', 'on')
    set(handles.uicontrols.text.text_removeVoxelsOfSize, 'Enable', 'on')
end


function loadedCellFile_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function loadedCellFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_detFilterSize.
function pushbutton_detFilterSize_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
filterSize = determineFilterSize(hObject, eventdata, handles);
set(handles.uicontrols.edit.kernelSize, 'String', num2str(filterSize));
storeValues(hObject, eventdata, handles);
toggleBusyPointer(handles, false)


% --- Executes on button press in autoFilterSize.
function autoFilterSize_Callback(hObject, eventdata, handles)
if get(handles.uicontrols.checkbox.autoFilterSize, 'value')
    set(handles.uicontrols.edit.kernelSize, 'Enable', 'off')
    set(handles.uicontrols.pushbutton.pushbutton_detFilterSize, 'Enable', 'off')
else
    set(handles.uicontrols.edit.kernelSize, 'Enable', 'on')
    set(handles.uicontrols.pushbutton.pushbutton_detFilterSize, 'Enable', 'on')
end
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_files_exportAll.
function pushbutton_files_exportAll_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, false)
files = handles.settings.lists;

h = waitbar(0, 'Exporting files...', 'Name', 'Please wait');

for file = 1:length(files.files_nd2)
    fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');
    if fileType == 1
        filename = files.files_nd2(file).name;
        convertNdToTiff(handles, filename);
        
    else
        uiwait(msgbox('No exportable file selected!', 'Warning', 'warn', 'modal'));
    end
    try
        waitbar(file/length(files.files_nd2), h);
    end
    
end
pushbutton_refreshFolder_Callback(hObject, eventdata, handles);
try
    delete(h);
end
toggleBusyPointer(handles, false)


% --- Executes on button press in forceVTKSeries.
function forceVTKSeries_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in trackingStartNewSeries.
function trackingStartNewSeries_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in temporalCorrection.
function temporalCorrection_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in svd.
function svd_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);

% --- Executes on button press in skipDeclumpingFirstFrame.
function watershedding_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);

% --- Executes on button press in scaleUp.
function scaleUp_Callback(hObject, eventdata, handles)
pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.topHatSize.String),1);
handles.uicontrols.text.text_workflow_segmentation_denoising_tophatUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);

pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.trackCellsDilatePx.String),1);
handles.uicontrols.text.text_workflow_cellTracking_dilateUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);

pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.removeVoxelsOfSize.String),3);
handles.uicontrols.text.text_removeVoxelsOfSize.String = sprintf('vox (%.2f \x03BCm\x00B3)', pxSize);

pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.gridSpacing.String),1);
handles.uicontrols.text.text_workflow_segmentation_objectDeclumping_cubeSideLengthUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);

if any(strfind(handles.uicontrols.text.text_parameterUnitConversion.String, 'vox'))
    pxSize = convertToUm(handles,str2double(handles.uicontrols.edit.parameterInput.String),1);
    handles.uicontrols.text.text_parameterUnitConversion.String = sprintf('vox (%.2f \x03BCm)', pxSize);
end
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_updateScaling.
function pushbutton_updateScaling_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
dxy = str2num(get(handles.uicontrols.edit.scaling_dxy, 'String'));
dz = str2num(get(handles.uicontrols.edit.scaling_dz, 'String'));
displayStatus(handles, 'Applying new scaling info to all images...', 'green');
try
    for i = 1:length(handles.settings.lists.files_metadata)
        metadata = handles.settings.metadataGlobal{i};
        data = metadata.data;
        data.scaling.dxy = dxy/1000;
        data.scaling.dz = dz/1000;
        
        handles.settings.metadataGlobal{i}.data = data;
        save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name), 'data');
        
        % Update scaling for other channels
        channelData = get(handles.uicontrols.popupmenu.channel, 'String');
        if numel(channelData) > 1
            channel = channelData{get(handles.uicontrols.popupmenu.channel, 'Value')};
            ch_toProcess = find(~cellfun(@(x) strcmp(x, channel), channelData));
            for c = 1:numel(ch_toProcess)
                filename_ch = fullfile(handles.settings.directory, ...
                    strrep(handles.settings.lists.files_metadata(i).name, ['ch', getChannelName(channel)], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
                
                try
                    data = load(filename_ch);
                    data = data.data;
                    data.scaling.dxy = dxy/1000;
                    data.scaling.dz = dz/1000;
                    save(filename_ch, 'data');
                catch err
                    warning('backtrace', 'off');
                    warning(err.message);
                    warning('backtrace', 'on');
                end
            end
        end
        
    end
catch err
    uiwait(msgbox(sprintf('The following error occurred: %s', err.message), 'Error', 'error', 'modal'));
end
guidata(hObject, handles);
displayStatus(handles, 'Done', 'black', 'add');
toggleBusyPointer(handles, false)


% --------------------------------------------------------------------
function context_VTKParams_updateFields_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
if ~isempty(handles.settings.lists.files_cells)
    try
        % load first file
        file = handles.java.files_jtable.getSelectedRow()+1;
        if ~file
            msgbox('No file selected.', 'Error', 'error');
            return;
        end
        data = load(fullfile(handles.settings.directory, 'data', handles.settings.lists.files_cells(file).name), 'objects');
        fNames = fieldnames(data.objects.stats);
        
        set(handles.uicontrols.popupmenu.filter_parameter, 'String', fNames);
        % Intensity related fields:
        intFields = strfind(fNames, 'Intensity_Mean');
        
        for i = 1:length(intFields)
            if ~isempty(intFields{i})
                set(handles.uicontrols.popupmenu.filter_parameter, 'Value', i)
                break;
            end
        end
        
        deleteInd = strcmp(fNames, 'Centroid');
        fNames(find(deleteInd)) = [];
        deleteInd = strcmp(fNames, 'BoundingBox');
        fNames(find(deleteInd)) = [];
        deleteInd = strcmp(fNames, 'Orientation_Matrix');
        fNames(find(deleteInd)) = [];
        deleteInd = strcmp(fNames, 'MinBoundBox_Cornerpoints');
        fNames(find(deleteInd)) = [];
        
        deleteInd = ~isempty(strfind(fNames, '_Idx_'));
        fNames(find(deleteInd)) = [];
        
        fNames = ['ID'; 'Distance_FromSubstrate'; 'RandomNumber'; fNames];
        
        tableData = [fNames num2cell(true(size(fNames)))];
        set(handles.uitables.cellParametersStoreVTK, 'Data', tableData);
        
        set(handles.uicontrols.popupmenu.renderParaview.String, 'Data', tableData(:,1), 'Value', 1);
        
    end
end
toggleBusyPointer(handles, false)


% --- Executes on button press in removeFloatingCells.
function removeFloatingCells_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in fadeBottom.
function fadeBottom_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function fadeBottomLength_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [-10 10]);


% --- Executes during object creation, after setting all properties.
function fadeBottomLength_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in declumpingMethod.
function declumpingMethod_Callback(hObject, eventdata, handles)

data = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = data.params;
if isfield(handles.layout.uipanels, 'panel_declumpingOptions')
    enableDisableChildren(handles.layout.uipanels.panel_declumpingOptions, 'off');
end
if isfield(handles.layout.uipanels, 'uipanel_workflow_segmentation_seededWatershed')
    enableDisableChildren(handles.layout.uipanels.uipanel_workflow_segmentation_seededWatershed, 'off')  
end

switch handles.uicontrols.popupmenu.declumpingMethod.String{handles.uicontrols.popupmenu.declumpingMethod.Value}
        case 'Cubes'
            enableDisableChildren(handles.layout.uipanels.panel_declumping_gridOptions, 'on')
            handles.uicontrols.edit.searchRadius.String = sprintf('%.1f', str2double(handles.uicontrols.edit.gridSpacing.String)*params.scaling_dxy/1000+0.1);
            handles.uicontrols.checkbox.considerSiblings.Enable = 'on';
            handles.uicontrols.text.considerSiblings_text.Enable = 'on';
        case 'None'
            enableDisableChildren(handles.layout.uipanels.panel_declumping_gridOptions, 'off')
            handles.uicontrols.checkbox.considerSiblings.Enable = 'off';
            handles.uicontrols.text.considerSiblings_text.Enable = 'off';
        case 'Label image'
            enableDisableChildren(handles.layout.uipanels.panel_declumping_gridOptions, 'off')
            handles.uicontrols.checkbox.considerSiblings.Enable = 'off';
            handles.uicontrols.text.considerSiblings_text.Enable = 'off';
        case 'Watershedding'
            enableDisableChildren(handles.layout.uipanels.panel_declumping_gridOptions, 'off')
            enableDisableChildren(handles.layout.uipanels.panel_declumpingOptions, 'on')
            enableDisableChildren(handles.layout.uipanels.uipanel_workflow_segmentation_seededWatershed, 'off')          
            handles.uicontrols.checkbox.considerSiblings.Enable = 'off';
            handles.uicontrols.text.considerSiblings_text.Enable = 'off';
        case 'seeded 3D Watershed'
            enableDisableChildren(handles.layout.uipanels.panel_declumping_gridOptions, 'off')
            enableDisableChildren(handles.layout.uipanels.panel_declumpingOptions, 'off');
            enableDisableChildren(handles.layout.uipanels.uipanel_workflow_segmentation_seededWatershed, 'on')
            handles.uicontrols.checkbox.considerSiblings.Enable = 'off';
            handles.uicontrols.text.considerSiblings_text.Enable = 'off';

    otherwise
            enableDisableChildren(handles.layout.uipanels.panel_declumping_gridOptions, 'off')
            handles.uicontrols.edit.searchRadius.String = '3';
            handles.uicontrols.checkbox.considerSiblings.Enable = 'off';
            handles.uicontrols.text.considerSiblings_text.Enable = 'off';
end


displayDeclumpingMethodHelpImage(handles, handles.uicontrols.popupmenu.declumpingMethod.Value)
storeValues(hObject, eventdata, handles);


function displayDeclumpingMethodHelpImage(handles, imID)
imagesc(handles.settings.declumpingMethodImages{imID}, 'Parent', handles.axes.axes_declumpingMethod);
box(handles.axes.axes_declumpingMethod, 'off');
try
    axis(handles.axes.axes_declumpingMethod, 'tight', 'equal', 'off')
end


% --- Executes during object creation, after setting all properties.
function declumpingMethod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gridSpacing_Callback(hObject, eventdata, handles)
data = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = data.params;
handles.uicontrols.edit.searchRadius.String = sprintf('%.1f', str2double(handles.uicontrols.edit.gridSpacing.String)*params.scaling_dxy/1000+0.1);;
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [1 100]);
pxSize = convertToUm(handles, str2double(handles.uicontrols.edit.gridSpacing.String),1);
handles.uicontrols.text.text_workflow_segmentation_objectDeclumping_cubeSideLengthUnit.String = sprintf('vox (%.2f \x03BCm)', pxSize);


% --- Executes during object creation, after setting all properties.
function gridSpacing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in simpleThresholding.
function simpleThresholding_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles)


function scaleFactor_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0.1 3]);


% --- Executes during object creation, after setting all properties.
function scaleFactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in segmentationMethod.
function segmentationMethod_Callback(hObject, eventdata, handles, init)
if nargin == 3
    init = false;
end
if exist('additionalCallbacks', 'file')
    handles = additionalCallbacks('segmentationMethod_Callback', hObject, eventdata, handles, init);
end
    
% Call declumping method callback
declumpingMethod_Callback(handles.uicontrols.popupmenu.declumpingMethod, eventdata, handles);

if nargin == 3
    storeValues(handles.uicontrols.popupmenu.segmentationMethod, eventdata, handles);
else
    storeValues(handles.uicontrols.popupmenu.segmentationMethod, eventdata, handles, 0, 1);
end

% --- Executes during object creation, after setting all properties.
function segmentationMethod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in thresholdingMethod.
function thresholdingMethod_Callback(hObject, eventdata, handles)

if handles.uicontrols.popupmenu.thresholdingMethod.Value == 5
    handles.uicontrols.edit.thresholdSensitivity.Visible = 'off';
    handles.uicontrols.pushbutton.pushbutton_ApplyTHAll.Visible = 'on';
    handles.uicontrols.edit.manualThreshold.Visible = 'on';
    handles.uicontrols.text.text_otsu_classes.Visible = 'off';
    handles.uicontrols.text.text_sensitivity.Visible = 'off';
    handles.uicontrols.text.text_manualThreshold.Visible = 'on';
    handles.uicontrols.text.text_thresholdSensitivity2.Visible = 'off';
else
    handles.uicontrols.edit.thresholdSensitivity.Visible = 'on';
    handles.uicontrols.pushbutton.pushbutton_ApplyTHAll.Visible = 'off';
    handles.uicontrols.edit.manualThreshold.Visible = 'off';
    handles.uicontrols.text.text_otsu_classes.Visible = 'off';
    handles.uicontrols.text.text_sensitivity.Visible = 'on';
    handles.uicontrols.text.text_manualThreshold.Visible = 'off';
    handles.uicontrols.text.text_thresholdSensitivity2.Visible = 'on';
end

if handles.uicontrols.popupmenu.thresholdingMethod.Value == 1
    handles.uicontrols.popupmenu.thresholdClasses.Enable = 'on';
    handles.uicontrols.popupmenu.thresholdClasses.Visible = 'on';
    handles.uicontrols.text.text_otsu_classes.Visible = 'on';
else
    handles.uicontrols.popupmenu.thresholdClasses.Visible = 'off';
    handles.uicontrols.text.otsu_classes_text.Visible = 'off';
end

storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function thresholdingMethod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function manualThreshold_Callback(hObject, eventdata, handles)
file = handles.java.files_jtable.getSelectedRow()+1;
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1e99], 'file', file);
if isempty(handles.uicontrols.edit.manualThreshold.String)
    handles.uicontrols.edit.manualThreshold.String = '0';
    handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1e99], 'file', file);
end


% --- Executes during object creation, after setting all properties.
function manualThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in thresholdClasses.
function thresholdClasses_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function thresholdClasses_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ApplyTHAll.
function pushbutton_ApplyTHAll_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
manualThreshold = str2num(get(handles.uicontrols.edit.manualThreshold, 'String'));
displayStatus(handles, 'Storing threshold for all images...', 'green');
for i = 1:numel(handles.settings.metadataGlobal)
    metadata = handles.settings.metadataGlobal{i};
    data = metadata.data;
    data.manualThreshold = manualThreshold;
    handles.settings.metadataGlobal{i}.data = data;
    save(fullfile(handles.settings.directory, handles.settings.lists.files_metadata(i).name), 'data');
end
guidata(hObject, handles);
displayStatus(handles, 'Done', 'black', 'add');
toggleBusyPointer(handles, false)


function minMergeSize_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 2]);


% --- Executes during object creation, after setting all properties.
function minMergeSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function splitConvexity_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1e99]);


% --- Executes during object creation, after setting all properties.
function splitConvexity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function splitVolume1_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1e99]);


% --- Executes during object creation, after setting all properties.
function splitVolume1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function splitVolume2_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0 1e99]);


% --- Executes during object creation, after setting all properties.
function splitVolume2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in keepSmallCellWithNoNeighbor.
function keepSmallCellWithNoNeighbor_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function mergeChannel1_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'integer', 'range', [1, numel(handles.uicontrols.popupmenu.channel.String)]);


% --- Executes during object creation, after setting all properties.
function mergeChannel1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mergeChannel2_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'array', 'condition', 'integer', 'range', [1, numel(handles.uicontrols.popupmenu.channel.String)]);


% --- Executes during object creation, after setting all properties.
function mergeChannel2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_tools_mergeChannels.
function pushbutton_tools_mergeChannels_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
mergeChannels(handles);
analyzeDirectory(hObject, eventdata, handles);
toggleBusyPointer(handles, false)


% --------------------------------------------------------------------
function menu_options_saveVTKIntermediateSteps_Callback(hObject, eventdata, handles)
if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off');
else
    set(hObject, 'Checked', 'on');
end


% --- Executes on selection change in outputFormat3D.
function outputFormat3D_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function outputFormat3D_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prepareFor3DPrinting.
function prepareFor3DPrinting_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in obtainConnectedStructure.
function obtainConnectedStructure_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function registrationReferenceFrame_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'integer', 'range', [1, numel(handles.settings.lists.files_tif)]);


% --- Executes during object creation, after setting all properties.
function registrationReferenceFrame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_setRegistrationReferenceFrame.
function pushbutton_setRegistrationReferenceFrame_Callback(hObject, eventdata, handles)
refFrame = handles.java.files_jtable.getSelectedRow+1;
set(handles.uicontrols.edit.registrationReferenceFrame, 'String', num2str(refFrame));

handles = storeValues(handles.uicontrols.edit.registrationReferenceFrame, eventdata, handles);
eventdata = struct('Indices', refFrame);
files_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on selection change in registrationMethod.
function registrationMethod_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function registrationMethod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in displayAlignedImage.
function displayAlignedImage_Callback(hObject, eventdata, handles)
try
    eventdata = struct('Indices', handles.java.files_jtable.getSelectedRow+1);
    files_Callback(hObject, eventdata, handles)
catch
    uiwait(msgbox('Cannot update image preview!', 'Please note', 'warn', 'modal'));
end


% --- Executes on button press in alignZ.
function alignZ_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in continueRegistration.
function continueRegistration_Callback(hObject, eventdata, handles)


function maxHeight_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [0, 1e99]);
if ~isempty(get(hObject, 'String'))
    set(hObject, 'BackgroundColor', 'y');
else
    set(hObject, 'BackgroundColor', 'w');
end


% --- Executes during object creation, after setting all properties.
function maxHeight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function flowDirection_Callback(hObject, eventdata, handles)
try
    currentValue = str2num(get(hObject, 'String'));
    set(hObject, 'String', num2str(currentValue(1:2)));
    handles = storeValues(hObject, eventdata, handles);
catch
    uiwait(msgbox('Please enter a 2D vector.', 'Please note', 'help', 'modal'));
    set(hObject, 'String', '0 1');
end
eventdata = struct('Indices', handles.java.files_jtable.getSelectedRow+1);
files_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function flowDirection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fixedOutputSize.
function fixedOutputSize_Callback(hObject, eventdata, handles)
if handles.uicontrols.checkbox.fixedOutputSize.Value
    handles.uicontrols.edit.registrationReferenceCropping.Enable = 'on';
    handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping.Enable = 'on';
    
else
    handles.uicontrols.edit.registrationReferenceCropping.Enable = 'off';
    handles.uicontrols.pushbutton.pushbutton_setRefFrameCropping.Enable = 'off';
end

handles = storeValues(hObject, eventdata, handles);
eventdata = struct('Indices', handles.java.files_jtable.getSelectedRow+1);
files_Callback(hObject, eventdata, handles);
guidata(hObject, handles)


% --- Executes on button press in pushbutton_interpolateCropping.
function pushbutton_interpolateCropping_Callback(hObject, eventdata, handles)
%set(handles.uicontrols.checkbox.imageRegistration, 'value', 1);
handles = interpolateCropping(hObject, eventdata, handles);
eventdata = struct('Indices', handles.java.files_jtable.getSelectedRow+1);
files_Callback(hObject, eventdata, handles)
guidata(hObject, handles);


function registrationReferenceCropping_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'array', 'condition', 'cropping');

eventdata = struct('Indices', handles.java.files_jtable.getSelectedRow+1);
files_Callback(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function registrationReferenceCropping_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cropRangeInterpolated.
function cropRangeInterpolated_Callback(hObject, eventdata, handles)


function removeBottomSlices_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'integer', 'range', [0 1e99]);


% --- Executes during object creation, after setting all properties.
function removeBottomSlices_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cellParametersNoSaving.
function cellParametersNoSaving_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_orthoViewLabelled.
function pushbutton_orthoViewLabelled_Callback(hObject, eventdata, handles)

if sum(handles.data.objects.goodObjects) == 0
    uiwait(msgbox('Cannot plot data. No valid objects found!', 'Warning', 'warn', 'modal'));
    return;
end

if ~isfield(handles.data.objects, 'PixelIdxList')
    uiwait(msgbox('Data does not contain volumetric information!', 'Error', 'error', 'modal'));
    return;
end

toggleBusyPointer(handles, true)
selectedField = get(handles.uicontrols.listbox.listbox_visCell_params, 'Value');
fNames = fieldnames(handles.data.objects.stats);
values = [handles.data.objects.stats.(fNames{selectedField})];
values(~logical(handles.data.objects.goodObjects)) = NaN;

if numel(unique(values)) > 10
    minVal = prctile(values, 1);
    maxVal = prctile(values, 95);
    cmap = parula(5001);
    cmap(1,:) = [0 0 0];
elseif numel(unique(values)) == 2
    minVal = min(values)-1;
    maxVal = max(values)+1;
    cmap = [0 0 0; 1 0 0; 0 1 0];
elseif numel(unique(values)) == 3
    minVal = min(values)-1;
    maxVal = max(values)+1;
    cmap = [0 0 0; 1 0 0; 0 1 0; 1 1 0];
else
    minVal = nanmin(values)-1;
    maxVal = nanmax(values);
    cmap = parula(5001);
    cmap(1,:) = [0 0 0];
end

values(~logical(handles.data.objects.goodObjects)) = 0;

L = zeros(handles.data.objects.ImageSize);

for k = 1 : handles.data.objects.NumObjects
    L(handles.data.objects.PixelIdxList{k}) = values(k);
end
L(isnan(L)) = 0;

h = zSlicer(L, cmap, 'title', sprintf('zSlicer: %s', fNames{selectedField}), ...
    'clim', [minVal maxVal], 'parentGui', handles);
h.Position = positionExternalFigure(handles);
toggleBusyPointer(handles, false)

% --- Executes on button press in sendEmail.
function sendEmail_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function email_to_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function email_to_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function email_from_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function email_from_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function email_smtp_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function email_smtp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_sendTestEmail.
function pushbutton_sendTestEmail_Callback(hObject, eventdata, handles)
email_to = get(handles.uicontrols.edit.email_to, 'String');
email_from = get(handles.uicontrols.edit.email_from, 'String');
email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');

setpref('Internet','E_mail',email_from);
setpref('Internet','SMTP_Server',email_smtp);

sendmail(email_to,'Biofilm Segmentation', ...
    'Test email from Biofilm Segmentation Toolbox by Raimo Hartmann.');

uiwait(msgbox('Email was sent.', 'Please note', 'help', 'modal'));


% --------------------------------------------------------------------
function menu_tools_Callback(hObject, eventdata, handles)


% --- Executes on button press in speedUpSSD.
function speedUpSSD_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function tempFolder_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function tempFolder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browseTempFolder.
function pushbutton_browseTempFolder_Callback(hObject, eventdata, handles)
%% Select input directory
directoryTemp = '';

if exist('directory.mat','file')
    load('directory.mat');
end

directoryTemp = uigetdir(directoryTemp, 'Please select temp-directory');
if directoryTemp
    save('directory.mat', 'directoryTemp', '-append');
else
    uiwait(msgbox('No folder selected.', 'Please note', 'help', 'modal'));
    return;
end

set(handles.uicontrols.edit.tempFolder, 'String', directoryTemp);
storeValues(handles.uicontrols.edit.tempFolder, eventdata, handles)
tempDirInfo(handles)


% --- Executes on button press in deleteTempFiles.
function deleteTempFiles_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_deleteTempFiles.
function pushbutton_deleteTempFiles_Callback(hObject, eventdata, handles)
projectFolders = strsplit(handles.settings.directory, filesep);
temp_folder = fullfile(get(handles.uicontrols.edit.tempFolder, 'String'), projectFolders{end-1}, projectFolders{end});
rmdir(temp_folder,'s')
displayStatus(handles, ['Temp-folder "',temp_folder,'" cleared'], 'green');
tempDirInfo(handles)


function tempFileSize_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tempFileSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_deleteAllTempFiles.
function pushbutton_deleteAllTempFiles_Callback(hObject, eventdata, handles)
temp_folder = get(handles.uicontrols.edit.tempFolder, 'String');
rmdir(temp_folder,'s')
mkdir(temp_folder)
displayStatus(handles, ['Temp-folder cleared'], 'green');
tempDirInfo(handles)


% --- Executes on button press in invertStack.
function invertStack_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_restoreParametersCalculate.
function pushbutton_restoreParametersCalculate_Callback(hObject, eventdata, handles)
set(handles.uitables.cellParametersCalculate, 'Data', handles.tableData);


% --- Executes on button press in topHatFiltering_thresholding.
function topHatFiltering_thresholding_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_tools_distributeParametersFile_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
inputFolder = get(handles.uicontrols.edit.inputFolder, 'String');
parametersFile = fullfile(inputFolder, 'parameters.mat');

% get sister directories
sisterFolders = dir(fullfile(inputFolder, '..'));
sisterFolders = sisterFolders(3:end);
sisterFolders = sisterFolders([sisterFolders.isdir]);

for f = 1:numel(sisterFolders)
    if isdir(fullfile(inputFolder, '..', sisterFolders(f).name))
        try
            copyfile(parametersFile, fullfile(inputFolder, '..', sisterFolders(f).name, 'parameters.mat'), 'f');
            fprintf(' - copying parameters-file to %s\n', fullfile(inputFolder, '..', sisterFolders(f).name));
        end
    end
end
toggleBusyPointer(handles, false)
if handles.settings.showMsgs
    uiwait(msgbox([{'The parameter file has been copied to the following folders: ', ''}, {sisterFolders.name}], 'Please note', 'help', 'modal'));
end


% --------------------------------------------------------------------
function menu_file_nextDirDir_Callback(hObject, eventdata, handles, direction)
inputFolder = get(handles.uicontrols.edit.inputFolder, 'String');
[parentFolder, foldername] = fileparts(inputFolder);
folders = dir(parentFolder);
folders = folders([folders.isdir]);
isNavigation = cellfun(@(x) startsWith(x, '.'), {folders(:).name});
folders = folders(~isNavigation);
[~, ind] = sort_nat({folders.name});
folders = folders(ind);
ind2 = find(strcmp({folders.name}, foldername));


switch direction
    case 'next'
        if ind2 == numel(folders)
            ind_new = 1;
        else
            ind_new = ind2+1;
        end
    case 'previous'
        if ind2 == 1
            ind_new = numel(folders);
        else
            ind_new = ind2-1;
        end
end
set(handles.uicontrols.edit.inputFolder, 'String', fullfile(parentFolder, folders(ind_new).name));
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function newFolders = menu_file_duplicateDir_Callback(hObject, eventdata, handles, varargin)
toggleBusyPointer(handles, true)
inputFolder = get(handles.uicontrols.edit.inputFolder, 'String');
prompt = {'Number of replicates:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'1'};
if nargin == 3
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    answer = str2num(answer{1});
else
    answer = varargin{1};
end

i = 1;
counter = 1;
warning('backtrace', 'off');
newFolders = {};
while i <= answer
    updateWaitbar(handles, i/answer);
    new_folder_name = sprintf('%s-%d', inputFolder, i);
    
    if exist(new_folder_name, 'dir')
        warning('Directory "%s" already exists!', new_folder_name);
        answer = answer+1;
    else
        displayStatus(handles, sprintf('Creating replicate %d',counter), 'green');
        copyfile(inputFolder, new_folder_name);
        newFolders{end+1} = new_folder_name;
        displayStatus(handles, 'Done', 'black', 'add');
        counter = counter + 1;
    end
    
    i = i+1;
end
warning('backtrace', 'on');

updateWaitbar(handles, 0);
toggleBusyPointer(handles, false)

% --- Executes on button press in pushbutton_determineManualThreshold.
function pushbutton_determineManualThreshold_Callback(hObject, eventdata, handles, visualizeOtsu)
toggleBusyPointer(handles, true)
set(handles.uicontrols.pushbutton.pushbutton_determineManualThreshold, 'String', 'Please wait');
file = handles.java.files_jtable.getSelectedRow()+1;
if ~file
    msgbox('No file selected.', 'Error', 'error');
    return;
end
files = handles.settings.lists;
field = 'files_tif';

fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');
data = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = data.params;
params.inputDirectory = handles.settings.directory;

metadata_file = dir(fullfile(handles.settings.directory, files.files_metadata(file).name));
metadata = load(fullfile(handles.settings.directory,metadata_file.name));

try
    params.cropRange = metadata.data.cropRange;
catch
    params.cropRange = [];
end
try
    params.scaling_dxy = metadata.data.scaling.dxy*1000;
    params.scaling_dz = metadata.data.scaling.dz*1000;
end

if fileType == 2 || fileType ==4 || fileType == 5
    
    displayStatus(handles, ['Loading data: "', fullfile(handles.settings.directory, files.(field)(file).name), '"...'], 'black');
    
    
else
    displayStatus(handles, 'Please select a valid file', 'red');
    fprintf('Please select a valid file\n');
    toggleBusyPointer(handles, false)
    return;
end

imgfilter = imread3D(fullfile(handles.settings.directory, files.(field)(file).name));

imgfilter = double(imgfilter(:,:,2:end));

% Inverting stack
if isfield(params, 'invertStack')
    if params.invertStack
        imgfilter = imgfilter(:,:,linspace(size(imgfilter,3),1,size(imgfilter,3)));
    end
end

imgfilter = registerAndCropImage(imgfilter, params, 'linear', metadata);

if checkCancelButton(handles) || isempty(imgfilter)
    toggleBusyPointer(handles, false)
    updateWaitbar(handles, 0);
    set(handles.uicontrols.pushbutton.pushbutton_determineManualThreshold, 'String', 'Open ortho view of selected image stack for threshold determination');
    return;
end

params.thresholdSensitity = str2double(handles.uicontrols.edit.thresholdSensitivity.String);

if ~params.thresholdSensitivity
    params.thresholdSensitivity = 1;
end

switch handles.uicontrols.popupmenu.thresholdingMethod.Value
    case 1
        validSlices = squeeze(sum(sum(imgfilter, 1), 2))>0;
        
        switch get(handles.uicontrols.popupmenu.thresholdClasses, 'Value')
            case 1
                params.manualThreshold = params.thresholdSensitivity*multithresh(imgfilter(:, :, validSlices), 1);
            case 2
                threshold = multithresh(imgfilter(:, :, validSlices), 2);
                params.manualThreshold = params.thresholdSensitivity*threshold(1);
            case 3
                threshold = multithresh(imgfilter(:, :, validSlices), 2);
                params.manualThreshold = params.thresholdSensitivity*threshold(2);
        end
    case 2
        validSlices = squeeze(sum(sum(imgfilter, 1), 2))>0;
        params.manualThreshold = params.thresholdSensitivity*isodata(imgfilter(:, :, validSlices), 1);
    case 3
        validSlices = squeeze(sum(sum(imgfilter, 1), 2))>0;
        img_temp = imgfilter(:,:,validSlices);
        thresh = MCT_Thresholding(img_temp(:));
        params.manualThreshold = params.thresholdSensitivity*thresh;
    case 4
        validSlices = squeeze(sum(sum(imgfilter, 1), 2))>0;
        params.manualThreshold = params.thresholdSensitivity*robustBackground(imgfilter(:, :, validSlices));
    case 5
        params.manualThreshold = str2num(get(handles.uicontrols.edit.manualThreshold, 'String'));
end

if ~params.manualThreshold && ~(handles.uicontrols.popupmenu.thresholdingMethod.Value==5) && ~(params.thresholdSensitivity==0)
    uiwait(msgbox(sprintf('Automatic tresholding ("%s / %s") failed! Please use a different method.', ...
        handles.uicontrols.popupmenu.thresholdingMethod.String{handles.uicontrols.popupmenu.thresholdingMethod.Value}, handles.uicontrols.popupmenu.thresholdClasses.String{handles.uicontrols.popupmenu.thresholdClasses.Value}), 'Warning', 'warn', 'modal'));
end

if get(handles.uicontrols.popupmenu.manualThresholdMethod, 'Value') == 2 && ~strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Label image")
    if params.scaleUp && params.scaleFactor<1
        imgfilter = zInterpolation(imgfilter, params.scaling_dxy, params.scaling_dz, params, 1);
    end
    %% Perform SVD of xz-planes
    if params.svd && size(imgfilter, 3) > 1
        imgfilter = performSVD(imgfilter, 0, 0);
    end
    if params.denoiseImages
        %% Smoothing by convolution
        imgfilter = convolveBySlice(imgfilter, params);
    end
    if params.topHatFiltering
        %% Rolling ball filtering (TopHat)
        imgfilter = topHatFilter(imgfilter, params);
    end
    %% Rotate image
    %     if params.rotateImage && size(imgfilter, 3) > 1
    %        imgfilter = rotateBiofilmImg(imgfilter, params, 0);
    %     end
end

% Apply gamma value
% params.gamma = round(params.gamma);
% imgfilter = imgfilter.^params.gamma;

displayStatus(handles, 'Done', 'black', 'add');
updateWaitbar(handles, 0.8);
maxVal = max(imgfilter(:));
minVal = min(imgfilter(:));

cmap = gray(ceil(maxVal));

indBG = params.manualThreshold;

% First entry in blue
cmap(1,:) = [0 0 1];
%cmap(end,:) = [1 0 0];
cmap(1:ceil(indBG), 1) = 0;
cmap(1:ceil(indBG), 2) = 0;
cmap(1:ceil(indBG), 3) = 1;

threshold = struct('value', params.manualThreshold, 'max', maxVal, 'min', minVal);
sensitivity = struct('value', params.thresholdSensitivity, 'max', maxVal, 'min', minVal);

%%% Check threshold
if threshold.value > maxVal
    threshold.value = maxVal;
    %maxVal = threshold.value+1;
end
if threshold.value < minVal
    threshold.value = minVal;
    %minVal = max(threshold.value-1,0);
end

% %%% double check sensitvity and threshold value
% if ~(handles.uicontrols.popupmenu.thresholdingMethod.Value==5)
%     sensitivity.value = max(sensitivity.value, minVal/threshold.value);
%     sensitivity.value = min(sensitivity.value, maxVal/threshold.value); 
% end


updateWaitbar(handles, 1);
updateWaitbar(handles, 0);

scaling = struct('dxy', metadata.data.scaling.dxy, 'dz', metadata.data.scaling.dz);
 


toggleBusyPointer(handles, false)

if handles.uicontrols.popupmenu.thresholdingMethod.Value == 5
    uiwait(zSlicer(imgfilter, cmap, 'title', 'Thresholding image',...
        'threshold', threshold, 'parentGui', handles, 'scaling', scaling, 'mode', 'threshold', 'clim', [floor(minVal) ceil(maxVal)]));
else
    uiwait(zSlicer(imgfilter, cmap, 'title', 'Thresholding image',...
        'threshold', threshold, 'sensitivity', sensitivity, 'parentGui', handles, 'scaling', scaling, 'mode', 'threshold', 'clim', [floor(minVal) ceil(maxVal)]));
    thresholdSensitivity_Callback(handles.uicontrols.edit.thresholdSensitivity, eventdata, handles);
end

set(handles.uicontrols.pushbutton.pushbutton_determineManualThreshold, 'String', 'Open ortho view of selected image stack for threshold determination');
storeValues(hObject, eventdata, handles, file);


% --- Executes on selection change in manualThresholdMethod.
function manualThresholdMethod_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function manualThresholdMethod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in intensity_task.
function intensity_task_Callback(hObject, eventdata, handles)
value = get(hObject, 'value');

switch value
    case 1
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'off', 'String', '');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Not needed - mean intensity is calculated per object', 'Enable', 'on');
    case 2
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'off', 'String', '');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Not needed - integrated intensity is calculated per object', 'Enable', 'on');
    case 3
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'on');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'off', 'String', '');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Not needed - intensity ratio is calculated per object', 'Enable', 'on');
    case 4
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'on');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'off', 'String', '');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Not needed - integrated intensity ratio is calculated per object', 'Enable', 'on');
    case 5
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '3');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Shell thickness around each object in px', 'Enable', 'on');
    case 6
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '3');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Shell thickness around each object in px', 'Enable', 'on');
    case 7
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '3');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Shell thickness around each object in px', 'Enable', 'on');
    case 8
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'on');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '20');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'on', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Patch size in px', 'Enable', 'on');
    case 9
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'on');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '20');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'on', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Patch size in px', 'Enable', 'on');
    case 10
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'off');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 1);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'Enable', 'off');
    case 11
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'on');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '20');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Patch size in px', 'Enable', 'on');
    case 12
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'on');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'off');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'on', 'value', 1);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'Enable', 'off');
    case 13
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '20');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Patch size in px (for cubes consider the same value as the cube side length)', 'Enable', 'on');
    case 14
        set(handles.uicontrols.text.text_channelDescription, 'Visible', 'off');
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on', 'String', '11');
        set(handles.uicontrols.checkbox.intensity_perStack, 'Enable', 'off', 'value', 0);
        set(handles.uicontrols.text.text_intensity_rangeUnit, 'String', 'Specify local neighborhood (typical minimum foci distance) in px (must be unenven)', 'Enable', 'on');
end

storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function intensity_task_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function intensity_range_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric');


% --- Executes during object creation, after setting all properties.
function intensity_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in intensity_ch.
function intensity_ch_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function intensity_ch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_intensity_addTask.
function pushbutton_intensity_addTask_Callback(hObject, eventdata, handles)
tableData = get(handles.uitables.intensity_tasks, 'data');
task = get(handles.uicontrols.popupmenu.intensity_task, 'value');
task_str = get(handles.uicontrols.popupmenu.intensity_task, 'string');
channel = get(handles.uicontrols.popupmenu.intensity_ch, 'Value');
channel_str = get(handles.uicontrols.popupmenu.intensity_ch, 'String');

try
    channel_str = channel_str{channel};
end

if strcmp(get(handles.uicontrols.text.text_channelDescription, 'visible'), 'on')
    ch2_str = get(handles.uicontrols.text.text_channelDescription , 'String');
    if isempty(ch2_str)
        uiwait(msgbox('A second fluorescence channel is required to continue!', 'Please note', 'help', 'modal'));
        return;
    end
    channel_str = [ch2_str(end), ' & ' channel_str];
end

if get(handles.uicontrols.checkbox.intensity_perStack, 'value')
    range = [];
    perStack = true;
else
    range = get(handles.uicontrols.edit.intensity_range, 'String');
    perStack = false;
end

if strcmp(get(handles.uicontrols.edit.intensity_range, 'enable'), 'off')
    range = [];
end

switch task
    case 8
        binaryData = true;
    case 9
        binaryData = true;
    case 10
        binaryData = true;
    case 11
        binaryData = true;
    case 13
        binaryData = true;
    otherwise
        binaryData = false;
end


data = {task_str{task}, range, channel_str, true, true, binaryData, perStack};

if isempty(tableData) || isempty(tableData{1,1})
    tableData = data;
else
    tableData(end+1,:) = data;
end
set(handles.uitables.intensity_tasks, 'data', tableData);
storeValues(handles.uitables.intensity_tasks, eventdata, handles);


% --- Executes on selection change in tagCells_parameter.
function tagCells_parameter_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function tagCells_parameter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_tagCells_addRule.
function pushbutton_tagCells_addRule_Callback(hObject, eventdata, handles)
tableData = get(handles.uitables.tagCells_rules, 'data');
operator = get(handles.uicontrols.popupmenu.tagCells_operator, 'value');
operator_str = get(handles.uicontrols.popupmenu.tagCells_operator, 'string');
parameter = get(handles.uicontrols.popupmenu.tagCells_parameter, 'Value');
parameter_str = get(handles.uicontrols.popupmenu.tagCells_parameter, 'String');
if ~iscell(parameter_str)
    parameter_str = {parameter_str};
end
data = {parameter_str{parameter}, operator_str{operator}, str2num(get(handles.uicontrols.edit.tagCells_value, 'String'))};
if isempty(tableData) || isempty(tableData{1,1})
    tableData = data;
else
    tableData(end+1,:) = data;
end
set(handles.uitables.tagCells_rules, 'data', tableData);
storeValues(handles.uitables.tagCells_rules, eventdata, handles);


% --- Executes on selection change in tagCells_operator.
function tagCells_operator_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function tagCells_operator_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tagCells_value_Callback(hObject, eventdata, handles)
currentValue = str2num(get(hObject, 'String'));
try set(hObject, 'String', num2str(currentValue(1))); catch; set(hObject, 'String', ''); end


% --- Executes during object creation, after setting all properties.
function tagCells_value_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tagCells_name_Callback(hObject, eventdata, handles)
hObject.String = matlab.lang.makeValidName(hObject.String);
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function tagCells_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ellipseRepresentation.
function ellipseRepresentation_Callback(hObject, eventdata, handles)
if exist('additionalCallbacks', 'file')
    handles = additionalCallbacks('ellipseRepresentation_Callback', hObject, eventdata, handles);
end


% --- Executes on button press in pushbutton_tagCells_clear.
function pushbutton_tagCells_clear_Callback(hObject, eventdata, handles)
set(handles.uitables.tagCells_rules, 'data', []);
storeValues(handles.uitables.tagCells_rules, eventdata, handles);


% --- Executes on button press in pushbutton_intensity_clear.
function pushbutton_intensity_clear_Callback(hObject, eventdata, handles)
set(handles.uitables.intensity_tasks, 'data', []);
storeValues(handles.uitables.intensity_tasks, eventdata, handles);


% --- Executes when entered data in editable cell(s) in intensity_tasks.
function intensity_tasks_CellEditCallback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in intensity_perStack.
function intensity_perStack_Callback(hObject, eventdata, handles)
if get(hObject, 'value')
    set(handles.uicontrols.edit.intensity_range, 'Enable', 'off');
else
    if handles.uicontrols.popupmenu.intensity_task.Value ~= 14
        set(handles.uicontrols.edit.intensity_range, 'Enable', 'on');
    end
end


% --- Executes on button press in pushbutton_determineManualThreshold_I_base.
function pushbutton_determineManualThreshold_I_base_Callback(hObject, eventdata, handles)
if exist('additionalCallbacks', 'file')
    handles = additionalCallbacks('pushbutton_determineManualThreshold_I_base_Callback', hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function menu_tools_dataExplorer_Callback(hObject, eventdata, handles)
try
    folder = handles.settings.directory;
catch
    folder = '';
end
folderNavigator({folder}, handles);



function visualization_rotation_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric');


% --- Executes during object creation, after setting all properties.
function visualization_rotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visualization_rotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in visualization_rotation_axis.
function visualization_rotation_axis_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function visualization_rotation_axis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_files_correctFrameNumbering_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'settings')
    fprintf('No files loaded!\n');
    displayStatus(handles, 'No files loaded!', 'red');
    return;
end

handles = correctFrameNumbering(handles);


% --- Executes on button press in pushbutton_files_checkFiles.
function pushbutton_files_checkFiles_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'settings')
    fprintf('No files loaded!\n');
    displayStatus(handles, 'No files loaded!', 'red');
    return;
end

toggleBusyPointer(handles, true)
enableCancelButton(handles);

maxFluorescence = zeros(numel(handles.settings.lists.files_tif, 1));
displayStatus(handles, 'Scanning files...', 'black');
files = handles.settings.lists.files_tif;

% Load first plane with more than 1 slice and get brightest plane
updateWaitbar(handles, 0.05)
for i = 1:numel(handles.settings.lists.files_tif)
    img = imread3D(fullfile(handles.settings.directory, files(i).name));
    img = img(:,:,2:end);
    
    if size(img, 3) > 1
        break;
    end
end

% Identify brightest plane
score = squeeze(sum(sum(img, 1), 2));
[~, zIdx] = max(score);


for i = 1:numel(handles.settings.lists.files_tif)
    updateWaitbar(handles, i/numel(files))
    try
        img = imread(fullfile(handles.settings.directory, files(i).name), zIdx+1);
        
        img = sort(img(:));
        
        maxFluorescence(i) = mean(img(end-200:end));
    catch
        maxFluorescence(i) = 0;
    end
    
    if checkCancelButton(handles)
        updateWaitbar(handles, 0)
        toggleBusyPointer(handles, false)
        return;
    end
end

h = figure('Name', 'Intensity profile');
addIcon(h);

h_ax = axes('Parent', h);
plot(h_ax, maxFluorescence, 'o-');
title(h_ax, {'Select threshold to delete out-of-focus images', '(this action has to be confirmed in the next step)'});
xlabel(h_ax, 'File index');
ylabel(h_ax, 'Intensity score');
try
    toggleBusyPointer(handles, false)
    x = ginput(1);
    toggleBusyPointer(handles, true)
catch
    updateWaitbar(handles, 0)
    toggleBusyPointer(handles, false)
    return;
end

filesToDelete = find(maxFluorescence<x(2));

choice = questdlg(sprintf('Delete all associated files of these %d files?', numel(filesToDelete)), ...
    'Delete file', ...
    'Yes','Cancel', 'Yes');
switch choice
    case 'Yes'
        displayStatus(handles, 'Done', 'black', 'add');
        for f = 1:numel(filesToDelete)
            file = filesToDelete(f);
            
            file_base = strfind(files(file).name, 'Nz');
            file_base = files(file).name(1:file_base+1);
            
            file_tif_metadata = dir(fullfile(handles.settings.directory, [file_base, '*']));
            
            ind = strfind(file_base, 'Nz');
            file_mask_cells_vtk = dir(fullfile(handles.settings.directory, 'data', [file_base(1:ind-2), '*']));
            
            for i = 1:length(file_tif_metadata)
                delete(fullfile(handles.settings.directory, file_tif_metadata(i).name));
                displayStatus(handles, ['Deleted: ', fullfile(handles.settings.directory, file_tif_metadata(i).name)], 'red');
            end
            for i = 1:length(file_mask_cells_vtk)
                delete(fullfile(handles.settings.directory, 'data', file_mask_cells_vtk(i).name));
                displayStatus(handles, ['Deleted: ', fullfile(handles.settings.directory, 'data', file_mask_cells_vtk(i).name)], 'red');
            end
            
        end
end

updateWaitbar(handles, 0)
displayStatus(handles, 'Done', 'black', 'add');
pushbutton_refreshFolder_Callback(hObject, eventdata, handles)
delete(h);
toggleBusyPointer(handles, false)


% --- Executes on button press in waitForMemory.
function waitForMemory_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function renderParaview_path_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function renderParaview_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in renderParaview.
function renderParaview_Callback(hObject, eventdata, handles)
if hObject.Value
    handles.uicontrols.edit.renderParaview_path.Enable = 'On';
    handles.uicontrols.checkbox.renderParaview_removeZOffset.Enable = 'On';
    handles.uicontrols.text.renderParaview_parameterText.Enable = 'On';
    handles.uicontrols.popupmenu.renderParaview_parameter.Enable = 'On';
    handles.uicontrols.popupmenu.outputFormat3D.Value = 1;
else
    handles.uicontrols.edit.renderParaview_path.Enable = 'Off';
    handles.uicontrols.checkbox.renderParaview_removeZOffset.Enable = 'Off';
    handles.uicontrols.text.renderParaview_parameterText.Enable = 'Off';
    handles.uicontrols.popupmenu.renderParaview_parameter.Enable = 'Off';
end
storeValues(hObject, eventdata, handles);


% --- Executes on button press in renderParaview_removeZOffset.
function renderParaview_removeZOffset_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on selection change in renderParaview_parameter.
function renderParaview_parameter_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function renderParaview_parameter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_process_batch_Callback(hObject, eventdata, handles)
% hObject    handle to menu_process_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_process_batch_allFolders_Callback(hObject, eventdata, handles)
if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off');
else
    set(hObject, 'Checked', 'on')
end


% --- Executes on button press in rotateBiofilm.
function rotateBiofilm_Callback(hObject, eventdata, handles)


% --- Executes on button press in rotateImage.
function rotateImage_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --------------------------------------------------------------------
function context_cropping_auto_Callback(hObject, eventdata, handles, method)
cropRange = findCropRange(hObject, eventdata, handles, method);


% --- Executes on button press in pushbutton_files_deconvolve.
function pushbutton_files_deconvolve_Callback(hObject, eventdata, handles)
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
prepareImagesForDeconvolution(handles, params.params);


function huygens_Niterations_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'integer', 'range', [1 200]);


% --- Executes during object creation, after setting all properties.
function huygens_Niterations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function huygens_qualityThreshold_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [1e-10 1]);


% --- Executes during object creation, after setting all properties.
function huygens_qualityThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function huygens_SNR_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'range', [1 50]);


% --- Executes during object creation, after setting all properties.
function huygens_SNR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function huygens_micrTemplate_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function huygens_micrTemplate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function huygens_deconTemplate_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function huygens_deconTemplate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in huygens_wavelengths.
function huygens_wavelengths_CellEditCallback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function noise_kernelSize_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'array', 'condition', 'odd', 'range', [3 501]);


% --- Executes during object creation, after setting all properties.
function noise_kernelSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stopProcessingNCellsMax.
function stopProcessingNCellsMax_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function NCellsMax_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'integer', 'range', [1 1e99]);


% --- Executes during object creation, after setting all properties.
function NCellsMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in files_createPosFolder.
function files_createPosFolder_Callback(hObject, eventdata, handles)
if hObject.Value
    handles.uicontrols.checkbox.files_createPosFolder.Value = 1;
    handles.uicontrols.checkbox.files_createPosFolder2.Value = 1;
else
    handles.uicontrols.checkbox.files_createPosFolder.Value = 0;
    handles.uicontrols.checkbox.files_createPosFolder2.Value = 0;
end
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_huygens_convertImagesToChannel.
function pushbutton_huygens_convertImagesToChannel_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
convertFolderContentToChannel(handles.settings.directory);
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_files_checkFiles.
function pushbutton_checkFiles_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_findOutOfFocusStacks.
function pushbutton_findOutOfFocusStacks_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_setRefFrameCropping.
function pushbutton_setRefFrameCropping_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
file = handles.java.files_jtable.getSelectedRow+1;

displayStatus(handles, ['Setting reference frame "',handles.settings.lists.files_tif(file).name, '"'], 'black');

%%% get image

files = handles.settings.lists;

fileType = get(handles.uicontrols.popupmenu.popupmenu_fileType, 'Value');


if fileType>1
    try
        % Read metadata and update edits for scaling/thresholds/etc...
        try
            metadata = handles.settings.metadataGlobal{file};
        catch
            metadata_file = dir(fullfile(handles.settings.directory, files.files_metadata(file).name));
            if ~isempty(metadata_file)
                metadata = load(fullfile(handles.settings.directory,metadata_file.name));
            else
                uiwait(msgbox('Metadata file does not exist!', 'Warning', 'warn', 'modal'));
            end
        end
        
        im = imread(fullfile(handles.settings.directory, files.files_tif(file).name), 1);
        projection = im;
        
        if get(handles.uicontrols.checkbox.imageRegistration, 'Value')
            try
                projection = performImageAlignment2D(im, metadata);
            catch
                if handles.settings.showMsgs
                    uiwait(msgbox('Image stack is not registered!', 'Please note', 'warn', 'modal'));
                else
                    warning('Image stack is not registered!');
                end
            end
        end
        
        
    catch
        disp('Could not load associated tif-stack!');
    end
end

h = figure('Name', handles.settings.lists.files_tif(file).name);
addIcon(h);

try
    intRange = [prctile(projection(:), 5) prctile(projection(:), 99.9)];
catch
    im_sorted = sort(projection(:));
    intRange = im_sorted([round(0.05*numel(im_sorted)) round(0.99*numel(im_sorted))]);
end

h_ax = axes('Parent', h);
imagesc(projection,'Parent', h_ax);
set(h_ax, 'cLim', intRange);
colormap(h_ax, gray(255));
axis(h_ax, 'tight', 'equal', 'off');

title('Please draw rectangle to set reference frame');
try
    cropRange = round(getrect);
catch
    cropRange = [];
end
if ~isempty(cropRange)
    cropRange(cropRange<1) = 1;
    
    if cropRange(1)+cropRange(3) > size(projection,2)
        cropRange(3) = size(projection,2)-cropRange(1);
    end
    
    if cropRange(2)+cropRange(4) > size(projection,1)
        cropRange(4) = size(projection,1)-cropRange(2);
    end
    
    
    
    set(handles.uicontrols.edit.registrationReferenceCropping, 'String', num2str(cropRange));
    displayStatus(handles, [' -> registration frame = [', num2str(cropRange),']'], 'black', 'add');
    
    set(handles.uicontrols.checkbox.displayAlignedImage, 'Value', 1);
    set(handles.uicontrols.checkbox.fixedOutputSize, 'Value', 1);
    
    handles = storeValues(handles.uicontrols.edit.registrationReferenceCropping, eventdata, handles);
    eventdata = struct('Indices', file);
    files_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);
    
end
try
    delete(h);
end
toggleBusyPointer(handles, false)


% --- Executes during object creation, after setting all properties.
function channel_seg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function paraview_pathExecutable_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function paraview_pathExecutable_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in removeZOffset.
function removeZOffset_Callback(hObject, eventdata, handles)


function FFmpeg_pathExecutable_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function FFmpeg_pathExecutable_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_FFmpeg_browseExecutable.
function pushbutton_FFmpeg_browseExecutable_Callback(hObject, eventdata, handles)


function movie_overlayFile_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function movie_overlayFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_movie_browseOverlayFile.
function pushbutton_movie_browseOverlayFile_Callback(hObject, eventdata, handles)


function framerate_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function framerate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_paraview_browseExecutable.
function pushbutton_paraview_browseExecutable_Callback(hObject, eventdata, handles)


function paraview_pathTemplate_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function paraview_pathTemplate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_paraview_browseTemplate.
function pushbutton_paraview_browseTemplate_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_action_exportToCSV.
function pushbutton_action_exportToCSV_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
exportData(hObject, eventdata, handles, 'csv');
toggleBusyPointer(handles, false)


% --- Executes on button press in pushbutton_action_exportToFCS.
function pushbutton_action_exportToFCS_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
exportData(hObject, eventdata, handles, 'fcs');
toggleBusyPointer(handles, false)


% --- Executes on button press in exportVTKafterEachProcessingStep.
function exportVTKafterEachProcessingStep_Callback(hObject, eventdata, handles)


% --- Executes when selected cell(s) is changed in cellParametersCalculate.
function cellParametersCalculate_CellSelectionCallback(hObject, eventdata, handles)
try
    if length(eventdata.Indices)<1
        return;
    end
    selectedRow = eventdata.Indices(1);
    selectedColumn = eventdata.Indices(2);
    
    cellParameterTable = handles.tableData;
    
    parameter = cellParameterTable{selectedRow, 1};
    defaultVal = cellParameterTable{selectedRow, 3};
    type = cellParameterTable{selectedRow, 4};
    question = cellParameterTable{selectedRow, 5};
    addedFields = cellParameterTable{selectedRow, 6};
    requiredModules = cellParameterTable{selectedRow, 7};
    description = cellParameterTable{selectedRow, 8};
    try
        link = cellParameterTable{selectedRow, 9};
    catch err
        link = 'usage/parameter_calculation.html';
    end
    
    if isempty(requiredModules)
        requiredModules = '';
    else
        requiredModules = ['Required modules: ', requiredModules];
    end
    
    
    description = strrep(description, ' um', ' &mu;m');
    description = strrep(description, 'NaN', '<i>NaN</i>');
    description = strrep(description, '^2', '<sup><font size="4">2</font></sup>');
    description = strrep(description, '^3', '<sup><font size="4">3</font></sup>');
    description = strrep(description, '^{-1}', '<sub><font size="4">-2</font></sub>');
    description = strrep(description, '^{-2}', '<sub><font size="4">-2</font></sub>');
    description = strrep(description, '^{-3}', '<sub><font size="4">-3</font></sub>');
    
    addedFields = strrep(addedFields, ' um', ' &mu;m');
    addedFields = strrep(addedFields, '^2', '<sup><font size="4">2</font></sup>');
    addedFields = strrep(addedFields, '^3', '<sup><font size="4">3</font></sup>');
    addedFields = strrep(addedFields, '^{-1}', '<sub><font size="4">-2</font></sub>');
    addedFields = strrep(addedFields, '^{-2}', '<sub><font size="4">-2</font></sub>');
    addedFields = strrep(addedFields, '^{-3}', '<sub><font size="4">-3</font></sub>');
    
    handles.uicontrols.text.parameterDescriptionJ.Text = sprintf( ...
        ['<html>', ...
        '<font size="5" face="sans serif, arial">%s<br>', ...
        '</font><font size="1" face="sans serif, arial"><br>', ...
        '</font><font size="5" face="sans serif, arial">Added features: <b>%s</b><br>', ...
        '</font><font size="1" face="sans serif, arial"><br>', ...'
        '</font><font size="5" face="sans serif, arial">%s</font>', ...
        '<html>'], description, addedFields, requiredModules);

    handles.layout.boxPanels.boxpanel_parameterDescription.HelpFcn = {@openHelp, link};
    handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.HelpFcn = {@openHelp, link};
    
    % Modules requirering input
    if ~isempty(question)
        handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'off';
        drawnow;
        
        if isnumeric(defaultVal)
            defaultVal = num2str(defaultVal);
        end
        
        if strcmp(type, 'file')
            handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Selection = 5;
            handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'on';
            handles.uicontrols.text.parameterInputDescription_file.String = question;
            handles.uicontrols.edit.parameters_filePath.UserData = {selectedRow, type};
            handles.uicontrols.pushbutton.pushbutton_parameters_selectFile.UserData = {selectedRow, type};
            
        else
            handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Selection = 6;
            handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'on';
            
            handles.uicontrols.text.parameterInputDescription.String = question;
            handles.uicontrols.edit.parameterInput.String = defaultVal;
            handles.uicontrols.edit.parameterInput.UserData = {selectedRow, type};
            
            if any(strfind(parameter, '[vox]'))
                pxSize = convertToUm(handles,str2double(defaultVal),1);
                handles.uicontrols.text.text_parameterUnitConversion.String = sprintf('vox (%.2f \x03BCm)', pxSize);
            else
                handles.uicontrols.text.text_parameterUnitConversion.String = '';
            end
            
        end
        
        try
            handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Title = sprintf(' Options for "%s"', parameter);
        end
        
    else
        
        switch lower(parameter)
            case 'intelligent merging/splitting of single cells'
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Selection = 3;
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'on';
            case 'filter objects'
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Selection = 2;
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'on';
            case 'fluorescence properties'
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Selection = 7;
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'on';
            case 'tag cells'
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Selection = 8;
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'on';
            case 'custom parameter'
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Selection = 4;
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'on';
            otherwise
                handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Visible = 'off';
        end
        
        try
            handles.layout.boxPanels.boxpanel_cellParameters_parameterTabs.Title = sprintf(' Options for "%s"', parameter);
        end
    end

catch err
    %%% What is the point of a try-catch block if you just rethrow the
    %%% exact same error??
    rethrow(err);
end


% --- Executes when entered data in editable cell(s) in tagCells_rules.
function tagCells_rules_CellEditCallback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


function parameterInput_Callback(hObject, eventdata, handles)
selectedRow = hObject.UserData{1};
type = hObject.UserData{2};

answer = hObject.String;

switch type
    case 'numeric'
        answer = str2double(answer);
        input = 'a number';
    case 'char'
        answer = answer;
        input = 'a string';
    case 'boolean'
        answer = boolean(str2double(answer));
        input = '1 or 0';
    otherwise
        answer = answer;
        input = 'something';
end

if isnan(answer)
    msgbox(sprintf('Please input %s!', input), 'Wrong input', 'help', 'modal');
else
    handles.uitables.cellParametersCalculate.Data{selectedRow, 3} = answer;
    handles.tableData{selectedRow, 3} = answer;
    storeValues(hObject, eventdata, handles);
    if any(strfind(handles.uicontrols.text.text_parameterUnitConversion.String, 'vox'))
        pxSize = convertToUm(handles,answer,1);
        handles.uicontrols.text.text_parameterUnitConversion.String = sprintf('vox (%.2f \x03BCm)', pxSize);
    end
    
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function parameterInput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_help_about_Callback(hObject, eventdata, handles)
about;


function splitVolume3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function splitVolume3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function splitAspectRatio_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function splitAspectRatio_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function parameters_filePath_Callback(hObject, eventdata, handles)
selectedRow = hObject.UserData{1};

filename = hObject.String;

if ~exist(filename, 'file')
    uiwait(msgbox(sprintf('File "%s" does not exist!', filename), 'Error', 'error', 'modal'));
    return;
end

handles.uicontrols.edit.parameters_filePath.String = filename;

handles.uitables.cellParametersCalculate.Data{selectedRow, 3} = filename;
handles.tableData{selectedRow, 3} = filename;
storeValues(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function parameters_filePath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_parameters_selectFile.
function pushbutton_parameters_selectFile_Callback(hObject, eventdata, handles)
if isdeployed
    path = fullfile(fileparts(which('BiofilmQ')), '..', 'includes', 'object processing', 'actions', 'user-defined parameters', 'template.m'); 
else
   path = fullfile(fileparts(which('BiofilmQ')), 'includes', 'object processing', 'actions', 'user-defined parameters', 'template.m'); 
end
[filename, directory] = uigetfile('*.m', 'Please select a Matlab script', path);
if ~directory
    uiwait(msgbox('No file selected.', 'Please note', 'help', 'modal'));
    return;
end

selectedRow = hObject.UserData{1};

filename = fullfile(directory, filename);

handles.uicontrols.edit.parameters_filePath.String = filename;

handles.uitables.cellParametersCalculate.Data{selectedRow, 3} = filename;
handles.tableData{selectedRow, 3} = filename;
storeValues(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on selection change in huygens_objTemplate.
function huygens_objTemplate_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function huygens_objTemplate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in analysis_files.
function analysis_files_CellSelectionCallback(hObject, eventdata, handles)

row = hObject.getSelectedRow+1;

biofilmData = getLoadedBiofilmFromWorkspace;

objects = biofilmData.data(row);
renderBiofilmThumbnail(handles, objects)


% --- Executes on button press in pushbutton_importSimulations.
function pushbutton_importSimulations_Callback(hObject, eventdata, handles)
handles = importSimulations(hObject, eventdata, handles);
pushbutton_refreshFolder_Callback(hObject, eventdata, handles);


function simulation_lengthScale_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function simulation_lengthScale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function simulation_sampling_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function simulation_sampling_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function simulation_timescale_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function simulation_timescale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in simulation_obtainPixelIdxLists.
function simulation_obtainPixelIdxLists_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_huygens_files_remove.
function pushbutton_huygens_files_remove_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
removeFilesAfterDeconvolution(handles);
toggleBusyPointer(handles, false)


% --- Executes on button press in pushButton_chooseBiofilm.
function pushbutton_chooseBiofilm_Callback(hObject, eventdata, handles)
chooseBiofilms(handles);


% --- Executes on selection change in visCells_plotType.
function visCells_plotType_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function visCells_plotType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function visualization_imageRange_Callback(hObject, eventdata, handles)
range = str2num(handles.uicontrols.edit.visualization_imageRange.String);

if isnumeric(range) && ~isempty(range)
    biofilmData = evalin('base', 'biofilmData');
    validFiles = 1:numel(biofilmData.data);
    range_new = assembleImageRange(intersect(range, validFiles));
    handles.uicontrols.edit.visualization_imageRange.String = num2str(range_new);
else
    handles.uicontrols.edit.visualization_imageRange.String = sprintf('1:%d', size(handles.uitables.analysis_files.Data, 1));
end


% --- Executes during object creation, after setting all properties.
function visualization_imageRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_visualization_imageRange_takeSel.
function pushbutton_visualization_imageRange_takeSel_Callback(hObject, eventdata, handles)
biofilmData = evalin('base', 'biofilmData');
validFiles = 1:numel(biofilmData.data);

selectedImages = handles.java.tableAnalysis{1}.getSelectedRows()+1;
selectedImages = arrayfun(@(x) handles.java.tableAnalysis{1}.getValueAt(x,0), selectedImages-1);
range = assembleImageRange(intersect(selectedImages, validFiles));

handles.uicontrols.edit.visualization_imageRange.String = range;
visualization_imageRange_Callback(hObject, eventdata, handles);


% --- Executes on button press in pushbutton_visualization_imageRange_takeAll.
function pushbutton_visualization_imageRange_takeAll_Callback(hObject, eventdata, handles)
biofilmData = evalin('base', 'biofilmData');
validFiles = 1:numel(biofilmData.data);

range_new = assembleImageRange(validFiles);
handles.uicontrols.edit.visualization_imageRange.String = num2str(range_new);


function thresholdSensitivity_Callback(hObject, eventdata, handles)
if isnan(str2double(get(hObject,'String'))) || str2double(get(hObject,'String'))<0
    msgbox('Please enter a positive number.', 'Warning', 'warn');
    handles.uicontrols.edit.thresholdSensitivity.String = '1';
end
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function thresholdSensitivity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_help_onlineHelp_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_help_gettingStarted_Callback(hObject, eventdata, handles)
openHelp([], [], 'index.html');

% --------------------------------------------------------------------
function menu_help_fileInput_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/fileInput.html');

% --------------------------------------------------------------------
function menu_help_imagePreparation_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/image_preparation.html');

% --------------------------------------------------------------------
function menu_help_segmentation_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/segmentation.html');

% --------------------------------------------------------------------
function menu_help_featureCalculation_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/parameter_calculation.html');

% --------------------------------------------------------------------
function menu_help_tracking_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/cube_tracking.html');

% --------------------------------------------------------------------
function menu_help_export_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/export.html');

% --------------------------------------------------------------------
function menu_help_analysis_Callback(hObject, eventdata, handles)
openHelp([], [], 'usage/visualization.html');


% --- Executes on button press in considerSiblings.
function considerSiblings_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes on button press in displayAllChannels.
function displayAllChannels_Callback(hObject, eventdata, handles)
try
    eventdata = struct('Indices', handles.settings.selectedFile);
    files_Callback(hObject, eventdata, handles);
    storeValues(hObject, eventdata, handles);
end


% --- Executes on button press in pushbutton_tagCells_deleteRow.
function pushbutton_tagCells_deleteRow_Callback(hObject, eventdata, handles)
try
    handles.uitables.tagCells_rules.Data(handles.settings.table_tagCellRules_selected(1), :) = [];
end


% --- Executes on button press in pushbutton_intensity_deleteRow.
function pushbutton_intensity_deleteRow_Callback(hObject, eventdata, handles)
try
    handles.uitables.intensity_tasks.Data(handles.settings.table_intensityTasks_selected(1), :) = [];
end


function simulation_expansionFactor_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function simulation_expansionFactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function changeFontSize_Callback(hObject, eventdata, handles, mode)
changeFontSize(hObject, eventdata, handles, mode);


% --- Executes when selected cell(s) is changed in tagCells_rules.
function tagCells_rules_CellSelectionCallback(hObject, eventdata, handles)
handles.settings.table_tagCellRules_selected = eventdata.Indices;
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in intensity_tasks.
function intensity_tasks_CellSelectionCallback(hObject, eventdata, handles)
handles.settings.table_intensityTasks_selected = eventdata.Indices;
guidata(hObject, handles);

function importValidationPushbutton_Callback(hObject, eventdata, handles)

    filename = handles.uicontrols.edit.importValidationFilename.String;

    feature_patterns = {...
        handles.uicontrols.edit.importPositionRegexp.String, ...
        handles.uicontrols.edit.importChannelRegexp.String, ...
        handles.uicontrols.edit.importTimeRegexp.String, ...
        handles.uicontrols.edit.importZPosRegexp.String};

    feature_patterns_regex = cellfun(@(x) ['(?<=', x, ')\d+'], feature_patterns, ...
        'UniformOutput', false);

    match = cellfun(@(x) regexpi(filename, x, 'match', 'once'), ...
        feature_patterns_regex, 'UniformOutput', false);

    index = cellfun(@(x) regexpi(filename, x, 'once'), ...
        feature_patterns_regex, 'UniformOutput', false);

    % Better results in a table:


    fmt =   {...
        'Pos     = %s', ...
        'Channel = %s', ...
        'Time    = %s', ...
        'zPos    = %s'};
    mesg = cellfun(@sprintf, fmt,match, 'Uniformoutput', false);

    [~, label, ~] = fileparts(filename);

    for j = 1:numel(feature_patterns)
        label = strrep(label, [feature_patterns{j}, match{j}] , '');
    end

    handles.uitables.importResults.Data = {};
    handles.uitables.importResults.RowName = 'numbered';
    handles.uitables.importResults.ColumnName = ...
        {'Filename', 'Label', 'Position', 'Channel', 'Time', 'zPos'};

    handles.uitables.importResults.Data = [{filename, label}, match];
    %     handles.uicontrols.text.text_importValidationResults.String = mesg;


    missing_data = cellfun(@isempty, handles.uitables.importResults.Data);
    if any(missing_data(:))
        handles.uitables.importResults.Data{missing_data} = '<html><font color="red">NaN</font></html>';

        handles.uitables.importResults.ColumnName(missing_data) = ...
            cellfun(@(x) ['<html><font color="red">', x, '</font></html>'], ...
            handles.uitables.importResults.ColumnName(missing_data), ...
            'UniformOutput', false);
    end


function importValidationPushbuttonAll_Callback(hObject, eventdata, handles)
    test = false;

    % TODO:
    % - rbg tifs are most likely threated as 3D data. This results in
    % information loss for zPos even if metadata is present in filename ...
    % Best create the information non the less and add in the import
    % Funktion a proper case switch ...


    toggleBusyPointer(handles, true);


    % Read all files with .tif / .tiff ending in current experiment
    % folder
    files_tif = dir(fullfile(handles.settings.directory, '*.tif'));
    files_tiff = dir(fullfile(handles.settings.directory, '*.tiff'));

    files = [files_tif, files_tiff];




    % Store information in uitable
    handles.uitables.importResults.Data = {};
    handles.uitables.importResults.RowName = 'numbered';

    if ~isempty(files)
        % Question: 2D or 3D?
        fprintf('Analyse dimension of tif-file "%s"\n', ...
            fullfile(files(1).folder, files(1).name))

        filename = fullfile(files(1).folder, files(1).name);
        imInfo = imfinfo(filename);
        if length(imInfo) == 1
            dimensions = 2;

            handles.uitables.importResults.ColumnName = ...
                {'Filename', 'Label', 'Position', 'Channel', 'Time', 'zPos'};

            handles.uitables.importResults.ColumnEditable = logical([0, 1, 1, 1, 1, 1]);

            feature_patterns = {...
                handles.uicontrols.edit.importPositionRegexp.String, ...
                handles.uicontrols.edit.importChannelRegexp.String, ...
                handles.uicontrols.edit.importTimeRegexp.String, ...
                handles.uicontrols.edit.importZPosRegexp.String};


        else
            dimensions = 3;

            handles.uitables.importResults.ColumnName = ...
                {'Filename', 'Label', 'Position', 'Channel', 'Time'};

            handles.uitables.importResults.ColumnEditable = logical([0, 1, 1, 1, 1]);

            feature_patterns = {...
                handles.uicontrols.edit.importPositionRegexp.String, ...
                handles.uicontrols.edit.importChannelRegexp.String, ...
                handles.uicontrols.edit.importTimeRegexp.String};
        end
        fprintf('Found %dD content\n', dimensions);

    else
        warning('No tif files found!')
        return
    end

    feature_patterns_regex = cellfun(@(x) ['(?<=', x, ')\d+'], feature_patterns, ...
        'UniformOutput', false);


    for i = 1:numel(files)
        filename = files(i).name;

        match = cellfun(@(x) regexpi(filename, x, 'match', 'once'), ...
            feature_patterns_regex, 'UniformOutput', false);

        [~, label, ~] = fileparts(filename);

        for j = 1:numel(feature_patterns)
            label = strrep(label, [feature_patterns{j}, match{j}] , '');
        end

        handles.uitables.importResults.Data = ...
            [handles.uitables.importResults.Data; [{filename, label}, match]];
    end

    
    missing_data = cellfun(@isempty, handles.uitables.importResults.Data);

    missing_cols = sum(missing_data,1);
    % double-check channels and automatically correct if necessary
    if ~missing_cols(4) 
            
        channels = unique(cellfun(@str2num, handles.uitables.importResults.Data(:,4)));
        channels = sort(channels(:));
        if any(channels~=(1:numel(channels))')
            answer = questdlg('Channel numbers need to be increasing integer values, starting at 1. Would you like to automatically correct your channel numbering?', ...
                    'Invalid channel numbering detected', ...
                    'Yes','No, keep original channel numbers','Yes');

            switch answer
                case 'Yes'
                    for i = 1:size(handles.uitables.importResults.Data, 1)
                        oldIndex = str2num(handles.uitables.importResults.Data{i, 4});
                        newIndex = find(channels==oldIndex);
                        handles.uitables.importResults.Data{i, 4} = ...
                            sprintf('<html><font color="red">%d</font></html>', newIndex);
                    end
                case 'No, keep original channel numbers.'
                    % Do nothing
            end
        end
    end

    if any(missing_data(:))
        if handles.settings.showMsgs
            % Does the user want to automatically modify the results?
            missing_metadata = handles.uitables.importResults.ColumnName(find(missing_cols));
            missing_metadata{1} = sprintf('Missing metadata detected! Fill in automatic values for:\n%s', missing_metadata{1});
            default_answer = arrayfun(@num2str, nan(1, sum(missing_cols ~= 0)), 'UniformOutput', false);
            answer = inputdlg(missing_metadata, 'Autofill metadata', 1, default_answer);

            if isempty(answer)
                answer = default_answer;
            end

            fill_indices = find(missing_cols);
            
            fill_converter = { ...
                @(x) x; @(x) x; @str2double; @str2double; @str2double; @str2double};
            fill_converter = fill_converter(fill_indices);
            
            fill_values = cellfun(@(fun, val) fun(val), fill_converter, answer, 'un', 0);


            for i = 1:size(handles.uitables.importResults.Data, 1)
                for j = 1:size(fill_indices, 2)
                    if missing_data(i,fill_indices(j))
                        switch class(fill_values{j})
                            case 'double'
                                format_string = '<html><font color="red">%.0f</font></html>';
                            case 'char'
                                format_string = '<html><font color="red">%s</font></html>';
                        end
                        handles.uitables.importResults.Data{i, fill_indices(j)} = ...
                            sprintf(format_string, fill_values{j});
                    end
                end
            end

        else % handles.settings.showMsgs disabled
            warning(['Missing Metadatainformation for import!\n', ...
                'Without messages enabled, you have fill them manually!'])
        end
        %TODO: Does the user manually want to anotate (or exclude) some files?
    end

    handles.uicontrols.pushbutton.importCustomTiffPushbutton.Enable = 'on';

    % TODO: Add script to disable this button in analyse directory
    if ~test
        toggleBusyPointer(handles, false);
    end
        
        
function importCustomTiffPushbutton_Callback(hObject, eventdata, handles)
    % Use 'create_testfiles.m' to create test images for the function
    toggleBusyPointer(handles, true);

    % test for incomplete table
    metadata_html = handles.uitables.importResults.Data;

    expression = '<html><font color="red">(.*)</font></html>';
    replace = '$1';
    metadata = cellfun(@(x) regexprep(x,expression,replace), metadata_html, ...
        'UniformOutput', false);

    % Convert to numeric
    metadata(:, 3:end) = num2cell(cellfun(@str2double, metadata(:, 3:end)));

    missing_data = cellfun( ...
        @(x) isempty(x) || all(isnan(x)), metadata(:, 3:end));

    if any(missing_data(:))
        if handles.settings.showMsgs
            answer = questdlg(sprintf(['Missing Metadata. Please modify the table manually or use the automatic fill option.\n', ...
                'If you continue we will skip the files with incomplete metadata information']), ...
                'Missing metadata', ...
                'Continue', 'Cancel','Continue');
        else
            warning('Missing Metadata. Please modify the table manually or use the automatic fill option');
            answer = 'Continue';
        end

        if strcmp(answer, 'Cancel')
            toggleBusyPointer(handles, false);
            return;
        end
    end


    if false % Nice alternative (Thanks Hannah!)
        % If there are more than zeros timepoints present, interpret all NaNs as
        % additional timepoints. If no time is present at all, interpret all
        % as belonging to the same time
        times = [metadata{:, 5}];
        if sum(times~=times) == numel(times)
            times = ones(length(times),1);
        else
            indices = find(times~=times);
            times(indices) = round(max(times))+(1:length(indices));
        end
        metadata(:, 5) = {times(:)};

        % If there is more than one position present, interpret all NaNs as
        % additional positions. If no position is present at all, interpret all
        % as belonging to the same position
        positions = [metadata{:, 3}];
        if sum(positions~=positions)== numel(positions)
            positions = ones(length(positions),1);
        else
            indices = find(positions~=positions);
            positions(indices) = round(max(positions))+(1:length(indices));
        end
        metadata(:, 3) = {positions(:)};

        % zPos must be interpreted as
        % Todo...


    else
        % Delete lines with incomplete metadata information
        metadata = metadata(all(~missing_data,2), :);
    end

    cancel = false;
    mixedDims = false;
    containsRGB = false;
    wrongTimeFormat = false;
    noScaling = false;
    

    % Sort by Position
    [positions, ~, pos_idcs] = unique([metadata{:, 3}]);
    createdDirectories = cell(1,numel(positions));

    for p = 1:numel(positions)

        %TODO: It is good practise to create a backup directory
        pos = positions(p);
        metadata_p = metadata(pos_idcs == p, :);

        [outputDir,nameFile, ~] = fileparts(handles.settings.directory);
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end

        outputDir = fullfile(outputDir,[nameFile, '_Pos', num2str(pos)]);
        while exist(outputDir, 'dir')
            outputDir = strcat(outputDir, '-1');
        end
        
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        createdDirectories{p} = outputDir;

        enableCancelButton(handles);

        % Sort by Time/ frame
        [~, ~, frames] = unique(cell2mat(metadata_p(:, 5)));

        for frame = 1:max(frames)
            metadata_t = metadata_p(frames == frame, :);

            % Sort by Channel
            [~, ~, ch_idcs] = unique(cell2mat(metadata_t(:, 4)));
            for ch = 1:max(ch_idcs)
                metadata_ = metadata_t(ch_idcs == ch, :);

                % number of metadata colums are direct result dimension
                if size(metadata_, 1) == 1 % 3D or single 2D file
                    stack = imread3D(fullfile(handles.settings.directory, metadata_{1,1}));
                    stack(:, :, 2:end+1) = stack;

                else % sort 2D Files by zPos
                    [~, order] = sortrows(cell2mat(metadata_(:, end)), 1, 'ascend');
                    metadata_ = metadata_(order, :);

                    % Create stack for images
                    info = imfinfo(fullfile(handles.settings.directory, metadata_{1, 1}));
                    stack = zeros(info(1).Height, info(1).Width, size(metadata_, 1)+1);

                    for j = 1:size(metadata_, 1)
                        im_ = imread3D(fullfile(handles.settings.directory, metadata_{j, 1}));


                        if ismatrix(im_) % 2D graylevel
                            stack(:, :, j+1) = im_;

                        elseif size(im_ , 3) == 3 % 2D rgb
                            stack(:, :, j+1) = rgb2gray(im_);
                            containsRGB = true;

                        else % 3D stack -> use only first plane
                            stack(:, :, j+1) = im_(:, :, 1);
                            mixedDims = true;
                        end
                    end
                end

                proj = sum(stack(:, :, 2:end), 3);
                stack(:, :, 1) = proj/ max(proj(:))*(2^16-1);

                label = regexprep(metadata_{1,2},'_frame\d*','');

                fmt = '%s_time%.0f_pos%d_ch%d_frame%06d_Nz%d.tif';
                
                
                filename = sprintf(fmt, label, metadata_{1,5}, pos, metadata_{1, 4}, frame, size(stack, 3)-1);

                if ~exist(fullfile(outputDir, filename), 'file')
                    fprintf('Write file "%s"\n', filename);
                    imwrite3D(stack, fullfile(outputDir, filename));
                else
                    fprintf('   image file already exists, skipping\n');
                end

                % Create metadata
                try
                    params = load(fullfile(handles.settings.directory, 'parameters.mat'));
                    params = params.params;
                    dxy = params.scaling_dxy;
                    dz = params.scaling_dz;
                    % other option: Read from uicontrols
                    % dxy = handles.uicontrols.edit.scaling_dxy
                    % dz = handles.uicontrols.edit.scaling_dz

                catch
                    dz = 400;
                    dxy = 63;
                    noScaling = true;
                end
                data.scaling.dxy = dxy/1000;
                data.scaling.dz = dz/1000;
                try
                    date = datetime(sprintf('%.0f', metadata_t{1,5}),'InputFormat', 'yyyyMMddHHmmss');
                catch
                    try
                        wrongTimeFormat = true;
                        info = imfinfo(fullfile(handles.settings.directory, metadata_t{1, 1}));
                        date = datetime(info(1).FileModDate, 'Locale', get(0, 'Language'));
                    catch
                        date = datetime('now', 'Format', 'dd-MMM-yyyy HH:mm:ss');
                    end
                end
                data.date = datestr(date, 'dd-mmm-yyyy HH:MM:ss');

                if ~exist(fullfile(outputDir, [filename(1:end-4), '_metadata.mat']), 'file')
                    save(fullfile(outputDir, [filename(1:end-4), '_metadata.mat']), 'data');
                else
                    fprintf('   metadata file already exists, skipping\n');
                end


                if checkCancelButton(handles) || cancel
                    cancel = true;
                    break;
                end
            end
        end
    end

    toggleBusyPointer(handles, false);

    % Warning messages
    message = [];

    if mixedDims
        message{end+1} = ['- Found 3D image stacks within 2D directory.',...
            ' -> Only use the first slice of each stack.'];
    end

    if containsRGB
        message{end+1} = ['- Found 2D images with 3 channels.',...
            ' -> Imported as RGB images.'];
    end

    if noScaling
        message{end+1} = ['- No scaling set in data.', ...
            ' -> Please change value after import.'];
    end

    if wrongTimeFormat
        message{end+1} = ['- Some time metadata information could' ...
            ' not be converted to datetime.' ...
            ' -> File timestamp was used instead.'];
    end
    
    
    
    if handles.settings.showMsgs
        if any([mixedDims, containsRGB, noScaling, wrongTimeFormat])
            uiwait(warndlg(message,'Warning'));
        end

        % Delection dialogues
        try
            answer = questdlg([{'The following subdirectories were created:', ''}, createdDirectories, {'', ''}, 'Current directory:', handles.settings.directory], ...
                'Export finished', ...
                'Switch to 1. directory in list', 'Stay in current directory','Stay in current directory');

            switch answer
                case 'Switch to 1. directory in list'
                    handles.settings.directory = createdDirectories{1};
                    handles.uicontrols.edit.inputFolder.String = createdDirectories{1};
                    pushbutton_refreshFolder_Callback(handles.uicontrols.edit.inputFolder, eventdata, handles)
                case 'Stay in current directory'
                    % Do nothing
            end
        catch err
            warning(err.message);
        end
        
    else % only command line warning
        warning('backtrace', 'off');
        for i = 1:numel(message)
            warning(message{i});
        end
        warning('backtrace', 'on');
    end

    handles.settings.displayMode = '';




% --- Executes on button press in pushbutton_tools_transferChannels.
function pushbutton_tools_transferChannels_Callback(hObject, eventdata, handles)
toggleBusyPointer(handles, true)
transferSegmentation(handles);
analyzeDirectory(hObject, eventdata, handles);
toggleBusyPointer(handles, false)



function transferChannel2_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'numeric', 'condition', 'integer', 'range', [1, numel(handles.uicontrols.popupmenu.channel.String)]);

% --- Executes during object creation, after setting all properties.
function transferChannel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transferChannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function transferChannel1_Callback(hObject, eventdata, handles)
handles = checkAndStoreInput(handles, hObject, 'inputType', 'array', 'condition', 'integer', 'range', [1, numel(handles.uicontrols.popupmenu.channel.String)]);

% --- Executes during object creation, after setting all properties.
function transferChannel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transferChannel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_parameterCombination_newParamName_Callback(hObject, eventdata, handles)
presentParams = handles.uicontrols.popupmenu.popupmenu_parameterCombination_ParameterChoice.String;
if any(strcmp(presentParams, get(hObject,'String')))
   msgbox('Parameter name already present. If you proceed, this property will be overwritten by new results.', 'Warning');
end
storeValues(hObject, eventdata, handles);
% hObject    handle to edit_parameterCombination_newParamName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_parameterCombination_newParamName as text
%        str2double(get(hObject,'String')) returns contents of edit_parameterCombination_newParamName as a double


% --- Executes during object creation, after setting all properties.
function edit_parameterCombination_newParamName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_parameterCombination_newParamName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_parameterCombination_ParameterChoice.
function popupmenu_parameterCombination_ParameterChoice_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_parameterCombination_ParameterChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_parameterCombination_ParameterChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_parameterCombination_ParameterChoice


% --- Executes during object creation, after setting all properties.
function popupmenu_parameterCombination_ParameterChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_parameterCombination_ParameterChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_parameterCombination_formula_Callback(hObject, eventdata, handles)
storeValues(hObject, eventdata, handles);
% hObject    handle to edit_parameterCombination_formula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_parameterCombination_formula as text
%        str2double(get(hObject,'String')) returns contents of edit_parameterCombination_formula as a double


% --- Executes during object creation, after setting all properties.
function edit_parameterCombination_formula_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_parameterCombination_formula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_parameterCombination_add.
function pushbutton_parameterCombination_add_Callback(hObject, eventdata, handles)
params = handles.uicontrols.popupmenu.popupmenu_parameterCombination_ParameterChoice.String;
choice = handles.uicontrols.popupmenu.popupmenu_parameterCombination_ParameterChoice.Value;
parameterToAdd = params{choice};
strCom = handles.uicontrols.edit.edit_parameterCombination_formula.String;
if isempty(strCom)
    strCom = strcat('{', parameterToAdd, '}');
else
    strCom = strcat(strCom,'{', parameterToAdd, '}');
end
handles.uicontrols.edit.edit_parameterCombination_formula.String = strCom;
edit_parameterCombination_formula_Callback(handles.uicontrols.edit.edit_parameterCombination_formula, eventdata, handles);
% hObject    handle to pushbutton_parameterCombination_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_parameterCombination_testExpression.
function pushbutton_parameterCombination_testExpression_Callback(hObject, eventdata, handles)
filterExpr = handles.uicontrols.edit.edit_parameterCombination_formula.String;
try
    formulaRaw = filterExpr;
    try
        fields = extractBetween(formulaRaw,'{','}');
    catch
        fields = regexp(formulaRaw, '{.*?}', 'match');
        fields = cellfun(@(x) x(2:end-1), fields, 'UniformOutput', false);
    end
    formula = formulaRaw;
    if ~isempty(fields)
        for i = 1:numel(fields)
            formula = strrep(formula, ['{', fields{i}, '}'], '1');
        end
    else
        formula = formulaRaw;
    end

    eval(sprintf('test = %s;', formula));
    if isnumeric(test)|| islogical(test)
        success = 1;
    else
        success = 0;
    end
    errorStr = 'Expression (%s) is not valid!';
catch err
    errorStr = sprintf('Expression (%s) is not valid! Error: %s', filterExpr, err.message);
    success = 0;
end
if success
    msgbox('Formula is valid.') 
else
    uiwait(msgbox(errorStr, 'Error', 'error', 'modal'));
end
% hObject    handle to pushbutton_parameterCombination_testExpression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit246_Callback(hObject, eventdata, handles)
% hObject    handle to edit246 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit246 as text
%        str2double(get(hObject,'String')) returns contents of edit246 as a double


% --- Executes during object creation, after setting all properties.
function edit246_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit246 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_labelImage_Channel.
function popupmenu_labelImage_Channel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_labelImage_Channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_labelImage_Channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_labelImage_Channel


% --- Executes during object creation, after setting all properties.
function popupmenu_labelImage_Channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_labelImage_Channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
