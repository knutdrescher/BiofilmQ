function convertFolderContentToChannel(path)
%CONVERTFOLDERCONTENTTOCHANNEL(path) converts all deconvolved images from a folder 
%into a channel by copying them into the main directory, renaming and 
%modifying metadata
%
% input:    -path, path to experiment folder
% Images must contain the ending '_cmle.tif'

[channels,deconvolvedChannels] = getCurrentChannels(path);
pathToDeconvolution = fullfile(path, 'deconvolved images');

files = dir(fullfile(pathToDeconvolution, '*_cmle.tif'));

for j = 1:length(files)
    features = getFeaturesFromName(files(j).name);
    channel = features.channel;
    
    if isnan(channel)
        channelNumber = 2;
    else
        % If deconvolved images already exist as a channel based on the
        % same original channel, we do not need to generate a new channel
        % number
        if ~isempty(deconvolvedChannels) 
            if any(channel == deconvolvedChannels(:,1))
            index = find(channel == deconvolvedChannels(:,1), 1);
            channelNumber = deconvolvedChannels(index, 2);
            else
                channelNumber = max(channels)+1;
                channelNumber = max(channelNumber, max(deconvolvedChannels(:))+1);
                deconvolvedChannels(end+1, :) = [channel, channelNumber];
            end
        else
            channelNumber = max(channels)+1;
            deconvolvedChannels(end+1, :) = [channel, channelNumber];
        end
    end
    
    moveImageToChannel(path, files(j).name, channel, channelNumber);
    
end







end

