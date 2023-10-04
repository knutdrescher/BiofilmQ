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

fields = fieldnames(objects);
fields2Keep = {'Connectivity', 'NumObjects', 'ImageSize', 'PixelIdxList'};
fields(ismember(fields, fields2Keep)) = [];
CC = rmfield(objects, fields);
CC.NumObjects = 1;
CC.PixelIdxList = {};

parfor i = 1:N
    try 
        CC_temp = CC;
        CC_temp.PixelIdxList = PixelIdxList(i);
        if (length(ImageSize) == 3) && ((ImageSize(3))>1)
            convexity(i) = table2array(regionprops3(CC_temp, 'Solidity')); 
        else 
            convexity(i) = regionprops(CC, 'Solidity');
        end
    catch
        convexity(i) = NaN;
    end
end

convexity = num2cell(convexity);
[objects.stats.Shape_Convexity] = convexity{:};

if ~silent
    displayTime(ticValue);
end