function im_conv = convolveBySlice(img1raw, params, silent)
ticValue = displayTime;

if nargin == 2
    silent = 0;
end

if ~silent
    fprintf(' - removing noise');
end

try
    dxy = params.noise_kernelSize(1);
    dz = params.noise_kernelSize(2);
catch
    dxy = 5;
    dz = 3;
end

if ~silent
    fprintf(', [dxy=%d, dz=%d]', dxy, dz);
end

%im_conv = zeros(size(img1raw,1)+(dxy-1), size(img1raw,2)+(dxy-1), size(img1raw,3)+(dz-1));
strel = ones(dxy,dxy,dz);
strel(1, :, 1) = 0;
strel(end, :, 1) = 0;
strel(1, :, end) = 0;
strel(end, :, end) = 0;
strel(:, 1, 1) = 0;
strel(:, end, 1) = 0;
strel(:, 1, end) = 0;
strel(:, end, end) = 0;

% added
% strel = zeros(dxy,dxy,dz);
% strel(:,:,2) = 1;

strel = strel/sum(strel(:));

padsize = [dxy dxy dz];
img1raw = padarray(img1raw, padsize, 'replicate');
%if params.fastFFT
%    im_conv = convnfft(img1raw, strel, 'same');
%else
im_conv = convn(img1raw, strel, 'same');
%end
im_conv = im_conv(1+padsize(1):end-padsize(1),1+padsize(2):end-padsize(2),1+padsize(3):end-padsize(3));

%im_conv = convn(img1raw, strel);

%im_conv = im_conv([(dxy-1):end-(dxy-1)], :, :);
%im_conv = im_conv(:, [(dxy-1):end-(dxy-1)], :);
%im_conv = im_conv(:, :, [(dz-1):end-(dz-1)]);

if ~silent
    ticValue = displayTime(ticValue);
end