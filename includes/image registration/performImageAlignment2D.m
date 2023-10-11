function img1raw = performImageAlignment2D(img1raw, metadata, method, displayOutput)

tform = metadata.data.registration;

if nargin == 2
    ticValue = displayTime;
    fprintf(' - aligning image, translation: [x=%0.3f, y=%0.3f, z=%0.3f]', tform.T(4,1), tform.T(4,2), tform.T(4,3));
    method = 'linear';
end

% Registration only in 2D
tform2 = affine2d;
tform2.T(3,1) = tform.T(4,1);
tform2.T(3,2) = tform.T(4,2);

for i = 1:size(img1raw, 3)
    %img1raw(:,:,i)  = imwarp(img1raw(:,:,i),tform,'OutputView',imref2d(size(img1raw)), 'Interp', 'cubic');
    % note: cubic interpolation works only in 2D!
    img1raw(:,:,i)  = imwarp(img1raw(:,:,i),tform2,'OutputView',imref2d(size(img1raw)), 'Interp', method, 'FillValues', min(img1raw(:)));
end

%img1raw  = imwarp(img1raw,tform,'OutputView',imref3d(size(img1raw)), 'Interp', 'linear');
if nargin == 2
    ticValue = displayTime(ticValue);
end