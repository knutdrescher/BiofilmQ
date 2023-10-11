%% Example script to color points according to point density

% Handle to figure: h
% Handle to axes: h_ax

xLimits = h_ax.XLim;
yLimits = h_ax.YLim;

xScale = h_ax.XScale;
yScale = h_ax.YScale;

% Extract data from plot
xData = [];
yData = [];

for i = 1:numel(h_ax.Children)
    xData = [xData, h_ax.Children(i).XData];
    yData = [yData, h_ax.Children(i).YData];
end

MarkerEdgeColor = 'none';
Marker = h_ax.Children(1).Marker;
SizeData = h_ax.Children(1).SizeData;

% Obtain color
delete(h_ax.Children);
[C, M] = scatImage(xData, yData, 'Nbins', 20, 'xlim', xLimits,...
    'ylim', yLimits, 'smoothFactor', 15, 'xScale', xScale, 'yScale', yScale, ...
    'plotContourLines', true);

% Replot
scatter(h_ax, xData, yData, SizeData, C, Marker, 'filled');
cb = colorbar(h_ax);
cb.Label.String = 'Counts';

% Move contour lines on top of plot
uistack(M); 