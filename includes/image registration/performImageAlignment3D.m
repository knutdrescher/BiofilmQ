function img1raw = performImageAlignment3D(img1raw, metadata, method, silent)
if nargin == 2
    silent = 0;
    method = 'linear';
end

tform = metadata.data.registration;


ticValue = displayTime;
if ~silent
    fprintf(' - aligning image, translation: [x=%0.3f, y=%0.3f, z=%0.3f]', tform.T(4,1), tform.T(4,2), tform.T(4,3));
end

% Registration only in 2D
%tform2 = affine2d;
%tform2.T(3,1) = tform.T(4,1);
%tform2.T(3,2) = tform.T(4,2);

% for i = 1:size(img1raw, 3)
%     %img1raw(:,:,i)  = imwarp(img1raw(:,:,i),tform,'OutputView',imref2d(size(img1raw)), 'Interp', 'cubic');
%     % note: cubic interpolation works only in 2D!
%     img1raw(:,:,i)  = imwarp(img1raw(:,:,i),tform2,'OutputView',imref2d(size(img1raw)), 'Interp', 'linear');
% end

addZSlices = ceil(tform.T(4,3));
if addZSlices > 1
    if ~silent
        fprintf(' -> adding %d additional z-planes', addZSlices);
    end
    img1raw(:,:,end+1) = img1raw(:,:,end);
end
 
img1raw  = imwarp(img1raw,tform,'OutputView',imref3d(size(img1raw)), 'Interp', method, 'FillValues', double(min(img1raw(:))));

if ~silent
    ticValue = displayTime(ticValue);
end
