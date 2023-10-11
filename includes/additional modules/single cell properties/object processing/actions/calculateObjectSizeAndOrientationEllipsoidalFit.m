function objects = calculateObjectSizeAndOrientationEllipsoidalFit(objects)
ticValue = displayTime;

lengths = zeros(objects.NumObjects,1);
widths = zeros(objects.NumObjects,1);
heights = zeros(objects.NumObjects,1);
evecs = cell(objects.NumObjects,1);

toUm = @(voxel, scaling) voxel.*scaling/1000;

imageSize = objects.ImageSize;

PixelIdxList = objects.PixelIdxList;

parfor i = 1:objects.NumObjects
    try
        [y, x, z] = ind2sub(imageSize, PixelIdxList{i});
        
        [ell, evecs_perCell] = inertiaEllipsoid([x y z]);
        
        radii = ell(4:6);

        evecs{i} = evecs_perCell;
        
        lengths(i) = 2*radii(1);
        heights(i) = 2*radii(2);
        widths(i) = 2*radii(3);
    catch
        lengths(i) = 0;
        heights(i) = 0;
        widths(i) = 0;
        evecs{i} = [1 0 0; 0 1 0; 0 0 1];
        fprintf('      cell size could not be determined for cell #%d', i);
    end
end

widths = num2cell(toUm(widths, objects.params.scaling_dxy));
lengths = num2cell(toUm(lengths, objects.params.scaling_dxy));
heights = num2cell(toUm(heights, objects.params.scaling_dxy));
[objects.stats.Shape_Width] = widths{:};
[objects.stats.Shape_Length] = lengths{:};
[objects.stats.Shape_Height] = heights{:};
[objects.stats.Orientation_Matrix] = evecs{:};
displayTime(ticValue);
