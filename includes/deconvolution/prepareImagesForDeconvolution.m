function prepareImagesForDeconvolution(handles, varargin)

output_folder = fullfile(handles.settings.directory, 'deconvolved images');

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
files = handles.settings.listsAll.files_tif;

if nargin == 2
    params = varargin{1};
    
    wavelengths = params.huygens_wavelengths;
    range_per_channel  = str2num(params.action_imageRange);
    
    filesFeatures = cellfun(@(x) getFeaturesFromName(x), {files.name});
    files_channel = [filesFeatures.channel];
    
    channels = {};
    is_file_to_deconvolve = false(1, numel(files));
    for k = 1:size(wavelengths,1)
        if wavelengths{k,3}
            channels = {channels{1:end}, sprintf('ch%d', k)};
            files_in_channel = find(files_channel == k);
            range_per_channel = intersect(range_per_channel, 1:numel(files_in_channel));
            files_in_channel = files_in_channel(range_per_channel);
            is_file_to_deconvolve(files_in_channel) = true;
        end
    end
    files = files(is_file_to_deconvolve);
end

decon_files = dir(fullfile(output_folder, '*_cmle.tif'));
true_files = dir(fullfile(output_folder, '*.tif'));

if numel(files) == numel(decon_files)
   for i = 1:numel(decon_files) 
      delete(fullfile(decon_files(i).folder, decon_files(i).name)); 
   end
   delete(fullfile(decon_files(i).folder, '*.txt'));
   delete(fullfile(decon_files(i).folder, '*.hgsb'));
   delete(fullfile(decon_files(i).folder, '*.log'));
   fprintf('    - > deconvolution folder cleaned up\n');
   
   %return;
   
end

decon_files = dir(fullfile(output_folder, '*_cmle.tif'));

if numel(true_files) > 0 && numel(true_files) == numel(decon_files)
   fprintf('    - > all files in folder are already deconvolved\n');
   
   return;
end

%% Copy images into folder "for deconvolution"
ticValue = displayTime;

enableCancelButton(handles);
updateWaitbar(handles, 0.05)
fprintf(' - preparing images for deconvolution ');
displayStatus(handles, 'Preparing images for deconvolution...', 'black');
textprogressbar('      ');

textprogressbar(0);
bytes = cumsum([files.bytes]);

for i = 1:numel(files)
    files(i).folder = strrep(output_folder, '\', '/');
    if exist(fullfile(handles.settings.directory, 'deconvolved images', files(i).name), 'file')
        continue;
    end
    % Check if the image contain one of the required channels
    hasChannel = @(x) contains(files(i).name,x); 
    if sum(cellfun(hasChannel, channels))==0
        continue;
    end
    
    im = imread3D(fullfile(handles.settings.directory, files(i).name), [], 1);
    
    im(:,:,1) = [];
    
    imwrite3D(im, fullfile(output_folder, files(i).name), [], 1);
    
    textprogressbar(bytes(i)/bytes(end)*100);
    updateWaitbar(handles, i/numel(files))
    
    if checkCancelButton(handles)
        return;
    end
end

displayStatus(handles, 'Done', 'black', 'add');
textprogressbar(100);
textprogressbar(' Done.');
displayTime(ticValue);

%% Create batch file
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;
fprintf(' - creating batch file\n');
ticValue = displayTime;
fileName = generateHuygensBatchFile(files, output_folder, params);
displayTime(ticValue);
updateWaitbar(handles, 0)
%% Alternative:
% Create OME-tiff with proper metadata
