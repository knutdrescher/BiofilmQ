function [imgfilter, status, params, thresh] = imagePreProcessing(hObject, eventdata, handles, f, params, range, silent, ~)

if nargin < 7
    silent = 0;
end

status = 1;
imgfilter = [];

files = handles.settings.lists.files_tif;

% Load Metadata
metadata = load(fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']));

if isfield(metadata.data, 'I_base')
    params.I_base = metadata.data.I_base;
end
if isfield(metadata.data, 'cropRange')
    params.cropRange = metadata.data.cropRange;
end
if isfield(metadata.data, 'manualThreshold')
    params.manualThreshold = metadata.data.manualThreshold;
end

if ~isfield(metadata.data, 'scaling')
    disp(' - WARNING: Scaling not stored in metadata!');
    metadata.data.scaling.dxy = params.scaling_dxy/1000;
    metadata.data.scaling.dz = params.scaling_dz/1000;
end

% Load Image
if ~silent
    displayStatus(handles,['Loading image ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    fprintf(' - loading image "%s"', files(f).name);
    ticValue = displayTime;
end


% Load Image
loaded = 0;
while ~loaded
    try
        img1raw = double(imread3D(fullfile(params.inputDirectory, files(f).name), params, 1));
        loaded = 1;
    catch err
        if strcmp(err.identifier, 'MATLAB:imagesci:tiffmexutils:libtiffError')
            error(['File: "',files(f).name, '", ', err.message])
        end
        warning(err.message);
        pause(5)
    end
end
            
   
if ~silent
    displayTime(ticValue);
end
         
% Dischard first plane
img1raw = img1raw(:,:,2:end);

if size(img1raw, 3) == 1 && strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Edge detection")
    fprintf(' - 2D image -> padding 4 slices (required for edge-detection-based segmentation\n');
    
    img1raw(:,:,2) = img1raw(:,:,1);
    img1raw(:,:,3) = img1raw(:,:,1);
    img1raw(:,:,4) = img1raw(:,:,1);
    img1raw(:,:,5) = img1raw(:,:,1);
end

% Remove floating cells by median filtering along z per plane
% (experimental)
if params.removeFloatingCells
    img1raw = removeFloatingCells(img1raw, silent);
end

if isfield(params, 'invertStack')
    if params.invertStack && size(img1raw, 3) > 1
        if ~silent
            fprintf(' - inverting stack');
        end
        img1raw = img1raw(:,:,linspace(size(img1raw,3),1,size(img1raw,3)));
    end
end

islabelImage = strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Label image") && ...
    contains(files(f).name, sprintf('_ch%d_',params.popupmenu_labelImage_Channel)); % potential error source when _ch is picked individually by users.
if ~islabelImage
    method = 'linear'; 
else
    method = 'nearest';
end

% Image registration
if params.imageRegistration
    try
        if size(img1raw, 3) == 1
            img1raw = performImageAlignment2D(img1raw, metadata, method, silent);
        else
            img1raw = performImageAlignment3D(img1raw, metadata, method, silent);
        end
    catch
        disp(['Image #',num2str(f),' is not registered!']);
        uiwait(msgbox(' - WARNING: Image is not registered! Cannot continue.', 'Error', 'error', 'modal'));
        displayStatus(handles, 'Processing cancelled!', 'red');
        updateWaitbar(handles, 0);
        status = 0;
        return;
    end
end

% Determine Kernel Size
if params.autoFilterSize
    params.kernelSize = determineFilterSize([], [], [], img1raw, params);
end

% Crop image
if ~isempty(params.cropRange)
    params.cropRangeAfterRegistration = params.cropRange;
    
    if params.imageRegistration
        correctCropRange = 0;
        
        params.cropRangeAfterRegistration(1:2) = params.cropRange(1:2);
        
        % Make sure that cropped image does not move outside the reference
        % frame
        if params.fixedOutputSize
            if params.cropRangeAfterRegistration(1) < params.registrationReferenceCropping(1)
                params.cropRangeAfterRegistration(1) = params.registrationReferenceCropping(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) < params.registrationReferenceCropping(2)
                params.cropRangeAfterRegistration(2) = params.registrationReferenceCropping(2);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(1) + params.cropRange(3) > params.registrationReferenceCropping(1) + params.registrationReferenceCropping(3)
                params.cropRangeAfterRegistration(3) = params.registrationReferenceCropping(1)+params.registrationReferenceCropping(3)-params.cropRange(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) + params.cropRange(4) > params.registrationReferenceCropping(2) + params.registrationReferenceCropping(4)
                params.cropRangeAfterRegistration(4) = params.registrationReferenceCropping(2)+params.registrationReferenceCropping(4)-params.cropRange(2);
                correctCropRange = 1;
            end
        end
       
        if params.cropRange(3)+params.cropRangeAfterRegistration(1) > size(img1raw,2)
            params.cropRangeAfterRegistration(3) = size(img1raw,1)-params.cropRangeAfterRegistration(1);
            correctCropRange = 1;
        end
        
        if params.cropRange(4)+params.cropRangeAfterRegistration(2) > size(img1raw,1)
            params.cropRangeAfterRegistration(4) = size(img1raw,1)-params.cropRangeAfterRegistration(2);
            correctCropRange = 1;
        end
        
        if correctCropRange
            fprintf(' -> WARNING: crop range was confined by image border or crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        end
    else
        
    end
    
    img1raw = img1raw(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
        params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
else
    if params.imageRegistration && params.fixedOutputSize && ~isempty(params.registrationReferenceCropping)
        params.cropRange = params.registrationReferenceCropping;
        params.cropRangeAfterRegistration = params.cropRange;
        fprintf(' -> WARNING: crop range was confined by crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        
        img1raw = img1raw(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
            params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
    end
end

if params.exportVTKafterEachProcessingStep
    fprintf(' - saving intermediated processing results\n');
    if ~exist(fullfile(handles.settings.directory, 'data'), 'dir')
        mkdir(fullfile(handles.settings.directory, 'data'));
    end
    imwrite3D(img1raw, fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_cropped.tif']));
end
    
if params.fadeBottom && strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Edge detection")
    img1raw = fadeBottom(img1raw, params, silent);
end

%%% Determine threshold if necessary
if strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Thresholding")
   [status, thresh] = determineSimpleThreshold(img1raw, params); 
else
    thresh = 0;
end


% Remove noise and resize the image
if ~silent
    displayStatus(handles, 'processing...', 'blue', 'add');
    updateWaitbar(handles, (f+0.2-range(1))/(1+range(end)-range(1)));
end



%%% if declumping method is by label, only perform interpolation
if ~islabelImage
    [imgfilter, params] = resizingAndDenoising(img1raw, metadata, params, silent);
else
    imgfilter = zInterpolation_nearest(img1raw, metadata.data.scaling.dxy, metadata.data.scaling.dz, params, silent);
end

if params.speedUpSSD
    parsave_img(fullfile(params.temp_directory_fullPath, 'img', ['img_', num2str(f), '.mat']),imgfilter, params);
end