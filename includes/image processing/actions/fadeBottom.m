function img1raw = fadeBottom(img1raw, params, silent)

if nargin < 3
    silent = 0;
end

if ~silent
    fprintf(' - fading bottom');
end

I = squeeze(sum(sum(img1raw, 1), 2));

[~, ind] = max(I);

fadeBelow = ind+ceil(params.fadeBottomLength/(params.scaling_dz/1000));

if fadeBelow < 1
    fprintf(' -> fading not possible\n');
else
    if ~silent
        fprintf(', [fading slices=%d]\n', fadeBelow);
    end
    
    i = fadeBelow;
    count = 2;
    while i>0
        img1raw(:,:,i) = img1raw(:,:,i)/count;
        count = count * 2;
        i = i-1;
    end
end