function moveImageToChannel(path, name, originalChannel, newChannel)
% MOVEIMAGETOCHANNEL(path, name, originalChannel, newChannel) 
% turns deconvolved single image into a new channel image by 
% moving the file, renaming it and adding corresponding metadata
%
% input:    - path, the experiment path
%           - name, name of the file to move (must contain '_cmle')
%           - originalChannel, number of original channel
%           - newChannel, channel that the image will be transferred to

    assert(~isnan(originalChannel))

    pathToDeconvolution = fullfile(path, 'deconvolved images');
    originalName = strrep(name, '_cmle', '');
    new_Channel_str = sprintf('_ch%d_', newChannel);
    
    newName = regexprep(originalName, '_ch\d+_', new_Channel_str);
    assert(~strcmp(newName,originalName));

    % Start with metadata for this file. We would like to keep the
    % information which channels is a deconvolved file and what the
    % original channel number was. Therefore we also add the fields 'originalChannel'
    try
        metadata = load(fullfile(path, strrep(originalName, '.tif', '_metadata.mat')));
        data = metadata.data;
        data.originalChannel = originalChannel;
        save(fullfile(path, strrep(newName, '.tif', '_metadata.mat')), 'data');
    catch
       fprintf('-  metadata could not be loaded. Skipping file');
       return;
    end
    
    % read image and calculate projection
    im = imread3D(fullfile(pathToDeconvolution, name));
    im(:,:,2:end+1) = im;
    proj = squeeze(sum(im, 3));
    im(:,:,1) = proj/max(proj(:))*(2^16-1);
    
    % Write new file and delete old one
    imwrite3D(im, fullfile(path, newName));
    delete(fullfile(pathToDeconvolution, name));
    


end

