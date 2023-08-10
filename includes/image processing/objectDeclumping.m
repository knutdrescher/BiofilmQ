function [objects, status] = objectDeclumping(handles, imgfilter, imgfilter_edge_filled, regMax, params, filebase, prevData, f, metadata)
objects = [];
status = 0;

scaling_dxy = metadata.data.scaling.dxy * 1000; % nm

% Watershedding
disp('== Object declumping ==');

%% Preparing the Map for watershedding
fprintf(' - step 1: preparing image\n');

if params.removeVoxels
    ticValue = displayTime;
    fprintf('      step 1a: removing small stuff (less than %d connected voxels)', params.removeVoxelsOfSize);
    imgfilter_edge_filled = bwareaopen(imgfilter_edge_filled, params.removeVoxelsOfSize);
    displayTime(ticValue);
end

tmp_declumpingMethod = char(handles.uicontrols.popupmenu.declumpingMethod.String(params.declumpingMethod));
if strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Label image")
    tmp_declumpingMethod = 'Labels';
end

% TODO: Delete unnecessary parameters by calculating them locally

switch tmp_declumpingMethod
    case 'Cubes'
    % Cubes
    [objects, imgfilter, ImageContentFrame] = objectDeclumping_cube( ...
        handles, params, imgfilter_edge_filled, imgfilter, prevData);


    case 'None'
    % None
   [objects, imgfilter, ImageContentFrame] = objectDeclumping_none( ...
       handles, params, imgfilter_edge_filled, imgfilter, prevData);

    case 'Watershedding'
    % Watershedding
    [objects, imgfilter, ImageContentFrame] = objectDeclumping_watershed( ... 
        handles, params, imgfilter_edge_filled, imgfilter, prevData, regMax, f);
    
    case 'seeded 3D Watershed'
    % seeded watershed 3D
    [objects, imgfilter, ImageContentFrame] = objectDeclumping_seededWatershed3D( ...
        handles, params, imgfilter_edge_filled, imgfilter, prevData, regMax);
    
    case 'Labels'
    % by labels
   [objects, imgfilter, ImageContentFrame] = objectDeclumping_labels( ...
       handles, params, imgfilter_edge_filled, imgfilter, prevData);

    
    otherwise
        error('Requested instance segmentation not implemented')
    
end

if checkCancelButton(handles)
    return;
end

%% Measure properties
ticValue = displayTime;
fprintf(' - step 6: obtain object parameters');
toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3;

%% Calculate object parameters
if objects.NumObjects > 0
    %stats = regionprops(objects, imgfilter, 'Area', 'MeanIntensity', 'Centroid', 'BoundingBox');
    stats = objects.stats;
    
    % Add third coordinate to centroids and bounding boxes if image was 2D
    if numel(objects.ImageSize)==2
        centroids = cellfun(@(x) [x 1], {stats.Centroid}, 'UniformOutput', false);
        [stats.Centroid] = centroids{:};
        boundingBoxes = cellfun(@(x) [x(1:2) 0.5 x(3:4) 1], {stats.BoundingBox}, 'UniformOutput', false);
        [stats.BoundingBox] = boundingBoxes{:};
    end
    
%     fields = fieldnames(objects.stats);
%     for u = 1:length(fields)
%        field_temp = num2cell([objects.stats.(fields{u})]);
%        [stats.(fields{u})] = field_temp{:};
%     end
    
    objects.stats = stats;
    Volume = num2cell(toUm3([objects.stats.Area], scaling_dxy)); % um
    
    [objects.stats.Shape_Volume] = Volume{:};
    
    objects.stats = rmfield(objects.stats, 'Area');
    

    % Calculate "MeanIntensity" for different gamma value
    if params.gamma ~= 1 && strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Edge detection")
        stats_temp = regionprops(objects, imgfilter.^params.gamma, 'MeanIntensity');
        stats_temp = num2cell([stats_temp.MeanIntensity]);
        [objects.stats.(strrep([sprintf('Intensity_Mean_ch%d_gamma', params.channel), num2str(params.gamma)], '.', '_'))] = stats_temp{:};
    end
    

    [objects.stats.(sprintf('Intensity_Mean_ch%d', params.channel))] = stats.MeanIntensity;
    objects.stats = rmfield(objects.stats, 'MeanIntensity');
    
    
    if strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Thresholding")
        thres = 0;
    else
        % Remove objects of average intensity below threshold
        thres = params.I_base;
    end
    meanInt = [objects.stats.(sprintf('Intensity_Mean_ch%d', params.channel))];
    goodObjects = find(meanInt>thres);
    
    % Remove bad objects;
    objects.NumObjects = numel(goodObjects);
    objects.stats = objects.stats(goodObjects);
    objects.PixelIdxList = objects.PixelIdxList(goodObjects);
    objects.goodObjects = true(numel(goodObjects), 1);
    
    displayTime(ticValue);
    
    if params.fixedOutputSize && params.imageRegistration
        objects.ImageContentFrame = ImageContentFrame;
    end
    objects.params = params;
    objects.metadata = metadata;
    % Include relative timestamp
    
else

    if params.declumpingMethod == 5
        objects.stats = struct('Shape_Volume', [], sprintf('Intensity_Mean_ch%d', params.channel), [], 'Centroid', [], 'BoundingBox', [], strrep([sprintf('Intensity_Mean_ch%d_gamma', params.channel), num2str(params.gamma)], '.', '_'), []);
    else

        objects.stats = struct('Shape_Volume', [], sprintf('Intensity_Mean_ch%d', params.channel), [], 'Centroid', [], 'BoundingBox', [], strrep([sprintf('Intensity_Mean_ch%d_gamma', params.channel), num2str(params.gamma)], '.', '_'), [], ...
            'Cube_VolumeFraction', [], 'Grid_ID', [], 'Cube_CenterCoord', []);
    end

    objects.goodObjects = [];
    
    if params.fixedOutputSize && params.imageRegistration
        objects.ImageContentFrame = ImageContentFrame;
    end
    
    objects.params = params;
    objects.metadata = metadata;
    
    displayTime(ticValue);
    warning('backtrace', 'off')
    warning('NO CELLS FOUND!');
    warning('backtrace', 'on')
end

try
    gitInfo = getGitInfo();
    objects.version.gitInfo_segmentation = gitInfo;
    objects.version.BiofilmQVersion_segmentation = fileread('biofilmQ_version.txt');
end


%% Saving variables
fprintf(' - step 7: saving variables [objects]');

filename = [filebase, '_data.mat'];

props = whos('objects');
if props.bytes*10^(-9)> 2 
    if handles.settings.showMsgs
        answer = questdlg('The data file representing your segmentation is too large to be saved efficiently. Please crop or downscale your data using the scale option. If you continue, subsequent steps of the analysis will be significantly slower.', ...
        'Data file too large', ...
        'Stop segmentation', 'Continue segmentation','Stop segmentation');

        switch answer
            case 'Stop segmentation'
                handles.uicontrols.pushbutton.pushbutton_cancel.UserData = 1;
                guidata(handles.uicontrols.pushbutton.pushbutton_cancel, handles);
                return;
            case 'Continue segmentation'
                saveObjects(filename, objects, 'all', 'init');
        end
    else
        warning('backtrace', 'off');
        warning('The data file representing your segmentation is too large to be saved!\nDo not save segmentation results of "%s" ...', filename);
        warning('backtrace', 'on');
    end
else
    saveObjects(filename, objects, 'all', 'init');
end

status = 1;
