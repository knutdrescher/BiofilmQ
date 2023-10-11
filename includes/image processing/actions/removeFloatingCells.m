function img1raw = removeFloatingCells(img1raw, silent)
ticValue = displayTime;

if nargin < 2
    silent = 0;
end

if ~silent
    fprintf(' - removing floating cells');
end

if size(img1raw, 3) > 1
    parfor i = 1:size(img1raw, 1)
        img1raw(i, :, :) = min(cat(3, medfilt2(squeeze(img1raw(i, :, :)), [1 3]), squeeze(img1raw(i, :, :))), [], 3);
    end
else
    fprintf(' -> 2D image (cancelled)');
end

if ~silent
    displayTime(ticValue);
end