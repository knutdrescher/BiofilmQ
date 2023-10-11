function newName = generateValidFileName(filename, index, s3)

if strcmp(filename(end-3:end), '.tif')
    filename = filename(1:end-4);
end
fileNameProps = getFeaturesFromName(filename);
startInd = length(filename);

if ~isnan(fileNameProps.pos)
    position = fileNameProps.pos;
    startInd = min(startInd, fileNameProps.pos_index-4);
else
    position = 1;
end
if ~isnan(fileNameProps.frame)
    frame = fileNameProps.frame;
    startInd = min(startInd, fileNameProps.frame_index-6);
else
    frame = index;
end
if ~isnan(fileNameProps.channel)
    channel = fileNameProps.channel;
    startInd = min(startInd, fileNameProps.channel_index-3);
else
    channel = 1;
end

newName = filename(1:startInd);
newName = strcat(newName, sprintf('pos%d_ch%d_frame', position, channel), num2str(frame, '%06d'), '_Nz', num2str(s3));

end