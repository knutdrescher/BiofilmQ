function channelName = getChannelName(channelName)
% converts deconvolved channel name into string containing only the channel
% number

    start = strfind(channelName, ' (deconvolved from');
    if ~isempty(start)
        channelName = channelName(1:start-1);
    end

end

