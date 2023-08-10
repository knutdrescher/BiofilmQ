function imgfilter_bw = threshBySlice(imgfilter, smooth_factor, debug)

switch nargin
    case 1
        smooth_factor = 25;
        debug = false;
        
    case 2
        debug = false;
        
    case 3
        % pass
        
    otherwise
        error('Invalid number of input argmuments');
end

thresh = size(imgfilter, 3);

validZSlices = squeeze(sum(sum(imgfilter, 1), 2))>0;
validXSlices = squeeze(sum(sum(imgfilter, 2), 3))>0;
validYSlices = squeeze(sum(sum(imgfilter, 1), 3))>0;


% Would be even better if I threshold only on the real data and interpolate
% afterwards.
parfor z_ = 1:size(imgfilter, 3)
    if validZSlices(z_)
    thresh(z_) = multithresh(imgfilter(validXSlices,validYSlices,z_));
    
    else
        thresh(z_) = Inf;
    end
end
thresh2 = smooth(thresh,smooth_factor);

%% debug
if debug
    figure()
    hold on
    plot(thresh)
    plot(thresh2)
end
% idx = convhull(1:numel(thresh), thresh)
% idx(end) = [];
% thresh_convex = thresh(idx);


imgfilter_bw = zeros(size(imgfilter));

for z_ = 1:size(imgfilter, 3)
    imgfilter_bw(:, :, z_) = imgfilter(:, :, z_) > thresh2(z_);
end

%% debug
if debug
    imwrite3D(imgfilter_bw, 'imgfilter_bw.tif')
end

return


    
