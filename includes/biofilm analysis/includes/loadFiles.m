function [handles, status, biofilmData] = loadFiles(hObject, eventdata, handles)
%% Load files
% Define input folder
ticValue = displayTime;
status = 0;

input_folder = handles.settings.directory;

if ~exist(fullfile(input_folder, 'data'))
    uiwait(msgbox('Images are not segmented, yet.', 'Error', 'error', 'modal'));
    return;
end

NChannel = numel(handles.handles_analysis.uicontrols.popupmenu.channel.String);

if NChannel == 1
    cells = dir(fullfile(input_folder, 'data', '*_data.mat'));
    channel = 1;
else
    channel = handles.handles_analysis.uicontrols.popupmenu.channel.Value;
    cells = dir(fullfile(input_folder, 'data', sprintf('*_ch%d*_data.mat', channel)));
end

[~, idx] = sort_nat({cells.name});

cells = cells(idx);

params = load(fullfile(input_folder, 'parameters.mat'));
params = params.params;

if isempty(cells)
    if handles.settings.showMsgs
        uiwait(msgbox('Images are not segmented, yet.', 'Error', 'error', 'modal'));
    else
        error('Images are not segmented, yet.');
    end
    
    return;
end

enableCancelButton(handles);
updateWaitbar(handles, 1/100)

if handles.handles_analysis.uicontrols.checkbox.loadMaxFrame.Value
    Nmax = str2num(handles.handles_analysis.uicontrols.edit.maxNCells.String);
    t_max = min([length(cells), str2num(handles.handles_analysis.uicontrols.edit.maxFrameToLoad.String)]);
else
    Nmax = [];
    t_max = length(cells) ;
end
timeStamps = ones(t_max, 1);

if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    selTime = get(handles.handles_analysis.uicontrols.popupmenu.refTimepointFile, 'Value');
    entries = get(handles.handles_analysis.uicontrols.popupmenu.refTimepointFile, 'String');
    refTimepoint = entries{selTime};
    refData = load(refTimepoint);
    
    assert(isdatetime(refData.data.date))
    
    time_temp = datetime([params.files{1,4}, ' ' , params.files{1,2}], 'InputFormat', 'dd.MM.yyyy HH:mm:ss'); % Very dirty hack
    timeShift = seconds(time_temp - refData.data.date);
    
    fprintf('        timeshift to reference frame: %.2f h\n', timeShift/60/60);
else
    timeShift = 0;
end

try
    timeStampsCell = cellfun(@(x, y) sprintf('%s %s', x, y), params.files(:,4), params.files(:,2), 'UniformOutput', false);
    for k = 1:t_max
        try
            time_temp = datetime(timeStampsCell{k}, 'InputFormat', 'dd.MM.yyyy HH:mm:ss');
            timeStamps(k) = seconds(time_temp);
        catch
            timeStamps(k) = 0;
        end
    end
    searchForTimestampInFile = false;
catch
    searchForTimestampInFile = true;
    fprintf(' - using default time points\n');
end

Mbytes = cumsum([cells.bytes]/1024/1024);

loadFields = {'globalMeasurements', 'stats', 'metadata', 'timepoint'};
if get(handles.handles_analysis.uicontrols.checkbox.loadPixelIdxLists, 'Value')
    loadFields = [loadFields, 'PixelIdxList'];
end


fprintf('        loading %d files [size: %.1f Gb]', t_max, Mbytes(t_max)/1024);
h = ProgressBar(t_max);

dataArray = linspace(0,Mbytes(t_max), t_max);
dataArrayP = dataArray;

data_struct = [];
toUm = @(voxel, scaling) voxel.*scaling/1000;

timepoints = zeros(1, t_max);
toRemove= [];
for k = 1:t_max
    data = loadObjects(fullfile(input_folder, 'data', cells(k).name), loadFields, 1);
    
    % Calculate additional data  (single cell)
    NCells = numel(data.goodObjects);
    
    if isfield(data, 'metadata')
        metadata = data.metadata;
    else
        try
        metadata = load(fullfile(input_folder, strrep(cells(k).name, '_data.mat', '_metadata.mat')));
        end
    end
    
    % Try to overwrite timepoints by timepoints in metadata stored in
    % object file
    try
        datetime_ = datetime(metadata.data.date);
    catch
        datetime_ = datetime('now', 'Format', 'dd-MMM-yyyy HH:mm:ss');
    end
    
    if k == 1
        startDateTime = datetime_;
    end
    
    duration_ = datetime_ - startDateTime;
     
    timeStamps(k) = seconds(duration_); 
    
    timepointPerCell = num2cell(repmat(hours(duration_), 1, NCells)); % hours
    
    if searchForTimestampInFile
        try
            timepointPerCell = num2cell(repmat(data.timepoint/60/60, 1, NCells));
            timepoints(k) = data.timepoint;
        end
    end
    
    cellNumberPerCell = num2cell(repmat(NCells, 1, NCells));
    framePerCell = num2cell(repmat(k, 1, NCells));
    if NCells > 0
        try
            Distance_FromSubstrate = num2cell(toUm(cellfun(@(x) x(3), {data.stats.Centroid}), data.metadata.data.scaling.dxy*1000));
        catch
            Distance_FromSubstrate = num2cell(toUm(cellfun(@(x) x(3), {data.stats.Centroid}), data.params.scaling_dxy));
        end
        
        x = num2cell(cellfun(@(x) x(1), {data.stats.Centroid}));
        y = num2cell(cellfun(@(x) x(2), {data.stats.Centroid}));
        z = num2cell(cellfun(@(x) x(3), {data.stats.Centroid}));
        
        [data.stats.Time] = timepointPerCell{:};
        [data.stats.Cell_Number] = cellNumberPerCell{:};
        [data.stats.Frame] = framePerCell{:};
        [data.stats.Distance_FromSubstrate] = Distance_FromSubstrate{:};
        [data.stats.CentroidCoordinate_x] = x{:};
        [data.stats.CentroidCoordinate_y] = y{:};
        [data.stats.CentroidCoordinate_z] = z{:};
    else
        [data.stats.time] = NaN;
        [data.stats.cell_number] = NaN;
        [data.stats.frame] = NaN;
        [data.stats.Distance_FromSubstrate] = NaN;
        [data.stats.CentroidCoordinate_x] = NaN;
        [data.stats.CentroidCoordinate_y] = NaN;
        [data.stats.CentroidCoordinate_z] = NaN;
    end
    
    % Calculate additional data  (global)
    data.globalMeasurements.Cell_Number = NCells;
    data.globalMeasurements.Time = timeStamps(k)/60/60;
    data.globalMeasurements.Frame = k;
    
    fNames = sort(setdiff(fieldnames(data), 'Connectivity'));
    for f = 1:numel(fNames)
        data_struct(k).Filename = cells(k).name;
        data_struct(k).Size = Mbytes(k);
        data_struct(k).timeStamp = timeStamps(k);
        data_struct(k).(fNames{f}) = data.(fNames{f});
    end
    
    steps = find(Mbytes(k) > dataArray);
    dataArray(steps) = [];
    
    for s = 1:numel(steps)
        h.progress;
    end
    
    status = find(Mbytes(k) >= dataArrayP);
    updateWaitbar(handles, numel(status)/t_max)
    
    if ~isempty(Nmax)
        if sum(data.goodObjects) > Nmax
            break;
        end
    end
    
    if checkCancelButton(handles)
        break;
    end
end

if searchForTimestampInFile
    timepoints = timepoints';
else
    timepoints = timeStamps(1:k);
end

clear data;
h.stop;

if ~isempty(Nmax)
    fprintf('        loaded files: %d, max. cells (%d/%d)\n', k, sum(data_struct(k).goodObjects), Nmax);
else
    fprintf('        loaded files: %d, max. cells (%d)\n', k, sum(data_struct(k).goodObjects));
end

% Display loaded fields
fprintf('        fields: [');
for f = 1:numel(loadFields)-1
    fprintf('%s, ', loadFields{f});
end
fprintf('%s]', loadFields{end});

% Prepare structure
biofilmData = struct('data', data_struct', 'timepoints', timepoints, 'timeShift', timeShift, 'params', params);
assignin('base', 'biofilmData', biofilmData);

if get(handles.handles_analysis.uicontrols.checkbox.loadPixelIdxLists, 'Value')
    volumetricInformation = 'Yes';
else
    volumetricInformation = 'No';
end

handles.handles_analysis.uicontrols.text.text_dataDetails.String = {sprintf('Files loaded: %d (%.2f Gb)', numel(biofilmData.data), Mbytes(k)/1000),...
    sprintf('Max number of cells: %d', max(cellfun(@sum, {data_struct.goodObjects}))),...
    sprintf('Fluorescence channel: %d', channel),...
    sprintf('Timeshift due to reference timepoint: %.2f h', timeShift/60/60),...
    sprintf('Volumetric information loaded: %s', volumetricInformation)};

range_new = assembleImageRange(1:k);
handles.uicontrols.edit.visualization_imageRange.String = num2str(range_new);

updateWaitbar(handles, 0)

displayTime(ticValue);
status = 1;

