function [objects, nematicOrderParameter_mean] = calculateNematicOrdering(objects, params, range)

ticValue = displayTime;

objects = calculateAlignments(objects, params);

if ~isfield(objects.stats, 'Orientation_Matrix')
    % Determine ellipsoid first
    fprintf(' - determining ellipsoidal fit');
    objects = calculateAspectRatios(objects, params);
end
% Calculate cellular local nematic order parameter S
nematicOrderParameter = zeros(objects.NumObjects,1);
N_cells = zeros(objects.NumObjects,1);
evecs_global = {objects.stats.Orientation_Matrix};
centroids_global = {objects.stats.Centroid};
goodObjects = objects.goodObjects;
N = objects.NumObjects;

parfor i = 1:N
    try
        evecs = evecs_global{i};
        
        vec1 = evecs(:,1); % Take the longest Eigenvector
        centroid = centroids_global{i};
        
        [cells_sortedByDistance, distances] = getNeighborCells_centroids(centroid, centroids_global, goodObjects, params.scaling_dxy);
        
        % Kick out the first cell if there are more than 1 cells
        if numel(cells_sortedByDistance) > 1
            cells_sortedByDistance = cells_sortedByDistance(2:end);
            distances = distances(2:end);
        end
        distances = distances./(params.scaling_dxy/1000);
        
        % Find cells with in range
        cells_inRange = cells_sortedByDistance(distances < range);
        
        % Go through the cells in range and calculate the nematic order
        % parameter S
        S = zeros(numel(cells_inRange), 1);

        if ~isempty(cells_inRange)
            vec1_ = repmat(vec1, 1, numel(cells_inRange));

            % all evecs are concatenated to matrix, every third column is
            % the longest eigenvector of each object.
            evecs2_ = [evecs_global{cells_inRange}];
            vec2_ = evecs2_(:, 1:3:end);
            
            % Vectorized dot product calculated dot column by column:
            % [vec1, ..., vec1] * [vec2_1, vec2_2, ... , vec2_#cells_inRange]
            %  = [vec1 * vec2_1, vec1 * vec2_2 ... ]
            S = 1.5*dot(vec1_, vec2_).^2-0.5;
        end
        
        nematicOrderParameter(i) = mean(S);
        N_cells(i) = numel(cells_inRange);
    catch err
        nematicOrderParameter(i) = NaN;
        N_cells(i) = 0;
        disp(['    - nematic order could not be determined for cell #', num2str(i)]);
    end
end

nematicOrderParameter_mean = nanmean(nematicOrderParameter);
nematicOrderParameter = num2cell(nematicOrderParameter);
[objects.stats.(sprintf('Architecture_NematicOrderParameter_range%d', range))] = nematicOrderParameter{:};
fprintf('   - [%d vox] on average calculated over %d cells, <S>=%.02f', range, round(nanmean(N_cells)), nematicOrderParameter_mean);
displayTime(ticValue);

