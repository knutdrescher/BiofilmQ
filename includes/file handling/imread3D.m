function I = imread3D(f, params, silent)
%IMREAD3D reads a stack of images into a 3D array
ticValue = displayTime;
if nargin < 3
    silent = 0;
end

filename = f;

[filebase, fname, ext] = fileparts(filename);

deconvolvedVersion = false;
if exist(fullfile(filebase, 'deconvolved images'), 'dir')
    if exist(fullfile(filebase, 'deconvolved images', [fname, '_cmle', ext]), 'file')
        filename = fullfile(filebase, 'deconvolved images', [fname, '_cmle', ext]);
        deconvolvedVersion = true;
        if ~silent
            fprintf(' [deconvolved version]');
        end
    end
end

if ~silent
    textprogressbar('      ');
end
% reading of a filename and setting size of the array

   
    
slice = imread(filename,1);
imInfo = imfinfo(filename);
z = length(imInfo);

if nargin == 1 || isempty(params)
    slices = z;
    params.maxHeight = 0;
else
    
    if ~isempty(params.maxHeight)
        slices = ceil(params.maxHeight/(params.scaling_dz/1000))+1;
    else
        slices = z;
        params.maxHeight = (slices-1) * (params.scaling_dz/1000);
    end
    
    if slices > z
        slices = z;
    end
end

I = zeros(imInfo(1).Height,imInfo(1).Width,slices, 'uint16');
% reading image slice-by-slice and adding it to the array
for i = 1:slices
    try
        im_temp = imread(filename,'Index', i, 'Info', imInfo);
        if size(im_temp,3)==3
           im_temp = rgb2gray(im_temp); 
        end
        I(:,:,i) = im_temp;
        if ~mod(i,10)
            if ~silent
                textprogressbar(i/slices*100);
            end
        end
    catch err
        warning(err.message);
        break;
    end
end

if deconvolvedVersion
    I(:,:,2:end+1) = I;
    proj = squeeze(sum(I, 3));
    I(:,:,1) = proj/max(proj(:))*(2^16-1);
end
%figure,imshow3D(I)

if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    fprintf(' %d slice(s) read (~%.02f um)', slices, params.maxHeight);
    displayTime(ticValue);
end