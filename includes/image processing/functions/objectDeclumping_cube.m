function [objects, imgfilter, ImageContentFrame] = objectDeclumping_cube(handles, params, imgfilter_edge_filled, imgfilter, prevData)

disp(' - step 2: finding connected components');
    w = imgfilter_edge_filled;
    w = bwlabeln(w);

    if checkCancelButton(handles)
        toggleBusyPointer(handles, false);
        return;
    end

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
            if params.waitForMemory
                checkMemory(handles, 30);
            end
            w_med = ordfilt3D(w>0, 14);
        end
        w(~w_med) = 0;

        displayTime(ticValue);
    end

    if checkCancelButton(handles)
        return;
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

    if checkCancelButton(handles)
        return;
    end

    
    %% Removing small objects
    fprintf(' - step 4: remove small objects\n');
    if params.removeVoxels
        w = bwareaopen(w, params.removeVoxelsOfSize); 
    end
    
    
    objects = cubeSegmentation(w, params.gridSpacing,imgfilter);
    
    

