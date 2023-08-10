function [objects, distMap] = calculateDistanceToSurfaceExcludeSide(objects, params, options)
% This module was designed for a special use case for Francisco. The
% biofilm is sitting on the side of the image (i.e. 2x2 stiched image).
% In this case the biofilm was larger than the taken image stack. Therefore
% the biofilm air/ liquid interface was only at the side of the channel:
%
% xy view:            xz view:
% ----------------    ----------------
% |#########     |    |#####         |
% |##########    |    |########      |
% |#########     |    |###########   |
% |#######       |    ----------------
% |              |    
% ----------------
%
% If you now calculate the convex hull, make a box around the hull, 
% fill all holes and open one side you directly get the distance to
% the interface
%
% xy view:            xz view:
% ---------------    ---------------
% |#####4321         |##321         
% |#######321        |####2111      
% |######211         |#####432111   
% |1111111           ---------------
% |                  
% ---------------



% Extract res and openSide
pattern = '(?<=res=)(?<res>\d+).*(?<==)(?<side>\d+)';
match = regexpi(options, pattern, 'names');
if ~isempty(match)
    res = str2num(match.res);
    indDist = str2num(match.side);
else 
    res = 20;
    indDist = 2;
end

ticValue = displayTime;

fprintf(' [resolution=%d vox, open side=%d]', res, indDist);
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

sZ = size(biofilmHull, 3);
% or-projection of hull to z-axis and finds index of last non-zero item 
try
    heightContent = find(any(biofilmHull, [1 2]), 1, 'last');
catch % Version < R2018b
    heightContent = find(any(any(biofilmHull, 1),2), 1, 'last');
end
% cap upper 20%
biofilmHull = biofilmHull(:,:,1:round(0.8*heightContent));


biofilmHull([1 end],:,:) = 1;
biofilmHull(:,[1 end],:) = 1;
biofilmHull(:,:,[1 end]) = 1;

stepwise = 0;
switch indDist
    case 1
        biofilmHull(:,1,:) = 0;
    case 2
        biofilmHull(:,end,:) = 0;
    case 3
        biofilmHull(1,:,:) = 0;
    case 4
        biofilmHull(end,:,:) = 0;
    case 6
        stepwise = 1;
    otherwise
        biofilmHull(:,1,:) = 0;
        biofilmHull(:,end,:) = 0;
        biofilmHull(1,:,:) = 0;
        biofilmHull(end,:,:) = 0;
end

fprintf('      - filling holes');
biofilmHull = imfill(biofilmHull, 'holes');

distMap = bwdist(true-biofilmHull);
distMap = padarray(distMap, [0 0 round(sZ-0.8*heightContent)], nan, 'post');

if stepwise
    mat = labelmatrix(objects)>0;
    mat(1,:,:) = 0;
    mat(end,:,:) = 0;
    mat(:,1,:) = 0;
    mat(:,end,:)=0;
    distMap = zeros(size(mat));
    for j = 1:size(mat,3)
       distMap(:,:,j) = bwdist(~mat(:,:,j)); 
    end
end

coords = [objects.stats.Centroid];
Cx = coords(1:3:end);
Cy = coords(2:3:end);
Cz = coords(3:3:end);

% Beware: First coordinate in 'Centroids' is actually the y-axis of image
% plot image if unsure!
ind = sub2ind(size(distMap), round(Cy), round(Cx), round(Cz));
distanceToSurface = distMap(ind);
distanceToSurface = toUm(distanceToSurface, params.scaling_dxy);
distanceToSurface = num2cell(distanceToSurface);

[objects.stats.(sprintf('Distance_ToSurfaceSideOnly_openSide%d_resolution%d', indDist, res))] = distanceToSurface{:};

displayTime(ticValue);

