%% z-Interpolation
function img_normalized_resized = zInterpolation_nearest(img_normalized, dxy, dz, params, silent)

if nargin == 4
    silent = 0;
end

if ~silent
    fprintf(' - resize Biofilm');
end

if size(img_normalized, 3) == 1
    fprintf(' -> skipped (2D image!)');
    img_normalized_resized = img_normalized;
    return;
end

if dz == dxy
    fprintf(' -> skipped (scaling along xy and z is already equal)\n');
    img_normalized_resized = img_normalized;
    return;
end

ticValue = displayTime;

if params.scaleUp
    scaleFactor = params.scaleFactor;
else
    scaleFactor = 1;
end

dxy = dxy/scaleFactor;

% Calculate the ratio
resizeFactor = dz/dxy;

T = affine3d([scaleFactor 0 0 0; 0 scaleFactor 0 0; 0 0 resizeFactor 0; 0 0 0 1]);
img_normalized_resized = imwarp(img_normalized, T, 'interp', 'nearest', 'FillValues', 0);

% Crop central part (in previous version the central part was always
% cropped!)
if isfield(params, 'blindDeconvolution')
    if params.blindDeconvolution
        img_normalized_resized = img_normalized_resized(:,:,4:end-4);
    end
end

if ~silent
    fprintf(', new size: [x=%d, y=%d, z=%d] (scale-factor=%.02f)', size(img_normalized_resized,1), size(img_normalized_resized,2), size(img_normalized_resized,3), scaleFactor);
    displayTime(ticValue);
end