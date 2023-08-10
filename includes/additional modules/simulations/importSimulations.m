function handles = importSimulations(hObject, eventdata, handles)
%% Convert simulation data into data structure generated after biofilm segmentation of fluorescence images
% by Raimo Hartmann (raimo.hartmann@gmail.com)

disp(['=========== Simulation import ===========']);
ticValueAll = displayTime;

% Load parameters
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

range = str2num(params.action_imageRange);

files = handles.settings.lists.files_sim;

range_new = intersect(range, 1:numel(files));

if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

if ~exist(fullfile(handles.settings.directory, 'data'), 'dir')
    mkdir(fullfile(handles.settings.directory, 'data'));
end

%% Parameters
params_sim = [];
% Define input folder containing the simulation output data
% (format: *timestep*.txt-files)
params_sim.input_folder = handles.settings.directory;

% Define resolution
params_sim.scaling_dxy = params.simulation_sampling; % unit: µm/voxel -> used for centroids, this value corresponds to our 100x silicon oil objective from olympus with NA 1.38
params_sim.scaling_dxy_um = params.simulation_lengthScale; % unit: µm/length_unit, convert the lengths units in the simulation into µm

% For N values greater than 1 only the Nth files are loaded
params_sim.everyNthFile = 1;
params_sim.lastFileOnly = 0;
params_sim.cellSolidity = params.simulation_expansionFactor;

input_folder = params_sim.input_folder;

%% Load inpunt parameters
file_input_params = dir(fullfile(input_folder, 'SimulationInput.txt'));
if isempty(file_input_params)
    uiwait(msgbox('Biofilm parameter file "SimulationInput.txt" does not exist!', 'Error', 'error', 'modal'));
    return;
end

fprintf(' - preparing data\n');
enableCancelButton(handles);
updateWaitbar(handles, 0.1);

dataArray = readtable_fast(fullfile(input_folder, file_input_params(1).name));

params_sim.inputParameters = dataArray;

% Time conversion
% Implement switch statement to calculate tau_r and tau_t

params_sim.dt = params_sim.inputParameters.dt;

if sum(cellfun(@(x) ~isempty(x), strfind(fieldnames(params_sim.inputParameters), 'tau_r'))) % Look for field tau_r
    params_sim.tau_r = params_sim.inputParameters.tau_r;
    params_sim.tau_g = params.simulation_timescale; %sec
    params_sim.tau_t = params_sim.tau_r * params_sim.tau_g;
else
    params_sim.tau_g = NaN;
    params_sim.tau_t = params_sim.inputParameters.tau_t;
    params_sim.tau_r = NaN;
end

%% Load simulation data
% Determine output files
if isempty(files)
    error('No files present in folder "%s"!', input_folder);
end

containsErrors = 1;
while containsErrors
    % Load the last biofilm file to extract the maximum dimensions
    txt_data = readtable_fast(fullfile(input_folder, files(end).name));
    dimX = [floor(params_sim.scaling_dxy_um/params_sim.scaling_dxy*min(txt_data.Centroid_1)) ceil(params_sim.scaling_dxy_um/params_sim.scaling_dxy*max(txt_data.Centroid_1))];
    dimY = [floor(params_sim.scaling_dxy_um/params_sim.scaling_dxy*min(txt_data.Centroid_2)) ceil(params_sim.scaling_dxy_um/params_sim.scaling_dxy*max(txt_data.Centroid_2))];

    maxCellLength = ceil(params_sim.scaling_dxy_um/params_sim.scaling_dxy*max(txt_data.SemiAxis1));
    sY = dimX(2)-dimX(1)+2*maxCellLength;
    sX = dimY(2)-dimY(1)+2*maxCellLength;

    if sX > 10000 || sY > 10000
        fprintf('         -> removing file "%s"...\n', files(end).name);
        files(end) = [];
    else
        containsErrors = 0;
    end
end
    
if params_sim.lastFileOnly
    % Load only last file
    filesToLoad = numel(files);
    
    data = cell(1, numel(filesToLoad));
    
    % Check how far in negative z-direction cells grow
    txt_data = readtable_fast(fullfile(input_folder, files(filesToLoad).name));
    minZ = floor(params_sim.scaling_dxy_um/params_sim.scaling_dxy * min(txt_data.Centroid_3));
else
    filesToLoad = 1:range(end);
    filesToTake = range; %1:params_sim.everyNthFile:numel(files);
    
    data = cell(1, numel(filesToLoad));
    
    % Check how far in negative z-direction cells grow
    minZ = zeros(1,numel(filesToLoad));
    parfor f = 1:numel(filesToLoad)
        i = filesToLoad(f);
        % Read data for txt-file
        txt_data = readtable_fast(fullfile(input_folder, files(i).name));
        minZ(f) = floor(params_sim.scaling_dxy_um/params_sim.scaling_dxy * min(txt_data.Centroid_3));
    end
end

updateWaitbar(handles, 0.3);
% Load files
requiredSimFields = {'Centroid_1', 'Centroid_2', 'Centroid_3',...
    'DirVector1_1', 'DirVector1_2', 'DirVector1_3',...
    'DirVector2_1', 'DirVector2_2', 'DirVector2_3',...
    'DirVector3_1', 'DirVector3_2', 'DirVector3_3',...
    'SemiAxis1', 'SemiAxis2', 'SemiAxis3', 'Previous_Parent'};

fprintf(' - loading simulation output');
h = ProgressBar(round(numel(filesToLoad)/10));
for f = 1:numel(filesToLoad)
    if ~mod(f, 10)
        h.progress;
    end
    i = filesToLoad(f);
    %fprintf('loading file %d of %d\n', i, numel(files));
    
    stats = [];
    
    % Read data for txt-file
    txt_data = readtable_fast(fullfile(input_folder, files(i).name));
    
    % Store dimensions of the current image
    data{f}.ImageSize = [sX, sY, ceil(params_sim.scaling_dxy_um/params_sim.scaling_dxy * max(txt_data.Centroid_3))+2*maxCellLength-min(minZ)];
    data{f}.NumObjects = size(txt_data,1);
    data{f}.Connectivity = 26;
    data{f}.goodObjects = true(1, size(txt_data,1));
    data{f}.Filename = files(i).name;
    data{f}.isSimulation = true;
    data{f}.params = params;
    data{f}.params_sim = params_sim;
    
    remainingFields = setdiff(txt_data.Properties.VariableNames, requiredSimFields);
    
    % Assign data
    for j = 1:size(txt_data,1)
        % Centroid is stored in pixel units
        stats(j).Centroid = params_sim.scaling_dxy_um/params_sim.scaling_dxy * [txt_data.Centroid_1(j); txt_data.Centroid_2(j); txt_data.Centroid_3(j)]' + maxCellLength/2;
        stats(j).Centroid = stats(j).Centroid - [dimX(1) dimY(1) min(minZ)];
        
        stats(j).Orientation_Matrix = [txt_data.DirVector1_1(j) txt_data.DirVector2_1(j) txt_data.DirVector3_1(j);...
            txt_data.DirVector1_2(j) txt_data.DirVector2_2(j) txt_data.DirVector3_2(j);...
            txt_data.DirVector1_3(j) txt_data.DirVector2_3(j) txt_data.DirVector3_3(j)];
        
        % All measurements are stored in µm
        stats(j).Shape_Length = params_sim.scaling_dxy_um*2*txt_data.SemiAxis1(j);
        stats(j).Shape_Height = params_sim.scaling_dxy_um*2*txt_data.SemiAxis2(j);
        stats(j).Shape_Width = params_sim.scaling_dxy_um*2*txt_data.SemiAxis3(j);
        stats(j).Shape_Volume = 4/3*pi*stats(j).Shape_Length/2*stats(j).Shape_Height/2*stats(j).Shape_Width/2;
        if ~isempty(txt_data.Previous_Parent(j))
            stats(j).Track_Parent = txt_data.Previous_Parent(j);
        else
            stats(j).Track_Parent = 0; % New cells have empty entry in Rachel's simulations!
        end
        stats(j).Track_ID = 1;
        
        % Assign remaining fields
        if ~isempty(remainingFields)
           for i = 1:numel(remainingFields)
               stats(j).(remainingFields{i}) = txt_data.(remainingFields{i})(j);
           end
        end
        
    end
    %fprintf(' - mean values: v=%g, l=%g\n', mean([stats.Shape_Volume]), mean([stats.length]));
    
    data{f}.stats = stats;
    
    % Extract timepoint
    ind = strfind(files(f).name, 'timestep');
    data{f}.timepoint = str2num(files(f).name(ind+8:end-4)) * params_sim.dt * params_sim.tau_t;
end
h.stop;

% Take only every Nth file and adjust parents
if numel(filesToTake) == 1 && filesToTake > 1
    filesToTake = [1 filesToTake];
    removeFirstDatapoint = true;
else
    removeFirstDatapoint = false;
end

data_Nth = cell(1, numel(filesToTake));
data_Nth{1} = data{1};
for f = 2:numel(filesToTake)
    i = filesToTake(f);
    
    if i > 1        
        %fprintf('processing file %d of %d\n', i, numel(files));
        
        % Link daughter cells with right parents
        currentFile = i;
        parents = [data{currentFile}.stats.Track_Parent];
        
        while currentFile > filesToTake(f-1)+1
            currentFile = currentFile - 1;
            parents_prior = [data{currentFile}.stats.Track_Parent];
            parents = parents_prior(parents);
        end
    end
    
    % Assign right parents
    data_Nth{f} = data{i};
    parents = num2cell(parents);
    [data_Nth{f}.stats.Track_Parent] = parents{:};
end
if removeFirstDatapoint
    data_Nth = data_Nth(2:end);
end
% Overwrite full data structure
data = data_Nth;

%% Generate PixelIdxLists
if params.simulation_obtainPixelIdxLists
    data = generatePixelIdxListForSimulations(handles, data, params_sim);
end

updateWaitbar(handles, 0.7);
fprintf(' - writing output');
h = ProgressBar(round(numel(data)/10));
%% Write files
if ~exist(fullfile(handles.settings.directory, 'data'), 'dir')
    mkdir(fullfile(handles.settings.directory, 'data'));
end
for i = 1:numel(data)
    filename = [data{i}.Filename(1:end-4), '_data.mat'];
    saveObjects(fullfile(handles.settings.directory, 'data', filename), data{i}, 'all', 'init', 1);
    if ~mod(i, 10)
        h.progress;
    end
    
    if checkCancelButton(handles)
        break;
    end
end
h.stop;
updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);
