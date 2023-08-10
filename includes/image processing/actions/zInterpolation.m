%% z-Interpolation
function img_normalized_resized = zInterpolation(img_normalized, dxy, dz, params, silent)

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
nZ_new = round(size(img_normalized, 3)*resizeFactor);
nX = round(size(img_normalized,1)*scaleFactor);
nY = round(size(img_normalized,2)*scaleFactor);

% Sophisticated with 3x3 interpolation

%T = maketform('affine', [scaleFactor 0 0; 0 scaleFactor 0; 0 0 resizeFactor; 0 0 0;]);
%R = makeresampler({'linear','linear','linear'},'replicate'); %cubic interpolation causes artifacts
%img_normalized_resized = tformarray(img_normalized,T,R,[1 2 3],[1 2 3], [nX nY nZ_new],[],0);

% Faster:
T = affine3d([scaleFactor 0 0 0; 0 scaleFactor 0 0; 0 0 resizeFactor 0; 0 0 0 1]);
img_normalized_resized = imwarp(img_normalized, T, 'interp', 'linear', 'FillValues', 0);

% Crop central part (in previous version the central part was always
% cropped!)
if isfield(params, 'blindDeconvolution')
    if params.blindDeconvolution
        img_normalized_resized = img_normalized_resized(:,:,4:end-4);
    end
end

if ~silent
    fprintf(', new size: [x=%d, y=%d, z=%d] (scale-factor=%.02f)', size(img_normalized_resized,1), size(img_normalized_resized,2), size(img_normalized_resized,3), scaleFactor);
    ticValue = displayTime(ticValue);
end

% parallized version of imresize
% chunksZ = 2:10:size(img_normalized, 3);
% if chunksZ(end) ~= size(img_normalized, 3)+1;
%     chunksZ(end+1) = size(img_normalized, 3)-1;
% end
%
% im_chunk = cell(1,numel(chunksZ)-1);
% im_chunk_res = cell(1,numel(chunksZ)-1);
%
% for i = 1:numel(chunksZ)-1
%     im_chunk{i} = img_normalized(:,:,chunksZ(i)-1:chunksZ(i+1)+1);
% end
%
% parfor i = 1:numel(chunksZ)-1
%     i
%     if i == 1
%         sZ_temp = chunksZ(i+1)-(chunksZ(i)-1)+1;
%     elseif i == numel(chunksZ)-1
%         sZ_temp = chunksZ(i+1)+1-chunksZ(i)+1;
%     else
%         sZ_temp = chunksZ(i+1)-chunksZ(i)+1;
%     end
%
%     nZ_new_temp{i} = ceil(sZ_temp*resizeFactor);
%
%     T = maketform('affine', [scaleFactor 0 0; 0 scaleFactor 0; 0 0 resizeFactor; 0 0 0;]);
%     R = makeresampler({'linear','linear','linear'},'circular'); %cubic interpolation causes artifacts
%     im_chunk_res{i} = tformarray(im_chunk{i},T,R,[1 2 3],[1 2 3], [nX nY nZ_new_temp{i}],[],0);
% end
%
% img_normalized_resized2 = zeros(nX, nY, nZ_new);
% for i = 1:numel(chunksZ)-1
%     img_normalized_resized2(:,:,chunksZ(i)-1:chunksZ(i+1)+1) = im_chunk_res{i};
% end