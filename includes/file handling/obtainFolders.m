function folders = obtainFolders(inputFolder, varargin)

% Parse input parameters
p = inputParser;

addRequired(p, 'inputFolder');
addParameter(p, 'state', 'all');
addParameter(p, 'foldersToProcess', {''});

parse(p,inputFolder,varargin{:});

% Assign parameters
inputFolder = p.Results.inputFolder;
state = p.Results.state;
foldersToProcess = p.Results.foldersToProcess;

%% Process folderlist
folders = genpath(inputFolder);
folders = strsplit(folders, ';');

%% Only take folders being subfolders of folders listed in folderList
if ~isempty(foldersToProcess{1})
    % Only take folders to process
    continueWithFolders = false(1, numel(folders));
    for i = 1:numel(foldersToProcess)
        processFolder = strfind(folders, foldersToProcess{i});
        continueWithFolders(~cellfun(@isempty, processFolder)) = true;
    end
    folders = folders(continueWithFolders);
end

%% Generate subset of processed folders
if strcmpi(state, 'processed')
    % Only take folders which have a data folder present
    continueWithFolders = false(1, numel(folders));
    for i = 1:numel(folders)
        [~, lastFolder] = fileparts(folders{i});
        if strcmp(lastFolder, 'data')
            continueWithFolders(i) = true;
        end
    end
    folders = folders(continueWithFolders);
    
    % Strip data-folders
    folders = cellfun(@fileparts, folders, 'UniformOutput', false);
end
 
%% Generate subset of processed folders
if strcmpi(state, 'unprocessed')
    % Only take folders which have no data folder present
    continueWithFolders = false(1, numel(folders));
    for i = 1:numel(folders)
        if ~isdir(fullfile(folders{i}, 'data'))
            continueWithFolders(i) = true;
        end
    end
    folders = folders(continueWithFolders);
end

folders = folders';