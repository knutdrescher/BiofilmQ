
function transferSegmentation(handles)
ticValueAll = displayTime;

showPopup = handles.settings.showMsgs;

params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

assert(numel(params.mergeChannel2) == 1);
assert(isnumeric(params.mergeChannel1));
assert(isnumeric(params.mergeChannel2));

range = str2num(params.action_imageRange);

files = handles.settings.lists.files_tif;


range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

currentChannel = params.channel;

sourceChannel = params.transferChannel2;
destChannels = unique(params.transferChannel1, 'stable');

N = numel(destChannels);


if ~exist(fullfile(handles.settings.directory, 'data', 'backup_transfer'), 'dir')
    mkdir(fullfile(handles.settings.directory, 'data', 'backup_transfer'));
end
    
for f = 1:numel(range)
    i = range(f);
    ticValueImage = displayTime;
    fprintf('=========== Processing image %d of %d  ===========\n', i, numel(range));
    
    updateWaitbar(handles, (f-0.7)/numel(range));
    
    
    filename =  strrep(files(i).name, '.tif', '_data.mat');
    
    filename_source = strrep(filename, sprintf('_ch%d', currentChannel), sprintf('_ch%d', sourceChannel));
    
    if ~exist(fullfile(handles.settings.directory, 'data', filename_source), 'file')
                showErrorMessage(...
            sprintf('The required file %s does not exist!', fullfile(handles.settings.directory, 'data', filename_source)), ...
            showPopup);
        continue
    end
    
    
    updateWaitbar(handles, (f-0.3)/numel(range));
    
    displayStatus(handles, ...
        sprintf('Loading image sets %d of %d ...', i, numel(range)), ...
        'blue');
    

    for j = 1:N
        filename_dest = strrep(filename, sprintf('_ch%d', currentChannel), sprintf('_ch%d', destChannels(j)));
        if exist(fullfile(handles.settings.directory, 'data', filename_dest), 'file')
            copyfile(fullfile(handles.settings.directory, 'data', filename_dest), fullfile(handles.settings.directory, 'data','backup_transfer', filename_dest));
                ticValue = displayTime();
                fprintf(' -> moving original files to "data/backup_transfer"');
        end
        copyfile(fullfile(handles.settings.directory, 'data', filename_source), fullfile(handles.settings.directory, 'data', filename_dest));
    end
    
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