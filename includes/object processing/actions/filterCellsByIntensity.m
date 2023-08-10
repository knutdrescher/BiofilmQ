function objects = filterCellsByIntensity(objects, filterField, logScale, thresh)

% The filterFields ID, x, y, z are not really measurment files but set by
% the segmentation, thus we have to extract them first
if strcmp(filterField, 'ID')
    meanInt = 1:numel(objects.stats);
elseif strcmp(filterField, 'CentroidCoordinate_x')
    meanInt = cellfun(@(x) x(1), {objects.stats.Centroid});
elseif strcmp(filterField, 'CentroidCoordinate_y')
    meanInt = cellfun(@(x) x(2), {objects.stats.Centroid});
elseif strcmp(filterField, 'CentroidCoordinate_z')
    meanInt = cellfun(@(x) x(3), {objects.stats.Centroid});
else
    meanInt = double([objects.stats.(filterField)]);
end


if isempty(meanInt)
    return;
end

if nargin < 4
    h = figure;
    h_ax = axes('Parent', h);
    title(h_ax, 'Please select threshold');
    
    
    
    if logScale
        minInt = min(meanInt);
        if minInt == 0
            minInt = 0.1;
        end
        maxInt = max(meanInt);
        if minInt >= maxInt
            maxInt = minInt + 1;
        end
        
        x = logspace(log10(minInt), log10(maxInt), 250);
    else
        x = linspace(min(meanInt), max(meanInt), 250);
    end
    try
        if numel(unique(meanInt)) < 5
            x = unique(meanInt);
        end
        N = histc(meanInt, x);
    catch
        N = 0;
    end
    
    if numel(N) >= 5
        plot(h_ax, x, N, '.-'); hold on;
    else
        plot(h_ax, x, N, 'o-'); hold on;
    end
    
    try
        xlim(h_ax, [0.9*min(x) 1.1*max(x)]);
    end
    
    if logScale && min(x) > 0
        set(h_ax, 'XScale', 'log');
        set(h_ax, 'YScale', 'log');
    end
    %ylimits = get(gca, 'ylim');
    %ylimits(1) = 0.8;
    %set(gca, 'ylim', ylimits);
    [label, unit] = returnUnitLabel(filterField);
    
    xlabel(h_ax, sprintf('%s %s', label, unit));
    ylabel(h_ax, 'Counts');
    
    
    drawnow
    
    % if nargin >= 5
    %     disp(' - filtering cells');
    %     ylimits = get(gca, 'ylim');
    %
    %     if abs(thresh(1))< Inf
    %         plot([thresh(1) thresh(1)], [ylimits(1) ylimits(2)]);
    %     end
    %     if abs(thresh(2))<Inf
    %         plot([thresh(2) thresh(2)], [ylimits(1) ylimits(2)]);
    %     end
    %
    % %     [~, file] = fileparts(filename);
    % %     title(file, 'Interpreter', 'none');
    %     xlabel(filterField, 'Interpreter', 'none');
    %     ylabel('counts');
    %
    %     drawnow;
    %
    %     pause(0.5);
    % end
else
    
    if thresh(1) == -Inf
        objects.goodObjects = (meanInt <= thresh(2))';
    elseif thresh(2) == Inf
        objects.goodObjects = (meanInt >= thresh(1))';
    elseif thresh(1)==Inf && thresh(2) == Inf
        objects.goodObjects = ones(length(meanInt),1);
    else
        objects.goodObjects = (meanInt <= thresh(2))' & (meanInt >= thresh(1))';
    end
    
end

