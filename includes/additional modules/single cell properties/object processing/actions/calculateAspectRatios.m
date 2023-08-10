function objects = calculateAspectRatios(objects, params, silent)
if nargin < 3
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

objects = calculateObjectSizeAndOrientationEllipsoidalFit(objects);

lengths = [objects.stats.Shape_Length];
heights = [objects.stats.Shape_Height];
widths = [objects.stats.Shape_Width];

Shape_AspectRatio_LengthToWidth = lengths./widths;
Shape_AspectRatio_HeightToWidth = heights./widths;


Shape_AspectRatio_LengthToWidth = num2cell(Shape_AspectRatio_LengthToWidth);
[objects.stats.Shape_AspectRatio_LengthToWidth] = Shape_AspectRatio_LengthToWidth{:};

Shape_AspectRatio_HeightToWidth = num2cell(Shape_AspectRatio_HeightToWidth);
[objects.stats.Shape_AspectRatio_HeightToWidth] = Shape_AspectRatio_HeightToWidth{:};

if ~silent
    displayTime(ticValue);
end

 