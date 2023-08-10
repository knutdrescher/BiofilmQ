%% Calculate autocorrelation
% returned values for zero3D/2D and rVec are in ?m
% autcorr3D/XY_mean are normalized averaged per stack
% autocorrXY_mean_par are for each z-plane starting at the bottom

function [zero3D, zero2D, zero2D_Substrate, rVec, autocorr3D_mean, autocorrXY_mean, autocorrXY_substrate, autocorrXY_mean_par, posPixFraction] = calculateAutocorrelation3D(imBW, params)


ticValue = displayTime;

imBW = logical(imBW);
if nargin < 2
    % Specify pixel spacing
    params.scaling = 0.0632; % unit: um
    
    % Resize the image by a factor of 0.25 to speed up processing and to get
    % rid of the cell fine-structure
    params.scaleFactor = 0.25;
    
    % Resolution of ACF in px
    params.dr = 1;
    
    params.dilation = 0;
    
    % If set to 0, the frame is not padded and correlation does not go to
    % zero for large values of r -> edge effects!
    params.fullFrame = 0;
end

% Dilate image
if params.dilation
    imBW = imdilate(imBW, ones(3,3,3));
end

% Rescale image
if params.scaleFactor ~= 1
    fprintf('    resizing image [scale = %.2f]\n', params.scaleFactor);
    %T = maketform('affine', [params.scaleFactor 0 0; 0 params.scaleFactor 0; 0 0 params.scaleFactor; 0 0 0;]);
    %R = makeresampler({'linear','linear','linear'},'circular'); %cubic interpolation causes artifacts
    %imBW = tformarray(imBW,T,R,[1 2 3],[1 2 3], ceil([size(imBW,1)*params.scaleFactor size(imBW,2)*params.scaleFactor size(imBW,3)*params.scaleFactor]),[],0);
    
    if size(imBW, 3) == 1
        T = affine2d([params.scaleFactor 0 0; 0 params.scaleFactor 0; 0 0 1]);
    else
        T = affine3d([params.scaleFactor 0 0 0; 0 params.scaleFactor 0 0; 0 0 params.scaleFactor 0; 0 0 0 1]);
    end
    imBW = imwarp(double(imBW), T, 'interp', 'linear', 'FillValues', 1);
end

posPixFraction = squeeze(sum(sum(imBW, 1), 2)./(size(imBW,1)*size(imBW,2)));

% Setup the binning parameters
% Maximum correlation length
r_max = size(imBW, 1);%min([size(imBW, 1)/2 size(imBW, 2)/2 size(imBW, 3)/2]);
fprintf('    correlating over length [d = %d px, %.1f um, dxyz = %.2f um/px, dr = %d px, dilation = %d, full frame = %d]\n', r_max, r_max*params.scaling, params.scaling, params.dr, params.dilation, params.fullFrame);

% Create binning vector
rVec = 0:params.dr:r_max;

% Calculate autocorrelation
autocorr3D_mean = NaN;
if size(imBW, 3) > 1
    %% full 3D
    fprintf('        -> in 3D');
    
    meanVal = mean(imBW(:));
    if params.fullFrame
        sX = size(imBW,1);
        sY = size(imBW,2);
        sZ = size(imBW,3);
        
        SFFT = 2*max([sX sY sZ]);
        correlationMap = meanVal*ones(SFFT,SFFT,SFFT);
        
        correlationMap(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1,...
            floor((SFFT-sZ)/2):floor((SFFT+sZ)/2)-1)= imBW;
        
        correlationMap_ref = zeros(SFFT,SFFT,SFFT);
        correlationMap_ref(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1,...
            floor((SFFT-sZ)/2):floor((SFFT+sZ)/2)-1) = 1;
    else
        correlationMap = imBW;
        correlationMap_ref = ones(size(imBW));
    end
    
    autocorr3D = abs(fftshift(ifftn(fftn(correlationMap).*conj(fftn(correlationMap)))));
    autocorr3D = autocorr3D - numel(correlationMap)*meanVal^2;
    autocorr3D_ref = abs(fftshift(ifftn(fftn(correlationMap_ref).*conj(fftn(correlationMap_ref)))));
    autocorr3D = autocorr3D./autocorr3D_ref;
    
    autocorr3D_mean = zeros(numel(rVec)-1, 1);
    autocorr3D_std = zeros(numel(rVec)-1, 1);
    
    % Determine center of image
    x_c_m = round(size(autocorr3D,1)/2);
    y_c_m = round(size(autocorr3D,2)/2);
    z_c_m = round(size(autocorr3D,3)/2);
    
    % Average ACF values along a shells centered at the image's center at
    % distances specified in "rVec"
    indFrame = find(autocorr3D);
    [x_c, y_c, z_c] = ind2sub(size(autocorr3D), indFrame);
    
    fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
    % Calculate distance of specific pixel to center of image
    dist = fhypot(x_c_m-x_c, y_c_m-y_c, z_c_m-z_c);
    
    for r_ind = 1:numel(rVec)-1
        indDist = find(dist > rVec(r_ind) & dist <= rVec(r_ind+1));
        
        ind = sub2ind(size(autocorr3D), x_c(indDist), y_c(indDist), z_c(indDist));
        autocorr3D_mean(r_ind, :) = mean(autocorr3D(ind));
        autocorr3D_std(r_ind, :) = std(autocorr3D(ind));
    end
    
    %autocorr3D_mean = autocorr3D_mean-min(autocorr3D_mean);
    %autocorr3D_std = autocorr3D_std/max(autocorr3D_mean);
    %autocorr3D_mean = autocorr3D_mean/max(autocorr3D_mean);
end

%% in xy-plane
fprintf(', for all xy-planes');
data_par = cell(size(imBW, 3), 1);
for z = 1:size(imBW, 3)
    data_par{z} = imBW(:,:,z);
end

[~, substrateID] = max(cellfun(@(x) sum(x(:)), data_par));

autocorrXY_mean_par = cell(size(imBW, 3), 1);
autocorrXY_std_par = cell(size(imBW, 3), 1);

parfor z = 1:size(imBW, 3)
    imBW_z = data_par{z};
    
    meanVal = mean(imBW_z(:));
    
    if params.fullFrame
        
        
        sX = size(imBW_z,1);
        sY = size(imBW_z,2);
        
        SFFT =2*max([sX sY]);
        
        correlationMap = meanVal*ones(SFFT,SFFT);
        
        correlationMap(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1) = imBW_z;

        correlationMap_ref = zeros(size(correlationMap,1),size(correlationMap,2));
        correlationMap_ref(floor((SFFT-sX)/2):floor((SFFT+sX)/2)-1,...
            floor((SFFT-sY)/2):floor((SFFT+sY)/2)-1) = 1;

    else
        correlationMap = imBW_z;
        correlationMap_ref = ones(size(imBW_z));
    end
    
    autocorrXY = autocorr2d(correlationMap);
    autocorrXY = autocorrXY - numel(correlationMap)*meanVal*meanVal;
    
    autocorrXY_ref = autocorr2d(ones(size(correlationMap_ref)));
    autocorrXY = autocorrXY./autocorrXY_ref;
    
    autocorrXY_mean_par{z} = zeros(numel(rVec)-1, 1);
    autocorrXY_std_par{z} = zeros(numel(rVec)-1, 1);
    
    % Determine center of image
    x_c_m = round(size(autocorrXY,1)/2);
    y_c_m = round(size(autocorrXY,2)/2);
    
    % Average ACF values along a shells centered at the image's center at
    % distances specified in "rVec"
    indFrame = find(autocorrXY);
    [x_c, y_c] = ind2sub(size(autocorrXY), indFrame);
    
    % Calculate distance of specific pixel to center of image
    dist = hypot(x_c_m-x_c, y_c_m-y_c);
    
    for r_ind = 1:numel(rVec)-1
        indDist = find(dist > rVec(r_ind) & dist <= rVec(r_ind+1));
        
        ind = sub2ind(size(autocorrXY), x_c(indDist), y_c(indDist));
        autocorrXY_mean_par{z}(r_ind, :) = nanmean(autocorrXY(ind));
        autocorrXY_std_par{z}(r_ind, :) = nanstd(autocorrXY(ind));
    end
    
    %autocorrXY_mean_par{z} = autocorrXY_mean_par{z}-min(autocorrXY_mean_par{z});
    %autocorrXY_std_par{z} = autocorrXY_std_par{z}/max(autocorr3D_mean);
    %autocorrXY_mean_par{z} = autocorrXY_mean_par{z}/max(autocorrXY_mean_par{z});
end

autocorrXY_mean = nanmean([autocorrXY_mean_par{:}], 2);
autocorrXY_std = nanstd([autocorrXY_mean_par{:}], [], 2);
autocorrXY_substrate = autocorrXY_mean_par{substrateID};

rVec = rVec/params.scaleFactor*params.scaling;

zero3D = rVec(find(autocorr3D_mean < 0, 1));
if isempty(zero3D)
    zero3D = NaN;
end
zero2D = rVec(find(autocorrXY_mean < 0, 1));
zero2D_Substrate = rVec(find(autocorrXY_substrate < 0, 1));

if isempty(zero2D)
    zero2D = NaN;
end
if isempty(zero2D_Substrate)
    zero2D_Substrate = NaN;
end
%plot(rVec(1:end-1), autocorr3D_mean, rVec(1:end-1), autocorrXY_mean);
%legend({'3D', '2D'});
displayTime(ticValue);

