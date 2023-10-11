% Create cube outline matrix

img = zeros(objects.ImageSize);
img_labeled = labelmatrix(objects) > 0;

% Resolution defines the grid
res = objects.params.gridSpacing;

sY = size(img_labeled, 2);
sX = size(img_labeled, 1);

X = 1:res:sX;
Y = 1:res:sY;

sZ = size(img_labeled, 3);
Z = 1:res:sZ;

counter = 1;
for z = Z
    for x = X
        for y = Y
            % Determine fraction of occupied volume
            % Cross
            Xfrac = x-res/2:x+res/2-1;
            Yfrac = y;
            Zfrac = z;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];

            img(Xfrac, Yfrac, Zfrac) = true;
            
            Xfrac = x;
            Yfrac = y;
            Zfrac = z-res/2:z+res/2-1;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];

            img(Xfrac, Yfrac, Zfrac) = true;
            
            Xfrac = x;
            Yfrac = y-res/2:y+res/2-1;
            Zfrac = z;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];

            img(Xfrac, Yfrac, Zfrac) = counter;
            counter = counter + 1;
            
        end
    end
end

img(~img_labeled) = 0;

objects_cubeOutline = conncomp(img);
objects_cubeOutline.stats = regionprops(objects_cubeOutline);
objects_cubeOutline.goodObjects = true(1, objects_cubeOutline.NumObjects);
outlines = isosurfaceLabel(labelmatrix(objects_cubeOutline), objects_cubeOutline, 1, {'ID'}, objects.params);
mvtk_write(outlines,fullfile(handles.settings.directory, 'data', 'outlines.vtk'), 'legacy-binary',{});