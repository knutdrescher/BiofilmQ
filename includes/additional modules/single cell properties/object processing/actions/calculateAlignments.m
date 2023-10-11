function objects = calculateAlignments(objects, params)
ticValue = displayTime;

if ~isfield(objects.stats, 'Orientation_Matrix')
    objects = calculateObjectSizeAndOrientationEllipsoidalFit(objects);
end

Alignment_Flow = nan(objects.NumObjects, 1);
Alignment_Zaxis = nan(objects.NumObjects, 1);
Alignment_Radial = nan(objects.NumObjects, 1);


coords = [objects.stats.Centroid];
x = coords(1:3:end);
y = coords(2:3:end);
z = coords(3:3:end);

min_z = min(z);

if isempty(min_z)
    min_z = NaN;
end

CM = [mean(x), mean(y), min_z];


radial_vec = [x'-CM(1), y'-CM(2), z'-CM(3)];
    
N = objects.NumObjects;

evecs = {objects.stats.Orientation_Matrix};

try
    flowDirection = [params.flowDirection 0];
catch
    flowDirection = [0 0 0];
end

parfor i=1:N
    try
        Alignment_Radial(i) = acos(abs(dot(evecs{i}(:,1),radial_vec(i,:)))/(norm(radial_vec(i,:))));
        Alignment_Zaxis(i) = acos(abs(dot(evecs{i}(:,1),[0 0 1])));
    catch
        fprintf('          WARNING: angle (radial, z) for cell #%d cannot be determined!\n', i);
    end
    try
        Alignment_Flow(i) = acos(abs(dot(evecs{i}(:,1),flowDirection))/norm(flowDirection));
    catch
        fprintf('          WARNING: angle (flow) for cell #%d cannot be determined!\n', i);
    end
end

Alignment_Flow2 = num2cell(Alignment_Flow);
[objects.stats.Alignment_Flow] = Alignment_Flow2{:};
Alignment_Zaxis2 = num2cell(Alignment_Zaxis);
[objects.stats.Alignment_Zaxis] = Alignment_Zaxis2{:};
Alignment_Radial2 = num2cell(Alignment_Radial);
[objects.stats.Alignment_Radial] = Alignment_Radial2{:};

fprintf(' - <Alignment_Flow>=%.02f, <Alignment_Zaxis>=%.02f, <Alignment_Radial>=%.02f', nanmean(Alignment_Flow), nanmean(Alignment_Zaxis), nanmean(Alignment_Radial));
displayTime(ticValue);