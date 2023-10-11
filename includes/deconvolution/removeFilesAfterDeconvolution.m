function removeFilesAfterDeconvolution(handles)
% REMOVEFILESAFTERDECONVOLUTION(handles) removes file from 'deconvolved images'
% folder, which do not have a cmle ending. Can either be called using GUI
% (in this case, handles is the GUI handles) or from batch file, in which
% case handles should be the directory


if isstruct(handles)
    mode = 1;
    output_folder = fullfile(handles.settings.directory, 'deconvolved images');
else
    mode = 0;
    output_folder = handles;
end


if ~exist(output_folder, 'dir')
    warning('Files are not deconvoluted.');
    return;
end

if mode
    displayStatus(handles, 'Removing files...', 'black')
end

true_files = dir(fullfile(output_folder, '*.tif'));

try
    delete(fullfile(output_folder, '*.txt'));
    delete(fullfile(output_folder, '*.hgsb'));
    delete(fullfile(output_folder, '*.log'));
end

for j = 1:numel(true_files)
    if mode
        updateWaitbar(handles, j/numel(true_files));
    end
    
    name = true_files(j).name;
    % only delete files without cmle ending
    if ~any(strfind(name, 'cmle'))
        delete(fullfile(true_files(j).folder, true_files(j).name));
    end
end
if mode
    displayStatus(handles, 'Done', 'gray', 1);
    updateWaitbar(handles, 0);
end

leftfiles = dir(output_folder);
if length(leftfiles)<3
    rmdir(output_folder);
end

end

