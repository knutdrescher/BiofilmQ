function [objects, imgfilter, ImageContentFrame] = ...
    objectDeclumping_seededWatershed3D( ...
    handles, params, imgfilter_bw, imgfilter, prevData, regMax)


    disp('3D Watershedding algorithm')


    debug = true;

    %% based on segmenation image
    N = sum(regMax(:));

    if debug
        fprintf('Number of maxima: %d\n', N);
    end

    % ToDo: Maybe we can reduce number of local maxima by thresholding
    % multithresh(imgfilter_thresh(:))

    ticValue = displayTime;
    w = seededWatershed3D(imgfilter, imgfilter_bw, regMax, params.seededWatershedCellThresh);

    displayTime(ticValue);

    % copied from decolumping None
    disp(' - step 2: finding connected components');
    % Remove bottom
    try
        if params.removeBottomSlices
            if params.removeBottomSlices < size(w, 3)
                w = w>0;
                w(:,:,1:params.removeBottomSlices) = [];
                imgfilter(:,:,1:params.removeBottomSlices) = [];
                w = bwlabeln(w);
            else
                warning('backtrace', 'off');
                warning('Cannot remove %d bottom slice(s), as biofilm is not thick enough!', params.removeBottomSlices)
                warning('backtrace', 'on');
            end
        end
    end
    
    if params.median3D
        ticValue = displayTime;
        fprintf('      step 3b: 3D median filter');
        %imgfilter_edge_filled = medfilt3(imgfilter_edge_filled, [3 3 3]);

        try
            w_med = medfilt3(w>0);
        catch
            params.waitForMemory = false;
            if params.waitForMemory
                checkMemory(handles, 30);
            end
            w_med = ordfilt3D(w>0, 14);
        end
        w(~w_med) = 0;

        displayTime(ticValue);
    end


    % Paste image into reference frame
    if params.fixedOutputSize && params.imageRegistration
        ticValue = displayTime;
        fprintf('      step 3c: padding image');

        w = applyReferencePadding(params, w);
        [imgfilter, x, y] = applyReferencePadding(params,imgfilter);

        ImageContentFrame = [min(x) max(x) min(y) max(y)];

        displayTime(ticValue);
    else
        ImageContentFrame = [];
    end

    
    %% Finding connected components
    fprintf(' - step 4: finding connected components');
    ticValue = displayTime;
    objects = conncomp(w);
    fprintf(', found %d objects', objects.NumObjects);
    displayTime(ticValue);
    
    
    %% Removing small objects
    fprintf(' - step 5: obtain object sizes\n');
    objects.stats = regionprops(objects, 'Area');
    
    % Remove one pixel structures
    area = [objects.stats.Area];
    if params.removeVoxels
        smallObj = area < params.removeVoxelsOfSize;
        smallObjInd = find(smallObj);
        if ~isempty(smallObjInd)
            fprintf('      removing %d small cells (< %d voxels)\n', sum(smallObj), params.removeVoxelsOfSize);
            objects.PixelIdxList = objects.PixelIdxList(~smallObj);
            objects.NumObjects = sum(~smallObj);
            objects.stats = objects.stats(~smallObj);
        end
    else
        smallObj = area==1;
        smallObjInd = find(smallObj);
        if ~isempty(smallObjInd)
            fprintf('      removing %d very small cells (1 vox)\n', sum(smallObj));
            objects.PixelIdxList = objects.PixelIdxList(~smallObj);
            objects.NumObjects = sum(~smallObj);
            objects.stats = objects.stats(~smallObj);
        end
    end

    
    %% Parameter calculation
    stats = regionprops(objects, imgfilter, 'Area', 'MeanIntensity', 'Centroid', 'BoundingBox');
    objects.stats = stats;

    


