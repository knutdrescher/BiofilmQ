function processObjects(hObject, eventdata, handles)
disp(['=========== Calculating cell properties ===========']);

ticValueAll = displayTime;

% Load parameters
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;
range = str2num(params.action_imageRange);

files = handles.settings.lists.files_cells;
if ~isempty(files(:))
    validFiles = find(cellfun(@(x) isempty(x), strfind({files.name}, 'missing')));
    
    range_new = intersect(range, validFiles);
    
    if numel(range) ~= numel(range_new)
        fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
    end
else
    range_new = [];
end
range = range_new;

if isempty(range)
    uiwait(msgbox('No object files present.', 'Error', 'error', 'modal'));
    fprintf('No object files present -> Processing cancelled.\n');
    return;
end

try
    enableCancelButton(handles)
end

%% Walk through the files
for f = range
    ticValueImage = displayTime;
    disp(['=========== Processing image ', num2str(f), ' of ', num2str(length(files)), ' ===========']);
    
    % Update waitbar
    updateWaitbar(handles, (f-range(1))/(1+range(end)-range(1))+0.001);
    
    % Load segmented objects
    displayStatus(handles,['Processing cells ', num2str(f), ' of ', num2str(length(files)), '...'], 'blue');
    filename = fullfile(handles.settings.directory, 'data', files(f).name);
    
    try
        objects = loadObjects(filename);
    catch
       fprintf('   - skipping file \n') 
    end
    
    if objects.NumObjects == 0
        fprintf('   - empty file (skipping)\n');
        continue;
    end

    updateWaitbar(handles, (f+0.6-range(1))/(1+range(end)-range(1)));
    displayStatus(handles, 'calculating properties...', 'blue', 'add');
    
    try
        imageFilename = handles.settings.lists.files_tif(f).name;
    catch
        imageFilename = '';   
    end
    
    objects = calculateCellProperties(handles, objects, params, imageFilename, f);
    
    % Save files
    updateWaitbar(handles, (f+0.9-range(1))/(1+range(end)-range(1)));
    if ~params.cellParametersNoSaving
        try
            gitInfo = getGitInfo();
            objects.version.gitInfo_paramCalculation = gitInfo;
            objects.version.BiofilmQVersion_paramCalculation = fileread('biofilmQ_version.txt');
        end
        saveObjects(filename, objects, 'all', 'overwrite')
    end
    
    displayStatus(handles, 'Done', 'blue', 'add');

    fprintf('-> total elapsed time per image')
    displayTime(ticValueImage);
    
    if checkCancelButton(handles)
        break;
    end
end

% if params.sendEmail
%     email_to = get(handles.uicontrols.edit.email_to, 'String');
%     email_from = get(handles.uicontrols.edit.email_from, 'String');
%     email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
%     
%     setpref('Internet','E_mail',email_from);
%     setpref('Internet','SMTP_Server',email_smtp);
%     
%     sendmail(email_to,['[Biofilm Toolbox] Calculation of cell parameters finished: "', handles.settings.directory, '"']', ...
%         ['Calculation of cell parameters of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
% end

updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);
