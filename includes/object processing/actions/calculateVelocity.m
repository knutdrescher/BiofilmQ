function objects_t2 = calculateVelocity(objects_t1, objects_t2, params, init)

if nargin == 3
    init = 0;
end

if init
    velocity = num2cell(zeros(1, objects_t2.NumObjects));
    [objects_t2.stats.Track_Velocity] = velocity{:};
    return;
end

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
toUm = @(voxel, scaling) voxel.*params.scaling_dxy/1000;

try
    dt = (datenum(objects_t2.metadata.data.date) - datenum(objects_t1.metadata.data.date))*24*60*60;
    
    velocity = nan(numel(objects_t2.stats),1);
    
    % Identify dublicate parent entries
    parents = [objects_t2.stats.Track_Parent];
    
    % Get centroids of parents
    centroids_parents = [objects_t1.stats.Centroid];
    x_parents = centroids_parents(1:3:end);
    y_parents = centroids_parents(2:3:end);
    z_parents = centroids_parents(3:3:end);
    
    % Get centroids of current frame
    centroids = [objects_t2.stats.Centroid];
    x = centroids(1:3:end);
    y = centroids(2:3:end);
    z = centroids(3:3:end);
    
    % Find cells with parents
    parents(isnan(parents)) = 0;
    validCells = find(parents);
    
    % Calculate the moved distances
    x_parents = x_parents(parents(validCells));
    y_parents = y_parents(parents(validCells));
    z_parents = z_parents(parents(validCells));
    
    x = x(validCells);
    y = y(validCells);
    z = z(validCells);
    
    distances = fhypot(x-x_parents, y-y_parents, z-z_parents);
    
    % Calculate to um
    distances = toUm(distances);
    
    % Calculate velocities
    velocity(validCells) = distances/dt; % um/s
    
    % fprintf('      - velocities <v> [%f um/s]\n', nanmean(velocity));
    
    velocity = num2cell(velocity);
    [objects_t2.stats.Track_Velocity] = velocity{:};
catch err
    fprintf('%s\n', err.message);
end