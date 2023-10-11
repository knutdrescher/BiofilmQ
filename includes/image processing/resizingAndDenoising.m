function [img, params] = resizingAndDenoising(img1raw, metadata, params, silent)
if nargin == 3
    silent = 0;
end

if ~silent
    disp(' -> Preparing image');
end
%% Scaling information
dxy = metadata.data.scaling.dxy; %nm;
dz = metadata.data.scaling.dz; %nm;

img = img1raw;
    
%% Perform SVD of xz-planes
if params.svd && size(img, 3) > 1
    img = performSVD(img, 0, silent);
end
   
%% z-Interpolation
if size(img, 3) > 1
    img = zInterpolation(img, dxy, dz, params, silent);
end

%% Do either denoising or Rolling Ball (Top-hat filter)
if params.denoiseImages
    %% Smoothing by convolution
    img = convolveBySlice(img, params, silent);
end

%% Rotate image
if params.rotateImage && size(img, 3) > 1
    [img, params] = rotateBiofilmImg(img, params, silent);
end

if params.topHatFiltering
    %% Rolling ball filtering (TopHat)
    img = topHatFilter(img, params);
end
