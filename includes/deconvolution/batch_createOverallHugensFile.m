%% Generate combined batch file for all files
function fileName = batch_createOverallHugensFile(input_folder, output_folder, params, folders)

folders = obtainFolders(input_folder, 'foldersToProcess', folders);

files = [];
isdecon = @(x) isempty(strfind(x, '_cmle'));
for i = 1:numel(folders)
    if exist(fullfile(folders{i}, 'deconvolved images'))
        files_temp = dir(fullfile(folders{i}, 'deconvolved images', '*.tif'));
        
        if ~isempty(files_temp)
            % Remove cmle-files
            if length(files_temp)>1
                files_decon = arrayfun(isdecon,{files_temp.name});
                files_temp(files_decon) = [];
            % we need to distinguish, because otherwise the result is
            % always 1
            else
                if ~isempty(strfind(files_temp.name, '_cmle'))
                    files_temp(files_decon) = [];
                end
            end
            
            % Remove files which are deconvolved
            valid_files = true(numel(files_temp), 1);
            for j = 1:numel(files_temp)
                if exist(fullfile(files_temp(j).folder, [files_temp(j).name(1:end-4), '_cmle.tif']), 'file')
                    valid_files(j) = false;
                    
                    % Delete image
                    % delete(fullfile(files_temp(j).folder, files_temp(j).name))
                end
            end
            files_temp = files_temp(valid_files);
            
            if ~isempty(files_temp)
               files = vertcat(files, files_temp); 
            end
        end
        
    end
end

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
fileName = generateHuygensBatchFile(files, output_folder, params);