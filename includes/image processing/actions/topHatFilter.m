%% Rolling ball filtering (TopHat)

function img1_topHat = topHatFilter(img1raw, params, silent)
if nargin < 3
    silent = 0;
end


if ~silent
    ticValue = displayTime;
    fprintf(' - top-hat filtering, slice-wise, disk-size [s=%d]', params.topHatSize);
end

tic
img1_topHat = zeros(size(img1raw));
%se = strel3d(params.topHatSize);
se = strel('disk',params.topHatSize);

%img1_topHat = imtophat(img1raw,se);
 parfor i=1:size(img1raw, 3)
     img = img1raw(:,:,i);  
     img1_topHat(:,:,i) = imtophat(img,se);
 end
 
if ~silent
    displayTime(ticValue);
end