% Works likes bwconncomp but also for labelled images (by Raimo Hartmann)
% Inputs:
%     w: labelled matrix 

function objects = conncomp(w)

NumObjects = max(w(:));
temp = regionprops(w, 'PixelIdxList');

objects.PixelIdxList = {temp.PixelIdxList};

if size(w,3) > 1
    objects.Connectivity = 26;
else
    objects.Connectivity = 8;
end

objects.ImageSize = size(w);
objects.NumObjects = NumObjects;
