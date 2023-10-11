function registerImages(hObject, eventdata, handles)
%% Walk through the files (32GB memory = 1 worker) and segment cells
%parfor (f = 1:length(files), 2)

disp(['=========== Image registration ===========']);
% Load parameters
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

% get reference frame
referenceFrame = params.registrationReferenceFrame;

range = str2num(get(handles.uicontrols.edit.action_imageRange, 'String'));
colors = colormap(parula(numel(range)));

range(find(range==referenceFrame)) = [];

rangInd = find(range<referenceFrame);

if numel(range) == 1
    range = [referenceFrame, range];
else
    if min(range) < referenceFrame
        range = [referenceFrame, range(rangInd(end)+1:end), referenceFrame, range(sort(rangInd, 'Descend'))];
    else
        range = [referenceFrame, range];
    end
end

scale = 1;

files = handles.settings.lists.files_tif;

if referenceFrame < 1 || referenceFrame > numel(files)
    uiwait(msgbox(sprintf('Reference frame with index #%d is not existing!', referenceFrame), 'Cancelling...', 'error'));
    return;
end

[~, inputFolder] = fileparts(get(handles.uicontrols.edit.inputFolder, 'String'));
h = figure('Name', sprintf('Registration: %s', inputFolder));
h_ax = axes('Parent', h);

plot3(h_ax, 0,0,0, 'o');
set(h_ax, 'NextPlot', 'add');
xlabel('x (px)'); ylabel('y (px)'); zlabel('z (px)');
title(sprintf('Translation of %s', inputFolder),  'Interpreter', 'none');

% Loading the first image and extract the bright plane
%fprintf(' - extracting the first slice of the reference frame [#%d]\n', referenceFrame);
%displayStatus(handles, 'Extracting index of first slice', 'black');

%img1 = imread3D(fullfile(handles.settings.directory, files(referenceFrame).name));
%img1 = img1(:,:,2:end);

%imSize = size(img1);

%[~, maxValInd] = max(sum(sum(img1,1),2));

%disp(['    - first slice: ', num2str(maxValInd)]);
%displayStatus(handles, [' -> ',num2str(maxValInd)], 'black', 'add');

% Initializing optimizer metric
[optimizer, metric] = imregconfig('monomodal');
%metric = registration.metric.MattesMutualInformation();

translations = [];

% try reading the first 30 slices
slicesRead = 40;

enableCancelButton(handles);

for j = 1:numel(range)
    f = range(j);
    handles.java.files_jtable.changeSelection(f-1, 0, false, false);
    
    disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    % Update waitbar
    updateWaitbar(handles, (j+0.1-1)/(numel(range)));
    
    % Load Metadata
    metadata = load(fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']));
    
    % Load Image
    displayStatus(handles,['Loading image ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    
    if f ~= referenceFrame
        img_fixed = img_moving;
        img_fixed_zx = img_zx;
        img_fixed_zy = img_zy;
    end
    
    % try reading
    %img_moving = imread(fullfile(handles.settings.directory, files(f).name), maxValInd);
    
    
    %img_moving = zeros(imSize(1), imSize(2), slicesRead);
    img_moving_stack = [];
    for i = 2:slicesRead
        try
            img_moving_stack(:,:,i-1) = imread(fullfile(handles.settings.directory, files(f).name), i);
            %counter = counter + 1;
        catch
            break;
        end
    end
    
    %Load the projection
    img_moving = imread(fullfile(handles.settings.directory, files(f).name), 1);
    
%     try
%         thresh = multithresh(img_moving);
%         objects = regionprops(bwconncomp(bwareaopen(img_moving>thresh, 20)));
%         coords = [objects.Centroid];
%         ind = floor(numel(objects)/2);
%         x = coords(1:2:end);
%         y = coords(2:2:end);
%         x = round(x(ind));
%         y = round(y(ind));
%     catch
       % [x, y] = findpeak(squeeze(sum(img_moving_stack, 3)), 0);
%    end
    
    if f == referenceFrame
        % make cross section images
        %img_zx = squeeze(img_moving_stack(:, x, :));
        %img_zy = squeeze(img_moving_stack(y, :, :));
        
        img_zx = squeeze(sum(img_moving_stack,2));
        img_zy = squeeze(sum(img_moving_stack,1));
        
        % weighting images (less weight for higher z-planes, linear decrease)
%         for z = 1:size(img_zx, 2)
%             if z >= maxValInd-1
%                 img_zx(:,z) = 1/(1+0.05*(z-maxValInd+1))*img_zx(:,z);
%                 img_zy(:,z) = 1/(1+0.05*(z-maxValInd+1))*img_zy(:,z);
%             else
%                 img_zx(:,z) = 1/(1+0.05*abs(z-maxValInd))*img_zx(:,z);
%                 img_zy(:,z) = 1/(1+0.05*abs(z-maxValInd))*img_zy(:,z);
%             end
%         end
    end
    
    %     img_moving = imread3D(fullfile(handles.settings.directory, files(f).name)); %imread(fullfile(handles.settings.directory, files(f).name), maxValInd);
    %     img_moving = img_moving(:,:,2:end);
    %     if size(img_moving, 3) < 16
    %         img_moving = padarray(img_moving, [0 0 16-size(img_moving, 3)], 'replicate', 'post');
    %         fprintf('       - enlarging image\n');
    %     end
    
    % Plan: Read fist 30 slices and than make two registrations, crosswise and
    % take the mean value
    
    if f ~= referenceFrame
        %moving and fixed
        displayStatus(handles,['registering...'], 'blue', 'add');
        fprintf(' - registering images, along xy');
        ticValue = displayTime;
        imshowpair(img_fixed,img_moving, 'Parent',handles.axes.axes_preview);
        text(1,1, ' registration: along xy', 'Parent', handles.axes.axes_preview, 'VerticalAlignment', 'top', 'Color', 'r');
        drawnow;
        
        switch params.registrationMethod
            case 1
                fprintf(' [method: full correlation]');
                
                usfac = 10;
                output = dftregistration(fft2(single(img_fixed)),fft2(single(img_moving)),usfac);
                
                tform_xy = affine2d;
                tform_xy.T(3,1:2) = [output(4), output(3)];
                
            case 2
                fprintf(' [method: MeanSquares]');
                tform_xy = imregtform(img_moving, img_fixed, 'translation', optimizer, metric);
        end
        
        
        % Save data temporarly for registration along z
        tform = affine3d;
        tform.T(4,1:2) = tform_xy.T(3,1:2) + translations(range(j-1),1:2);
        tform.T(4,3) = 0;
        metadata.data.registration = tform;
        ticValue = displayTime(ticValue);
        
        updateWaitbar(handles, (j+0.4-1)/(numel(range)));
        
        if params.alignZ
            
            ticValue = displayTime;
            % Calculate the registration for the cross sections
            img_moving_stack_aligned = performImageAlignment2D(img_moving_stack, metadata, 'linear', 0);
           
            
            sZ = size(img_moving_stack_aligned,3);

            img_zx = squeeze(sum(img_moving_stack_aligned,2));
            img_zy = squeeze(sum(img_moving_stack_aligned,1));
            
            % Adapt number of z-slices to the one with the lowerst number
            minZ = min([size(img_zx, 2) size(img_fixed_zx, 2)]);
            
            
            img_zx_corr = img_zx(:,1:minZ);
            img_fixed_zx_corr = img_fixed_zx(:,1:minZ);
            
            img_zy_corr = img_zy(:,1:minZ);
            img_fixed_zy_corr = img_fixed_zy(:,1:minZ);
            
            fprintf('                       along zx');
            try
                imshowpair(img_fixed_zx,img_zx, 'Parent',handles.axes.axes_preview);
                axis(handles.axes.axes_preview, 'square')
                text(1,1, ' registration: along zx', 'Parent', handles.axes.axes_preview, 'VerticalAlignment', 'top', 'Color', 'r');
                drawnow;

                usfac = 100;
                output = dftregistration(fft2(single(img_fixed_zx_corr)),fft2(single(img_zx_corr)),usfac);
                
                tform_zx = affine2d;
                tform_zx.T(3,1:2) = [output(4), 0];
                
                
                
                
                
%                 % Moving the images
%                 zShift = -5:5;
%                 zShiftFine = -5:0.01:5;
%                 zScore = zeros(numel(zShift, 1));
%                 for zIdx = 1:numel(zShift)
%                     z = zShift(zIdx);
%                     
%                     if z < 0
%                         img_moving_z = padarray(img_zx_corr,[0, abs(z)],'replicate','post');
%                         img_fixed_z = padarray(img_fixed_zx_corr,[0, abs(z)],'replicate','pre');
%                     end
%                     
%                     if z > 0
%                         img_moving_z = padarray(img_zx_corr,[0, abs(z)],'replicate','pre');
%                         img_fixed_z = padarray(img_fixed_zx_corr,[0, abs(z)],'replicate','post');
%                     end
%                     
%                     if z == 0
%                         img_moving_z = img_zx_corr;
%                         img_fixed_z = img_fixed_zx_corr;
%                     end
%                     zScore(zIdx) = pearson_coeff(img_moving_z, img_fixed_z);
%                 end
%                 fitresult = smoothingSpline(zShift, zScore, 0.9);
%                 [~, zMaxIdx] = max(fitresult(zShiftFine));
%                 tform_zx.T(3,1:2) = [zShiftFine(zMaxIdx), 0];
                
                if tform_zx.T(3,1) > 4
                    fprintf(' (cannot be determined)');
                    tform_zx.T(3,1) = 4;
                end
                if tform_zx.T(3,1) < -4
                    fprintf(' (cannot be determined)');
                    tform_zx.T(3,1) = -4;
                end
                
                
            catch
                tform_zx = affine2d;
            end
            
            
            updateWaitbar(handles, (j+0.6-1)/(numel(range)));
            
            fprintf(', along zy');
            try
                imshowpair(img_fixed_zy,img_zy, 'Parent',handles.axes.axes_preview);
                axis(handles.axes.axes_preview, 'square')
                text(1,1, ' registration: along zy', 'Parent', handles.axes.axes_preview, 'VerticalAlignment', 'top', 'Color', 'r');
                drawnow;

                usfac = 100;
                output = dftregistration(fft2(single(img_fixed_zy_corr)),fft2(single(img_zy_corr)),usfac);
                
                tform_zy = affine2d;
                tform_zy.T(3,1:2) = [output(4), 0];
%                 
%                 % Moving the images
%                 zShift = -5:5;
%                 zShiftFine = -5:0.01:5;
%                 zScore = zeros(numel(zShift, 1));
%                 for zIdx = 1:numel(zShift)
%                     z = zShift(zIdx);
%                     
%                     if z < 0
%                         img_moving_z = padarray(img_zy_corr,[0, abs(z)],'replicate','post');
%                         img_fixed_z = padarray(img_fixed_zy_corr,[0, abs(z)],'replicate','pre');
%                     end
%                     
%                     if z > 0
%                         img_moving_z = padarray(img_zy_corr,[0, abs(z)],'replicate','pre');
%                         img_fixed_z = padarray(img_fixed_zy_corr,[0, abs(z)],'replicate','post');
%                     end
%                     
%                     if z == 0
%                         img_moving_z = img_zy_corr;
%                         img_fixed_z = img_fixed_zy_corr;
%                     end
%                     zScore(zIdx) = pearson_coeff(img_moving_z, img_fixed_z);
%                 end
%                 fitresult = smoothingSpline(zShift, zScore, 0.9);
%                 [~, zMaxIdx] = max(fitresult(zShiftFine));
%                 tform_zy.T(3,1:2) = [zShiftFine(zMaxIdx), 0];
                
                if tform_zy.T(3,1) > 4 
                    fprintf(' (cannot be determined)');
                    tform_zy.T(3,1) = 4;
                end
                if tform_zy.T(3,1) < -4
                    fprintf(' (cannot be determined)');
                    tform_zy.T(3,1) = -4;
                end
                
            catch
                tform_zy = affine2d;
            end
            ticValue = displayTime(ticValue);
            %disp(['    - translation: x=', num2str(tform.T(3,1)), ' y=', num2str(tform.T(3,2)), ' z=', num2str(tform.T(3,3))]);
        else
            tform_zx = affine2d;
            tform_zy = affine2d;
        end
        
        tform = affine3d;
        tform.T(4,1:2) = tform_xy.T(3,1:2) + translations(range(j-1),1:2);
        tform.T(4,3) = mean([tform_zx.T(3,1), tform_zy.T(3,1)]) + translations(range(j-1),3);
        
        fprintf('    - translation: [x=%0.2f, y=%0.2f, z=%0.2f (%0.2f/%0.2f)]', tform.T(4,1), tform.T(4,2),...
            tform.T(4,3), tform_zx.T(3,1), tform_zy.T(3,1));
        
        if abs(tform.T(4,3)) > 3
            fprintf('    -> strong shift in z-direction!');
        end
        
        if tform.T(4,3) < -4
            tform.T(4,3) = -4;
            fprintf(' Limit negative shift to %0.2f', tform.T(4,3));
        end
        
        % Pull the biofilm back to the origin
        %if abs(tform.T(4,3)) > 0.5
        tform.T(4,3) = tform.T(4,3)*0.8;
        fprintf('    -> adjusted z-value to %0.2f', tform.T(4,3));
        %end
        
        %tform.T(3,1:2) = tform.T(3,1:2) + translations(f-1,1:2);
        metadata.data.registration = tform;
        translations(f,:) = tform.T(4,:);
        
    else
        fprintf(' - reference image [position fixed]');
        
        if params.continueRegistration
            if isfield(metadata.data, 'registration')
                fprintf(' -> continuing registration\n');
                fprintf('    - translation: [x=%0.2f, y=%0.2f, z=%0.2f]', metadata.data.registration.T(4,1), metadata.data.registration.T(4,2),...
            metadata.data.registration.T(4,3));
                translations(f,:) = metadata.data.registration.T(4,:);
            end
        else
            metadata.data.registration = affine3d;
            translations(f,:) = [0 0 0 1];
        end
    end
    
    if j > 1
        if ~isvalid(h_ax)
            h = figure('Name', sprintf('Registration: %s', inputFolder));
            h_ax = axes('Parent', h);
            set(h_ax, 'NextPlot', 'add');
            xlabel('x / px'); ylabel('y / px'); zlabel('z / px');
        end
        try
            plot3(h_ax, [translations(range(j-1),1) translations(range(j),1)], [translations(range(j-1),2) translations(range(j),2)],...
                [translations(range(j-1),3) translations(range(j),3)], 'Color', colors(j,:), 'LineWidth', 2);
            title(sprintf('Translation of %s (frame %d)', inputFolder, f), 'Interpreter', 'none');
        end
    end
    
    % Save Metadata
    updateWaitbar(handles, (j+0.8-1)/(numel(range)));
    
    fprintf('\n - saving data -> (main: ch%d)', params.channel);
    displayStatus(handles,['saving data...'], 'blue', 'add');
    data = metadata.data;
    save(fullfile(handles.settings.directory, [files(f).name(1:end-4), '_metadata.mat']), 'data');
    
    channelData = get(handles.uicontrols.popupmenu.channel, 'String');
    
    if numel(channelData) > 1
        if ~isfield(metadata.data, 'registration')
            delete(h);
            uiwait(msgbox('Cannot continue existing registration! First image of sequence is not registered!', 'Error', 'Error', 'modal'));
            break;
        end
        reg = metadata.data.registration;
        currentChannel = cellfun(@(x) strcmp(getChannelName(x), num2str(params.channel)), channelData);
        ch_toProcess = find(~currentChannel);
        for c = 1:numel(ch_toProcess)
            fprintf(', (ch%d)', ch_toProcess(c));
            filename_ch = fullfile(handles.settings.directory, ...
                strrep([files(f).name(1:end-4), '_metadata.mat'], ['ch', getChannelName(channelData{currentChannel})], ['ch', getChannelName(channelData{ch_toProcess(c)})]));
            
            data = load(filename_ch);
            data = data.data;
            data.registration = reg;
            
            save(filename_ch, 'data');
        end
    end
    displayStatus(handles, 'Done', 'black', 'add');
    fprintf('\n');
    
    if checkCancelButton(handles)
        break;
    end
      
    
end

try
    h_ax.Title.String = {h_ax.Title.String, ' (Registration finished. This window may now be closed)'};
end

if params.sendEmail
    email_to = get(handles.uicontrols.edit.email_to, 'String');
    email_from = get(handles.uicontrols.edit.email_from, 'String');
    email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
    
    setpref('Internet','E_mail',email_from);
    setpref('Internet','SMTP_Server',email_smtp);
    
    sendmail(email_to,['[Biofilm Toolbox] Image registration finished: "', handles.settings.directory, '"']', ...
        ['Image registration of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
end

updateWaitbar(handles, 0);
disp('Done');

