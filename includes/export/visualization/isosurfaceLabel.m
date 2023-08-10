function cells = isosurfaceLabel(w_mask_label, objects, resolution, custom_fields, params, ellipseRepresentation)
fprintf(' - step 1: creating isosurfaces ');
%% Label Matrix after watershedding
%clearvars -except mask w_mask_label objects
if nargin == 5
    ellipseRepresentation = 0;
else
    if ellipseRepresentation
        fprintf(' (elliptical representation)');
    end
end
% Create vertices and faces for all cells
ticValue = displayTime;
fprintf('\n');

cells = struct;

if isfield(objects, 'goodObjects')
    goodObjects = objects.goodObjects;
else
    goodObjects = true(objects.NumObjects, 1);
end

Ncells = double(max(w_mask_label(:)));
M = cell(Ncells, 1);

%textprogressbar('      ');
%for chunk = 1:1200:Ncells
%    textprogressbar(chunk/Ncells*100);
%endInd = chunk+1199;
%if endInd > Ncells
%    endInd = Ncells;
%end


%Create this to reduce overhead for parfor loop
BB = [objects.stats.BoundingBox];
BoundingBox = cell(6,1);
BoundingBox{1} = BB(1:6:end);
BoundingBox{2} = BB(2:6:end);
BoundingBox{3} = BB(3:6:end);
BoundingBox{4} = BB(4:6:end);
BoundingBox{5} = BB(5:6:end);
BoundingBox{6} = BB(6:6:end);


rotation = params.visualization_rotation;
rotation_axis = params.visualization_rotation_axis;

ticValue = displayTime;

%parfor i = chunk:endInd %1:double(max(w_mask_label(:)));;

if params.obtainConnectedStructure
    fprintf('      -> one object ID only');
    w = labelmatrix(objects);
    [~, ind] = max(histc(w(:), 1:max(w(:))));
    w = (w==ind);
    
    w(:, :, 1) = 0;
    w(1, :, :) = 0;
    w(end, :, :) = 0;
    w(:, 1, :) = 0;
    w(:, end, :) = 0;
    
    objects.stats = objects.stats(ind);
    
    [Xmask, Ymask, Zmask] = meshgrid(1:size(w,2),1:size(w,1),1:size(w,3));
    [F,V, ~] = MarchingCubes(Xmask,Ymask, Zmask, w, 0.5);
    P = struct;
    P.faces = F;
    P.vertices = V;
    if resolution < 1
        M{1} = reducepatch(P, resolution);
    else
        M{1} = P;
    end
else
    
    centroids = {objects.stats.Centroid};
    h = ProgressBar(round(Ncells/20));
    if ellipseRepresentation
        evecsArray = {objects.stats.Orientation_Matrix};
        lengths = [objects.stats.Shape_Length] / (objects.params.scaling_dxy/1000);
        heights = [objects.stats.Shape_Height] / (objects.params.scaling_dxy/1000);
        widths = [objects.stats.Shape_Width] / (objects.params.scaling_dxy/1000);
        
        parfor i = 1:Ncells
            if ~mod(i, 20)
                h.progress;
            end
            if goodObjects(i)
                coords = centroids{i};
                evecs = evecsArray{i};
                clength = lengths(i);
                cheight = median(widths);
                cwidth = median(widths);
                X = coords';
                [x, y, z, ~] = ellipsoid_plot_analysis(X, evecs(:, 1), evecs(:, 2), evecs(:, 3), ...
                    clength / 2, cheight / 2, cwidth / 2);
                
                
                cell3D = surf2patch(x,y,z, 'triangles');
                
                try
                    if resolution < 1
                        cell3D = reducepatch(M{i}, resolution);
                        if isempty(cell3D.faces)
                            cell3D = M{i};
                        end
                    end
                end
                
                if rotation
                    cell3D = rotatePatch(cell3D, rotation, rotation_axis);
                end
                
                M{i} = cell3D;
                
            end
        end
    else
        PixelIdxList = objects.PixelIdxList;
        ImageSize = objects.ImageSize;
        if numel(ImageSize) == 2
            ImageSize(3) = 1;
        end
        
        parfor i = 1:Ncells
            if ~mod(i, 20)
                try
                    h.progress;
                end
            end
            if goodObjects(i)
                
                x = floor(BoundingBox{1}(i)):ceil(BoundingBox{1}(i)+BoundingBox{4}(i));
                y = floor(BoundingBox{2}(i)):ceil(BoundingBox{2}(i)+BoundingBox{5}(i));
                z = floor(BoundingBox{3}(i)):ceil(BoundingBox{3}(i)+BoundingBox{6}(i));
                
                w_mask_label_par = false(ImageSize(1), ImageSize(2), ImageSize(3));
                w_mask_label_par(PixelIdxList{i}) = true;
                
                single_cell_matrix = w_mask_label_par(y(2:end-1), x(2:end-1), z(2:end-1)) == true;
                single_cell_matrix = padarray(single_cell_matrix, [1 1 1]);
                
                [Xmask, Ymask, Zmask] = meshgrid(x,y,z);
                
                
                if resolution < 1
                    
                    S = size(single_cell_matrix,1)*size(single_cell_matrix,2)*size(single_cell_matrix,3);
                    
                    if S < 100000
                        P = isosurface(Xmask,Ymask, Zmask, single_cell_matrix, 0.5);
                    else
                        %disp('marching cubes');
                        [F,V, ~] = MarchingCubes(Xmask,Ymask, Zmask, single_cell_matrix, 0.5);
                        P = struct;
                        P.faces = F;
                        P.vertices = V;
                    end
                    
                    cell3D = reducepatch(P, resolution);
                    if isempty(cell3D.faces)
                        cell3D = P;
                    end
                        
                else
                    cell3D = isosurface(Xmask,Ymask, Zmask, single_cell_matrix, 0.5);
                end
                
                if rotation
                    cell3D = rotatePatch(cell3D, rotation, rotation_axis);
                end
                M{i} = cell3D;
            end
        end
        
    end
    h.stop;
    fprintf('         %d cells processed', sum(goodObjects));
end

%textprogressbar(100);
%textprogressbar(' Done');

displayTime(ticValue);
ticValue = displayTime;
fprintf(' - step 2: tagging');


% Determine Array length
counter = 1;
verticesLength = 0;
facesLength = 0;

for i = 1:length(M)
    if ~isempty(M{i})
        if counter > 1
            verticesLength(counter) = verticesLength(counter-1) + size(M{i}.vertices,1);
            facesLength(counter) = facesLength(counter-1) + size(M{i}.faces,1);
        else
            verticesLength(counter) = size(M{i}.vertices,1);
            facesLength(counter) = size(M{i}.faces,1);
        end
        counter = counter + 1;
    end
end

verticesLengthTotal = verticesLength(end);
facesLengthTotal = facesLength(end);
cells.vertices = zeros(verticesLengthTotal, 3);
cells.faces = zeros(facesLengthTotal, 3);

% Custom fields
counter = 1;


for i = 1:length(custom_fields)
    cells.(custom_fields{i}) = zeros(verticesLengthTotal,1);
end

errorMsg = 0;
missingFields = {};
for i = 1:length(M)
    if ~isempty(M{i})
        numFaces(counter) = size(M{i}.faces,1);
        numVertices(counter) = size(M{i}.vertices,1);
        
        if counter > 1
            add = add+numVertices(counter-1);
        else
            add = 0;
        end
        
        if counter > 1
            cells.faces(facesLength(counter-1)+1:facesLength(counter),:) = M{i}.faces+add;
            cells.vertices(verticesLength(counter-1)+1:verticesLength(counter),:) = M{i}.vertices;
        else
            cells.faces(1:facesLength(counter), :) = M{i}.faces+add;
            cells.vertices(1:verticesLength(counter), :) = M{i}.vertices;
        end
        
        %cells.faces = [cells.faces; M{i}.faces+add];
        %cells.vertices = [cells.vertices; M{i}.vertices];
        
        %Custom fields
        for j = 1:length(custom_fields)
            switch custom_fields{j}
                case 'ID'
                    customVar = counter;
                case 'CentroidCoordinate_x'
                    customVar = objects.stats(i).Centroid(1);
                case 'CentroidCoordinate_y'
                    customVar = objects.stats(i).Centroid(2);
                case 'CentroidCoordinate_z'
                    customVar = objects.stats(i).Centroid(3);
                case 'Distance_FromSubstrate'
                    customVar = objects.stats(i).Centroid(3)*objects.params.scaling_dxy/1000;
                case 'RandomNumber'
                    customVar = 1000*rand;
                    %customVar = objects.stats(i).Centroid(3)*params.scaling_dxy/1000;
                otherwise
                    if isfield(objects.stats, custom_fields{j})
                        customVar = objects.stats(i).(custom_fields{j});
                    else
                        missingFields = union(missingFields, custom_fields{j});
                    end
            end
            
            
            
            try
                if counter > 1
                    cells.(custom_fields{j})(verticesLength(counter-1)+1:verticesLength(counter),:) = customVar*ones(size(M{i}.vertices,1),1);
                else
                    cells.(custom_fields{j})(1:verticesLength(counter),:) = customVar*ones(size(M{i}.vertices,1),1);
                end
            catch
                errorMsg = 1;
            end
        end
        
        counter = counter + 1;
    end
end

if errorMsg
    disp('-> An error ocurred!');
end
displayTime(ticValue);

if ~isempty(missingFields)
    missingFields = cellfun(@(x) [x, ', '], missingFields, 'UniformOutput', false);
    missingFields = [missingFields{:}];
    missingFields = missingFields(1:end-2);
    warning('off','backtrace')
    warning('Fields [%s] not found in data!', missingFields);
    warning('on','backtrace')
end

function cell3D = rotatePatch(cell3D, theta, rotation_axis)
switch rotation_axis
    case 1 % Rotation around x-axis
        R = [1 0 0; 0 cosd(theta) -sind(theta); 0 sind(theta) cosd(theta)];
    case 2 % Rotation around y-axis
        R = [cosd(theta) 0 sind(theta); 0 1 0; -sind(theta) 0 cosd(theta)];
    case 3 % Rotation around z-axis
        theta = -1*theta;
        R = [cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1];
end

vR = [cell3D.vertices(:,1) cell3D.vertices(:,2) cell3D.vertices(:,3)]*R;
cell3D.vertices(:,1) = vR(:,1);
cell3D.vertices(:,2) = vR(:,2);
cell3D.vertices(:,3) = vR(:,3);
