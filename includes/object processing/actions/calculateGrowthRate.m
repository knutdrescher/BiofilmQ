function objects_t2 = calculateGrowthRate(objects_t1, objects_t2, params, init)

if nargin == 3
    init = 0;
end

if init
    growthRate = num2cell(zeros(1, objects_t2.NumObjects));
    [objects_t2.stats.Track_GrowthRate] = growthRate{:};
    
    volumeLossDispersingCells = num2cell(zeros(1, objects_t2.NumObjects));
    [objects_t2.stats.Track_VolumeLossDispersingCells] = volumeLossDispersingCells{:};
    return;
end
    
try
    dt = (datenum(objects_t2.metadata.data.date) - datenum(objects_t1.metadata.data.date))*24*60*60;
    
    v1 = [objects_t2.stats.Shape_Volume];
    v2 = [objects_t1.stats.Shape_Volume];
    
    coords2 = {objects_t1.stats.Centroid};
    
    parents = [objects_t2.stats.Track_Parent];
    newCells = find(parents == 0);
    lostCells = setdiff(objects_t1.NumObjects, parents);
    
    volumeLossDispersingCells = zeros(1, objects_t2.NumObjects);
    growthRate = zeros(1, objects_t2.NumObjects);
    growthRate(newCells) = v1(newCells);
    
    parentIDs = unique(parents(parents>0));
    for p = 1:numel(parentIDs)
        siblings = find(parents == parentIDs(p));
        growthRate(siblings) = ((sum(v1(siblings)) - v2(parentIDs(p)))/numel(siblings));
    end
    
    
    % Assign the volume loss from dispersed cells to the closest by
    % remaining cell
    for j = 1:numel(lostCells)
        [indObj_exp, distances] = getNeighborCells(coords2{lostCells(j)}, objects_t2, params);
        %fprintf('%d, ', indObj_exp(2));
        growthRate(indObj_exp(2)) = growthRate(indObj_exp(2)) - v2(lostCells(j));
        volumeLossDispersingCells(indObj_exp(2)) = - v2(lostCells(j));
    end
    
    growthRate = num2cell(growthRate / (dt/60) );
    [objects_t2.stats.Track_GrowthRate] = growthRate{:};
    
    volumeLossDispersingCells = num2cell(volumeLossDispersingCells / (dt/60) );
    [objects_t2.stats.Track_VolumeLossDispersingCells] = volumeLossDispersingCells{:};
catch err
    fprintf('%s\n', err.message);
end