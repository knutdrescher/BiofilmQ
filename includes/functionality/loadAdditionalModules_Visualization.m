function handles = loadAdditionalModules_Visualization(handles)
if isdeployed
    addModules = dir(fullfile(handles.settings.pathGUI, '..', 'includes', 'additional modules visualization'));
else
    addModules = dir(fullfile(handles.settings.pathGUI, 'includes', 'additional modules visualization'));
end

addModules = addModules(setdiff(find([addModules.isdir]), [1, 2]));

% It is possible to enable the additional module 'trajectory analysis' for extended functionality of
% BiofilmQ. This modules is used in the drescher lab and specific to the
% data type generated there. There is no guarantee that it will work as expected on
% your data, so be cautious when using it.

modules = {};%{'trajectory analysis'}

fprintf('\n');
for i = 1:numel(addModules)
    if any(cellfun(@(x) strcmp(x,addModules(i).name), modules))
        fprintf('Enabling additional module "%s"\n', addModules(i).name);
        eval(sprintf('handles = enable_%s(handles);', strrep(addModules(i).name, ' ', '_')));
    end
end