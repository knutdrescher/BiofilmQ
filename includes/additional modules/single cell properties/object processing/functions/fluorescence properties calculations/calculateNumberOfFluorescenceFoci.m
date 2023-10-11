function objects = calculateNumberOfFluorescenceFoci(objects, img, ch, range)

range2 = round((range-1)/2);

rangeMask = 5;
center = median(1:rangeMask);
mask = ones(rangeMask,rangeMask,rangeMask); 
mask(center, center, center)=0;
localMaxima = img{ch} > imdilate(img{ch}, mask);
localMaxima(labelmatrix(objects)==0) = 0;
localMaximaIdx = find(localMaxima);
maximaInt = img{ch}(localMaximaIdx);

quality = zeros(numel(maximaInt), 1);
intensity = zeros(numel(maximaInt), 1);

sX = size(localMaxima);
for i = 1:numel(maximaInt)
    try
        if numel(objects.ImageSize) == 3
            [x, y, z] = ind2sub(sX, localMaximaIdx(i));
            tmp = img{ch}(x-range2:x+range2,y-range2:y+range2,z-range2:z+range2);
            tmp_small = img{ch}(x-1:x+1,y-1:y+1,z-1:z+1);
        else
            [x, y] = ind2sub(sX, localMaximaIdx(i));
            tmp = img{ch}(x-range2:x+range2,y-range2:y+range2);
            tmp_small = img{ch}(x-1:x+1,y-1:y+1);
        end
        intensity(i) = mean(tmp_small(:));
        Isum = sum(tmp_small(:));
        quality(i) = intensity(i)/((sum(tmp(:)) - Isum)/(numel(tmp)-numel(tmp_small)));
        % In a random image or local maxima are below 0.5 or 0.55
    end
end

%         % Compare with random image
%         im_rand = rand(size(img_processed_noNoise{ch}));
%         localMaxima_rand = im_rand > imdilate(im_rand, mask);
%         localMaxima_rand(labelmatrix(objects)==0) = 0;
%         localMaximaIdx_rand = find(localMaxima_rand);
%         maximaInt = im_rand(localMaximaIdx_rand);
%
%         quality_rand = zeros(numel(maximaInt), 1);
%         intensity_rand = zeros(numel(maximaInt), 1);
%
%         sX = size(im_rand);
%         for i = 1:numel(maximaInt)
%             try
%                 [x, y, z] = ind2sub(sX, localMaximaIdx_rand(i));
%                 tmp = im_rand(x-range2:x+range2,y-range2:y+range2,z-range2:z+range2);
%                 tmp_small = im_rand(x-1:x+1,y-1:y+1,z-1:z+1);
%                 intensity_rand(i) = mean(tmp_small(:));
%                 %quality_rand(i) = intensity_rand(i)/(mean(tmp(:)) - intensity_rand(i));
%                 Isum = sum(tmp_small(:));
%                 quality_rand(i) = intensity_rand(i)/((sum(tmp(:)) - Isum)/(numel(tmp)-numel(tmp_small)));
%                 % In a random image or local maxima are below 0.5 or 0.55
%             end
%         end
%
%
%figure;
%plot(hist(quality, 1000)); hold on; plot(hist(quality_rand, 1000));

% Calculate cutoff
% cutoff = prctile(quality_rand, 99.9);
% validMaxima = find(quality > cutoff);
% localMaximaIdx = localMaximaIdx(validMaxima);
% intensity = intensity(validMaxima);
% quality = quality(validMaxima);

% New appoach by automatic thresholding
cutoff = multithresh(quality, 2);
validMaxima = find(quality > cutoff(2));
localMaximaIdx = localMaximaIdx(validMaxima);
intensity = intensity(validMaxima);
quality = quality(validMaxima);

fprintf('       - found %d foci [range: %d]\n', numel(validMaxima), range);

% Calculate number of maxima per cell
foci_number = cell(1, objects.NumObjects);
foci_idx = cell(1, objects.NumObjects);
foci_intensity = cell(1, objects.NumObjects);
foci_quality = cell(1, objects.NumObjects);

for i = 1:objects.NumObjects
    [N, fociIdx] = intersect(localMaximaIdx, objects.PixelIdxList{i});
    foci_number{i} = numel(N);
    foci_idx{i} = localMaximaIdx(fociIdx);
    foci_intensity{i} = intensity(fociIdx);
    foci_quality{i} = quality(fociIdx);
end

[objects.stats.(sprintf('Foci_Number_ch%d_range%d', ch, range))] = foci_number{:};
[objects.stats.(sprintf('Foci_Idx_ch%d_range%d', ch, range))] = foci_idx{:};
[objects.stats.(sprintf('Foci_Intensity_ch%d_range%d', ch, range))] = foci_intensity{:};
[objects.stats.(sprintf('Foci_Quality_ch%d_range%d', ch, range))] = foci_quality{:};

end
