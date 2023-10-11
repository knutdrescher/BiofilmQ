function [imgfilter, status, imgfilter_edge_filled, regMax, params] = ...
    edgeThresholding(handles, imgfilter, params, metadata, metadata_filename)

status = 0;
imgfilter_edge_filled = [];
regMax = [];

disp('== Finding cell outlines ==');

try
    displayStatus(handles, 'edge detection...', 'blue', 'add');
catch
    fprintf('edge detection...\n')
end

imgfilter(imgfilter<0) = 0;

% Calculating background
if params.I_base_perStack
    I_base = multithresh(imgfilter, 2);
    I_base = I_base(1);
    
    data = metadata.data;
    data.I_base = params.I_base;
    save(metadata_filename, 'data');
else
    if isempty(params.I_base)
        I_base = 0;
    else
        I_base = params.I_base;
    end
end
params.I_base = I_base;
fprintf(' - background: %0.2f\n', params.I_base);


if checkCancelButton(handles)
    return;
end

% Find the brightest (most crowded) plane to extract a threshold to remove
% the very low intensity background
ticValue = displayTime;
fprintf(' - step 1: LoG filtering, kernel size [k=%d]', params.kernelSize);

thres = I_base;

params.gamma = round(params.gamma);

imgfilter = imgfilter.^params.gamma;



% difference between 3D and 2D images
if ismatrix(imgfilter)
    
        % Create LoG filter for edge detection
    %sigma = paramsrnelSigma;
    fsize = params.kernelSize; %ceil(sigma*3) * 2 + 1;
    op_gauss = fspecial('gaussian',fsize);
    op_log = fspecial('log',fsize);
    %op_log = op_log - sum(op_log(:))/numel(op_log); % make the op to sum to zero
    % LoG filtering
    % Fast Method (lots of RAM!)

    % Pad image first
    padsize = size(op_log);
    imgfilter2_forConv = padarray(imgfilter, padsize, 'replicate');
    
    imLoG = convn(imgfilter2_forConv,op_log, 'same');
    % Crop the central part
    imLoG = imLoG(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2));

    displayTime(ticValue);
    %
    if checkCancelButton(handles)
        return;
    end
    
    img_edges_temp = zeroCrossings2D(imLoG, 1);
    % Fill the faces
    img_edges2 = padarray(img_edges_temp, [1 1], 1);
    clear img_edges_temp
    img_edges2(imLoG==0) = 1;
    
        
    
else
    % Create LoG filter for edge detection
    %sigma = paramsrnelSigma;
    fsize = params.kernelSize; %ceil(sigma*3) * 2 + 1;
    op_gauss = fspecial3('gaussian',fsize);
    op_log = fspecial3('log',fsize);
    %op_log = op_log - sum(op_log(:))/numel(op_log); % make the op to sum to zero
    % LoG filtering
    % Fast Method (lots of RAM!)

    % Pad image first
    padsize = size(op_log);
    imgfilter2_forConv = padarray(imgfilter, padsize, 'replicate');

    imLoG = convn(imgfilter2_forConv,op_log, 'same');

    % Crop the central part
    imLoG = imLoG(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2),1+padsize(3):end-padsize(3));

    displayTime(ticValue);
    %
    if checkCancelButton(handles)
        return;
    end
    % Finding edges by looking for zero-crossings
    img_edges_temp = zeroCrossings3D(imLoG, 1);
    % Fill the faces
    img_edges2 = padarray(img_edges_temp, [1 1 1], 1);
    clear img_edges_temp
    img_edges2(imLoG==0) = 1;
end

% Gaussian smoothing
fprintf(' - step 2: gaussian smoothing, kernel size [k=%d]', params.kernelSize);
ticValue = displayTime;
%imgfilter_smooth = smooth3(imgfilter2, 'gaussian', fsize, sigma);

imgfilter_smooth2 = convn(imgfilter2_forConv, op_gauss, 'same');
clear imgfilter2_forConv


if ismatrix(imgfilter_smooth2)
    imgfilter_smooth2 = imgfilter_smooth2(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2));
else
    imgfilter_smooth2 = imgfilter_smooth2(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2),1+padsize(3):end-padsize(3));
end

displayTime(ticValue);
if checkCancelButton(handles)
    return;
end
% Calculate the local maxima
ticValue = displayTime;
fprintf(' - step 3: detecting local maxima');
%imgfilter_smooth = -imgfilter_smooth2;
minLandscape = imgfilter_smooth2;
minLandscape = max(minLandscape(:))-minLandscape;
%minLandscape = imLoG;

regMax = imregionalmin(minLandscape);

regMax(~imgfilter) = 0;
regMax(imgfilter<(I_base)^params.gamma) = 0;

regMax(img_edges2) = 0;
regMax(imLoG>=0) = 0;
clear imLoG

% Finding indices of Maxima
regMaxInd = find(regMax);
displayTime(ticValue);

if checkCancelButton(handles)
    return;
end
% Filling 3D
ticValue = displayTime;
fprintf(' - step 4: filling 3D');
imgfilter_edge_filled = imfill(img_edges2, regMaxInd, 6);
imgfilter_edge_filled(imgfilter<(I_base)^params.gamma) = 0;
displayTime(ticValue);

status = 1;
