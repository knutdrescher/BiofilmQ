function [channels,deconvolvedChannels] = getCurrentChannels(path)
% [channels,deconvolvedChannels] = GETCURRENTCHANNELS(path) retrieves current
% channels from image and metadata information, sorting by original
% channels and deconvolved channels
%
% returns CHANNELS containing all original channel numbers as well as
% DECONVOLVEDCHANNELS, containing the original channel numbers in the first
% column and deconvolved channel numbers in the second column
%
% input: path, path to experiment

files = dir(fullfile(path, '*.tif'));

channels = [];
deconvolvedChannels = [];
addChannel = {};
for j = 1:length(files)
    features = getFeaturesFromName(files(j).name);
    channel = features.channel;
    if isnan(channel)
        addChannel{end+1} = files(j).name;
    else
        if ~any(channels==channel) && ~any(deconvolvedChannels==channel)
            metadata = load(fullfile(path, strrep(files(j).name, '.tif', '_metadata.mat')));
            metadata = metadata.data;
            
            if isfield(metadata, 'originalChannel')
                deconvolvedChannels(end+1,1) = metadata.originalChannel;
                deconvolvedChannels(end,2) = channel;
            else
                channels = [channels, channel];
            end
        end
        
    end
end

if ~isempty(addChannel)
    if isempty(channels)
        channel = 1;
    else
        channel = max(channels)+1;
    end
    for k = 1:length(addChannel) 
        name = addChannel{k};
        
        assert(contains(name, '_frame'))
        newName = strrep(name, '_frame', sprintf('_ch%d_frame', channel));
        
        if ~exist(fullfile(path, newName), 'file')
            movefile(fullfile(path, name), fullfile(path, newName));
            movefile(fullfile(path, strrep(name, '.tif', '_metadata.mat')), fullfile(path, strrep(newName, '.tif', '_metadata.mat')));
        end
    end
    channels = [channels, channel];
end

end