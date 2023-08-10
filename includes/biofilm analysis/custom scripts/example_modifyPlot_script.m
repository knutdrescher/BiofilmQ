%% Example script to modify data before plotting

% This script will add a horizontal line ad x = 20

% Handle to figure: h
% Handle to axes: h_ax

h_ax.NextPlot = 'add';
yLimits = h_ax.YLim;
plot(h_ax, [20 20]/60, yLimits, '--', 'Color', 'black')
