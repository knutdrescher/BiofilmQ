function [indObj_exp, distances] = getNeighborCells(centroid_sim, objects_exp, params)
% This function determines IDs and distances of neighboring cells
% centroid_sim: coordinates of reference cell
% objects_exp: objects structure in where to find neighboring cells

goodObjects = objects_exp.goodObjects;

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
toUm = @(voxel, scaling) voxel.*scaling/1000;

centroids = [objects_exp.stats.Centroid];

x = centroids(1:3:end);
y = centroids(2:3:end);
z = centroids(3:3:end);

dist = fhypot(centroid_sim(1)-x, centroid_sim(2)-y, centroid_sim(3)-z);

dist(~goodObjects) = Inf;

[dist, indObj_exp] = sort(dist);

distances = toUm(dist, params.scaling_dxy);






