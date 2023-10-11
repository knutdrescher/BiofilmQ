function objects = calculateInterCellSpacing(objects, params, searchRadius)

ticValue = displayTime;

fprintf('    - preparing data');

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
toUm = @(voxel, scaling) voxel.*scaling/1000;

PixelIdxList = objects.PixelIdxList;
goodObjects = objects.goodObjects;
PixelIdxList(~goodObjects) = {[]};

img_idx = vertcat(PixelIdxList{:});
if ischar(searchRadius)
    searchRadius = str2num(searchRadius);
end

resolution = 0.05;

%% Calculate vertices and faces
w_mask_label = labelmatrix(objects);

Ncells = objects.NumObjects;

M = cell(Ncells, 1);

% Create this to reduce overhead for parfor loop
BB = [objects.stats.BoundingBox];
BoundingBox = cell(6,1);
BoundingBox{1} = BB(1:6:end);
BoundingBox{2} = BB(2:6:end);
BoundingBox{3} = BB(3:6:end);
BoundingBox{4} = BB(4:6:end);
BoundingBox{5} = BB(5:6:end);
BoundingBox{6} = BB(6:6:end);

ImageSize = objects.ImageSize;
if numel(ImageSize) == 2
    ImageSize(3) = 1;
end

h = ProgressBar(Ncells);
parfor i = 1:Ncells
    h.progress;
    if goodObjects(i)
        
        x = floor(BoundingBox{1}(i)):ceil(BoundingBox{1}(i)+BoundingBox{4}(i));
        y = floor(BoundingBox{2}(i)):ceil(BoundingBox{2}(i)+BoundingBox{5}(i));
        z = floor(BoundingBox{3}(i)):ceil(BoundingBox{3}(i)+BoundingBox{6}(i));
        
        w_mask_label_par = false(ImageSize(1), ImageSize(2), ImageSize(3));
        w_mask_label_par(PixelIdxList{i}) = true;
        
        single_cell_matrix = w_mask_label_par(y(2:end-1), x(2:end-1), z(2:end-1)) == true;
        single_cell_matrix = padarray(single_cell_matrix, [1 1 1]);
        
        [Xmask, Ymask, Zmask] = meshgrid(x,y,z);
        
        S = size(single_cell_matrix,1)*size(single_cell_matrix,2)*size(single_cell_matrix,3);
        
        if S < 100000
            P = isosurface(Xmask,Ymask, Zmask, single_cell_matrix, 0.5);
        else
            [F,V, ~] = MarchingCubes(Xmask,Ymask, Zmask, single_cell_matrix, 0.5);
            P = struct;
            P.faces = F;
            P.vertices = V;
        end
        cell3D = reducepatch(P, resolution);
            
        M{i} = cell3D;
        
    end
end
h.stop;

%% Calculate normal vectors
faceNormals = cell(numel(M), 1);
for i = 1:numel(M)
    if isempty(M{i})
        faceNormals{i} = [];
    else
        try
            faceNormals{i} = patchnormals(M{i});
        catch
            faceNormals{i} = [];
        end
    end
end

%% Propagate each vector until it hits another cell
img_bw = w_mask_label>0;
w_mask_label_goodObjects = true(size(w_mask_label));
w_mask_label_goodObjects(img_idx) = false;
img_bw(w_mask_label_goodObjects) = 0;
%PixelIdxList = objects.PixelIdxList;

%img_bw_vis = double(img_bw);

searchRange = 2:searchRadius;
interCellSpacing_mean = nan(numel(faceNormals), 1);
interCellSpacing_min = nan(numel(faceNormals), 1);
interCellSpacing_var = nan(numel(faceNormals), 1);

parfor i = 1:numel(faceNormals)
   
    interCellSpacing = nan(numel(faceNormals{i}), 1);
    if ~isempty(faceNormals{i})    
        for j = 1:size(faceNormals{i}, 1)
            
            n = faceNormals{i}(j,:)/norm(faceNormals{i}(j,:));
            
            meanCoord = mean(M{i}.vertices(M{i}.faces(j,:), :));
            
            %img_bw_vis(round(meanCoord(2)), round(meanCoord(1)), round(meanCoord(3))) = 4;
            
            for s = 1:numel(searchRange)
                
                propagatedCoord = round(meanCoord + searchRange(s)*n);
                try
                    %img_bw_vis(propagatedCoord(2), propagatedCoord(1), propagatedCoord(3)) = 2;
                    %idx = sub2ind(ImageSize, propagatedCoord(2), propagatedCoord(1), propagatedCoord(3));
                    % 
                    if img_bw(propagatedCoord(2), propagatedCoord(1), propagatedCoord(3))% && ~ismember(PixelIdxList{i}, idx)
                        if s < 3
                            break; % Touching cell
                        else
                            interCellSpacing(j) = searchRange(s);
                            %img_bw_vis(propagatedCoord(2), propagatedCoord(1), propagatedCoord(3)) = 3;
                            break;
                        end
                    end
                catch
                    break
                end
            end
        end
    end
    try
        interCellSpacing_mean(i) = nanmean(interCellSpacing);
        interCellSpacing_min(i) = nanmin(interCellSpacing);
        interCellSpacing_var(i) = nanstd(interCellSpacing);
    catch
        interCellSpacing_mean(i) = NaN;
        interCellSpacing_min(i) = NaN;
        interCellSpacing_var(i) = NaN;
    end
end

interCellSpacing_mean = interCellSpacing_mean * params.scaling_dxy/1000;
interCellSpacing_min = interCellSpacing_min * params.scaling_dxy/1000;
interCellSpacing_var = interCellSpacing_var * params.scaling_dxy/1000;

interCellSpacing_mean = num2cell(interCellSpacing_mean);
interCellSpacing_min = num2cell(interCellSpacing_min);
interCellSpacing_var = num2cell(interCellSpacing_var);
%zSlicer(img_bw_vis+1, [0 0 0; 1 0 0; 0 1 0; 1 1 0; 0 1 1])

[objects.stats.(sprintf('Distance_InterCellSpacing_Mean_range%d', searchRadius))] = interCellSpacing_mean{:};
[objects.stats.(sprintf('Distance_InterCellSpacing_Min_range%d', searchRadius))] = interCellSpacing_min{:};
[objects.stats.(sprintf('Distance_InterCellSpacing_Variance_range%d', searchRadius))] = interCellSpacing_var{:};

fprintf('    - Inter cell spacing [mean = %.2f, std = %.2f]', nanmean([interCellSpacing_mean{:}]), nanstd([interCellSpacing_var{:}]))
displayTime(ticValue);
