function objects = cubeSegmentation(w, res, imgfilter)
% Do declumping by sorting in grid

    if nargin == 2
        imgfilter = [];
    end
        
    
    fprintf('      splitting cells into grid [resolution=%d vox]', res);
    ticValue = displayTime;
    sY = size(w, 1);
    sX = size(w, 2);
    surfaceImage = bwperim(w);
    
    
    X = res/2+1:res:sX+res/2;
    Y = res/2+1:res:sY+res/2;

    sZ = size(w, 3);
    Z = res/2+1:res:sZ+res/2;
    if isempty(Z)
        Z = 1;
    end
    w = double(w>0);
    
    count = 1;
    boxVolume = [];
    boxSurface = [];
    
    maxEntries = numel(X)*numel(Y)*numel(Z);
    globalID = zeros(1, maxEntries);
    IDcount = 1;
    
    centerCoord = [];
        
    for z = Z
        for x = X
            for y = Y
                % Determine fraction of occupied volume
                Xfrac = x-res/2:x+res/2-1;
                Yfrac = y-res/2:y+res/2-1;
                Zfrac = z-res/2:z+res/2-1;
                
                Xfrac(Xfrac>sX) = [];
                Yfrac(Yfrac>sY) = [];
                Zfrac(Zfrac>sZ) = [];
                Xfrac(Xfrac<1) = [];
                Yfrac(Yfrac<1) = [];
                Zfrac(Zfrac<1) = [];
                
                w_crop = w(Yfrac, Xfrac, Zfrac);
                if sum(w_crop(:))
                    w(Yfrac, Xfrac, Zfrac) = count*w(Yfrac, Xfrac, Zfrac);
                    centerCoord{count} = [x y z];
                    boxVolume(count) = numel(Xfrac)*numel(Yfrac)*numel(Zfrac);
                    boxSurface(count) = sum(sum(sum(surfaceImage(Yfrac, Xfrac, Zfrac))));
                    globalID(count) = IDcount;
                    
                    count = count + 1;
                end
                IDcount = IDcount + 1;
            end
        end
    end
    objects = conncomp(w);
    
    if isempty(imgfilter)
        stats = regionprops(objects, 'Area', 'Centroid', 'BoundingBox');
    else
        stats = regionprops(objects, imgfilter, 'Area', 'MeanIntensity', 'Centroid', 'BoundingBox');
    end
    volume_fraction = [stats.Area]./boxVolume;
    volume_fraction = num2cell(volume_fraction);
    boxSurface = num2cell(boxSurface);
    globalID(~globalID) = [];
    globalID = num2cell(globalID);
    objects.stats = stats;
    
    if isempty(centerCoord)
        centerCoord{1} = [NaN NaN NaN];
    end
    
    [objects.stats.Cube_VolumeFraction] = volume_fraction{:};
    [objects.stats.Cube_Surface] = boxSurface{:};
    [objects.stats.Grid_ID] = globalID{:};
    [objects.stats.Cube_CenterCoord] = centerCoord{:};
    
    displayTime(ticValue);
end