function [ellipsoid labels] = imInertiaEllipsoid(img, varargin)
%IMINERTIAELLIPSOID Inertia ellipsoid of a 3D binary image
%
%   ELLI = imInertiaEllipsoid(IMG)
%   IMG is a binary image of a single particle or region.
%   ELLI = [XC YC ZC A B C PHI THETA PSI] is an ellispoid defined by its
%   center [XC YC ZC], 3 radii A, B anc C, and a 3D orientation angle given
%   by (PHI, THETA, PSI).
%
%   ELLI = imInertiaEllipsoid(LBL)
%   Computes inertia ellipsoid of each region in the label image LBL. The
%   result is NL-by-9 array, with NL being the number of unique labels in
%   input image.
%
%   ELLI = imInertiaEllipsoid(..., SCALE)
%   Specifies a spatial calibration for ech of the x, y and z axes. SCALE
%   is a 1-by-3 row vector containing size of elementary voxel in each
%   direction.
%
%   Example
%     % Draw inertia ellipsoid of human head image
%     % (requires image processing toolbox, and slicer program for display)
%     metadata = analyze75info('brainMRI.hdr');
%     I = analyze75read(metadata);
%     bin = imclose(I > 0, ones([3 3 3]));
%     orthoSlices3d(I, [60 80 13], [1 1 2.5]);
%     axis equal;
%     view(3);
%     elli = imInertiaEllipsoid(bin, [1 1 2.5]);
%     drawEllipsoid(elli)
%
%   See also
%     drawEllipsoid
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-12-01,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% size of image
dim = size(img);

% extract spatial calibration
scales = [1 1 1];
if ~isempty(varargin)
    scales = varargin{1};
end

% extract the set of labels, and remove label for background
labels = unique(img(:));
labels(labels==0) = [];

nLabels = length(labels);

% allocate memory for result
ellipsoid = zeros(nLabels, 9);

for i = 1:nLabels
    % extract points of the current particle
    inds = find(img==labels(i));
    [y x z] = ind2sub(dim, inds);
    
    % number of points
    n = length(inds);

    % compute approximate location of ellipsoid center
    xc = mean(x);
    yc = mean(y);
    zc = mean(z);

    center = [xc yc zc] .* scales;
    
    % recenter points (should be better for numerical accuracy)
    x = (x - xc) * scales(1);
    y = (y - yc) * scales(2);
    z = (z - zc) * scales(3);

    points = [x y z];
    
    % compute the covariance matrix
    covPts = cov(points) / n;
    
    % perform a principal component analysis with 2 variables,
    % to extract inertia axes
    [U S] = svd(covPts);
    
    % extract length of each semi axis
    radii = 2 * sqrt(diag(S)*n)';
    
    % sort axes from greater to lower
    [radii ind] = sort(radii, 'descend');
    
    % format U to ensure first axis points to positive x direction
    U = U(ind, :);
    if U(1,1) < 0
        U = -U;
        % keep matrix determinant positive
        U(:,3) = -U(:,3);
    end
    
    % convert axes rotation matrix to Euler angles
    angles = rotation3dToEulerAngles(U);
    
    % concatenate result to form an ellipsoid object
    ellipsoid(i, :) = [center radii angles];
end

