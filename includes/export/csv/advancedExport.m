function advancedExport(handles)

% get data location
outputdir = uigetdir(handles.settings.directory, 'Select data parent folder'); 

dataFolders = dir([outputdir, '\*']); 
dataFolders = dataFolders([dataFolders.isdir]);
dataFolders = dataFolders(~(strcmp({dataFolders.name}, '..')|strcmp({dataFolders.name}, '.')));

dataFiles = dir(fullfile(dataFolders(1).folder, dataFolders(1).name, 'data\*ch1_frame*.mat'));

if isempty(dataFiles)
    
    h = msgbox('No .mat file present! Is channel 1 segmented?','','warn');
    uiwait(h);
    return
    
end

% check for amount of channels

ch = {'ch1'}; 
j = 2; 

while exist(fullfile(dataFiles(1).folder, strrep(dataFiles(1).name, '_ch1_', ['_ch', num2str(j), '_']))) 

    ch{j} = ['ch', char(string(j))]; 
    j = j + 1; 

end

% get variables to extract
varList = {}; 

for k = 1:length(ch)

    dataFile = load(fullfile(dataFiles(1).folder, strrep(dataFiles(1).name, '_ch1_', ['_', ch{k}, '_']))); 
    varList{k} = ['Object_Number'; fieldnames(dataFile.globalMeasurements)];

end

[exportX, exportY, exportCase, variables2Check, channel2Check] = variableSelectionGui(varList, ch);

toggleBusyPointer(handles, true)
updateWaitbar(handles, 0.01);

% prealocate dataTable                
dataMat = nan(length(dataFolders), length(dataFiles), length(variables2Check));           
nFolders = length(dataFolders); 
nFiles = length(dataFiles);
nVars = length(variables2Check);
 
for m = 1:nFolders

    % get data location for different timepoints in position folder
    
    dataFiles = dir(fullfile(dataFolders(m).folder, dataFolders(m).name, 'data\*ch1_frame*.mat'));
     
    % extract requested data from files
    
    disp(['Exporting Position ', num2str(m), '...'])
    
    for n = 1:nFiles
        
        % loop through variables and channels
        
        for p = 1:nVars

            if strcmp(variables2Check{p}, 'Object_Number')
                try 
                    ObjectNumber = load(fullfile(dataFiles(n).folder, strrep(dataFiles(n).name,...
                        '_ch1_', ['_ch', num2str(channelTemp), '_'])), 'NumObjects');
                    dataMat(m, n, p) = ObjectNumber.NumObjects;
                    continue
                catch
                    disp(['Object number for position ', char(string(m)), ', frame ', ...
                        char(string(n)), ' missing!'])
                    continue
                end
            end
                                
            channelTemp = channel2Check(p);
            if ~(p>1 && (channel2Check(p) == channel2Check(p-1)))      
                try                
                    dataFile = load(fullfile(dataFiles(n).folder, strrep(dataFiles(n).name,...
                    '_ch1_', ['_ch', num2str(channelTemp), '_'])), 'globalMeasurements');  
                catch 
                    disp(['Global measurements for position ', char(string(m)), ', frame ', ...
                        char(string(n)), ' missing!'])
                    break
                end
            end

            if isfield(dataFile.globalMeasurements, variables2Check{p})
                dataMat(m, n, p) = dataFile.globalMeasurements.(variables2Check{p}); 
            else
                disp([variables2Check{p}, ' for position ', char(string(m)), ', frame ', ...
                    char(string(n)), ' missing!'])
            end
        end           
    end
    
    updateWaitbar(handles, (m-1)/(nFolders)+0.01);
    
end

% Get names of positions, frames and variables

frames = cellfun(@(x) sprintf('frame %d', x), num2cell(1:nFiles), 'UniformOutput', false);
positions = {dataFolders.name};
variables = cellfun(@horzcat, cellfun(@(x) sprintf('ch%d ', x), num2cell(channel2Check), 'UniformOutput', false), variables2Check, 'UniformOutput', false);
% Variable names are sometimes too long for the accepted excel sheet name 
% length. Set this to one to use 'Variable n' as sheet name
variableFlag = 0; 

% switch through cases (x-axis variable of table, y-axis variable of table)
% and create dataTable iterating through third variable

switch exportX 
    case 'Position'
        switch exportY
            case 'Frame'
                sheetNames = variables; 
                variableFlag = 1; 
                for r = 1:nVars 
                    dataTable{r}(:, 1) = ['Placeholder'; frames'];
                    dataTable{r}(:, 2:length(positions)+1) = [positions; num2cell(dataMat(:, :, r))'];
                end
            case 'Variable'
                sheetNames = frames; 
                for r = 1:nFiles
                    dataTable{r}(:, 1) = ['Placeholder'; variables'];
                    dataTable{r}(:, 2:length(positions)+1) = [positions; squeeze(num2cell(dataMat(:, r, :)))'];
                end             
        end
    case 'Frame'
        switch exportY
            case 'Position'
                sheetNames = variables; 
                variableFlag = 1; 
                for r = 1:nVars
                    dataTable{r}(:, 1) = ['Placeholder'; positions'];
                    dataTable{r}(:, 2:length(frames)+1) = [frames; num2cell(dataMat(:, :, r))];
                end           
            case 'Variable'
                sheetNames = positions; 
                for r = 1:nFolders
                    dataTable{r}(:, 1) = ['Placeholder'; variables'];
                    dataTable{r}(:, 2:length(frames)+1) = [frames; squeeze(num2cell(dataMat(r, :, :)))'];
                end            
        end        
    case 'Variable'
        switch exportY
            case 'Position'
                sheetNames = frames; 
                for r = 1:nFiles
                    dataTable{r}(:, 1) = ['Placeholder'; positions']; 
                    dataTable{r}(:, 2:length(variables)+1) = [variables; squeeze(num2cell(dataMat(:, r, :)))];  
                end
            case 'Frame'
                sheetNames = positions;
                for r = 1:nFolders
                    dataTable{r}(:, 1) = ['Placeholder'; frames']; 
                    dataTable{r}(:, 2:length(variables)+1) = [variables; squeeze(num2cell(dataMat(r, :, :)))];  
                end
        end
end

% Export data: either all dataTables in one sheet or each data table in a
% different sheet of an excel file

delete(fullfile(outputdir, 'Summary_multiple_variables.xlsx'));

updateWaitbar(handles, 0.95)

switch exportCase
    case 'Data summary (all in one sheet)'
        dataTableWrite = {}; 
        for s = 1:length(dataTable)
            dataTableTemp = dataTable{s};
            dataTableTemp{1, 1} = []; 
            dataTableTitle = [sheetNames{s} cell(1, size(dataTableTemp, 2)-1)]; 
            dataTableWrite = [dataTableWrite; dataTableTitle; dataTableTemp; cell(3, size(dataTableTemp, 2))];
        end       
        writecell(dataTableWrite, fullfile(outputdir, 'Summary_multiple_variables.xlsx'))
    case 'Different sheets'
        for s = 1:length(dataTable)
            dataTableTemp = dataTable{s};
            dataTableTemp{1, 1} = []; 
            if variableFlag == 1
                dataTableTitle = [sheetNames{s} cell(1, size(dataTableTemp, 2)-1)]; 
                dataTableWrite = [dataTableTitle; dataTableTemp];
                writecell(dataTableWrite, fullfile(outputdir, 'Summary_multiple_variables.xlsx'), 'Sheet', ['Variable ', num2str(s)]);
            else
                writecell(dataTableTemp, fullfile(outputdir, 'Summary_multiple_variables.xlsx'), 'Sheet', sheetNames{s});
            end
        end          
end

updateWaitbar(handles, 1)
toggleBusyPointer(handles, false)
updateWaitbar(handles, 0)

end

 
 