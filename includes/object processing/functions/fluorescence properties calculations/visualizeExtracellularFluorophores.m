function visualizeExtracellularFluorophores(objects, img, ch_task, opts, task, handles, filename, range)

objects_shells = calculateObjectShells(objects, range);

shells_mask = labelmatrix(objects_shells)>0;

% determine threshold
shells = img{ch_task}(shells_mask);
%threshold = mean(shells);
%aboveThreshold = img{ch_task}>threshold;
%intensity = img{ch_task}(aboveThreshold);
%[Y, X, Z] = ind2sub(objects.ImageSize, find(aboveThreshold));

intensity = shells;
[Y, X, Z] = ind2sub(objects.ImageSize, find(shells_mask));
matrix = struct('vertices',[X Y Z], 'intensity',intensity);

zIdx = strfind(filename, '_Nz');
frameIdx = strfind(filename, '_frame');
% chIdx = strfind(filename, '_ch');
% filename(chIdx+3) = num2str(ch_task);
mvtk_write(matrix, fullfile(handles.settings.directory, 'data', [filename(1:frameIdx-1), '_shell_', filename(frameIdx+1:zIdx-1), '.vtk']) , 'legacy-binary', {'intensity'});



