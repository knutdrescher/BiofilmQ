function w = objectDeclumpingByWatershedding(handles, imgfilter, imgfilter_edge_filled, regMax, params, f)

%% Watershedding part
disp(' - step 2: watershedding');

fsize = params.kernelSize+round((0.2*params.kernelSize)/2)*2; %ceil(sigma*3) * 2 + 1;

if ismatrix(imgfilter)
    cube = [0 1 0; 1 1 1; 0 1 0];
    op_gauss = fspecial('gaussian',fsize);
    
else
    imgfilter_edge_filled(:, :, [1:2, end-1:end]) = 0;
    
    cube = zeros(3,3,3);
    cube(:,:,1) = [0 0 0; 0 1 0; 0 0 0];
    cube(:,:,2) = [0 1 0; 1 1 1; 0 1 0];
    cube(:,:,3) = [0 0 0; 0 1 0; 0 0 0];
    
    op_gauss = fspecial3('gaussian',fsize);
    
end



% Clear sides
imgfilter_edge_filled([1:2, end-1:end],:,:) = 0;
imgfilter_edge_filled(:,[1:2, end-1:end],:) = 0;


if ~params.skipDeclumpingFirstFrame || f > 1
    watershedMap = imgfilter;
    
    %% Distance transform
    if params.cutIndentions
        % Erode cells by one pixel to remove non-filled outlines and reduce the size
        imgfilter_edge_filled_dist = imerode(imgfilter_edge_filled, cube);
        
        ticValue = displayTime;
        fprintf('      step 2a: calculating distance-map');
        distMap = bwdist(1-imgfilter_edge_filled_dist)*params.cutIndentions+1;
        watershedMap = watershedMap.*distMap;
        ticValue = displayTime;
    else
        disp('      step 2a: skipping calculation of distance-map (not wanted)');
    end
    
    %% Enhancing maxima
    watershedMap(regMax) = 10*watershedMap(regMax);
    
    %% Smoothing
    ticValue = displayTime;
    
    fprintf('      step 2b: smoothing, kernel size [k=%d]\n', fsize);
    

    
    padsize = size(op_gauss);
    watershedMap = padarray(watershedMap, padsize, 'replicate');

    imgfilter_smooth_ws = convn(watershedMap, op_gauss, 'same');

    
    if ismatrix(imgfilter)
        imgfilter_smooth_ws2 = imgfilter_smooth_ws(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2));
    else
        imgfilter_smooth_ws2 = imgfilter_smooth_ws(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2),1+padsize(3):end-padsize(3));
    end
    
    imgfilter_smooth_ws2 = -imgfilter_smooth_ws2;
    if checkCancelButton(handles)
        return;
    end
    
    
    %% Masking image
    imgfilter_smooth_ws2(~imgfilter_edge_filled) = 1;
    
    %% watershedding
    w = watershed3D(imgfilter_smooth_ws2);    

    % Set largest object (background) to 0
    [~, ind] = max(histc(w(:), 1:max(w(:))));
    w(w==ind) = 0;
else
    disp(' - step 2: watershedding -> skipped (first frame)');
    w = imgfilter_edge_filled;
    w = bwlabeln(w);
end