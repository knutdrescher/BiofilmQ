function objects = calculateDistanceToObjectID(objects, cellID)

ticValue = displayTime;

if ~isempty(cellID)
    if isfield(objects.stats, 'Cube_CenterCoord')
        coords = [objects.stats.Cube_CenterCoord];
    else
        coords = [objects.stats.Centroid];
    end
    x = coords(1:3:end);
    y = coords(2:3:end);
    z = coords(3:3:end);
    
    try
        CM = [x(cellID) y(cellID) z(cellID)];
    catch ME
        if strcmp(ME.identifier, 'MATLAB:badsubscript')
            fprintf('   - Error: distance to specific object cannot be calculated [reason: %s]', ME.message);
            return
        else
            rethrow(ME)
        end
    end
    
    toUm = @(voxel, scaling) voxel.*scaling/1000;
    
    fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
    
    distanceToSpecificCell = fhypot(CM(1)-x, CM(2)-y, CM(3)-z);
    
    distanceToSpecificCell = num2cell(toUm(distanceToSpecificCell, objects.params.scaling_dxy));
    
    [objects.stats.(sprintf('Distance_ToObject_id%d', cellID))] = distanceToSpecificCell{:};
    
    fprintf('   - distance to cell %d: [x=%.02f, y=%.02f, z=%.02f]', cellID, CM(1), CM(2), CM(3));
else
    fprintf('   - WARNING: distance to specific object cannot be calculated [reason: no object ID specified]');
end
displayTime(ticValue);

