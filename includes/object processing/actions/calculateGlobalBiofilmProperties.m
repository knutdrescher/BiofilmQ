function objects = calculateGlobalBiofilmProperties(objects, silent)

if nargin < 3
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

scaling = objects.params.scaling_dxy/1000;

if isfield(objects.stats, 'IsRelatedToFounderCells')
    IsRelatedToFounderCells = [objects.stats.IsRelatedToFounderCells];
    stats = objects.stats(logical(IsRelatedToFounderCells));
else
    stats = objects.stats;
    fprintf('    - field [IsRelatedToFounderCells] not found. Global calculations will be performed on all cells'); 
end

% Calculate global aspect ratios
coords = {stats.Centroid};

coords = cellfun(@(coord) coord*scaling, coords, 'UniformOutput', false);

% evecs = {stats.evecs};
% 
% lengths = {stats.length};
% widths = {stats.width};
% heights = {stats.height};
%
% endpoints_x = cellfun(@(coord, evec, length, width, height, dim) [coord(dim)...
%     coord(dim)-length/2*evec(dim,1) coord(dim)+length/2*evec(dim,1)...
%     coord(dim)-height/2*evec(dim,2) coord(dim)+height/2*evec(dim,2)...
%     coord(dim)-width/2*evec(dim,3) coord(dim)+width/2*evec(dim,3)...
%     ], coords, evecs, lengths, widths, heights, num2cell(1*ones(1, numel(coords))), 'UniformOutput', false);
% 
% endpoints_y = cellfun(@(coord, evec, length, width, height, dim) [coord(dim)...
%     coord(dim)-length/2*evec(dim,1) coord(dim)+length/2*evec(dim,1)...
%     coord(dim)-height/2*evec(dim,2) coord(dim)+height/2*evec(dim,2)...
%     coord(dim)-width/2*evec(dim,3) coord(dim)+width/2*evec(dim,3)...
%     ], coords, evecs, lengths, widths, heights, num2cell(2*ones(1, numel(coords))), 'UniformOutput', false);
% 
% endpoints_z = cellfun(@(coord, evec, length, width, height, dim) [coord(dim)...
%     coord(dim)-length/2*evec(dim,1) coord(dim)+length/2*evec(dim,1)...
%     coord(dim)-height/2*evec(dim,2) coord(dim)+height/2*evec(dim,2)...
%     coord(dim)-width/2*evec(dim,3) coord(dim)+width/2*evec(dim,3)...
%     ], coords, evecs, lengths, widths, heights, num2cell(3*ones(1, numel(coords))), 'UniformOutput', false);

% convert {1 x N{1x3}} cell to 3 x N matrix
coords_ = reshape(cell2mat(coords),3, []);
endpoints_x = coords_(1, :);
endpoints_y = coords_(2, :);
endpoints_z = coords_(3, :);


% Correct offset
endpoints_z = endpoints_z-prctile(endpoints_z, 1);

% Ignore some cells sticking out
xRange = [prctile(endpoints_x, 1), prctile(endpoints_x, 99)];
yRange = [prctile(endpoints_y, 1), prctile(endpoints_y, 99)];
zRange = [prctile(endpoints_z, 1), prctile(endpoints_z, 99.5)];

% xRange = [min(endpoints_x), max(endpoints_x)];
% yRange = [min(endpoints_y), max(endpoints_y)];
% zRange = [min(endpoints_z), max(endpoints_z)];

% Get rid of all points outside
validIdx = unique([find(endpoints_x >= xRange(1) & endpoints_x <= xRange(2)) ...
                  find(endpoints_y >= yRange(1) & endpoints_y <= yRange(2)) ...
                  find(endpoints_z >= zRange(1) & endpoints_z <= zRange(2))]);

endpoints_x = endpoints_x(validIdx);              
endpoints_y = endpoints_y(validIdx);   
endpoints_z = endpoints_z(validIdx);   


% Initialize parameters
baseWidth = nan;
baseLength = nan;
baseEccentricity = 1;
baseArea = nan;


if numel(validIdx) >= 3 % Convex hull requires 3 points
    
    % Obtain convex hull of base
    [K, V] = convhull(endpoints_x, endpoints_y);
    
    x = endpoints_x(K);
    y = endpoints_y(K);
    
    if numel(x) > 5
        ellipse_t = fit_ellipse(x,y);
        
        if strcmp(ellipse_t.status, '')
            
            if ellipse_t.b < ellipse_t.a
                baseEccentricity = sqrt(1-(ellipse_t.b)^2/(ellipse_t.a)^2);
            else
                baseEccentricity = sqrt(1-(ellipse_t.a)^2/(ellipse_t.b)^2);
            end
            
            baseWidth = 2*ellipse_t.b;
            baseLength = 2*ellipse_t.a;
            
            baseArea = pi*ellipse_t.a*ellipse_t.b;
        end
    else
        baseArea = V;
    end
    
end

xHeight = abs(xRange(2)-xRange(1));
yHeight = abs(yRange(2)-yRange(1));
zHeight = abs(zRange(2)-zRange(1));

globalAspectRatio_heightToLength = zHeight/baseLength;
globalAspectRatio_heightToWidth = zHeight/baseWidth;
globalAspectRatio_lengthToWidth = baseLength/baseWidth;

% 
% aspect_ZX = zHeight/(xHeight/2);
% aspect_ZY = zHeight/(yHeight/2);
% aspect_XY = xHeight/yHeight;

if ~isfield(objects, 'globalMeasurements')
    objects.globalMeasurements = [];
end

objects.globalMeasurements.Biofilm_Width = baseWidth;
objects.globalMeasurements.Biofilm_Length = baseLength;
objects.globalMeasurements.Biofilm_Height = zHeight;
objects.globalMeasurements.Biofilm_BaseEccentricity = baseEccentricity;
objects.globalMeasurements.Biofilm_BaseArea = baseArea;
objects.globalMeasurements.Biofilm_Volume = sum([stats.Shape_Volume]);
objects.globalMeasurements.Biofilm_AspectRatio_HeightToLength = globalAspectRatio_heightToLength;
objects.globalMeasurements.Biofilm_AspectRatio_HeightToWidth = globalAspectRatio_heightToWidth;
objects.globalMeasurements.Biofilm_AspectRatio_LengthToWidth = globalAspectRatio_lengthToWidth;

if isfield(objects.globalMeasurements, 'Biofilm_SubstrateArea')
    globalSubstrateArea = objects.globalMeasurements.Biofilm_SubstrateArea;
else
    fprintf('global measurement "globalSubstrateArea" is missing -> "baseArea" is used instead!')
    globalSubstrateArea = baseArea;
end

objects.globalMeasurements.Biofilm_VolumePerSubstrate = objects.globalMeasurements.Biofilm_Volume/globalSubstrateArea;

if isfield(objects.globalMeasurements, 'Biofilm_OuterSurface')
    objects.globalMeasurements.Biofilm_OuterSurfacePerSubstrate = objects.globalMeasurements.Biofilm_OuterSurface/globalSubstrateArea;
    objects.globalMeasurements.Biofilm_OuterSurfacePerVolume = objects.globalMeasurements.Biofilm_OuterSurface/objects.globalMeasurements.Biofilm_Volume;
    objects.globalMeasurements.Biofilm_OuterSurfaceIgnoreSubstratePerSubstrate = objects.globalMeasurements.Biofilm_OuterSurface_ignoreSubstrate/globalSubstrateArea;
    objects.globalMeasurements.Biofilm_OuterSurfaceIgnoreSubstratePerVolume = objects.globalMeasurements.Biofilm_OuterSurface_ignoreSubstrate/objects.globalMeasurements.Biofilm_Volume;
else
    fprintf('global measurement "surface" is missing -> assign "nan" to "surfacePerSubstrat" & "surfacePerSubstrat"!')
    objects.globalMeasurements.Biofilm_OuterSurfacePerSubstrate = nan;
    objects.globalMeasurements.Biofilm_OuterSurfacePerVolume = nan;
end

if ~silent
    displayTime(ticValue);
end