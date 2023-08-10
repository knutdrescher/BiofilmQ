function data = generatePixelIdxListForSimulations(handles, data, params_sim)
fprintf(' - generating volumetric data');
params_sim.conversionFactor = 1/params_sim.scaling_dxy*params_sim.scaling_dxy_um;
cellLength_px = 1*params_sim.conversionFactor;

%%
h = ProgressBar(numel(data));
for f = 1:numel(data)
    h.progress;
    centroids = {data{f}.stats.Centroid};
    evecs = {data{f}.stats.Orientation_Matrix};
    lengths = [data{f}.stats.Shape_Length]/(params_sim.scaling_dxy_um*2);
    heights = [data{f}.stats.Shape_Height]/(params_sim.scaling_dxy_um*2);
    widths = [data{f}.stats.Shape_Width]/(params_sim.scaling_dxy_um*2);
    
    cellPxlList = cell(1, data{f}.NumObjects);
    
    sX = data{f}.ImageSize(1); 
    sY = data{f}.ImageSize(2);
    sZ = data{f}.ImageSize(3);
    
    parfor i = 1:data{f}.NumObjects % loop can run parallel
        
        % Centroid of cell
        vec_1 = evecs{i}(:, 1);
        vec_2 = evecs{i}(:, 2);
        vec_3 = evecs{i}(:, 3);
        vec_l = [lengths(i), heights(i), widths(i)];
        
        rotMat = [vec_1 vec_2 vec_3]';
        
        coords = centroids{i};
        rot = @(x, y, z) rotMat*([x y z]-coords)';
        
        a = vec_l(1)*cellLength_px*params_sim.cellSolidity;
        b = vec_l(2)*cellLength_px*params_sim.cellSolidity;
        c = vec_l(3)*cellLength_px*params_sim.cellSolidity;
        
        maxCellLength = max([a b c]);
        
        X = coords(1)-maxCellLength:coords(1)+maxCellLength;
        Y = coords(2)-maxCellLength:coords(2)+maxCellLength;
        Z = coords(3)-maxCellLength:coords(3)+maxCellLength;
             
        [x, y, z] = meshgrid(floor(min(X)):ceil(max(X)), floor(min(Y)):ceil(max(Y)), floor(min(Z)):ceil(max(Z)));
        
        vec_rot = rot(x(:), y(:), z(:));
        
        idx = find(vec_rot(1,:).^2/a^2+vec_rot(2,:).^2/b^2+vec_rot(3,:).^2/c^2 < 1);
        
        % Remove pixels touching the border
        badVoxel = unique([find(y(idx) < 1 | y(idx) > sX), find(x(idx) < 1 | x(idx) > sY), find(z(idx) < 1 | z(idx) > sZ)]);
        idx(badVoxel) = [];
        
        PxlIndices = sub2ind([sX sY sZ], y(idx), x(idx), z(idx));
       
        cellPxlList{i} = PxlIndices(:);
        
    end
    data{f}.PixelIdxList = cellPxlList;
    stats = regionprops(data{f}, 'BoundingBox');
    for i = 1:data{f}.NumObjects
        data{f}.stats(i).BoundingBox = stats(i).BoundingBox;
    end
end
h.stop;
