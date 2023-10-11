function objects = mergeObjectsAuto(objects, params, medianVolume, forceMerging)
if isfield(objects, 'merged') && forceMerging == 0
   disp('      cells are already merged!'); 
   return;
end

ticValue = displayTime;

goodObjects = objects.goodObjects;
volumes = [objects.stats.Shape_Volume];
minObjectSize = params.mergeFactor*medianVolume; % Criterion for merging

fprintf('      median volume = %0.2f, min cell volume = %0.2f (%d cells)', medianVolume, minObjectSize, numel(volumes(goodObjects)));

textprogressbar('      ');
unitConversion = ((objects.params.scaling_dxy*1e-9)^3/(1e-6)^3);
toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3;

% To ovoid considering of bad objects:
% volume of bad objects is set above the merging criterion
% bad objects are removed from the labeled image and therefore not
% considered to merge with
volumes(~goodObjects) = minObjectSize;
badObjectIDs = find(~goodObjects);

imageSize = objects.ImageSize;
PixelIdxList = objects.PixelIdxList;
w = labelmatrix(objects);

% Remove bad objects from labelled matrix
objects_onlyGoodCells = objects;
objects_onlyGoodCells.stats = objects.stats(goodObjects);
objects_onlyGoodCells.PixelIdxList = objects.PixelIdxList(goodObjects);
objects_onlyGoodCells.NumObjects = sum(goodObjects);
w_good = labelmatrix(objects_onlyGoodCells);

w(w_good==0) = 0;

% for i = 1:numel(badObjectIDs)
%     w(w==badObjectIDs(i)) = 0;
 % end


deletedObjects = false(size(volumes));

counter = 0;
estNumObj = length(find(volumes<minObjectSize));

while min(volumes) < minObjectSize
    
    smallObjects = find(volumes<minObjectSize);
    
    % always take the first object
    i = 1;
    
    % Expand object by 2 pixels (we added a line between objects!)
    
    objID = smallObjects(i);
    neighbors = neighbourND(PixelIdxList{objID}, imageSize);
    dilated = neighbourND(neighbors(:),imageSize);
    shell = setxor(dilated, PixelIdxList{objID});
    
    
    % Neighboring objects:
    try
        obj_neighborS = unique(w(shell));
    catch
        % Cell is on the boundary of the image
        volumes(objID) = minObjectSize;
        continue;
    end
    deleteObj = 0;
    
    if max(obj_neighborS) > 0
        obj_neighborS(obj_neighborS == 0) = [];
        
        obj_neighbor = zeros(length(obj_neighborS), 3);
        obj_neighbor(:,1) = obj_neighborS;
        
        
        % Overlap size
        obj_neighbor_overlapp = zeros(length(obj_neighborS),1);
        for j = 1:length(obj_neighborS)
            % calculation of overlap
            obj_neighbor(j,2) = sum(w(shell) == obj_neighborS(j)); %
            obj_neighbor(j,3) = length(PixelIdxList{obj_neighborS(j)});
        end
        
        
        % SPECIFY THE MERGING METHOD HERE!
        if params.mergingStrategy == 1
            % Take object with biggest overlap
            [~, ind] = max(obj_neighbor(:,2));
        else params.mergingStrategy
            % Take smallest neighbor object
            [~, ind] = min(obj_neighbor(:,3));
        end
        
        % Check whether overlap is larger than 10px
        if obj_neighbor(ind,2) > 10
            
            % Fuse with object with ID "ind"
            
            PixelIdxList{obj_neighbor(ind,1)} = [PixelIdxList{obj_neighbor(ind,1)}; PixelIdxList{objID}];
            
            
            % Remove small object
            w(PixelIdxList{objID}) = obj_neighbor(ind,1);
            %w(w==objID) = obj_neighbor(ind,1); % slow
            
            % Change the volume of the enlarged object
            %objects.stats(obj_neighbor(ind,1)).volume = length(PixelIdxList{obj_neighbor(ind,1)})*unitConversion;
            volumes(obj_neighbor(ind,1)) = volumes(obj_neighbor(ind,1)) + volumes(objID);
            volumes(objID) = minObjectSize;
            
            deletedObjects(objID) = 1;
            
            %disp([' - fused obj ', num2str(objID), ' with ', num2str(obj_neighbor(ind,1))]);
            
        else
            volumes(objID) = minObjectSize;
            %disp([' - obj ', num2str(objID), ' has almost no overlap with neighbors and will not be fused']);
        end
    else
        volumes(objID) = minObjectSize;
        
        if ~params.keepSmallCellWithNoNeighbor
            deleteObj = 1;
            %disp([' - obj ', num2str(objID), ' has no neighbors and was deleted']);
        end
    end
    
    if deleteObj
        deletedObjects(objID) = 1;
        w(PixelIdxList{objID}) = 0;
        %w(w==objID) = 0; %very slow
        volumes(objID) = minObjectSize;
    end
    
    
    counter = counter + 1;
    if ~mod(counter,20)
        textprogressbar(counter/estNumObj*100);
    end
end

textprogressbar(100);
textprogressbar(' Done.');


objects.PixelIdxList = PixelIdxList;

try
    objects.goodObjects(deletedObjects) = [];
catch
    fprintf(' - "goodObjects" could not be updated.\n');
end
objects.NumObjects = objects.NumObjects - sum(deletedObjects);
objects.PixelIdxList(deletedObjects) = [];
BB = regionprops(labelmatrix(objects));

objects.stats(deletedObjects) = [];

for i = 1:length(objects.stats)
    objects.stats(i).BoundingBox = BB(i).BoundingBox;
    objects.stats(i).Centroid = BB(i).Centroid;
    objects.stats(i).Shape_Volume = toUm3(BB(i).Area, objects.params.scaling_dxy);
end

if numel(objects.ImageSize)==2
    centroids = cellfun(@(x) [x 1], {objects.stats.Centroid}, 'UniformOutput', false);
    [objects.stats.Centroid] = centroids{:};
    boundingBoxes = cellfun(@(x) [x(1:2) 0.5 x(3:4) 1], {objects.stats.BoundingBox}, 'UniformOutput', false);
    [objects.stats.BoundingBox] = boundingBoxes{:};
end
    
objects.merged = 1;

fprintf('\n      summary: merged cells = %d, elapsed time', sum(deletedObjects));
displayTime(ticValue);

