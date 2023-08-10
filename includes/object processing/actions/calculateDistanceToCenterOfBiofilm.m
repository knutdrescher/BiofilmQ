function objects = calculateDistanceToCenterOfBiofilm(objects)

ticValue = displayTime;

N = objects.NumObjects;


goodObjects = objects.goodObjects;

coords = [objects.stats.Centroid];

x = coords(1:3:end);
y = coords(2:3:end);
z = coords(3:3:end);

x_ = x(goodObjects);
y_ = y(goodObjects);
z_ = z(goodObjects);

CM = [mean(x_), mean(y_), mean(z_)];

toUm = @(voxel, scaling) voxel.*scaling/1000;

% Calculate distances
fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);

distanceToCenter = fhypot(CM(1)-x, CM(2)-y, CM(3)-z);
distanceToCenterOfBiofilm = fhypot(CM(1)-x, CM(2)-y, min(z)-z);

distanceToCenter = num2cell(toUm(distanceToCenter, objects.params.scaling_dxy));
distanceToCenterOfBiofilm = num2cell(toUm(distanceToCenterOfBiofilm, objects.params.scaling_dxy));

distanceToCenter(~goodObjects) = {NaN};
distanceToCenterOfBiofilm(~goodObjects) = {NaN};

[objects.stats.Distance_ToBiofilmCenter] = distanceToCenter{:};
[objects.stats.Distance_ToBiofilmCenterAtSubstrate] = distanceToCenterOfBiofilm{:};

fprintf('   - CM: [x=%.02f, y=%.02f, z=%.02f]', CM(1), CM(2), CM(3));
displayTime(ticValue);
