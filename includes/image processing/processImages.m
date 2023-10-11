function processImages(hObject, eventdata, handles)
disp(['=========== Image processing ===========']);
ticValueAll = displayTime;
%% Walk through the files (32GB memory = 1 worker) and segment cells
% Load parameters
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

range = str2num(params.action_imageRange);

files = handles.settings.lists.files_tif;

range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

if ~exist(fullfile(handles.settings.directory, 'data'), 'dir')
    mkdir(fullfile(handles.settings.directory, 'data'));
end

if params.imageRegistration && params.fixedOutputSize && isempty(params.registrationReferenceCropping)
    uiwait(msgbox('Please setup a reference frame crop range to proceed.', 'Please note', 'help', 'modal'));
    return;
end

enableCancelButton(handles);
prevData = [];

%% Not used at the moment
if params.speedUpSSD
    if ~exist(params.tempFolder, 'dir')
        uiwait(msgbox('Temp-directory is not a valid directory!', 'Error', 'error', 'modal'));
        error('Please specify a valid temp-directory!');
    end
    
    % Create folders
    temp_directory = params.tempFolder;
    inputFolderStructure = strsplit(handles.settings.directory, filesep);
    temp_directory_fullPath = fullfile(temp_directory, inputFolderStructure{end-1}, inputFolderStructure{end});
    
    if ~exist(temp_directory_fullPath, 'dir')
        mkdir(fullfile(temp_directory_fullPath, 'img'));
        mkdir(fullfile(temp_directory_fullPath, 'raw'));
    end
    
    % Copy raw images
    % Start copying image-files
    displayStatus(handles,['Copying images into temp-folder ...'], 'blue');
    fprintf('-> copying images into temp-folder [in "%s"]\n', temp_directory_fullPath);
    
    % Get parallel pool
    count = 1;
    for i = 1:range(end)
        if ~exist(fullfile(temp_directory_fullPath, 'raw', files(i).name))
            % Start copying
            F_raw(count) = parfeval(@copyfile,1,fullfile(handles.settings.directory, files(i).name), fullfile(temp_directory_fullPath, 'raw', files(i).name));
            count = count + 1;
        end
    end
    
    params.temp_directory_fullPath = temp_directory_fullPath;
    params.inputDirectory = fullfile(temp_directory_fullPath, 'raw');
    imagePreProcessingDone = 0;
    
    if exist('F_raw')
        wait(F_raw);
    end
end
%%



for f_ind = 1:numel(range)
    try
        
        f = range(f_ind);
        
        % Select row in file table
        try
            handles.java.files_jtable.changeSelection(f-1, 0, false, false);
        end
        
        ticValueImage = displayTime;
        disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
        % Update waitbar
        updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1))+0.01);
        
        % If Temp-folder is enabled, process all images first and then continue
        % with edge detection
        if params.speedUpSSD
            if ~imagePreProcessingDone
                ticValue = displayTime;
                fprintf(' - Preparing images on SSD [in "%s"]', temp_directory_fullPath);
                h = ProgressBar(numel(range));
                parfor i = 1:numel(range)
                    f_par = range(i);
                    
                    if ~exist(fullfile(temp_directory_fullPath, 'img', ['img_', num2str(f_par), '.mat']), 'file')
                        % File was not processed, yet
                        imagePreProcessing(hObject, [], handles, f_par, params, range, 1);
                    end
                    h.progress;
                end
                h.stop;
                imgFiles = dir(fullfile(temp_directory_fullPath, 'img', 'img*.mat'));
                fprintf('      [generated data: %.1f Gb]', sum([imgFiles.bytes])/1e9)
                ticValue = displayTime(ticValue);
                imagePreProcessingDone = 1;
            end
            
            
            % Load Image
            ticValue = displayTime;
            displayStatus(handles,['Loading image ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
            fprintf(' - loading image "%s"', files(f).name);
            img = load(fullfile(temp_directory_fullPath, 'img', ['img_', num2str(f), '.mat']));
            imgfilter = img.img;
            
            img.params.I_base_perStack = params.I_base_perStack;
            params = img.params;
            
            displayTime(ticValue);
        else
            params.inputDirectory = handles.settings.directory;
            
            % Pre-Process image
            [imgfilter, status, params, thresh] = imagePreProcessing(hObject, eventdata, handles, f, params, range);
            if ~status
                break;
            end
        end
        
        % The crop range contained in the structure params after image
        % filtering includes already the image registration and can be used
        % directly
        
        % Load Metadata
        metadata_filename = fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']);
        metadata = load(metadata_filename);
        
        if params.scaleUp
            metadata.data.scaling.dxy = metadata.data.scaling.dxy/params.scaleFactor;
            metadata.data.scaling.dz = metadata.data.scaling.dxy; % after z-interpolation dxy=dz
        end
        % Update "params" which are stored inside each *_data.mat file
        params.scaling_dxy = metadata.data.scaling.dxy * 1000;
        params.scaling_dz = metadata.data.scaling.dz * 1000;   
    
        try
            params.I_base = metadata.data.I_base;
        end
        
        if params.exportVTKafterEachProcessingStep
            saveIntermediateSteps = 1;
            fprintf(' - saving intermediated processing results\n');
            imwrite3D(imgfilter, fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_filtered.tif']));
        else
            saveIntermediateSteps = 0;
        end
        
        % Detect cells
        updateWaitbar(handles, (f+0.4-range(1))/(1+range(end)-range(1)));
        
        switch char(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod))

            case 'Thresholding'
            % simple Thresholding 
            [status, imgfilter_edge_filled] = ...
                simpleThresholding(imgfilter, params, thresh);      
            case 'Edge detection'
            % edgeThresholding
            [imgfilter2, status, imgfilter_edge_filled, regMax, params] = ...
                edgeThresholding(handles, imgfilter, params, metadata, metadata_filename);
            case 'Label image'
            % label image
                handles_copy = handles;
                handles_copy.settings.lists.files_tif(f).name = strrep(handles_copy.settings.lists.files_tif(f).name , ...
                    sprintf('_ch%d', params.channel), sprintf('_ch%d', params.popupmenu_labelImage_Channel));
                [imgfilter_edge_filled, status, params, thresh] = imagePreProcessing(hObject, eventdata, handles_copy, f, params, range);
            case 'Thresholding by Slice'
            % Thresholding by Slice
                imgfilter_edge_filled = threshBySlice( ...
                    imgfilter, ...
                    params.thresholdBySliceSmoothRange, ... 
                    params.thresholdBySliceDebug);
                status = 1;

            otherwise
                error('Segmentation Method not implemented yet')
        end
        
        
        if ~exist('regMax', 'var')
            regMax = false(size(imgfilter));
            
            ticValue = displayTime;
            fprintf('- calculate local maxima');
            if params.declumpingMethod == 3
                regMax = imregionalmax(imgfilter_edge_filled .* imgfilter);
            end
            displayTime(ticValue);

        end

        if ~status
            break;
        end
        
        %%%Fill holes
        %imgfilter_edge_filled = fillGaps(imgfilter_edge_filled);
        
        if params.exportVTKafterEachProcessingStep
            fprintf(' - saving intermediated processing results\n');
            imwrite3D(imgfilter_edge_filled, fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_binary.tif']));
        end
        
        % Watershedding
        displayStatus(handles, 'segmentation...', 'blue', 'add');
        updateWaitbar(handles, (f+0.6-range(1))/(1+range(end)-range(1)));
        filebase = fullfile(handles.settings.directory, 'data', files(f).name(1:end-4));
        

        if isfield(params, 'temporalCorrection') && params.temporalCorrection && f > 1
            try
                if isempty(prevData)
                    prevFilename = fullfile(handles.settings.directory, 'data', [files(f-1).name(1:end-4), '_data.mat']);
                    if exist(prevFilename)
                        prevData.objects = loadObjects(prevFilename);
                    else
                        error;
                    end
                end
                % otherwise work with the data provided by the last
                % watershedding call
            catch
                prevData = [];
                disp(' - Temporal correction not possible!');
            end
        else
            prevData = [];
        end

        
        [prevData.objects, status] = objectDeclumping(handles, imgfilter, imgfilter_edge_filled, regMax, params, filebase, prevData, f, metadata);
        
        if params.exportVTKafterEachProcessingStep
            fprintf(' - saving intermediated processing results\n');
            imwrite3D(labelmatrix(prevData.objects), fullfile(handles.settings.directory, 'data', [files(f).name(1:end-4), '_segmented.tif']));
        end
        
        if ~status
            break;
        end
        
        displayStatus(handles, 'Done', 'blue', 'add');
        
        fprintf('-> total elapsed time per image')
        displayTime(ticValueImage);
        
        % Check if cell number is reached
        if params.stopProcessingNCellsMax
            if prevData.objects.NumObjects > params.NCellsMax
                fprintf('-> max number of cells reached (Nmax = %d)-> stopping segmentation.\n', params.NCellsMax);
                break;
            end
        end
    catch err
        warning('backtrace', 'off')
        fprintf('\n');
        warning(err.message);
        warning('backtrace', 'on')
    end
end

% if params.sendEmail
%     email_to = get(handles.uicontrols.edit.email_to, 'String');
%     email_from = get(handles.uicontrols.edit.email_from, 'String');
%     email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
%
%     setpref('Internet','E_mail',email_from);
%     setpref('Internet','SMTP_Server',email_smtp);
%
%     sendmail(email_to,['[Biofilm Toolbox] Segmentation finished: "', handles.settings.directory, '"']', ...
%         ['Segmentation of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
% end

updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);
