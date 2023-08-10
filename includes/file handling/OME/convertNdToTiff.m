function convertNdToTiff(handles, filenames)
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

range = str2num(params.action_imageRange);

files = handles.settings.lists.files_nd2;

range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;

if isempty(range)
    uiwait(msgbox('Please enter a valid image range.', 'Please note', 'help', 'modal'));
    return;
end

cancel = false;
createdDirectories = [];
for f = 1:numel(filenames)
    filename = filenames{f};
    disp(['=========== Loading image ', filename, ' ===========']);
    
    enableCancelButton(handles);
    
    displayStatus(handles,['Loading image ', filename, '...'], 'black');
    
    fileInfo = dir(fullfile(handles.settings.directory, filename));
    reader = bfGetReader(fullfile(handles.settings.directory, filename));
    omeMeta = reader.getMetadataStore();
    
    if exist(fullfile(handles.settings.directory, 'lut.txt'), 'file')
        fileID = fopen(fullfile(handles.settings.directory, 'lut.txt'),'r');
        lut = textscan(fileID,'%s');
        fclose(fileID);
        lut = lut{1};
    else
        lut = [];
    end
    
    if exist(fullfile(handles.settings.directory, 'rescale.txt'), 'file')
        fileID = fopen(fullfile(handles.settings.directory, 'rescale.txt'),'r');
        rescale = textscan(fileID,'%f');
        fclose(fileID);
        rescale = rescale{1};
    else
        rescale = 1;
    end
    
    sPos = reader.getSeriesCount();
    
    
    for pos = 1:sPos
        [~,name,~] = fileparts(filename);
        outputDir = fullfile(handles.settings.directory, name);
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        
        try
            if handles.uicontrols.checkbox.files_createPosFolder.Value
                outputDir = fullfile(outputDir, ['Pos', num2str(pos)]);
                if ~exist(outputDir, 'dir')
                    mkdir(outputDir);
                    
                end
            end
            createdDirectories{end+1} = outputDir;
        end
        
        sX = omeMeta.getPixelsSizeX(pos-1).getValue();
        sY = omeMeta.getPixelsSizeY(pos-1).getValue();
        sZ = omeMeta.getPixelsSizeZ(pos-1).getValue();
        sCh = omeMeta.getPixelsSizeC(pos-1).getValue();
        sT = omeMeta.getPixelsSizeT(pos-1).getValue();
        imageName = char(omeMeta.getImageName(pos-1));
        
        if ~isempty(strfind(imageName, filename))
            imageName = [];
        end
        
        try
            dz = double(omeMeta.getPixelsPhysicalSizeZ(pos-1).value)*1000; %in nm
        catch
            dz = 1;
            warning('backtrace', 'off');
            warning('No z-scaling stored in data! Please revise and adapt value after export!');
            warning('backtrace', 'on');
        end
        try
            dxy = double(omeMeta.getPixelsPhysicalSizeX(pos-1).value)*1000; %in nm
        catch
            dxy = 1;
            warning('backtrace', 'off');
            warning('No xy-scaling stored in data! Please revise and adapt value after export!');
            warning('backtrace', 'on');
        end
        dt = 1;
        readMethod = 2;
        
        bug = 0;
        if bug
            sT_z = sT;
            sT = 1;
        end
        
        disp(['    - pos=',num2str(sPos),', x=',num2str(sX),', y=',num2str(sY),', z=',num2str(sZ),', ch=',num2str(sCh),', t=',num2str(sT)]);
        
        %% Parameters
        data.scaling.dxy = dxy/1000/rescale;
        data.scaling.dz = dz/1000;
        
        
        if isempty(lut)
            %             if isempty(imageName)
            %                 prefix = [filename(1:end-4), '_'];
            %             else
            %                 prefix = [filename(1:end-4), '_', imageName, '_'];
            %             end
            
            prefix = [filename(1:end-4), '_'];
        else
            prefix = [filename(1:end-4), '__', lut{pos}, '__'];
        end
        
        %% Loop over timepoints
        try
            refTime = double(omeMeta.getPlaneDeltaT(0,0).value);
        catch
            refTime = 0;
        end
        for t = 1:sT
            disp(['    -- timepoint ',num2str(t),'/',num2str(sT),' --']);
            displayStatus(handles,[num2str(t), '...'], 'black', 'add');
            
            for ch = 1:sCh
                
                % Update waitbar
                updateWaitbar(handles, ((f-1)+pos/sPos*0.1+t/sT/sPos+ch/sCh/sPos/sT)/numel(filenames));
                
                % Extract timepoint
                features = getFeaturesFromName(filename);
                if isnan(features.time)
                    try
                        reader.setSeries(pos-1);
                        index = reader.getIndex(0, ch-1, t-1);
                        dt2 = double(omeMeta.getPlaneDeltaT(pos-1,index).value)-refTime; % in s
                        data.date = datestr(dt2/60/60/24+fileInfo.datenum, 'dd-mmm-yyyy HH:MM:SS');
                    catch
                        data.date = datestr(fileInfo.datenum, 'dd-mmm-yyyy HH:MM:SS');
                    end
                else
                    data.date = datestr(features.time*features.timeMultiplier/60/60/24, 'dd-mmm-yyyy HH:MM:SS');
                end
                
                if ~exist(fullfile(outputDir, [prefix, 'pos',num2str(pos), '_ch',num2str(ch), '_frame', num2str(t, '%06d'), '_Nz',num2str(sZ),'.tif']), 'file')
                    
                    img = getND2Stack(reader, pos, ch, t, sX, sY, sZ);
                    
                    if rescale ~= 1
                        T = affine3d([rescale 0 0 0; 0 rescale 0 0; 0 0 1 0; 0 0 0 1]);
                        img = imwarp(img, T, 'FillValues', 0);
                    end
                    
                    firstSlice = sum(img,3);
                    img(:,:,2:end+1) = img;
                    img(:,:,1) = firstSlice/max(firstSlice(:))*(2^16-1);
                    
                    disp(['Write file "', prefix, 'pos',num2str(pos), '_ch',num2str(ch), '_frame', num2str(t, '%06d'), '_Nz',num2str(sZ),'.tif"']);
                    
                    imwrite3D(img, fullfile(outputDir, [prefix, 'pos',num2str(pos), '_ch',num2str(ch), '_frame', num2str(t, '%06d'), '_Nz',num2str(sZ),'.tif']));
                else
                    fprintf('   image file already exists, skipping\n');
                end
                if ~exist(fullfile(outputDir, [prefix, 'pos',num2str(pos), '_ch',num2str(ch), '_frame', num2str(t, '%06d'), '_Nz',num2str(sZ),'_metadata.mat']), 'file')
                    save(fullfile(outputDir, [prefix, 'pos',num2str(pos), '_ch',num2str(ch), '_frame', num2str(t, '%06d'), '_Nz',num2str(sZ),'_metadata.mat']), 'data');
                else
                    fprintf('   metadata file already exists, skipping\n');
                end
                
                if checkCancelButton(handles) || cancel
                    cancel = true;
                    break;
                end
                
            end
            
            if checkCancelButton(handles) || cancel
                cancel = true;
                break;
            end
        end
        
        if checkCancelButton(handles) || cancel
            cancel = true;
            break;
        end
    end
    
    % Close the reader
    reader.close();
    if checkCancelButton(handles) || cancel
        cancel = true;
        break;
    end
end

displayStatus(handles,'Done', 'black', 'add');
updateWaitbar(handles, 0);

%if handles.uicontrols.checkbox.files_createPosFolder.Value
    if handles.settings.showMsgs
        try
            createdDirectories = unique(createdDirectories);
            answer = questdlg([{'The following subdirectories were created:', ''}, createdDirectories, {'', ''}, 'Current directory:', handles.settings.directory], ...
                'Export finished', ...
                'Switch to 1. directory in list', 'Stay in current directory','Stay in current directory');
            
            switch answer
                case 'Switch to 1. directory in list'
                    handles.settings.directory = createdDirectories{1};
                    handles.uicontrols.edit.inputFolder.String = createdDirectories{1};
                case 'Stay in current directory'
                    % Do nothing
            end
        end
    end
% else
%     if handles.settings.showMsgs
%         try
%             answer = questdlg('Export of the selected file(s) is finished. Do you want to switch to tif-file mode to continue with the segmentation?', ...
%                 'Continue?', ...
%                 'Yes, switch to tif-mode', 'No, I want to continue exporting images','No, I want to continue exporting images');
%             
%             switch answer
%                 case 'Yes, switch to tif-mode'
%                     handles.uicontrols.popupmenu.popupmenu_fileType.Value = 2;
%                     storeValues(hObject, eventdata, handles);
%                 case 'No, I want to continue exporting images'
%                     % Do nothing
%             end
%         end
%     end
% end
