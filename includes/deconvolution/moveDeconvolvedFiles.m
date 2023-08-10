function moveDeconvolvedFiles(input_folder, varargin)

m = msgbox({strcat('Please start Huygens and run the batch script created in ',input_folder , '. Click ok ONLY if deconvolution has finished!')}, 'Deconvolution in progress', 'error');
%% Monitor and sort files during deconvolution
ticValue = displayTime;
while isvalid(m)
    files = dir(fullfile(input_folder, '*_cmle.tif'));
    
    if isempty(files) || ~huygensLogFileExists(files(1))
        pause(5);
        continue;
    else
        try
            huygens_file = getHuygensLogFile(files(1));
            fid = fopen(huygens_file);
            data = textscan(fid,'%s', 'Delimiter', '\n');
            fclose(fid);
            
            idx1 = strfind(data{1}{8}, 'path {');
            idx2 = strfind(data{1}{8}(idx1:end), '}');
            parentDir = fileparts(data{1}{8}(idx1+6:idx1+idx2(1)-2));
            
            movefile(fullfile(files(1).folder, files(1).name), fullfile(parentDir, files(1).name));
            delete(huygens_file);
            
            fprintf('File "%s" moved to "%s"', files(1).name, parentDir)
            displayTime(ticValue);
            ticValue = displayTime;
            
            if nargin==2
                channelInfo = varargin{1};
                % move files to channel
                parentDir = strrep(parentDir, '/', '\');
                parentDir = strrep(parentDir, '\deconvolved images', '');
                findDir = @(x) strcmp(x, parentDir);
                currentFolder = cellfun(findDir, {channelInfo.folder});
                deconvolvedChannels = channelInfo(find(currentFolder,1)).deconvolvedChannels;
                features = getFeaturesFromName(files(1).name);
                channel = features.channel;
                newChannel = deconvolvedChannels(find(deconvolvedChannels==channel,1),2);
                moveImageToChannel(parentDir, files(1).name, channel, newChannel)
            end
        catch e
            warning(e.message);
        end
    end

end
end

function huygens_log_file = getHuygensLogFile(im_file)
    [folder, name, ~] = fileparts(fullfile(im_file.folder, im_file.name));
    huygens_log_file = fullfile(folder, [name, '.hgsb']);
end

function boolean = huygensLogFileExists(im_file)
    boolean = isfile(getHuygensLogFile(im_file));
end

