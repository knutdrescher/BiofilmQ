function [X, Y] = getCellEndpoints(stats, scaling_dxy)

centroid = [stats.Centroid];
x = centroid(1:3:end);
y = centroid(2:3:end);
z = centroid(3:3:end);

evecs = {stats.Orientation_Matrix};

length = [stats.length]/scaling_dxy;
width = [stats.width]/scaling_dxy;
height = [stats.height]/scaling_dxy;

X = zeros(numel(evecs), 3);
Y = zeros(numel(evecs), 3);
for k = 1:numel(evecs)
    X(k, :) = [x(k)-length(k)/2*evecs{k}(1,1) y(k)-length(k)/2*evecs{k}(2,1) z(k)-length(k)/2*evecs{k}(3,1)];
    Y(k, :) = [x(k)+length(k)/2*evecs{k}(1,1) y(k)+length(k)/2*evecs{k}(2,1) z(k)+length(k)/2*evecs{k}(3,1)];
end
end