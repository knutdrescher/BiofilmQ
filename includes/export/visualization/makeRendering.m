%%
function makeRendering(objects, filename, pathParaview, parameter, removeZOffset)

switch parameter
    case 'RandomNumber'
        parameterRange = [0 1];
    case 'ID'
        parameterRange = [1 objects.NumObjects];
    otherwise
        [~, ~, parameterRange] = returnUnitLabel(parameter, {objects});
end

if removeZOffset
    img = labelmatrix(objects);
    projZ = squeeze(sum(sum(img, 1), 2));
    zOffset = find(projZ, 1)+5;
else
    zOffset = 0;
end

centroids = [objects.stats.Centroid];

xOffset = -mean(centroids(1:3:end));
yOffset = -mean(centroids(2:3:end));

[path, filename, ext] = fileparts(filename);

biofilmFiles = struct('name', [filename, ext]);

outputDir = fullfile(path, 'rendered biofilms');
if ~exist(outputDir, 'dir')
   mkdir(outputDir); 
end
outputFilename = fullfile(outputDir, [biofilmFiles.name(1:end-4), sprintf('_%s_range(%.2f_%.2f).png', parameter, parameterRange(1), parameterRange(2))]);
if exist(outputFilename, 'file')
    delete(outputFilename)
end

fileID = fopen(fullfile(outputDir, 'command.py'),'w');
fprintf(fileID, 'renderView1 = GetActiveViewOrCreate(''RenderView'')\n');

fprintf(fileID, 'renderView1.Background = [1.0, 1.0, 1.0]\n');
fprintf(fileID, 'renderView1.EnableOSPRay = 1\n');
fprintf(fileID, 'renderView1.Shadows = 1\n');
fprintf(fileID, 'renderView1.AmbientSamples = 5\n');
fprintf(fileID, 'renderView1.SamplesPerPixel = 2\n');
fprintf(fileID, 'renderView1.OrientationAxesVisibility = 0\n');
fprintf(fileID, 'renderView1.KeyLightIntensity = 0.8\n');
fprintf(fileID, 'renderView1.KeyLightAzimuth = 40\n');
fprintf(fileID, 'renderView1.HeadLightKHRatio = 1.5\n');
fprintf(fileID, 'renderView1.BackLightElevation = 10.0\n');
fprintf(fileID, 'renderView1.FillLightKFRatio = 1.0\n');
fprintf(fileID, 'renderView1.FillLightElevation = -35.0\n');
fprintf(fileID, 'renderView1.FillLightAzimuth = 30.0\n');
fprintf(fileID, 'renderView1.KeyLightElevation = 30.0\n');

fprintf(fileID, 'renderView1.CameraPosition = [1700, 0, 500]\n');
fprintf(fileID, 'renderView1.CameraFocalPoint = [100, 0, 240]\n');
fprintf(fileID, 'renderView1.CameraViewUp = [-0.108005149095703, 0.0, 0.994150334591713]\n');
fprintf(fileID, 'renderView1.CameraParallelScale = 2177.37606856795\n');

% add vtk-files
for j = 1:numel(biofilmFiles)
    i = 1;
    fprintf(fileID,'file%d = LegacyVTKReader(FileNames=[''%s''])\n', i, strrep(fullfile(path, biofilmFiles(j).name), '\', '//'));
    fprintf(fileID,'file%dDisplay = Show(file%d, renderView1)\n', i, i);
    
    
    fprintf(fileID,'file%dDisplay.Position = [%.1f, %.1f, %.1f]\n', i, xOffset, yOffset, -zOffset);
    fprintf(fileID,'file%dDisplay.SetScalarBarVisibility(renderView1, False)\n', i);
    fprintf(fileID,'ColorBy(file%dDisplay, (''POINTS'', ''%s''))\n', i, parameter);
    fprintf(fileID,'nematicOrderParameter3LUT = GetColorTransferFunction(''%s'')\n', parameter);
    fprintf(fileID,'nematicOrderParameter3LUT.RescaleTransferFunction(%.1f, %.1f)\n', parameterRange(1), parameterRange(2));
    fprintf(fileID,'nematicOrderParameter3LUT.BelowRangeColor = [0.23137254901960785, 0.2980392156862745, 0.7529411764705882]\n');
    fprintf(fileID,'nematicOrderParameter3LUT.AboveRangeColor = [0.7058823529411765, 0.01568627450980392, 0.14901960784313725]\n');

    
    % add plane
    fprintf(fileID,'plane = Plane()\n');
    fprintf(fileID,'plane.Origin = [%.1f, %.1f, %.1f]\n', -5000, -5000, 0);
    fprintf(fileID,'plane.Point1 = [%.1f, %.1f, %.1f]\n', 5000, -5000, 0);
    fprintf(fileID,'plane.Point2 = [%.1f, %.1f, %.1f]\n', -5000, 10000, 0);

    fprintf(fileID,'planeDisplay = Show(plane, renderView1)\n');
    
    % export screenshot
    fprintf(fileID, 'SaveScreenshot(''%s'', magnification=1, quality=100, view=renderView1)\n', strrep(outputFilename, '\', '//'));    
end


fclose(fileID);


if isunix
    command = sprintf('"%s" --script="%s"', pathParaview, fullfile(outputDir, 'command.py &'));
    system(command);yes
else
    proc = System.Diagnostics.Process;
    proc.StartInfo.FileName = sprintf('%s', pathParaview);
    proc.StartInfo.Arguments =  sprintf('--script="%s"', fullfile(outputDir, 'command.py'));
    proc.Start();
end

goOn = false;
fprintf('   waiting for Paraview to render files...\n');

while ~goOn
    if exist(outputFilename, 'file')
        pause(2);
        goOn = 1;
        if ~isunix
            proc.Kill;
        end
        fprintf('   all files have been rendered -> continueing\n');
    end
end

%delete(fullfile(outputDir, 'command.py'))