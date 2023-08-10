% How to use the script:
% 1.) load segmentation results
% 2.) inside BiofilmQ GUI use the menue item 'Debugging' -> 
%   'Export figure handles to MATLAB workspace'
% 3.) (optional) modify outputname in this script './data/cubes.vtk')
% 4.) execute script

% Copyright (C) 2019 Max Planck Institute for Terrestrial Microbiology

% Eric Jelli (eric.jelli@mpi-marburg.mpg.de)

% Create cube outline matrix

img = zeros(objects.ImageSize);
img_labeled = labelmatrix(objects) > 0;

% Resolution defines the grid
res = objects.params.gridSpacing;

sY = size(img_labeled, 1);
sX = size(img_labeled, 2);

X = res/2+1:res:sX+res/2;
Y = res/2+1:res:sY+res/2;

sZ = size(img_labeled, 3);
Z = res/2+1:res:sZ+res/2-1;

counter = 1;

for z = Z
    for x = X
        for y = Y
            
            Xfrac = x-res/2:x+res/2-1;
            Yfrac = y-res/2:y+res/2-1;
            Zfrac = z-res/2:z+res/2-1;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];
                
            current_cube = img_labeled(Yfrac, Xfrac, Zfrac);
            
            if any(current_cube(:))
                img(Yfrac, Xfrac, Zfrac) = counter;
                counter = counter + 1;
            end
            
        end
    end
end

objects_cubeOutline = conncomp(img);
objects_cubeOutline.stats = regionprops(objects_cubeOutline);

% Transfer existing parameters
f1 = fieldnames(objects_cubeOutline.stats);
f2 = fieldnames(objects.stats);
for i = 1:numel(f2)
    if ~any(strcmp(f1, f2{i}))
        [objects_cubeOutline.stats.(f2{i})] = objects.stats.(f2{i});
    end
end

objects_cubeOutline.goodObjects = true(1, objects_cubeOutline.NumObjects);
outlines = isosurfaceLabel(labelmatrix(objects_cubeOutline), objects_cubeOutline, 1, union({'ID', 'RandomNumber'}, f2), objects.params);
mvtk_write(outlines,fullfile(handles.settings.directory, 'data', 'cubes.vtk'), 'legacy-binary',union({'ID', 'RandomNumber'}, f2));