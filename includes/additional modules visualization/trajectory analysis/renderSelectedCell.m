function renderSelectedCell(node, obj, varargin)
% TODO: - Refactoring
% Parse inputs
parser = inputParser;
parser.addParameter('Timepoint', 0, @(x) isnumeric(x));
parser.addParameter('PlotAllNodes', 0, @(x) isnumeric(x));
parser.addParameter('FieldName', [], @(x) ischar(x));

parser.parse(varargin{:});
timepoint    = parser.Results.Timepoint;
fieldName    = parser.Results.FieldName;
plotAllNodes    = parser.Results.PlotAllNodes;

biofilmData = getLoadedBiofilmFromWorkspace;
parameterTree = evalin('base', 'parameterTree');

if plotAllNodes
    % determine all nodes until the root
    currentNode = node;
    nodes = node;
    while currentNode
        currentNode = obj.Parent(currentNode);
        
        if currentNode
            nodes = [nodes currentNode];
        end
    end
    nodes = sort(nodes);
else
    nodes = node;
end


try
    h_fig = evalin('base', 'h_fig');
    figure(h_fig);
catch
    h_fig = open('visualizeTree.fig');
    assignin('base', 'h_fig', h_fig);
end

h_ax1 = findobj('Tag', 'axes1');
h_ax2 = findobj('Tag', 'axes2');
h_ax3 = findobj('Tag', 'axes3');

%view(h_ax1, 90,0)
%view(h_ax2, 90,0)

%% Plotting
%cmap = [linspace(0,1,256)' linspace(1,0,256)', zeros(256,1)];
cmap = colormap(lines(numel(obj.Node)));

%view(h_ax1, 3);
grid(h_ax1, 'on');
%view(h_ax2, 3);
grid(h_ax2, 'on');

set(h_ax1, 'NextPlot', 'add');
set(h_ax2, 'NextPlot', 'add');
set(h_ax3, 'NextPlot', 'add');

box(h_ax1, 'on');
box(h_ax2, 'on');
box(h_ax3, 'on');

set(h_ax1, 'XLimMode', 'Auto', 'YLimMode', 'Auto', 'ZLimMode', 'Auto');
delete(findobj(h_ax1, 'Tag', 'biofilm'));


if isempty(findobj(h_ax1, 'Type', 'Light'))
    camlight(light(h_ax1));
    camlight(light(h_ax2));
    xlabel(h_ax1, 'x');
    ylabel(h_ax1, 'y');
    zlabel(h_ax1, 'z');
    xlabel(h_ax2, 'x');
    ylabel(h_ax2, 'y');
    zlabel(h_ax2, 'z');
    xlabel(h_ax3, 'Frame');
    title(h_ax2, 'Overview');
    title(h_ax3, 'Parameter');
end


if fieldName
    % Plot something in axis3
    plotData = [];
else
    fieldName = [];
end

for n = 1:numel(nodes)
    node = nodes(n);
    frames = sort(parameterTree(node).frameData);
    
    % Remove the first node
    frames(~frames) = [];
    stats = [];
    
    if timepoint
        ind_frames = ceil(numel(frames)*timepoint);
        frames = frames(ind_frames);
    end
    
    for f = 1:numel(frames)
        % obtain cell data
        ind = find(parameterTree(node).frameData == frames(f));
        frame = parameterTree(node).frameData(ind);
        title(h_ax1, ['Track_ID: ', num2str(parameterTree(node).Track_IDData(1)), ', Frame: ', num2str(frame)]);
        
        cellID = parameterTree(node).IDData(ind);
        parentID = parameterTree(node).parentIDData(ind);
        
        objects = biofilmData.data(frame);
        
        if isfield(objects, 'PixelIdxList')
            
            big_cell_matrix = false(objects.ImageSize);
            
            cell_ind = objects.PixelIdxList{cellID};
            
            resolution = 0.3;
            
            x = floor(objects.stats(cellID).BoundingBox(1)):ceil(objects.stats(cellID).BoundingBox(1)+objects.stats(cellID).BoundingBox(4));
            y = floor(objects.stats(cellID).BoundingBox(2)):ceil(objects.stats(cellID).BoundingBox(2)+objects.stats(cellID).BoundingBox(5));
            z = floor(objects.stats(cellID).BoundingBox(3)):ceil(objects.stats(cellID).BoundingBox(3)+objects.stats(cellID).BoundingBox(6));
            
            fprintf('frame: %d, cellID: %d, parent: %d\n', frame, cellID, parentID);
            %fprintf('[x = %0.2f, y = %0.2f, z = %0.2f]\n', objects.stats(cellID).Centroid(1),...
            %    objects.stats(cellID).Centroid(2), objects.stats(cellID).Centroid(3));
            
            big_cell_matrix(cell_ind) = 1;
            single_cell_matrix = big_cell_matrix(y(2:end-1), x(2:end-1), z(2:end-1));
            single_cell_matrix = padarray(single_cell_matrix, [1 1 1]);
            
            [Xmask, Ymask, Zmask] = meshgrid(x,y,z);
            
            if resolution < 1
                P = isosurface(Xmask,Ymask, Zmask, single_cell_matrix, 0.5);
                M = reducepatch(P, resolution);
            else
                M = isosurface(Xmask,Ymask, Zmask, single_cell_matrix, 0.5);
            end
            
            try
                if f ~= numel(frames)
                    delete(h_cell1);
                    delete(h_cell2);
                end
            end
            h_cell1 = patch(M, 'FaceColor', cmap(node,:), 'EdgeColor', 'none', 'Tag', num2str(cellID), 'FaceLighting', 'gouraud', 'AmbientStrength', 0.5, 'SpecularStrength', 0.2, 'Parent', h_ax1);
            h_cell2 = patch(M, 'FaceColor', cmap(node,:), 'EdgeColor', 'none', 'Tag', num2str(cellID), 'FaceLighting', 'gouraud', 'AmbientStrength', 0.5, 'SpecularStrength', 0.2, 'Parent', h_ax2);
            
        else
            params.scaling_dxy = biofilmData.params.scaling_dxy/1000;
            coords = objects.stats(cellID).Centroid;
            evecs = objects.stats(cellID).Orientation_Matrix;
            length = objects.stats(cellID).Shape_Length / params.scaling_dxy;
            height = objects.stats(cellID).Shape_Height / params.scaling_dxy;
            width = objects.stats(cellID).Shape_Width / params.scaling_dxy;
            
            
            
            %replace line with ellipse functions
            %X = [coords' - 0.5*length*evecs(:,1), coords' + 0.5*length*evecs(:,1)]';
            %line(X(:,1), X(:,2), X(:,3), 'Color', cmap(node,:), 'Tag', num2str(cellID), 'Parent', h_ax1, 'LineWidth', 3);
            % line(X(:,1), X(:,2), X(:,3), 'Color', cmap(node,:), 'Tag', num2str(cellID), 'Parent', h_ax2, 'LineWidth', 3);
            
            X = [coords]';
            [x, y, z, ~] = ellipsoid_plot_analysis(X, evecs(:, 1), evecs(:, 2), evecs(:, 3), ...
                length / 2, height / 2, width / 2);
            surf(x, y, z, 'FaceColor', cmap(node, :), 'Tag', num2str(cellID), 'Parent', h_ax1, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
            surf(x, y, z, 'FaceColor', cmap(node, :), 'Tag', num2str(cellID), 'Parent', h_ax2, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
        end
        
        %% Plot cell pole ages
        if isfield(objects.stats(cellID), 'cellPoleAge')
            [Xpol1, Xpol2] = getCellEndpoints(objects.stats(cellID), biofilmData.params.scaling_dxy/1000);
            text(Xpol1(1), Xpol1(2), Xpol1(3), num2str(objects.stats(cellID).cellPoleAge(1)), 'Parent', h_ax1, 'Color', cmap(node, :), 'FontSize', 16, 'FontWeight', 'bold')
            text(Xpol2(1), Xpol2(2), Xpol2(3), num2str(objects.stats(cellID).cellPoleAge(2)), 'Parent', h_ax1, 'Color', cmap(node, :), 'FontSize', 16, 'FontWeight', 'bold')
            end

        daspect(h_ax1, [1 1 1]);
        daspect(h_ax2, [1 1 1]);
        
        
        if fieldName
            try

                stats(end+1, :) = objects.stats(cellID).(fieldName);
            end
        end
        
        
        if ~timepoint
            pause(0.1);
        end
    end
   plotData(end+1).nodeID = nodes(n);
   plotData(end).frames = frames;
   plotData(end).stats = stats;
end


centroid = [objects.stats.Centroid];
y = centroid(1:3:end);
x = centroid(2:3:end);
z = centroid(3:3:end);

res = 40;
X = -2*res:res:objects.ImageSize(1)+2*res;
Y = -2*res:res:objects.ImageSize(2)+2*res;
Z = 0:res:objects.ImageSize(3)+2*res;

im = zeros(numel(X)-1, numel(Y)-1, numel(Z)-1);

for i = 1:numel(Z)-1
    ind = find(Z(i)<=z & z<=Z(i+1));
    im(:,:,i) = histcounts2(x(ind)', y(ind)', X', Y');
end

%K = convhull(x,y,z);
%h_all = patch('Vertices', [x', y', z'], 'Faces', K, 'FaceAlpha', 0.1);

[Xmask, Ymask, Zmask] = meshgrid(Y(1:end-1)+res/2,X(1:end-1)+res/2,Z(1:end-1)+res/2);
M = isosurface(Xmask,Ymask, Zmask, im, 0.5);
set(h_ax1, 'XLimMode', 'Manual', 'YLimMode', 'Manual', 'ZLimMode', 'Manual');
delete(findobj(h_ax2, 'Tag', 'biofilm'));
h_all = patch(M, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none', 'Tag', 'biofilm', 'FaceLighting', 'gouraud', 'AmbientStrength', 0.5, 'SpecularStrength', 0.2, 'FaceAlpha', 0.15, 'Parent', h_ax1);
h_all = patch(M, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', [0.5 0.5 0.5], 'EdgeAlpha', 0.3, 'Tag', 'biofilm', 'FaceLighting', 'gouraud', 'AmbientStrength', 0.5, 'SpecularStrength', 0.2, 'FaceAlpha', 0.15, 'Parent', h_ax2);


for n = 1:numel(plotData)
    if size(plotData(n).stats, 2) == 1
        plot(h_ax3, plotData(n).frames, plotData(n).stats, 'o-', 'Color', cmap(plotData(n).nodeID,:));
    elseif size(stats, 2) == 3
        plot3(h_ax3, plotData(n).stats(:, 1), plotData(n).stats(:,2), plotData(n).stats(:,3), 'o', 'Color', cmap(node,:));
    end
    
    
end
if size(plotData(n).stats, 2) == 1
    xlabel(h_ax3, 'frame');
    ylabel(h_ax3, fieldName);
elseif size(stats, 2) == 3
    xlabel(h_ax3, 'x');
    ylabel(h_ax3, 'y');
    zlabel(h_ax3, 'z');
end
    


