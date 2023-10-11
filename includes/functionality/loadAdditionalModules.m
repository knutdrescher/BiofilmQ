function handles = loadAdditionalModules(handles)
if isdeployed
    addModules = dir(fullfile(handles.settings.pathGUI, '..', 'includes', 'additional modules'));
else
    addModules = dir(fullfile(handles.settings.pathGUI, 'includes', 'additional modules'));
end

addModules = addModules(setdiff(find([addModules.isdir]), [1, 2]));

% List of modules to load. We recommend the list below, however it is
% possible to enable additional modules for extended functionality of
% BiofilmQ. These modules are used in the drescher lab and specific to the
% data type generated there. There is no guarantee that they will work as expected on
% your data, so be cautious when using any of them.

modules = {'cell tracking', 'ellipse representation' , 'single cell properties'};%, ...
            % note that when using single cell segmentation, single cell properties also need to be enabled
            %'single cell segmentation', 'image series curation', ...
            % 'huygens deconvolution', 'simulations', 'thresholding by slice'};

fprintf('\n');
for i = 1:numel(addModules)
    if any(cellfun(@(x) strcmp(x,addModules(i).name), modules))
        fprintf('Enabling additional module "%s"\n', addModules(i).name);
        eval(sprintf('handles = enable_%s(handles);', strrep(addModules(i).name, ' ', '_')));
    end
end

if isdeployed
    for i = 1:numel(modules)
        try
            fprintf('Enabling additional module "%s"\n', modules{i});
            eval(sprintf('handles = enable_%s(handles);', strrep(modules{i}, ' ', '_')));
        catch
            fprintf(['Module not found: ', modules{i}]);
        end
    end
end
    