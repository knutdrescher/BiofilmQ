function objects = calculateSurfaceProperties(objects, params, range)

if ~isfield(objects.stats, 'Cube_CenterCoord')
    fprintf(' -> Does require grid-based segmentation! -> Cancelled.\n');
    return;
end

%% Comment:
% The implementation of this module has to be improved in the future (i.e.
% by adding a range parameter)

ticValue = displayTime;

% Calculate local area density
objects = calculateLocalAreaDensity(objects, params, range);

w = labelmatrix(objects)>1;
centerCoord = [objects.stats.Cube_CenterCoord];
centerCoord_x = centerCoord(1:3:end);
centerCoord_y = centerCoord(2:3:end);
centerCoord_z = centerCoord(3:3:end);

[pillars, pID] = unique([centerCoord_x', centerCoord_y'], 'rows');

% add zero slice on each end to also capture pixels at the border as
% outline
matrix_extended = zeros(objects.ImageSize(1)+2, objects.ImageSize(2)+2, objects.ImageSize(3)+2);
matrix_extended(2:end-1,2:end-1,2:end-1) = labelmatrix(objects)>0;
outline = bwperim(matrix_extended);
outline = outline(2:end-1,2:end-1,2:end-1);

surface_perSubstrate = zeros(numel(objects.stats), 1);
surface = zeros(numel(objects.stats), 1);
surface_noBottom = surface;
roughness = zeros(numel(objects.stats), 1);
roughness_L1 = zeros(numel(objects.stats),1);
thickness = zeros(numel(objects.stats),1);
thickness_single = zeros(numel(pID),1);

sX = size(w, 2);
sY = size(w, 1);

for i = 1:numel(pID)
    singlePillar = intersect(find(centerCoord_x == centerCoord_x(pID(i))), find(centerCoord_y == centerCoord_y(pID(i)))); 
    
    % Resolution defines the grid
    res = objects.params.gridSpacing;
    x = centerCoord_x(pID(i)) + [-res/2 res/2];
    y = centerCoord_y(pID(i)) + [-res/2 res/2];
    
    if x(2) > sX
        x(2) = sX;
    end
    
    if y(2) > sY
        y(2) = sY;
    end
    
    %     x = [floor(objects.stats(singlePillar(1)).BoundingBox(1)) ceil(objects.stats(singlePillar(1)).BoundingBox(1)+objects.stats(singlePillar(1)).BoundingBox(4))];
    %     y = [floor(objects.stats(singlePillar(1)).BoundingBox(2)) ceil(objects.stats(singlePillar(1)).BoundingBox(2)+objects.stats(singlePillar(1)).BoundingBox(5))];
    %     x(1) = max(x(1),1);
    %     y(1) = max(y(1),1);
    %     x(2) = min(x(2), size(w,2));
    %     y(2) = min(y(2), size(w,1));

    pillarImage = w(y(1):y(2), x(1):x(2), :);
    
    % Calculate surface
    pillarImage_surface = outline(y(1):y(2), x(1):x(2), :);
       
    surface(i) = sum(pillarImage_surface(:));
    
    %%% remove bottom
    surface_plane = sum(pillarImage_surface,3) ;
    surface_plane = arrayfun(@(x) max([x>0, x-1]), surface_plane(:));
    surface_noBottom(i) = sum(surface_plane);
    
    pillarImage_surface = sum(pillarImage_surface(:))/(size(pillarImage, 1)*size(pillarImage, 2));
    
    surface_perSubstrate(singlePillar) = repmat(pillarImage_surface, numel(singlePillar), 1);
    
    % Calculate roughness
    % roughness is the thickness of the biofilm at the position of the
    % pillar
    roughness_image = zeros(size(pillarImage, 1), size(pillarImage, 2));
    for h = 1:size(pillarImage, 3)
        roughness_image(pillarImage(:,:,h)>0) = h;
    end
    roughness_image(roughness_image==0) = [];
    roughness_singlePillar = std(roughness_image(:));
    rough_mean = mean(roughness_image(:));
    roughness_singlePillar_l1 = 1/(numel(roughness_image)*rough_mean)*sum(abs(roughness_image(:)-rough_mean));
    
    roughness(singlePillar) = repmat(roughness_singlePillar, numel(singlePillar), 1);
    thickness(singlePillar) = repmat(mean(roughness_image(:)), numel(singlePillar),1);
    roughness_L1(singlePillar) = repmat(roughness_singlePillar_l1, numel(singlePillar),1);
    thickness_single(i) = mean(roughness_image(:));
end
surface_perSubstrate = num2cell(surface_perSubstrate);
[objects.stats.Surface_PerSubstrateArea] = surface_perSubstrate{:};


%toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3;
toUm = @(voxel, scaling) voxel.*(scaling/1000);
toUm2 = @(voxel, scaling) voxel.*(scaling/1000)^2;

%roughness = num2cell(toUm3(roughness, params.scaling_dxy));
%roughness_L1 = num2cell(toUm3(roughness_L1, params.scaling_dxy));
%[objects.stats.localRoughness] = roughness{:};
%[objects.stats.localRoughness_L1] = roughness_L1{:};
thickness = num2cell(toUm(thickness, objects.params.scaling_dxy));
[objects.stats.Surface_LocalThickness] = thickness{:};

thickness_single = toUm(thickness_single, objects.params.scaling_dxy);
meanThickness = nanmean(thickness_single);
globalRoughness = nanstd(thickness_single); 
globalRoughness_L1 = 1/(numel(thickness_single)*meanThickness)*nansum(abs(meanThickness-thickness_single));
objects.globalMeasurements.Biofilm_MeanThickness = meanThickness;
%objects.globalMeasurements.globalRoughness = globalRoughness;
objects.globalMeasurements.Biofilm_Roughness = globalRoughness_L1;

objects.globalMeasurements.Biofilm_OuterSurface = toUm2(nansum(surface),objects.params.scaling_dxy);
objects.globalMeasurements.Biofilm_OuterSurface_ignoreSubstrate = toUm2(nansum(surface_noBottom),objects.params.scaling_dxy);

fprintf('   - other surface properties');
displayTime(ticValue);