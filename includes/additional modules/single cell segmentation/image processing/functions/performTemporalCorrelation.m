function objects = performTemporalCorrelation(objects, prevData, params)
ticValue = displayTime;
fprintf('      performing temporal correction');
w = labelmatrix(objects);

try
    % Calculate ellipsoidal fit
    fprintf(', obtaining orientation');
    prevData.objects = calculateCellOrientationEllipsoidalFit(prevData.objects, params);
    fprintf('         determining affected cells \n');
    
    evecsPreviousFrame = [prevData.objects.stats.Orientation_Matrix];
    firstEvecs = evecsPreviousFrame(:,1:3:end);
    
    centroidsPreviousFrame = [prevData.objects.stats.Centroid];
    x = round(centroidsPreviousFrame(1:3:end));
    y = round(centroidsPreviousFrame(2:3:end));
    z = round(centroidsPreviousFrame(3:3:end));
    
    % Propagate the first Eigenvectors  of the ellipsoidal fit for
    % one/two pixel(s)
    prevImSize = prevData.objects.ImageSize;
    
    % Check wether two objects can be merged here
    mergeList = cell(numel(x), 1);
    
    h = ProgressBar(numel(x));
    parfor i = 1:numel(x)
        h.progress;
        
        w_temp = labelmatrix(objects);
        
        Y = [x(i), y(i), z(i)];
        X = [Y; round(Y + 2*firstEvecs(:,i)'); round(Y - 2*firstEvecs(:,i)')];
        ind = sub2ind(prevImSize, X(:,2), X(:,1), X(:,3));
        
        mergeVol = unique(neighbourND(unique(neighbourND(unique(neighbourND(ind, objects.ImageSize)), objects.ImageSize)), objects.ImageSize));
        
        cellIDs = unique(w_temp(mergeVol));
        cellIDs = cellIDs(cellIDs>0);
        
        if numel(cellIDs) > 1
            shell = setxor(neighbourND(objects.PixelIdxList{cellIDs(1)}, objects.ImageSize), objects.PixelIdxList{cellIDs(1)});
            
            mergeListPerCell = zeros(numel(cellIDs)-1, 2);
            for j = 2:numel(cellIDs)
                % Check whether cells are neighbors
                if ~isempty(intersect(shell, objects.PixelIdxList{cellIDs(j)}))
                    mergeListPerCell(j-1, :) = [cellIDs(j) cellIDs(1)];
                end
            end
            mergeList{i} = mergeListPerCell;
        end
    end
    h.stop;
    
    % Merge the cells in w obtained from the parfor-loop
    mergeList(cellfun('isempty', mergeList)) = [];
    if ~isempty(mergeList)
        mergeListMat = zeros(sum(cellfun('size', mergeList, 1)), 2);
        ind = 1;
        for i = 1:numel(mergeList)
            mergeListMat(ind:ind+size(mergeList{i}, 1)-1, :) = mergeList{i};
            ind = ind + size(mergeList{i}, 1);
        end
        % Remove zeros
        mergeListMat(mergeListMat(:,1) == 0, :) = [];
        for i = 1:size(mergeListMat, 1)
            mergeListMat([false(i,2); mergeListMat(i+1:end,:)==mergeListMat(i,1)]) = mergeListMat(i, 2);
        end
        
        for i = 1:size(mergeListMat, 1)
            w(objects.PixelIdxList{mergeListMat(i,1)}) = mergeListMat(i,2);
        end
        fprintf('         %d cells corrected', size(mergeListMat, 1));
    else
        fprintf('         no cells corrected');
    end
    
    objects = conncomp(w);
    objects.stats = regionprops(objects, 'Area');
catch
    fprintf(' -> temporal correction not possible!');
end
displayTime(ticValue);