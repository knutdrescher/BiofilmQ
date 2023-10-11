function renderGrid(handles, wCells, wShell, wInt, filename, params)

I = wInt(wShell);
I = prctile(I, 80);

w = uint32(wInt>I | wShell);
w(wCells) = 0;

objects = cubeSegmentation(w, params.gridSpacing);

stats_temp_shell = regionprops(objects, wInt, 'MeanIntensity');
stats_temp_shell = num2cell([stats_temp_shell.MeanIntensity]);
[stats.MeanIntensity] = stats_temp_shell{:};

objects.goodObjects = ones(1, numel(stats));
customFields = {'Area', 'volume_fraction', 'Grid_ID', 'MeanIntensity'};
cells = isosurfaceLabel(labelmatrix(objects), objects, 0.05, customFields, params);
mvtk_write(cells,fullfile(handles.settings.directory, 'data', [filename(1:end-4), '_shell.vtk']), 'legacy-binary', customFields);
