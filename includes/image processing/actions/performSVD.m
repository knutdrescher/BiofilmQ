function img = performSVD(img1raw, removeFirstEigenvalue, silent)

if nargin == 1
    removeFirstEigenvalue = 0;
    silent = 0;
end
if nargin == 2
    silent = 0;
end

if ~silent
    fprintf(' - performing singular value decomposition\n');
end

ticValue = displayTime;

k = round(2/3*size(img1raw, 3));
if ~silent
    fprintf('      [keeping %d from %d eigenvalues]', k, size(img1raw, 3));
    fprintf(' - along xz');
end

img1 = img1raw;
for x = 1:size(img1raw,1)
    img_mean = mean(mean(squeeze(img1raw(x,:,:))));
    [U, S, V] = svd(squeeze(img1raw(x,:,:))-img_mean);
    for i = k+1:size(S,2)
        S(i,i) = 0;
    end
    %S(2,2) = mean([S(3,3), S(4,4)]);
    img1(x,:,:) = U*S*V'+img_mean;
end

if ~silent
    fprintf(', along yz');
end
img2 = img1raw;
for y = 1:size(img1raw,2)
    img_mean = mean(mean(squeeze(img1raw(:,y,:))));
    [U, S, V] = svd(squeeze(img1raw(:,y,:))-img_mean);
    for i = k+1:size(S,2)
        S(i,i) = 0;
    end
    %S(2,2) = mean([S(3,3), S(4,4)]);
    img2(:,y,:) = U*S*V'+img_mean;
end

img = (img1+img2)/2;

%img = img1raw;
if removeFirstEigenvalue
    if ~silent
        fprintf(', remove first eigenvalue');
    end
    for z = 1:size(img, 3)
        img_mean = mean(mean(img(:,:,z)));
        [U, S, V] = svd(img(:,:,z)-img_mean);
        
        S(1,1) = 1.5*mean([S(2,2), S(3,3)]);
        img(:,:,z) = U*S*V'+img_mean;
    end
end

if ~silent
    displayTime(ticValue);
end