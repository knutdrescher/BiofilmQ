function [objects, distMap] = calculateDistanceToSurface(objects, params, res)

ticValue = displayTime;

fprintf(' [resolution=%d vox]', res);
toUm = @(voxel, scaling) voxel.*scaling/1000;
toPix = @(voxel, scaling) voxel./(scaling/1000);

objectsHull = objects;

% Remove floating cells with a z-dimension of the bounding box of less than 800um
% if isfield(objects.stats, 'BoundingBox')
%     BB = [objects.stats.BoundingBox];
%     BBz = BB(6:6:end);
%     nonFloatingCells = BBz >  toPix(0.8, params.scaling_dxy);
%     objectsHull.stats = objectsHull.stats(nonFloatingCells);
% end

biofilmHull = createHull(objectsHull, params, res);

distMap = bwdist(true-biofilmHull);

centroid = [objects.stats.Centroid];
Cx = centroid(1:3:end);
Cy = centroid(2:3:end);
Cz = centroid(3:3:end);

%Find bad ccordinates
badCoordinates = unique([find(isnan(Cx)) find(isnan(Cy)) find(isnan(Cz))]);

ind = sub2ind(size(distMap), round(Cy), round(Cx), round(Cz));
ind(badCoordinates) = 1;
distanceToSurface = double(distMap(ind));
distanceToSurface = toUm(distanceToSurface, objects.params.scaling_dxy);
distanceToSurface(badCoordinates) = NaN;
distanceToSurface = num2cell(distanceToSurface);

[objects.stats.(sprintf('Distance_ToSurface_resolution%d', res))] = distanceToSurface{:};

displayTime(ticValue);

