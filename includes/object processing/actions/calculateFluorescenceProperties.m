function objects = calculateFluorescenceProperties(handles, objects, params, filename, options)
% Read options table with columns
% taskname (str); range (str); channel (int); Remove noise(bool); active(bool); binary(bool); per stack(bool);
opts = params.intensity_tasks;

if isempty(opts)
    fprintf('  -> No tasks selected!\n');
    return;
end

% Remove tasks which are not active
opts = opts([opts{:,5}], :);

if isempty(opts)
    fprintf('  -> No tasks are active!\n');
    return;
end
fprintf('\n');  

% get required binary channels
binaryData = [opts{:,6}]';

% Intensity-channels to process
personOrManders = cellfun(@(x) ~isempty(strfind(lower(x), 'mander')) || ~isempty(strfind(lower(x), 'pearson')) || ~isempty(strfind(lower(x), 'overlap')), opts(:,1));
ch_num_cell = cellfun(@(x) str2num(strrep(getChannelName(x), ' & ', ', ')), opts(~binaryData | personOrManders,3), 'UniformOutput', false);

ch_available = unique([ch_num_cell{:}]);

% constitutive channel comes first
if any(ch_available == params.channel)
    ch_available = [params.channel setdiff(ch_available, params.channel)];
end

% Binarychannels to process
ch_binary_num_cell = cellfun(@(x) str2num(strrep(x, ' & ', ', ')), opts(binaryData,3), 'UniformOutput', false);
ch_binary_available = unique([ch_binary_num_cell{:}]);

tryParentLink = 0;
if ~isempty(ch_available)
%% Prepare channels
[img_processed, background, ~, tryParentLink, params, metadata] ...
    = getImageFromRaw(handles, objects, params, filename, ch_available);
end   

%% Go through tasks
img_processed_noNoise = cell(max(ch_available), 1);
img_noBG = cell(max(ch_available), 1);
img_corr = cell(max(ch_available), 1);
obj = cell(max(ch_available), 1);
obj_nonMerged = cell(max(ch_available), 1);

% assign already loaded objects
obj{params.channel} = objects;

for task = 1:size(opts, 1)
    displayStatus(handles, sprintf('task #%d...', task), 'blue', 'add');
    fprintf(' - calculating "%s" [range: %s, channel: %s]\n', opts{task,1}, opts{task,2}, opts{task,3});
    
    % affected Channel
    ch_task = str2num(strrep(getChannelName(opts{task,3}), ' & ', ', '));
    
    % range
    try
        range = str2num(opts{task,2});
    catch
        range = [];
    end
    
    if ~opts{task,6} || personOrManders(task) % channels are not binary or binary, but requried for Pearson's or Mander's coefficient
        % remove noise if selected
        img = img_processed;
        if opts{task, 4}
            fprintf('     removing noise ');
            for ch_noise = ch_task
                fprintf(' ch %d', ch_noise);
                if isempty(img_processed_noNoise{ch_noise})
                    img_processed_noNoise{ch_noise} = convolveBySlice(img_processed{ch_noise}, params, 1); 
                else
                    fprintf(' (already done)');
                end
                img{ch_noise} = img_processed_noNoise{ch_noise};
            end

            fprintf('\n');
        end
    end
    
    if strcmpi(opts{task,1}, 'mean intensity per object')
        [objects, img_noBG] = calculateMeanIntensityPerObject(objects, img, ch_task, background, img_noBG);
        
    elseif strcmpi(opts{task,1}, 'integrated intensity per object')
        [objects, img_noBG] = calculateIntegratedIntensityPerObject(objects, img, ch_task, background, img_noBG);
        
    elseif strfind(lower(opts{task,1}), 'mean intensity ratio')
        [objects, img_noBG] = calculateFluorescenceRatio(objects, img, ch_task, background, img_noBG );
        
    elseif strfind(lower(opts{task,1}), 'integrated intensity ratio')
        [objects, img_noBG] = calculateIntegratedFluorescenceRatio(objects, img, ch_task, background, img_noBG );
        
        
    elseif strfind(lower(opts{task,1}), 'mean intensity per object-shell')
        [objects, img_noBG, img_corr] = calculateMeanIntensityPerObjectShell(objects, img, ch_task, background,  range, img_noBG, img_corr);

    elseif strfind(lower(opts{task,1}), 'integrated intensity per object-shell')
        [objects, img_noBG, img_corr] = calculateIntegratedIntensityPerObjectShell(objects, img, ch_task, background, range, img_noBG, img_corr);

    elseif  ~isempty(strfind(lower(opts{task,1}), 'vtk'))
        visualizeExtracellularFluorophores(objects, img, ch_task, opts, task, handles, filename, range);
        
    elseif strfind(lower(opts{task,1}), 'pearson')
        [objects] = calculatePearsonCorrelation(objects, img, ch_task, opts, task, range, params);
        
    elseif strfind(lower(opts{task,1}), 'mander')
        [objects, obj] = calculateMandersCorrelation(objects, img, ch_task, opts, task, handles, filename, obj, range, params);
        
    elseif strfind(lower(opts{task,1}), 'autocorrelation')
        [objects, obj] = calculateAutocorrelation(objects, filename, handles, obj, ch_task, params);
        
    elseif strfind(lower(opts{task,1}), 'density correlation of binary data')
        [objects, obj_nonMerged] = calculateDensityCorrelationBinary(objects, obj_nonMerged, ch_task, handles, filename, range);
        
    elseif strfind(lower(opts{task,1}), 'number of fluorescence foci')
        objects = calculateNumberOfFluorescenceFoci(objects, img, ch_task, range);
        
    elseif strfind(lower(opts{task,1}), '3d overlap between channels')
        objects = calculate3dOverlap(objects, img, ch_task, opts, task, handles, filename, obj);
        
    elseif strfind(lower(opts{task,1}), 'haralick')
        objects = calculateHaralickTextureFeatures(objects, img, ch_task, range);
        
    else
        warning(sprintf('The selected task "%s" is not valid', opts(task,1)));
        
    end
end

% im_temp = double(img_processed{ch})/double(max(img_processed{ch}(:)))*900;
% im_temp(bwperim(labelmatrix(objects))) = 1000;
% im_temp(localMaximaIdx) = 999;
% cmap = gray(1000);
% cmap(1000,:) = [1 0 0];
% cmap(999,:) = [0 1 0];
% zSlicer(im_temp, cmap)


% All cells which have a parent assign the intensity of the parent
if tryParentLink
    fprintf(' - Since we have a skipped frame in the channel information: try to assign parent values ...\n');
    if isfield(objects.stats, 'Track_Parent')
        fprintf(' - copying the intensity values of the parent cells existing in the previous frame\n');
        fileIndex = find( ...
                cellfun(@(x) ~isempty(x), ...
                    cellfun(@(x) strfind(x, filename), {handles.settings.lists.files_tif.name}, 'UniformOutput', false)));
        prevFrame = fileIndex-1;
        
        % Create previous filename        
        filePrev = handles.settings.lists.files_cells(prevFrame).name;
        
        objFileName = fullfile(handles.settings.directory, 'data', filePrev);
        fprintf(' - loading previous cell objects [%s] for comparison', filePrev);
        prevData = struct('objects', loadObjects(objFileName, 'stats'));
        
        % get fieldnames (intensity & correlation) which have to be taked from previous frames
        fnames = fieldnames(prevData.objects.stats);
        idx = [find(cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(lower(x), 'intensity'), fnames, 'UniformOutput', false)))...
            find(cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(lower(x), 'correlation'), fnames, 'UniformOutput', false)))...
            find(cellfun(@(x) ~isempty(x), cellfun(@(x) strfind(lower(x), 'foci'), fnames, 'UniformOutput', false)))];
        
        for i = 1:objects.NumObjects
            % Link intensity-values
            if ~isnan(objects.stats(i).Track_Parent) && objects.stats(i).Track_Parent
                for fn = 1:numel(idx)
                    objects.stats(i).(fnames{idx(fn)}) = prevData.objects.stats(objects.stats(i).Track_Parent).(fnames{idx(fn)});
                end
            end
        end
    else
        fprintf('    -> considered tracking cells first!');
    end
end


