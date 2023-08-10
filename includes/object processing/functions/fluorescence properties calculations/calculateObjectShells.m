function objects_shells = calculateObjectShells(objects, shellSize)

if isfield(objects.stats, 'Grid_ID')
    outline = find(bwperim(labelmatrix(objects)>0));
else
    outline = 0;
end

%% calculateMeanIntensityPerObjectShell
    % Measure shell profile
    
    objects_shells = objects;
    PixelIdxList = objects.PixelIdxList;
    PixelIdxList_shell = cell(1, numel(PixelIdxList));
    imageSize = objects.ImageSize;
    
    parfor i = 1:numel(PixelIdxList)
        shell = PixelIdxList{i};
        
        if outline
            shell = intersect(shell, outline);
        end
        
        for s = 1:shellSize
            if outline
                shell = setdiff(neighbourND(shell, imageSize), PixelIdxList{i});
            else
                shell = setxor(neighbourND(shell, imageSize), PixelIdxList{i});
            end
        end
        shell(~shell) = [];
        PixelIdxList_shell{i} = shell;
    end
    objects_shells.PixelIdxList = PixelIdxList_shell;

end