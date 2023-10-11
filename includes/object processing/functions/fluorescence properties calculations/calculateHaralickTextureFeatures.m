function objects = calculateHaralickTextureFeatures(objects, img, ch_task, range)

if numel(objects.ImageSize) == 2
    warning('backtrace', 'off')
    warning('The calculation of Haralick texture features is only implemented in 3D, yet.');
    warning('backtrace', 'on');
    return;
end
% ToDos:
% - in options the channel to use has to be stated
% - vectorize cooc3d.m to further improve performance
% - test on data where we know the results


% if ~isfield(objects.stats, 'Cube_CenterCoord')
%     fprintf(' -> Does require grid-based segmentation! -> Cancelled.\n');
%     return;
% end

ticValue = displayTime;

img = img{ch_task};

s = round(range*(objects.params.scaling_dxy/1000));
fprintf(' - range corresponds to: %.2f um\n', s);
grid = range;

if isfield(objects.stats, 'Cube_CenterCoord')
    coords = [objects.stats.Cube_CenterCoord];
else
    coords = [objects.stats.Centroid];
end

coords1 = reshape(coords, 3, []);
coords_start = round(coords1 - floor(grid/2));
coords_end   = round(coords1 + ceil(grid/2-1));

[sX, sY, sZ] = size(img);

% @le corresponds to '<='
ind = all(bsxfun(@le, coords_end, [sY; sX; sZ]), 1);
Nc = sum(ind);
coords_start = coords_start(:, ind);
coords_end = coords_end(:, ind);

cubes = zeros(grid, grid, grid, Nc);

for i = 1:Nc
    cubes(:, :, :, i) = img(coords_start(2, i):coords_end(2, i), coords_start(1, i):coords_end(1, i), coords_start(3, i):coords_end(3, i));
end

directions = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];

fprintf(' - calculating haralick features for each cube');
% Energy, Entropy, Correlation, Contrast, Variance, SumMean, Inertia, 
% Cluster Shade, Cluster tendency, Homogeneity,MaxProbability, 
% Inverse Variance; along each direction
hFeatures = cooc3d(cubes, 'distance', [1], 'direction',  directions);

% dim(hFeatures) = (num cubes, [all features_dir1, all features_dir2, ...])
% by adding another axis with length num directions dim(hFeatures) becomes 
% (num cubes, num features, num directions) and we can calculate the mean
% along the directions via
hFeatures = mean(reshape(hFeatures, Nc, [], size(directions, 1)), 3);

featureNames = {'Energy', 'Entropy', 'Correlation', 'Contrast', 'Homogeneity', ...
 'Variance', 'SumMean', 'Inertia', 'ClusterShade', 'ClusterTendency', ...
 'MaxProbability', 'InverseVariance'};

feature = NaN(size(ind));
for i = 1:numel(featureNames)
    if ~isempty(hFeatures)
        feature(ind) = hFeatures(:, i);
    end
    featureCell = num2cell(feature);
    [objects.stats.(sprintf('Texture_Haralick_%s_ch%d_range%d', featureNames{i}, ch_task, range))] = featureCell{:};
end

fprintf(' - finished');
displayTime(ticValue);

