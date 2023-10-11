% This is a template file for custom parameter calulation
% Available variables:
%
% fileIndex: Index of currently processed image stack in the Files panel
% objects: results of the segmentation routine contains the fields
%   - ImageSize: size of the cropped and isotropic rescaled image stack 
%   - NumObjects: number of segmented objects
%   - PixelIdxList: Indices of each object pixel in the cropped and
%       rescaled image stackand principal output data
%   - goodObjects: Objects which passed the object filtering
%   - measurementFields: Fieldnames of the already measured fields
%   - metadata.data: Information on the image stack prior to the
%   segmentation
%        - scaling: dxy and dz scaling of original image stack. In
%        particular usefull to convert pixel into um.
%   - params: program parameters during the segmentation
%   - stats: list of calculated object parameters
% parameter: path to the script to be executed
% params: all input fields of the program
% 
% To save a calculation permanently you have to modify the objects variable
% you can either save values per segmented object in a new objects.stats
% field:
%       custom_parameter = num2cell(zeros(objects.NumObjects, 1));
%       [objects.stats.customParameter] = custom_parameter{:};
%
% Or save a (global) parameter once per image stack;
%       objects.globalMeasurements.customGlobalParameter = fileIndex;
%
disp(['This is a template script.',...
    'Open the file "template.m" for additional information']);