function debug_output(X, imgfilter_thresh, max_dist, cutoff_drop, k, cluster)
    % What do I need for a descriptive output:
    % - Characteristic maxima distances
    % - Cluster locations 
    % - Cluster connections
    % - drops between clusters
    
    ticValue = displayTime;
    fprintf('Calculate all valid connection between maxima')
    valid = false(size(X, 1));
    size_ = size(imgfilter_thresh);

    parfor i = 1:size(X, 1)
        valid_ = false(size(X, 1), 1);
        for j = 1:i-1
            [cx, cy, cz] = Bresenham3D(X(i, 1), X(i, 2), X(i, 3), X(j, 1), X(j, 2), X(j, 3));
            profile = imgfilter_thresh(sub2ind(size_, cx, cy, cz));
            if ~any(profile == 0)
                valid_(j) = true;
            end
        end
        valid(i, :) = valid_;
    end
    displayTime(ticValue);
    
    valid_full = logical((valid + valid'));
    
    
    
    fprintf('\nNumber of points: %d\n', size(X, 1))
    
    tic;
    dist_full = pdist(X);
    d_full = squareform(dist_full);
    toc;
    d_full_nan = d_full;
    d_full_nan(~valid_full) = nan;
    
    d_nearest = zeros(size(d_full_nan));
    for i = 1:size(d_nearest,1)
        d_nearest(i, :) = sort(d_full_nan(i,:), 'ascend');
    end

    
    
    
    max_dist = max(d_full_nan(:))+1;
    
%     tic;
%     dist = pdist(X, @(p1, p2) distance_drop(p1, p2, imgfilter_thresh, max_dist, true));
%     toc;
    
    d = nan(size(X, 1));
    
     size_ = size(imgfilter_thresh);

    tic;
    parfor i = 1:size(X, 1)
        d_ = nan(size(X, 1), 1);
        for j = 1:i-1 % do not count distances twice
            [cx, cy, cz] = Bresenham3D(X(i, 1), X(i, 2), X(i, 3), X(j, 1), X(j, 2), X(j, 3));

            profile = imgfilter_thresh(sub2ind(size_, cx, cy, cz));

            if any(profile == 0) % crosses forbidden area
                d_(j) = -Inf;
            else
                l = linspace(double(profile(1)), double(profile(end)), numel(profile));
                profile_ = double(profile)-l;
                d_(j) = min(profile_);
            end
        end
        d(i, :) = d_;
    end
    toc;
    
        
    d_dim = d;
    d_dim(isinf(d_dim)) = nan;
    d_dim(isnan(d_dim)) = 0;
    d_dim = d_dim + d_dim';
    d_dim(~valid_full) = -Inf;
    orders = zeros(size(d_dim));
    for i = 1:size(d_dim,1)
        [d_dim(i, :), orders(i, :)] = sort(d_dim(i, :), 'descend');
    end
    
    %
    offset = 0:size(orders, 1)-1;
    offset = offset * size(orders, 2);
    orders_ = orders + offset';

    
    max_img = max(imgfilter_thresh, [], 3);
    
    intMax = imgfilter_thresh(sub2ind(size_, X(:, 1), X(:, 2), X(:, 3)));
    
    fprintf('Valid connetions: %d\n', sum(valid(:)));
    
    f1 = figure();
    ax1 = axes(f1);
    hold(ax1, 'on');
    histogram(intMax, 100);
    title(ax1, sprintf('%d Run: Intensities local maxima', k))
   
   
    f2 = figure();
    ax2 = axes(f2);
    hold(ax2, 'on');
    histogram(ax2, d_full(valid), 100);
    title(ax2, sprintf('%d Run: All valid distances', k));
    

    f3 = figure();
    ax3 = axes(f3);
    hold(ax3, 'on');
    histogram(ax3, d(valid), 100);
    title(ax3, sprintf('%d Run: Intensity drop between valid distances', k));
    
    f = figure();
    dscatter(d(valid), d_full(valid));
    title( sprintf('%d Run: Correlation Drop vs. Distance', k));
    xlabel(gca, 'Drop')
    ylabel(gca, 'Distance')
    
    f6 = figure();
    ax6 = axes(f6);
    hold(ax6, 'on');
    histogram(d_nearest(:, 1))
    title(ax6, sprintf('%d Run: Shortest distance to next maxima', k));
    

    
    
    f7 = figure();
    ax7 = axes(f7);
    hold(ax7, 'on');
    d_n = d_nearest(:, 1) ;
    dscatter(intMax(~isnan(d_n)), d_n(~isnan(d_n)));
    title(ax7, sprintf('%d Run: Maxima intensity vs. distance nearest neigbor', k));
    xlabel(ax7, 'Max. Intensity')
    ylabel(ax7, 'Distance nearest neigbor')
    
    if true% HARD CODED!
        f4 = figure();
        ax4 = axes(f4);
        hold(ax4, 'on');
        imagesc(ax4, max_img);
        scatter(ax4, X(:, 2), X(:, 1), 'r', 'filled');
        title(ax4, sprintf('%d Run: 2D projection of all seeds', k));
        
        
        [~, ~, ic] = unique(cluster);
        clustercounts = arrayfun(@(x) sum(ic == x), 1:max(ic));
        clusterdist = arrayfun(@(x) mean(pdist(X(ic == x, :))), 1:max(ic));
        
        f8 = figure();
        ax8 = axes(f8);
        hold(ax8, 'on');
        scatter(ax8, clustercounts, clusterdist, 'filled')
        title(ax8, sprintf('%d Run: Cluster size vs. mean distance', k));
        xlabel(ax8, 'Number of points in cluster');
        ylabel(ax8, 'Mean distance in the cluster');
        
        
        f9 = figure();
        ax9 = axes(f9);
        hold(ax9, 'on');
        histogram(ax9, sum(valid_full));
        title(ax9, sprintf('%d Run: Number of valid connections for each node', k))
        
        f10 = figure();
        ax10 = axes(f10);
        hold(ax10, 'on')
        imagesc(ax10, max(imgfilter_thresh, [], 3));
        
        for i = 1:size(d_dim, 1)
            for j_ = 1:2
                j = orders(i, j_);
                if valid(i,j)
                    plot3(ax10, [X(j, 2), X(i, 2)],[X(j, 1), X(i, 1)], [X(j, 3), X(i, 3)])
                end
            end
        end
        
        title(ax10, sprintf('%d Run: Connection along 2 lowest drops', k))
        
        
        f11 = figure();
        ax11 = axes(f11);
        hold(ax11, 'on')        
        x_ = d_full(orders_(:, 1:2));
        y_ = d_dim(:, 1:2);
        x_ = x_(:);
        y_ = y_(:);
        x_ = x_(~isinf(y_));
        y_ = y_(~isinf(y_));
        dscatter(x_(~isnan(x_)),y_(~isnan(y_)))
        title(ax11, sprintf('%d Run: Correlation lowest 2 drop vs distance', k))
        xlabel(ax11, 'Distances')
        ylabel(ax11, 'Drop value')
        
        
        f5 = figure();
        ax5 = axes(f5);
        hold(ax5, 'on')
        imagesc(ax5, max(imgfilter_thresh, [], 3));
        cmap = colormap();
        
        c = round(d/ min(d(valid)) * 63) + 1;
        
        for i = 1:numel(cluster)
            idcs = find(cluster == i);
            
            scatter3(ax5, X(idcs, 2), X(idcs, 1), X(idcs, 3), [], 'filled');
            for j_ = 1:numel(idcs)
                for k_ = 1:j_ - 1
                    
                    j = idcs(j_);
                    k = idcs(k_);
                    
                    if valid(j,k) && d(j,k) > -2000
                        try
                            plot3(ax5, [X(j, 2), X(k, 2)],[X(j, 1), X(k, 1)], [X(j, 3), X(k, 3)], 'Color', cmap(c(j,k), :))
                        catch e
                            rethrow(e)
                        end
                    end
                    
                end
            end
        end
        title(ax5, sprintf('%d Run: Cluster connections', k))
        
    end
    

    

end