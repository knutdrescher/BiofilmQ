
function mergeChannels(handles)
ticValueAll = displayTime;

showPopup = handles.settings.showMsgs;

params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

assert(numel(params.mergeChannel1) == 1);
assert(isnumeric(params.mergeChannel1));
assert(isnumeric(params.mergeChannel2));

range = str2num(params.action_imageRange);

files = handles.settings.lists.files_tif;


range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3;

currentChannel = params.channel;

mergeChannelArray = unique([params.mergeChannel1, params.mergeChannel2], 'stable');

N = numel(mergeChannelArray);

mergeConfirmed = false;
for f = 1:numel(range)
    i = range(f);
    ticValueImage = displayTime;
    fprintf('=========== Processing image %d of %d  ===========\n', i, numel(range));
    
    updateWaitbar(handles, (f-0.7)/numel(range));
    
    
    filename =  strrep(files(i).name, '.tif', '_data.mat');
    
    filenames = cell(N, 1);    
    for j = 1:numel(mergeChannelArray)
        filenames{j} = strrep(filename, sprintf('_ch%d', currentChannel), sprintf('_ch%d', mergeChannelArray(j)));
    end
    
    filepaths = cellfun(@(x) fullfile(handles.settings.directory, 'data', x), filenames, 'UniformOutput', false);
    
    if not(all(cellfun(@(x) exist(x, 'file') , filepaths)))
        
        showErrorMessage(...
            sprintf('The required file %s does not exist!', ...
            sprintf('"%s"\n', filepaths{cellfun(@(x) not(exist(x, 'file')) , filepaths)})), ...
            showPopup);
        continue
    end
    
    updateWaitbar(handles, (f-0.3)/numel(range));
    
    displayStatus(handles, ...
        sprintf('Loading image sets %d of %d ...', i, numel(range)), ...
        'blue');
    
    objects_cell = cell(N, 1);
    for j = 1:N
        objects_cell{j} = loadObjects(filepaths{j}, 'all');
    end
    
    displayStatus(handles, 'Done', 'blue', 'add');


    if ~mergeConfirmed
        if showPopup
            if areCubeSegmented(objects_cell)
                method_str = 'segmented with cube method';
                data_modification_str = { ...
                    'The overall image will be re-segmented with the cube method.', ...
                    'Any already calculated parameters have to be recalculated.'};
            else
                method_str = 'non-cubed data';
                data_modification_str = {...
                    'Only the object files will be merged.'};
            end

            question = { ...
                sprintf('Do you really want to merge the following files (%s)?', method_str), ...
                sprintf('\n%s%s into %s.\n', sprintf('%s, ', filenames{2:end-1}), filenames{end}, filenames{1}), ...
                data_modification_str{:}, ...
                'The original files will be copied to "data/non-merged data".'};
            
            answer = questdlg(question, ...
                'Confirm merge', ...
                'Yes','Cancel','Yes');
        else
            answer = 'Yes';
        end
        
        switch answer
            case 'Yes'
                mergeConfirmed = true;
            case 'Cancel'
                break;
        end
    end
    
    
    if areCubeSegmented(objects_cell)
        
        displayStatus(handles, 'Merging gridded data...', 'blue');
        
        objects = mergeChannelsCube(objects_cell, mergeChannelArray, objects_cell{1}.params.gridSpacing);
        
        objects.goodObjects = true(1, objects.NumObjects);
        
        Volume = num2cell(toUm3([objects.stats.Area], objects_cell{1}.params.scaling_dxy)); 
        [objects.stats.Shape_Volume] = Volume{:};
        objects.stats = rmfield(objects.stats, 'Area');
        
    else
        displayStatus(handles, 'Merging non-cubed data...', 'blue');

        try
            objects = mergeChannelsNone(objects_cell, mergeChannelArray);
        catch err
            if strfind(err.identifier, 'BiofilmQ')
                showErrorMessage(err.message , showPopup);
                continue
            else
                rethrow(err);
            end
        end
            
    end
    
    objects.params = objects_cell{1}.params;
    objects.metadata = objects_cell{1}.metadata;
    
    objects = averageObjectParameters(objects);
    objects.stats = orderfields(objects.stats);
    objects.globalMeasurements = orderfields(objects.globalMeasurements);
    
    ticValue = displayTime();
    fprintf(' -> moving original files to "data/non-merged data"');
    
    warning off;
    mkdir(fullfile(handles.settings.directory, 'data', 'non-merged data'));
    warning on;
    
    movefile(filepaths{1}, fullfile(handles.settings.directory, 'data', 'non-merged data', filenames{1}))
    for j = 2:N
        copyfile(filepaths{j}, fullfile(handles.settings.directory, 'data', 'non-merged data', filenames{j}))
    end
    displayTime(ticValue);
    
    saveObjects(filepaths{1}, objects, 'all', 'init');
    
   
    displayStatus(handles, 'Done', 'blue', 'add');
    
    if checkCancelButton(handles)
        break;
    end
    fprintf('-> total elapsed time per image')
    displayTime(ticValueImage);
end


updateWaitbar(handles, 0);

fprintf('-> total elapsed time')
displayTime(ticValueAll);
end

function all_cubed = areCubeSegmented(objects_cell)
    all_cubed = all(cellfun(@(x) isfield(x.stats, 'Grid_ID'), objects_cell));
end