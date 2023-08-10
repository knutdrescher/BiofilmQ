function [objects, obj_nonMerged] = calculateDensityCorrelationBinary(objects, obj_nonMerged, ch_task, handles, filename, range)
% Calculate density correlation of binary data
N = objects.NumObjects;

s = round(range*(objects.params.scaling_dxy/1000));
fprintf(' - range corresponds to: %.2f um\n', s);

% Load non-merged data
filename_ch1 = fullfile(handles.settings.directory, 'data', 'non-merged data', [filename(1:end-4), '_data.mat']);
filename_ch2 = strrep(filename_ch1, sprintf('_ch%d', ch_task(1)), sprintf('_ch%d', ch_task(2)));

if isempty(obj_nonMerged{ch_task(1)})
    obj_nonMerged{ch_task(1)} = loadObjects(filename_ch1);
end
if isempty(obj_nonMerged{ch_task(2)})
    obj_nonMerged{ch_task(2)} = loadObjects(filename_ch2);
end

img_ch1 = labelmatrix(obj_nonMerged{ch_task(1)}) > 0;
img_ch2 = labelmatrix(obj_nonMerged{ch_task(2)}) > 0;

[sX, sY, sZ] = size(img_ch1);

densityCorrelation_sum = nan(N, 1);

centroids = [objects.stats.Centroid];
centroids_floor = floor(centroids - range/2);
centroids_ceil = ceil(centroids + range/2-1);
bound_x = [centroids_floor(2:3:end); centroids_ceil(2:3:end)];
bound_y = [centroids_floor(1:3:end); centroids_ceil(1:3:end)];
bound_z = [centroids_floor(3:3:end); centroids_ceil(3:3:end)];

bound_x(bound_x<1) = 1;
bound_y(bound_y<1) = 1;
bound_z(bound_z<1) = 1;
bound_x(bound_x>sX) = sX;
bound_y(bound_y>sY) = sY;
bound_z(bound_z>sZ) = sZ;

for c = 1:N    
    densityCorrelation_sum(c) = densityCorr( ...
        img_ch1(bound_x(1,c):bound_x(2,c), bound_y(1,c):bound_y(2,c), bound_z(1,c):bound_z(2,c)), ...
        img_ch2(bound_x(1,c):bound_x(2,c), bound_y(1,c):bound_y(2,c), bound_z(1,c):bound_z(2,c)));
end

densityCorrelation_sum = num2cell(densityCorrelation_sum);
[objects.stats.(sprintf('Correlation_DensityCorrelation_Binary_ch%d_ch%d_range%d', ch_task(1), ch_task(2), range))] = densityCorrelation_sum{:};
end
