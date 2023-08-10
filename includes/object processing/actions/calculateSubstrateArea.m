function objects = calculateSubstrateArea(handles, objects,params, filename, layer)

toUm2 = @(voxel, scaling) voxel.*(scaling/1000)^2;

% % rescale tif stack layer to internal isotropic image resolution
% im_layer = round(params.scaling_dz/params.scaling_dxy*layer);

substrateLayer = zeros(objects.ImageSize);
if numel(objects.ImageSize) == 2
    substrateLayer = labelmatrix(objects)>0;
    colonies = regionprops(objects, substrateLayer, 'Area', 'MeanIntensity');
	coverage = num2cell([colonies.Area].*[colonies.MeanIntensity]);
else
    if strcmp(layer, '') || isempty(layer)
        [~, ~, img_raw, ~, params, ~] ...
        = getImageFromRaw(handles, objects, params, filename, params.channel);
        [~, layer] = max(sum(sum(img_raw{params.channel}, 1), 2));
    end
    
    im_layer = round(objects.params.scaling_dz/objects.params.scaling_dxy*layer);
    substrateLayer(:,:,im_layer) = 1;

    try % regionprops3 is a R2017b feature
        colonies = regionprops3(objects, substrateLayer, 'Volume', 'MeanIntensity');
        coverage = num2cell([colonies.Volume].*[colonies.MeanIntensity]);
    catch ME
        if (strcmp(ME.identifier, 'MATLAB:UndefinedFunction'))
            w = labelmatrix(objects);
            slice = w(:, :, im_layer);
            coverage = num2cell(histc(slice(:), 1:objects.NumObjects));
        else % unknown error
            rethrow(ME);
        end
    end

end

[objects.stats.Architecture_LocalSubstrateArea] = coverage{:};
objects.globalMeasurements.Biofilm_SubstrateArea = toUm2(sum([coverage{:}]), objects.params.scaling_dxy);
objects.globalMeasurements.Biofilm_SubstratumCoverage = sum([coverage{:}])/(objects.ImageSize(1)*objects.ImageSize(2));

end

