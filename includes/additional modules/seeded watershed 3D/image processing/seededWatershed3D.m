function w = seededWatershed3D(imgfilter,imgfilter_bw, regMax, cell_thresh)

% imgfilter - intinsity values of stack
% regMax - stack with true in local maxima
% imgfilter_bw - stack with foreground/ background segmentation (0 back, 1
% foreground);

% TODO:
% - Limit debug output to necessary output to determine the hyperparameters

% Optimization ideas:
% - Kick out local maxima which are below a certain threshold
% - Do not consider local maxima in an volume smaller than the expected
% cell size (or a fraction of it)

% Uasge:
% - We want to create first a slight oversegmentation to kick out unwantd
% maxima

% TODO: Find a good way for calculating the max distance.
max_dist = 100;

imgfilter_thresh = imgfilter_bw .* double(imgfilter);

ids = find(regMax);
[x, y, z] = ind2sub(size(regMax), ids);
X = [x, y, z];


%% Iteratively reduce number of maxima
fprintf('- step 1a: Reduce number of maxima');

ticValue = displayTime;

if size(X, 1) >= cell_thresh

fprintf([   '\t Calculate connections between %d maxima\n', ...'
            '\t\t Max distance: %f\n'], size(X, 1), max_dist);

dist = pdist(X, @(p1, p2) distance_drop(p1, p2, imgfilter_thresh, max_dist, true));
valid = ~isnan(dist) & ~isinf(dist);

cutoff_drop = multithresh(dist(valid));

fprintf('\t\t Drop threshold: %f', cutoff_drop);

cutoffTest =  @(i, j, d) ~isnan(d(i, j)) & ~isinf(-d(i, j)) & (d(i, j) > cutoff_drop);
cluster = getCluster(dist, cutoffTest);

X = reduceSeeds(X, cluster);

else
    fprintf([...
            '\t Only %d maxima\n', ...'
            '\t\t %d smaller than required number for maxima reduction  (%d)\n' ...
            '\t\t -> Skip seed reduction.'], ...
        size(X, 1), size(X, 1), cell_thresh);
end

displayTime(ticValue);


%% Seeded watershed algorithm
% From: github.com/tomasvicar/Cell-segmentation-methods-comparison/blob/master/final_segmentation/seeded_watershed.m
ticValue = displayTime;
fprintf('-step 1c: Perform watershed with %d seeds', size(X, 1));

points = false(size(imgfilter_thresh));
points(sub2ind(size(points), X(:, 1), X(:, 2), X(:, 3))) = true;

imp = imimposemin(-imgfilter_thresh, points);

final_seg=double(watershed(imp)>0).* imgfilter_bw;

L = -imimposemin(-final_seg, points)>0;
displayTime(ticValue);

ticValue = displayTime;
fprintf('-step 1d: Fill watershed ridges')
w = fillWatershedRidges(L, imgfilter_bw);
displayTime(ticValue);

end



function reduced_seeds = reduceSeeds(X, cluster)
% Perform principal component analysis to determine a reaonable represant
% for the all maxima within the cluster.

c_ = unique(cluster);

reduced_seeds = zeros(numel(c_), 3);
    for i = 1:numel(c_)
        idcs = find(cluster == c_(i));

        if numel(idcs) > 2
            [~, score, ~] = pca(X(idcs, :));
            [~, id_c] = min(norm(score));
            reduced_seeds(i, :) = X(idcs(id_c), :);

        elseif numel(idcs) == 2
            reduced_seeds(i, :) = round(mean(X(idcs, :), 1));

        else
            reduced_seeds(i, :) = X(idcs, :);
        end
    end
end


function w = fillWatershedRidges(L, imgfilter_bw)
ridges = imgfilter_bw & ~L;

rid_objs = bwconncomp(ridges);

w = bwlabeln(L);
bins = 1:max(w(:))+1;

imSize = size(imgfilter_bw);

for i = 1:rid_objs.NumObjects
    pixelIdxList = rid_objs.PixelIdxList{i};
    neighbors = neighbourND(pixelIdxList, imSize);
    neighbors(neighbors == 0) = [];

    [val, idx] = max(histcounts(w(neighbors), bins));
    if val > 0
        w(pixelIdxList) = idx;
    end
end
    
end