%% Generate Paraview state-file
function [stateFilename, CM] = generateXMLStateFile(input_directory, endFrame)
% Input directory
% input_directory = 'D:\Praveen\biofilm architecture\kdv692and 694\flow 0.1\22.01.2017 R234A kdv805 straight flow 0.1\Pos6-3';

filesVTK = dir(fullfile(input_directory, 'data', '*.vtk'));
filesMAT = dir(fullfile(input_directory, 'data', '*_data.mat'));

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
seriesParams.shiftX = num2str(-(objects.ImageSize(3)+50)); 
seriesParams.shiftY = num2str(0); 
seriesParams.shiftZ = num2str(900); 
seriesParams.plane = {num2str(CM(1)), '0', '0'};

stateTemplateFilename = 'D:\Praveen\biofilm architecture\paraview macros\state_Alignment_Zaxis.pvsm';

stateFilename = fullfile(input_directory, 'data', 'state.pvsm');

for i = 1:numel(filesVTK)
    seriesParams.filesVTK{i} = fullfile(input_directory, 'data', filesVTK(i).name);
end
seriesParams.frameNum = numel(filesVTK);
seriesParams.timepoints = num2cell(0:seriesParams.frameNum-1);
seriesParams.timepoints = cellfun(@(x) num2str(x), seriesParams.timepoints, 'UniformOutput', false);

%% Read template
docNode = xmlread(stateTemplateFilename);


% Loop over properties

docNode = changeXMLElement('Element', 'name', 'EndTime', num2str(seriesParams.frameNum), docNode);
docNode = changeXMLElement('Element', 'name', 'AnimationTime', '1', docNode);
docNode = changeXMLElement('Element', 'name', 'FileNameInfo', seriesParams.filesVTK{1}, docNode);
docNode = changeXMLElementList('Element', 'name', 'FileNames', seriesParams.filesVTK, docNode);
docNode = changeXMLElementList('Element', 'name', 'TimestepValues', seriesParams.timepoints, docNode);
% docNode = changeXMLElementList('Element', 'id', '6004.Position', {seriesParams.shiftX, seriesParams.shiftY, seriesParams.shiftZ}, docNode);
% docNode = changeXMLElementList('Element', 'id', '5823.Origin', {seriesParams.plane{1}, seriesParams.plane{2}, seriesParams.plane{3}}, docNode);
% docNode = addXMLElement('Domain', 'id', '5823.Origin', docNode);

docNode = changeXMLElementList('Element', 'id', '5531.Position', {seriesParams.shiftX, seriesParams.shiftY, seriesParams.shiftZ}, docNode);
docNode = changeXMLElementList('Element', 'id', '4659.Origin', {seriesParams.plane{1}, seriesParams.plane{2}, seriesParams.plane{3}}, docNode);
docNode = addXMLElement('Domain', 'id', '4659.Origin', docNode);

xmlwrite(stateFilename,docNode);

