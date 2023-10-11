function objects = removeObjectsOnBorder(handles, objects, params, filename)
ticValue = displayTime;

metadata = load(fullfile(handles.settings.directory, [filename(1:end-4), '_metadata.mat']));

try
    params.cropRange = metadata.data.cropRange;
catch
    params.cropRange = [];
end

w = labelmatrix(objects);
borderStack = false(size(w));

if isfield(objects, 'ImageContentFrame')
    x = objects.ImageContentFrame(1:2);
    y = objects.ImageContentFrame(3:4);
    
    borderStack(x(1), :, :) = true;
    borderStack(x(2), :, :) = true;
    borderStack(:, y(1), :) = true;
    borderStack(:, y(2), :) = true;
else
    % due to edge detection approach the cells never can touch the border 
    % 3 px are always missing. This is the reason why not the border px is
    % set to true
    borderStack(3,:,:) = true;
    borderStack(end-2,:,:) = true;
    borderStack(:,3,:) = true;
    borderStack(:,end-2,:) = true;
end

idsOnBorder = w(borderStack);
idsOnBorder = unique(idsOnBorder);

if idsOnBorder(1) == 0
    idsOnBorder(1) = [];
end

validIds = true(1, objects.NumObjects);
validIds(idsOnBorder) = false;

objects.PixelIdxList = objects.PixelIdxList(validIds);
objects.NumObjects = sum(validIds);
objects.goodObjects = objects.goodObjects(validIds);
objects.stats = objects.stats(validIds);

fprintf(' - %d of %d cells removed', sum(~validIds), numel(validIds));
displayTime(ticValue);
