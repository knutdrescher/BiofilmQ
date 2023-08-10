%% Generate Paraview Python File
function seriesParams = generatePythonMacro(parameter, range, colors, labelOutliers, input_directory, pathParaviewMacro, params, data, endFrame, folderAnimation)

filesVTK = dir(fullfile(input_directory, 'data', '*.vtk'));
filesMAT = dir(fullfile(input_directory, 'data', '*_data.mat'));

try
    if isempty(endFrame)
        clear endFrame
    end
end
try
    filesVTK = filesVTK(1:endFrame);
catch
    filesVTK = filesVTK(1:end);
end
try
    filesMAT = filesMAT(1:endFrame);
catch
    filesMAT = filesMAT(1:end);
end

if nargin < 8
    data = [];
end

if nargin < 10
    folderAnimation = fullfile(input_directory, 'data', 'animation');    
end

warning off;
mkdir(folderAnimation);
warning on;

% Load middle data-file for CM
objects = loadObjects(fullfile(input_directory, 'data', filesMAT(round(numel(filesVTK)/2)).name), 'stats' , 1);

% Extract CM for plane coordinates
centroids = [objects.stats.Centroid];
x = centroids(1:3:end);
y = centroids(2:3:end);
CM = [mean(x), mean(y)];

% Load last data-file for sZ
objects = loadObjects(fullfile(input_directory, 'data', filesMAT(end).name), 'ImageSize' , 1);

seriesParams = [];
seriesParams.shift = {num2str(-(objects.ImageSize(3)+50)) '0' '900'};
seriesParams.ori = {'0', '90', '0'};
seriesParams.plane = {num2str(CM(1)), '0', '0'};
seriesParams.parameter = parameter;
seriesParams.range = {num2str(range(1)), num2str(range(2))};
seriesParams.baseNamePNG = parameter;
seriesParams.outputFilename = ['animate_', parameter, '.py'];
seriesParams.labelOutliers = labelOutliers;
seriesParams.colors = colors;
seriesParams.folderAnimation = folderAnimation;

filenames = {filesVTK.name};
foldernames = {filesVTK.folder};

files = cellfun(@(folder, file) ['''', strrep(fullfile(folder, file), '\', '\\'), ''', '], foldernames, filenames, 'UniformOutput', false);
files = [files{:}];
seriesParams.filenames = files(1:end-2);

%% Write python macro
% Paraview command
fprintf(' - generating paraview-macro [%s]\n', seriesParams.outputFilename);
%fid = fopen(fullfile(pathParaviewMacro, 'animate_template_magnified.py'));
fid = fopen(fullfile(pathParaviewMacro, 'animate_template.py'));

macroStr = textscan(fid, '%s', 'delimiter', '\n');
macroStr = macroStr{1};
fclose(fid);

% Find the animation code part -> {animationCode}
line_animationCode = find(cellfun(@(x) ~isempty(x), strfind(macroStr, '{animationCode}')));
% Generate code to be inserted
animationCode = {''};

for t = 1:numel(filesVTK)
    
    if ~isempty(data) % Plot aspect ratio box
        [~, ~, ~, xHeight, yHeight, zHeight, xRange, yRange, zRange] = biofilmAspectRatio(data{t}, params, 1);
        
        animationCode{end+1, 1} = sprintf('box1.XLength = %.1f', xHeight);
        animationCode{end+1, 1} = sprintf('box1.YLength = %.1f', yHeight);
        animationCode{end+1, 1} = sprintf('box1.Center = [%.1f, %.1f, %.1f]', mean(xRange), mean(yRange), zRange(2));
        
        animationCode{end+1, 1} = sprintf('box2.XLength = %.1f', zHeight);
        animationCode{end+1, 1} = sprintf('box2.YLength = %.1f', yHeight);
        animationCode{end+1, 1} = sprintf('box2.Center = [%.1f, %.1f, %.1f]',...
            -(data{end}.ImageSize(3)+50) + (zRange(1) + zHeight/2), mean(yRange), 900-CM(1));
    end

    animationCode{end+1, 1} = sprintf('SaveScreenshot(''%s'', magnification=1, quality=100, view=renderView1)',...
        strrep(fullfile(folderAnimation, [seriesParams.baseNamePNG, '.',num2str(t, '%04d'),'.png']), '\', '/'));
    
    animationCode{end+1, 1} = 'animationScene1.GoToNext()';
end

for j = 1:size(macroStr,1)
    macroStr = strrep(macroStr, '{filenames}', seriesParams.filenames);
    macroStr = strrep(macroStr, '{sideViewCMX}', seriesParams.plane{1});
    macroStr = strrep(macroStr, '{sideViewCMY}', seriesParams.plane{2});
    macroStr = strrep(macroStr, '{sideViewCMZ}', seriesParams.plane{3});
    macroStr = strrep(macroStr, '{sideViewPosX}', seriesParams.shift{1});
    macroStr = strrep(macroStr, '{sideViewPosY}', seriesParams.shift{2});
    macroStr = strrep(macroStr, '{sideViewPosZ}', seriesParams.shift{3});
    macroStr = strrep(macroStr, '{sideViewOriX}', seriesParams.ori{1});
    macroStr = strrep(macroStr, '{sideViewOriY}', seriesParams.ori{2});
    macroStr = strrep(macroStr, '{sideViewOriZ}', seriesParams.ori{3});
    macroStr = strrep(macroStr, '{range_min}', seriesParams.range{1});
    macroStr = strrep(macroStr, '{range_half}', num2str((range(2)+range(1))/2));
    macroStr = strrep(macroStr, '{range_max}', seriesParams.range{2});
    macroStr = strrep(macroStr, '{color1_r}', num2str(seriesParams.colors.color1(1)));
    macroStr = strrep(macroStr, '{color1_g}', num2str(seriesParams.colors.color1(2)));
    macroStr = strrep(macroStr, '{color1_b}', num2str(seriesParams.colors.color1(3)));
    macroStr = strrep(macroStr, '{color2_r}', num2str(seriesParams.colors.color2(1)));
    macroStr = strrep(macroStr, '{color2_g}', num2str(seriesParams.colors.color2(2)));
    macroStr = strrep(macroStr, '{color2_b}', num2str(seriesParams.colors.color2(3)));
    macroStr = strrep(macroStr, '{color3_r}', num2str(seriesParams.colors.color3(1)));
    macroStr = strrep(macroStr, '{color3_g}', num2str(seriesParams.colors.color3(2)));
    macroStr = strrep(macroStr, '{color3_b}', num2str(seriesParams.colors.color3(3)));
    
    if sum(labelOutliers) > 0
        macroStr = strrep(macroStr, '{range_outside_min}', num2str(seriesParams.labelOutliers(1)));
        macroStr = strrep(macroStr, '{range_outside_max}', num2str(seriesParams.labelOutliers(2)));
        macroStr = strrep(macroStr, '{range_sel1}', '#');
        macroStr = strrep(macroStr, '{range_sel2}', '');
    else
        macroStr = strrep(macroStr, '{range_sel1}', '');
        macroStr = strrep(macroStr, '{range_sel2}', '#');
    end
    
    macroStr = strrep(macroStr, '{renderParameter}', seriesParams.parameter);
    macroStr = strrep(macroStr, '{renderParameter_no_underscore}', strrep(seriesParams.parameter, '_', ''));
end

macroStr = [macroStr(1:line_animationCode-1); animationCode(2:end); macroStr(line_animationCode+1:end)];

fid = fopen(fullfile(folderAnimation, seriesParams.outputFilename), 'w');
for j = 1:size(macroStr,1)
    fprintf(fid, '%s\n', macroStr{j});
end
fclose(fid);