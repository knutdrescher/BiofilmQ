function objects = calculateObjectBoundingBox(objects, params)

if numel(objects.ImageSize) == 2
    warning('backtrace', 'off')
    fprintf('\n');
    warning('2D images are not supported.');
    warning('backtrace', 'on')
    return;
end
ticValue = displayTime;
% Calculate longest and shortest side

lengths = zeros(objects.NumObjects,1);
heights = zeros(objects.NumObjects,1);
widths = zeros(objects.NumObjects,1);
cornerpoints_all = cell(objects.NumObjects,1);

toUm = @(voxel, scaling) voxel.*scaling/1000;

N = objects.NumObjects;
PixelIdxList = objects.PixelIdxList;
w = labelmatrix(objects);
parfor i = 1:N
    try
        
        [y, x, z] = ind2sub(size(w), PixelIdxList{i});
        
        %[center, radii, evecs, v, chi2] = ellipsoid_fit([x,y,z]);
        [~,cornerpoints,~,~,~] = minboundbox(x,y,z, [], 1);
        cornerpoints_all{i} = cornerpoints;
        
        side_length = [];
        points = [1 2];
        side_length(1) = norm([cornerpoints(points(2),1)-cornerpoints(points(1),1),...
            cornerpoints(points(2),2)-cornerpoints(points(1),2),...
            cornerpoints(points(2),3)-cornerpoints(points(1),3)], 2);
        points = [2 3];
        side_length(2) = norm([cornerpoints(points(2),1)-cornerpoints(points(1),1),...
            cornerpoints(points(2),2)-cornerpoints(points(1),2),...
            cornerpoints(points(2),3)-cornerpoints(points(1),3)], 2);
        points = [4 8];
        side_length(3) = norm([cornerpoints(points(2),1)-cornerpoints(points(1),1),...
            cornerpoints(points(2),2)-cornerpoints(points(1),2),...
            cornerpoints(points(2),3)-cornerpoints(points(1),3)], 2);
        
        side_length = sort(side_length);
        lengths(i) = side_length(3);
        heights(i) = side_length(2);
        widths(i) = side_length(1);
    catch err
        lengths(i) = 0;
        heights(i) = 0;
        widths(i) = 0;
        disp(['Cell size could not be determined for cell #', num2str(i)]);
    end
end

widths = num2cell(toUm(widths, params.scaling_dxy));
heights = num2cell(toUm(heights, params.scaling_dxy));
lengths = num2cell(toUm(lengths, params.scaling_dxy));

[objects.stats.MinBoundBox_Width] = widths{:};
[objects.stats.MinBoundBox_Height] = heights{:};
[objects.stats.MinBoundBox_Length] = lengths{:};
[objects.stats.MinBoundBox_Cornerpoints] = cornerpoints_all{:};
displayTime(ticValue);
