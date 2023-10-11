function renderBiofilmThumbnail(handles, objects)

h_ax = handles.axes.axes_analysis_overview;

centroid = [objects.stats.Centroid];
y = centroid(1:3:end);
x = centroid(2:3:end);
z = centroid(3:3:end);

res = 50;
X = -2*res:res:objects.ImageSize(1)+2*res;
Y = -2*res:res:objects.ImageSize(2)+2*res;

%% Correct 2D data
if numel(objects.ImageSize) == 2
    objects.ImageSize(3) = 1;
end

Z = 0:res:objects.ImageSize(3)+2*res;

im = zeros(numel(X)-1, numel(Y)-1, numel(Z)-1);

for i = 1:numel(Z)-1
    ind = find(Z(i)<=z & z<=Z(i+1));
    try
        im(:,:,i) = histcounts2(x(ind)', y(ind)', X', Y');
    catch
        x_temp = x(ind);
        y_temp = y(ind);
        for idx = 1:numel(x_temp)
            x_ind = find(X > x_temp(idx), 1);
            y_ind = find(Y > y_temp(idx), 1);
            im(x_ind, y_ind, i) = im(x_ind, y_ind, i) + 1;
        end
    end
end

[Xmask, Ymask, Zmask] = meshgrid(Y(1:end-1),X(1:end-1),Z(1:end-1));
M = isosurface(Xmask,Ymask, Zmask, im, 0.5);
%set(h_ax, 'XLimMode', 'Manual', 'YLimMode', 'Manual', 'ZLimMode', 'Manual');
delete(get(h_ax, 'children'));
%patch(M, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none', 'Tag', 'biofilm', 'FaceLighting', 'gouraud', 'AmbientStrength', 0.5, 'SpecularStrength', 0.2, 'FaceAlpha', 0.15, 'Parent', h_ax1);
%plot3(x,y,z, '.'); 
set(h_ax, 'NextPlot', 'add');
patch(M, 'FaceColor', [0.1 0.1 0.7], 'EdgeColor', [0.5 0.5 0.5], 'EdgeAlpha', 0.3, 'Tag', 'biofilm', 'FaceLighting', 'gouraud', 'AmbientStrength', 0.5, 'SpecularStrength', 0.2, 'FaceAlpha', 0.15, 'Parent', h_ax);


xlim(h_ax, [min(X) max(X)]);
ylim(h_ax, [min(Y) max(Y)]);
xlabel(h_ax, '');
ylabel(h_ax, '');
zlabel(h_ax, '');

box(h_ax, 'off');

view(h_ax, 45,45);

handles.layout.boxPanels.analysis_biofilmPreviewBoxPanel.Title = sprintf('Biofilm preview (%s)', objects.Filename);
