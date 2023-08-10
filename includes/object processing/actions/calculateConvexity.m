function objects = calculateConvexity(objects, silent)
if nargin < 2
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

convexity = zeros(objects.NumObjects,1);

N = objects.NumObjects;

PixelIdxList = objects.PixelIdxList;
ImageSize = objects.ImageSize;

parfor i = 1:N
    try
        [y, x, z] = ind2sub(ImageSize, PixelIdxList{i});
        if sum(sum(diff(z))) % 3D
            [~, v] = convhull(x,y,z);
        else % 2D
            [~, v] = convhull(x,y);
        end
        convexity(i) = numel(PixelIdxList{i})/v;
    catch
        convexity(i) = NaN;
    end
end


convexity = num2cell(convexity);
[objects.stats.Shape_Convexity] = convexity{:};

if ~silent
    displayTime(ticValue);
end