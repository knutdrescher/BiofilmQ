function objects = connectCells(objects, params)
ticValue = displayTime;

% Find biggest "cell" to which all shall be connected
w = labelmatrix(objects);

% Remove the bottom 27 planes
% w = w(:,:,1:end);

w(:,:,1:7) = max(w(:));
% add socket by adding 7 solid planes at the bottom

objects = bwconncomp(w>0);
stats = regionprops(objects, 'Centroid');
objects.stats = stats;
w = labelmatrix(objects);
[~, ind] = max(histc(w(:), 1:max(w(:))));


fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);

Ncells = double(max(w(:)));

fprintf(', N = %d cells are affected \n', Ncells);

%% Calculate distances to nearest neighbors
centroids = cell(3,1);
cc = [objects.stats.Centroid];
centroids{1} = cc(1:3:end);
centroids{2} = cc(2:3:end);
centroids{3} = cc(3:3:end);

parfor i = 1:Ncells
    if i ~= ind
        distances(i) = fhypot(centroids{1}(i)-centroids{1}(1), centroids{2}(i)-centroids{2}(1), centroids{3}(i)-centroids{3}(1));
    else
        distances(i) = 0;
    end
end

[distances, ind_dist] = sort(distances);
%%


bridgeVoxels = cell(1, Ncells);

ImageSize = objects.ImageSize;
PixelIdxList = objects.PixelIdxList;

%% Note: the following loop can also run as parfor loop, but then the bridges ar not as nice. In case it is run as parfor loop at indicated locations the code has to be changed

h = ProgressBar(Ncells);
w_par = labelmatrix(objects);
w_par_illu = w_par;

farAwayCells = 0;
for c = 1:Ncells
    i = ind_dist(c);
    
    h.progress;
    
    %% for the parforloop
    %w_par = labelmatrix(objects);
    
    
    if i ~= ind
        %fprintf('\n      bridging cell #%d', i);
        
        % Enlarge cell
        shell = setxor(neighbourND(PixelIdxList{i}, ImageSize), PixelIdxList{i});
        
        bridgeVox_smallStruct = 0;
        bridgeVox_largeStruct = 0;
        
      
        distance = 0;
        cancel = 0;
        while ~cancel
            % Test for overlap
            try
                o = find(w_par(shell)==ind);
                if ~isempty(o)
                   
                    
                    
                    % Find the shortest connection
                    minDist = zeros(numel(o), 1);
                    ind_minDist = zeros(numel(o), 1);
                    
                    for j = 1:numel(o)
                        [x_p, y_p, z_p] = ind2sub(ImageSize, shell(o(j)));
                        [x_s, y_s, z_s] = ind2sub(ImageSize, PixelIdxList{i});
                        dist = fhypot(x_p-x_s, y_p-y_s, z_p-z_s);     
                        [minDist_temp, ind_minDist_temp]  = min(dist);
                        minDist(j) = minDist_temp;
                        ind_minDist(j) = ind_minDist_temp;
                    end
                    [~, ind_minDist_large] = min(minDist);
                    
                    bridgeVox_largeStruct = shell(o(ind_minDist_large));
                    bridgeVox_smallStruct = PixelIdxList{i}(ind_minDist(ind_minDist_large));
                    
                    
%                     % Enlarge the found voxel to hit the single cell
%                     shell2 = setxor(neighbourND(bridgeVox_largeStruct, ImageSize), bridgeVox_largeStruct);
%                     distance2 = 0;
%                     cancel2 = 0;
%                     while ~cancel2
%                         try
%                             o2 = intersect(shell2, PixelIdxList{i});
%                             if ~isempty(o2)
%                                  
%                                 % Find the point with the closest distance
%                                  [x_p, y_p, z_p] = ind2sub(ImageSize, o(ind_minDist));
%                                  [x_s, y_s, z_s] = ind2sub(ImageSize, o2);
%                                  dist2 = fhypot(x_p-x_s, y_p-y_s, z_p-z_s);     
%                                  [~, ind_minDist2] = min(dist2);
%                                  
%                                 bridgeVox_smallStruct = o2(ind_minDist2);
%                                 break;
%                             end
%                             shell2 = union(neighbourND(shell2, ImageSize), shell2);
%                             distance2 = distance2 + 1;
%                             
%                             if distance2 > 30
%                                 cancel2 = 1;
%                             end
%                             
%                         catch
%                             cancel2 = 1;
%                         end
%                     end
                    
                    break;
                end
                
                shell = union(neighbourND(shell, ImageSize), shell);
                distance = distance + 1;
                
                if distance > 30
                    cancel = 1;
                end
            catch
                cancel = 1;
            end
        end
        
        if bridgeVox_smallStruct*bridgeVox_smallStruct > 0
            % Connect pixels
          
            [x1, y1, z1] = ind2sub(ImageSize, bridgeVox_smallStruct);
            [x2, y2, z2] = ind2sub(ImageSize, bridgeVox_largeStruct);
            
            steps = max([abs(x2-x1), abs(y2-y1), abs(z2-z1)]);
            
            %fprintf(' [bridge-length=%d]', steps);
            
            %X = round(linspace(min([x1 x2])-0.5, max([x1 x2])+0.5, steps));
            %Y = round(linspace(min([y1 y2])-0.5, max([y1 y2])+0.5, steps));
            %Z = round(linspace(min([z1 z2])-0.5, max([z1 z2])+0.5, steps));
            
            X = round(linspace(x1, x2, steps));
            Y = round(linspace(y1, y2, steps));
            Z = round(linspace(z1, z2, steps));
            
            ind_bridge = sub2ind(ImageSize, X, Y, Z);
            
            % Pump up bridge volume
            ind_bridge = union(neighbourND(ind_bridge, ImageSize), ind_bridge);
            
            bridgeVoxels{i} = ind_bridge;
        else
            %fprintf(' -> cell could not be bridged -> removed');
            bridgeVoxels{i} = [];
            farAwayCells = farAwayCells + 1;
        end
        
        %% for the for-loop
        if isempty(bridgeVoxels{i})
            w_par(PixelIdxList{i}) = 0;
            
            w_par_illu(PixelIdxList{i}) = ind+3;
        else
            w_par(bridgeVoxels{i}) = ind;
            w_par(PixelIdxList{i}) = ind;
            
            w_par_illu(bridgeVoxels{i}) = ind+1;
            w_par_illu(PixelIdxList{i}) = ind+2;
        end
    end
end
%% For the for-loop
 w = w_par;
%% For the parfor loop
% for i = 1:Ncells
%     if i ~= ind
%         if isempty(bridgeVoxels{i})
%             w(PixelIdxList{i}) = 0;%ind+3;
%             fprintf('\n     cell %d could not be bridged -> removed', i);
%         else
%             w(bridgeVoxels{i}) = ind+1;
%             w(PixelIdxList{i}) = ind+2;
%         end
%     end
% end
h.progress;
h.stop;
fprintf('      %d cells were removed (to far away from main volume)', farAwayCells);
fprintf(' - dilating cells');
% Dilate image
cube = zeros(3,3);
cube(:,:,1) = [0 0 0; 0 1 0; 0 0 0];
cube(:,:,2) = [0 1 0; 1 1 1; 0 1 0];
cube(:,:,3) = [0 0 0; 0 1 0; 0 0 0];
w = imdilate(w>0, cube);
 
objects = bwconncomp(w);

fprintf(', found %d objects', objects.NumObjects);
stats = regionprops(objects, 'Area', 'Centroid', 'BoundingBox');
objects.stats = stats;
toUm3 = @(voxel, scaling) voxel.*(scaling/1000)^3; %input in voxels and voxel side length in µm
% Calculating real units and rename the field area into volume
Volume = num2cell(toUm3([objects.stats.Area], params.scaling_dxy)); % µm
[objects.stats.Shape_Volume] = Volume{:};
objects.stats = rmfield(objects.stats, 'Area');
objects.goodObjects = true(1, objects.NumObjects);

displayTime(ticValue);






