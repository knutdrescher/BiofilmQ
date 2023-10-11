function objects = splitCellsByClustering_par(objects, params, medianVolume)
if isfield(objects, 'splitted')
    disp('      cells are already splitted!');
    return;
end

toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3;

volume = [objects.stats.Shape_Volume];

if ~isfield(objects.stats, 'Shape_AspectRatio_HeightToWidth')
    objects = calculateAspectRatios(objects, params, 1);
end

aspectHeightWidth = [objects.stats.Shape_AspectRatio_HeightToWidth];
goodObjects = objects.goodObjects;

fprintf('      median volume = %0.2f (%d cells)\n', medianVolume, numel(volume(goodObjects)));

%figure

% Identify objects to be splitted
cellsToBeSplitted = zeros(objects.NumObjects,1);
newCells = zeros(objects.NumObjects,1);

ticValue = displayTime;
convexityAll = [];
for i = find(objects.goodObjects)'

    [y, x, z] = ind2sub(objects.ImageSize, objects.PixelIdxList{i});
    try
        [~, v] = convhull(x,y,z);
    catch
        v = length(x);
    end
    
    convexity = numel(objects.PixelIdxList{i})/v;
    
    if (convexity < params.splitConvexity && volume(i) > params.splitVolume1*medianVolume) || (volume(i) > params.splitVolume2*medianVolume) || (volume(i) > params.splitVolume3*medianVolume && aspectHeightWidth(i) > params.splitAspectRatio)
        cellsToBeSplitted(i) = 1;
        newCells(i) = round(volume(i)/medianVolume);
    end
    convexityAll(i) = convexity;
end

cellsToBeSplitted = find(cellsToBeSplitted);
fprintf('      cells to be splitted = %d \n', numel(cellsToBeSplitted));

% Perform splitting in parallel
PixelIdxListSplitted = cell(numel(cellsToBeSplitted), 1);
failedToBeSplitted = false(numel(cellsToBeSplitted), 1);
BoundingBoxes = {objects.stats.BoundingBox};

%textprogressbar('      ');

%for chunk = 1:60:numel(cellsToBeSplitted)
%    textprogressbar(chunk/numel(cellsToBeSplitted)*100);

%    endInd = chunk+59;
%    if endInd > numel(cellsToBeSplitted)
%        endInd = numel(cellsToBeSplitted);
%    end

%    parfor c = chunk:endInd;

PixelIdxList = cell(1, numel(cellsToBeSplitted));
ImageSize = objects.ImageSize;

if numel(ImageSize) == 2
    ImageSize(3) = 1;
end

for c = 1:numel(cellsToBeSplitted)
    PixelIdxList(c) = objects.PixelIdxList(cellsToBeSplitted(c));
end

warning off;
parfor c = 1:numel(cellsToBeSplitted)
    skel = [];
    %w = labelmatrix(objects);
    
    link = [];
    i = cellsToBeSplitted(c);
    
    w = false(ImageSize(1), ImageSize(2), ImageSize(3));
    w(PixelIdxList{c}) = true;
    
    [y, x, z] = ind2sub(ImageSize, PixelIdxList{c});
    
    BB = BoundingBoxes{i};
    BBx = ceil(BB(1)):floor(BB(1)+BB(4));
    BBy = ceil(BB(2)):floor(BB(2)+BB(5));
    BBz = ceil(BB(3)):floor(BB(3)+BB(6));
    
    w_cropped = w(BBy, BBx, BBz);
    %w_cropped = w_cropped == i;
    
    % Skeletonize Volume
    try
        skel = bwskel(w_cropped);
    catch
        skel = Skeleton3D(w_cropped);
    end
    
    if ~sum(skel(:))
        fprintf('         cell #%d could not be skeletonized\n         continuing...      \n\n', i);
        failedToBeSplitted(c) = true;
        continue;
    end
    [skelX, skelY, skelZ] = ind2sub(size(w_cropped), find(skel));
    
    skelX = skelX + BBy(1);
    skelY = skelY + BBx(1);
    skelZ = skelZ + BBz(1);
    
    % Determine the link
    try
        [~,~,link] = Skel2Graph3D(skel, 10);
    catch
        link = [];
    end
    if isempty(link)
        link(1).point = find(skel)'; %just one branch
    end
    
    
    % Determine relative orientation of the branches
    angles_x = numel([link.point]); % dummy initialisation for loop
    angles_y = numel([link.point]);
    angles_z = numel([link.point]);
    
    for b = 1:numel(link)
        branch = link(b).point;
        [bx, by, bz] = ind2sub(size(w_cropped), branch);
        
        % Fit line
        [~, evecs] = inertiaEllipsoid([bx' by' bz']);
        if b == 1
            %evec1 = evecs(:,1);
            angles_x(1:numel(link(1).point)) = ones(numel(link(1).point),1)*abs(dot([1 0 0],evecs(:,1)));
            angles_y(1:numel(link(1).point)) = ones(numel(link(1).point),1)*abs(dot([0 1 0],evecs(:,1)));
            angles_z(1:numel(link(1).point)) = ones(numel(link(1).point),1)*abs(dot([0 0 1],evecs(:,1)));
        else
            % add items to angles_* depending on the number of points in
            % the current link
            vec_l = (numel(angles_x)+1) : (numel(angles_x)+numel(link(b).point));
            angles_x(vec_l) = ones(numel(vec_l),1)*abs(dot([1 0 0],evecs(:,1)));
            angles_y(vec_l) = ones(numel(vec_l),1)*abs(dot([0 1 0],evecs(:,1)));
            angles_z(vec_l) = ones(numel(vec_l),1)*abs(dot([0 0 1],evecs(:,1)));
        end
    end
    
    [By, Bx, Bz] = ind2sub(size(w_cropped), [link.point]);
    Bx = Bx+BBx(1);
    By = By+BBy(1);
    Bz = Bz+BBz(1);
    
    % plot3(x,y,z, 'o', 'color' , 'b'); hold on;
    % plot3(Bx,By,Bz, '+', 'color' , 'r'); hold on;
    % branchIndAll = sub2ind(ImageSize, Bx, By, Bz);
    
    closestPoints = dsearchn([Bx' By' Bz'], [x y z]);
    
    % [x,y,z] = ind2sub(ImageSize,PixelIdxList{i});
    % plot3(x,y,z, 'o', 'color' , 'b'); hold on;
    % [x,y,z] = ind2sub(ImageSize,branchIndAll);
    % plot3(x,y,z, '+'); hold off;
    
    
    % Determine how many cells shall by splitted
    k = round(volume(i)/medianVolume);
    
    %idx = kmeans([x y z],k);
    
    % Shift x, y, and z
    x_shift = min(x)-1;
    y_shift = min(y)-1;
    z_shift = min(z)-1;
    x = x-x_shift;
    y = y-y_shift;
    z = z-z_shift;
    % Create image
    im = zeros(max(x), max(y), max(z));
    sizeIm = size(im);
    im_ind = sub2ind(sizeIm, x, y, z);
    im(im_ind) = 1;
    
    % Erode image
    ind_thin = [];
    loop_count = 0;
    objects_thinned_labelled = [];
    closestPoints_thin = [];
    
    while isempty(ind_thin)
        se = strel('sphere', round(params.kernelSize/5)-loop_count);
        im_thinned = imerode(im, se);
        objects_thinned = bwconncomp(im_thinned);
        objects_thinned_labelled = labelmatrix(objects_thinned);
        
        % If erosion leads to more regions than specified by k calculate k
        % by the number of regions
        
        if max(objects_thinned_labelled(:)) > k
            k = max(objects_thinned_labelled(:));
        end
        % Find indices of thinned image
        ind_thin = find(objects_thinned_labelled>0);
        [x_thin, y_thin, z_thin] = ind2sub(size(im_thinned), ind_thin);
        
        % Look which part from the eroded image was closest
        if ~isempty(ind_thin)
            closestPoints_thin = dsearchn([x_thin y_thin z_thin], [x y z]);
        end
        loop_count = loop_count + 1;
    end
    
    % Perform clustering
    
    X = [x, y, z, 50*double(objects_thinned_labelled(ind_thin(closestPoints_thin))),...
        20*angles_x(closestPoints)', 20*angles_y(closestPoints)', 20*angles_z(closestPoints)'];
    %Z = linkage(X,'ward','euclidean','savememory','on');
    %idx = cluster(Z,'maxclust',k);
    %idx = kmeans(X,k);
    idx = kmeans(X,k);
    %scatter3(X(:,1),X(:,2),X(:,3),10,idx);
    %pause
    
    X = [x, y, z];

    try
        options = statset('Display','off', 'MaxIter', 500);
        obj = fitgmdist(X,k,'Options',options, 'Start', idx);
        idx = cluster(obj, X);
    catch
        fprintf('        GMM failed for cell %d\n', i);
    end
    %scatter3(X(:,1),X(:,2),X(:,3),10,idx);
    %pause;
    
    
    
    %scatter3(X(:,1),X(:,2),X(:,3),10,double(objects_thinned_labelled(ind_thin(closestPoints_thin))))
    
    % Transform into image
    sizeIm = size(im);
    im_ind = sub2ind(sizeIm, x, y, z);
    im(im_ind) = idx;
    
    % Find connected regions
    
    for r = 1:k
        region = bwconncomp(im==r);
        
        if region.NumObjects > 1
            % Find the larges entry
            [~, max_index] = max(cellfun('size', region.PixelIdxList, 1));
            
            % Loop over small stuff
            remainingRegions = 1:numel(region.PixelIdxList);
            remainingRegions(max_index) = [];
            %disp(['               ', num2str(numel(remainingRegions)), ' region(s) reassigned']);
            for r2 = 1:numel(remainingRegions)
                region_temp = region.PixelIdxList{remainingRegions(r2)};
                
                % Find the largest neighbor and merge with them
                shell = setxor(neighbourND(region_temp, sizeIm), region_temp);
                shell(shell==0) = [];
                cellIDs = unique(im(shell));
                cellIDs = cellIDs(cellIDs>0);
                
                if ~isempty(cellIDs)
                    overlap = zeros(numel(cellIDs), 1);
                    for o = 1:numel(cellIDs)
                        overlap(o) = sum(im(shell)==cellIDs(o));
                    end
                    
                    % Sort overlap
                    [~, ind] = sort(overlap, 'descend');
                    
                    % Assign to objects with largest overlap and delete from
                    % original structure
                    im(region_temp) = cellIDs(ind(1));
                else
                    im(region_temp) = 0;
                    %disp('               -> deleted');
                end
            end
            
        end
    end
    
    objects_new = conncomp(im);
    % Recalculate the pixel-indices
    for newObj = 1:objects_new.NumObjects
        [x_temp, y_temp, z_temp] = ind2sub(sizeIm, objects_new.PixelIdxList{newObj});
        x_temp = x_temp+x_shift;
        y_temp = y_temp+y_shift;
        z_temp = z_temp+z_shift;
        objects_new.PixelIdxList{newObj} = sub2ind(ImageSize, y_temp, x_temp, z_temp);
    end
    objects_new.ImageSize = ImageSize;
    PixelIdxListSplitted{c} = objects_new.PixelIdxList;
    
    
    % scatter3(X(:,1),X(:,2),X(:,3),10,angles_x(closestPoints))
    % axis equal
    
    %disp(['       - cell ', num2str(i), ' (v = ',num2str(volume(i)),') is splitted in ', num2str(k), ' cells']);
    
    % Create data
    %PixelIdxList_temp = cell(k, 1);
    %for n = 1:k
    %    PixelIdxList_temp{n} = PixelIdxList{i}(idx==n);
    %end
    %
    %PixelIdxListSplitted{c} = PixelIdxList_temp; % The original object is always stored at the beginning
    
end
warning on;
%end


for c = 1:numel(cellsToBeSplitted)
    if ~failedToBeSplitted(c)
        i = cellsToBeSplitted(c);
        objects.PixelIdxList{i} = PixelIdxListSplitted{c}{1};
        
        if numel(PixelIdxListSplitted{c}) > 1
            for j = 2:numel(PixelIdxListSplitted{c})
                objects.PixelIdxList{end+1} = PixelIdxListSplitted{c}{j};
            end
        end
    end
end

objects.goodObjects = [objects.goodObjects; true(numel(objects.PixelIdxList)-numel(goodObjects),1)];
objects.NumObjects = numel(objects.PixelIdxList);

% Update other parameters
stats = regionprops(labelmatrix(objects));
area = [stats.Area];
volumes = num2cell(toUm3(area, objects.params.scaling_dxy));
objects.stats = rmfield(stats, 'Area');
[objects.stats.Shape_Volume] = volumes{:};
objects.splitted = 1;

% Removing 1-voxel cells
smallObj = area<=1;
smallObjInd = find(smallObj);
if ~isempty(smallObjInd)
    fprintf('      removing %d very small cells (1 vox)\n', sum(smallObj));
    objects.PixelIdxList = objects.PixelIdxList(~smallObj);
    objects.NumObjects = sum(~smallObj);
    objects.stats = objects.stats(~smallObj);
    objects.goodObjects = objects.goodObjects(~smallObj);
    objects.NumObjects = numel(objects.PixelIdxList);
end


fprintf('      summary: splitted cells = %d (from %d), new cells = %d, elapsed time', ...
    numel(cellsToBeSplitted), numel(newCells), sum(newCells)-numel(cellsToBeSplitted));
displayTime(ticValue);
