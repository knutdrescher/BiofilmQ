function [img_processed, background, img_raw, tryParentLink, params, metadata] ...
    = getImageFromRaw(handles, objects, params, filename, ch_available)

%% Prepare channels
    img_raw = cell(max(ch_available), 1);
    img_processed = cell(max(ch_available), 1);
    background = zeros(max(ch_available), 1);
    
    % Remember size in case the other channel needs adaption
    if isfield(objects, 'ImageContentFrame')
        imSize = [objects.ImageContentFrame(2)-objects.ImageContentFrame(1)+1,...
            objects.ImageContentFrame(4)-objects.ImageContentFrame(3)+1,...
            objects.ImageSize(3)];
    else
        imSize = objects.ImageSize;
    end
    
    if numel(imSize) == 2
        imSize(3) = 1;
    end
    
    %% go through channels
    
    tryParentLink = 0;
    for ch = ch_available
        fprintf(' - preparing image ch %d\n', ch);
        
        % Contructing filename of file to load
        if ch ~= params.channel
            filename_currentCh = strrep(filename, sprintf('_ch%d', params.channel), sprintf('_ch%d', ch));
        else
            filename_currentCh = filename; % potantially pitfall
        end
        
        % Load metadata
        try
            params = objects.params;
        end
        metadata = load(fullfile(handles.settings.directory, [filename_currentCh(1:end-4), '_metadata.mat']));
        
        
        if ~isfield(params, 'cropRangeAfterRegistration')
            params.cropRangeAfterRegistration = [];
        end
        
        if ~isfield(metadata.data, 'scaling')
            disp(' - WARNING: Scaling not stored in metadata!');
            metadata.data.scaling.dxy = params.scaling_dxy;
            metadata.data.scaling.dz = params.scaling_dz;
        else
            metadata.data.scaling.dxy = metadata.data.scaling.dxy*1000;
            metadata.data.scaling.dz = metadata.data.scaling.dz*1000;
        end
        
        % Load Image
        displayStatus(handles,['Loading image ',filename_currentCh,'...'], 'blue');
        fprintf(' - loading image [%s]', filename_currentCh);
        img_raw{ch} = imread3D(fullfile(handles.settings.directory, filename_currentCh), params);
        
        % Forward fill channel (in case frame was skipped during acquisition)
        if ch ~= params.channel % if channel is not constitutive channel
            
            filename_2ndCh_prev = filename_currentCh;            
            % condition: 1px image and metadata.data marks it as 'frameSkipped'
            while size(img_raw{ch}, 1) == 1 && isfield(metadata.data, 'frameSkipped')
                
                frameInd = strfind(filename_2ndCh_prev, '_frame');
                currentFrame = str2num(filename_2ndCh_prev(frameInd+6:frameInd+11))-1;
                fprintf('    - image in %d not aquired, loading previous frame (#%d) instead', ch, currentFrame)
                % Create previous filename
                filename_2ndCh_prev = strrep(filename_currentCh, filename_currentCh(frameInd+6:frameInd+11), num2str(currentFrame, '%06d'));
                % lookup image based on frame/ pos string/ channel information (Nz is unknown)
                filePrev = dir(fullfile(handles.settings.directory, [filename_2ndCh_prev(1:frameInd+11), '*.tif']));
                img_raw{ch} = imread3D(fullfile(handles.settings.directory, filePrev(1).name), params);
                
                tryParentLink = 1;
            end
        end
        
        % Dischard first plane
        img_raw{ch} = img_raw{ch}(:,:,2:end);
        
        background(ch) = double(prctile(img_raw{ch}(:), 30));
        fprintf('     background: %d\n', background(ch)); 
        
        % Make 2D -> 3D
        if size(img_raw{ch}, 3) == 1 && strcmp(handles.uicontrols.popupmenu.segmentationMethod.String(params.segmentationMethod), "Edge detection")
            img_raw{ch}(:, :, 2:5) = repmat(img_raw{ch}(:,:,1), 1, 1, 4);
        end
        
        % Image registration
        if params.imageRegistration
            try
                if numel(size(img_raw{ch}))==2
                    img_raw{ch} = performImageAlignment2D(img_raw{ch}, metadata);
                else
                    img_raw{ch} = performImageAlignment3D(img_raw{ch}, metadata);
                end
            catch
                uiwait(msgbox('Image is not registered! Cannot continue.', 'Error', 'error'));
                displayStatus(handles, 'Processing cancelled!', 'red');
                updateWaitbar(handles, 0);
                set(handles.uicontrols.pushbutton.pushbutton_cancel, 'UserData', 0);
                return;
            end
        end
        
        % Invert image
        if isfield(params, 'invertStack')
            if params.invertStack && imSize(3) > 1
                img_raw{ch} = img_raw{ch}(:,:,size(img_raw{ch},3):-1:1);
            end
        end
        
        % Crop image
        if ~params.imageRegistration
            if ~isempty(params.cropRange)
                img_raw{ch} = img_raw{ch}(params.cropRange(2):params.cropRange(2)+params.cropRange(4), ...
                    params.cropRange(1):params.cropRange(1)+params.cropRange(3),:);
            end
        else
            if ~isempty(params.cropRangeAfterRegistration)
                
                img_raw{ch} = img_raw{ch}(...
                    params.cropRangeAfterRegistration(2) ...
                    : params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
                    params.cropRangeAfterRegistration(1) ...
                    : params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),...
                    :);
            end
        end
        
        % Remove noise and resize the image
        displayStatus(handles, 'processing...', 'blue', 'add');
        
        % Process image
        if imSize(3) > 1
            % z-Interpolation
            dxy = metadata.data.scaling.dxy;  %nm;
            dz = metadata.data.scaling.dz; %nm;
            img_processed{ch} = zInterpolation(img_raw{ch}, dxy, dz, params, 1);

            % Rotate image
            if params.rotateImage
                img_processed{ch}  = rotateBiofilmImg(img_processed{ch}, params);
            end

            % Remove bottom
            if params.removeBottomSlices && params.removeBottomSlices < size(img_processed{ch}, 3)
                img_processed{ch}(:,:,1:params.removeBottomSlices) = [];
            end
        else
            img_processed{ch} = img_raw{ch};
        end
        
        % If volume height does not match, adapt
        if size(img_processed{ch}, 3) < imSize(3)
            img_processed{ch} = padarray(img_processed{ch}, [0 0 imSize(3)-size(img_processed{ch}, 3)], 'replicate', 'post');
            fprintf('       - enlarging image\n');
        end
        if size(img_processed{ch}, 3) > imSize(3)
            img_processed{ch} = img_processed{ch}(:,:, 1:imSize(3));
            fprintf('       - shrinking image\n');
        end
              
        % Reference frame padding in x/y
        if params.fixedOutputSize && params.imageRegistration
            img_processed{ch} = applyReferencePadding(params, img_processed{ch});
        end
    end