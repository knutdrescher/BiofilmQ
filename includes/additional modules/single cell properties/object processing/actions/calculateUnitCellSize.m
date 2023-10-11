function objects = calculateUnitCellSize(objects, params)

ticValue = displayTime;

N = objects.NumObjects;
unitCellSize = nan(N,1);

coords = [objects.stats.Centroid];
x = coords(1:3:end);
y = coords(2:3:end);
z = coords(3:3:end);


try
    [V, C] = voronoin([x' y' z']);
catch
    fprintf('      - SKIPPING FRAME (too few cells)');
    unitCellSize = num2cell(unitCellSize);
    [objects.stats.Architecture_UnitCellSize] = unitCellSize{:};
    displayTime(ticValue);
    return;
end

parfor i = 1:N
    if ~isnan(sum(sum(V(C{i}, :)))) && ~isinf(sum(sum(V(C{i}, :))))
        try
            [~, unitCellSize(i)] = convhulln([V(C{i}, 1), V(C{i}, 2), V(C{i}, 3)], {'Qt','Pp'});
        catch
            unitCellSize(i) = NaN;
            disp(['    - unit cell size could not be determined for cell #', num2str(i)]);
        end
    else
        unitCellSize(i) = NaN;
        disp(['    - unit cell size could not be determined for cell #', num2str(i)]);
    end
end

toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3;
unitCellSize = toUm3(unitCellSize, params.scaling_dxy);


unitCellSize_median = nanmedian(unitCellSize);
fprintf('    - <U>=%.02f', unitCellSize_median);

unitCellSize = num2cell(unitCellSize);
[objects.stats.Architecture_UnitCellSize] = unitCellSize{:};
displayTime(ticValue);

