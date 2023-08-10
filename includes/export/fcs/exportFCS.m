function handles = exportFCS(handles, objects, params, fields, filename)
ticValue = displayTime;

fieldsSave = [];
data = [];

goodObjects = objects.goodObjects;

fields = setdiff(fields, {'Centroid', 'BoundingBox', 'Cube_CenterCoord', 'Orientation_Matrix', 'Timepoint'});


% The wirteFCS function sets all negativ values to 0.
% Check for negativ values
invalidProps = {};
for i = 1:numel(fields)
    if any(strcmp(fields{i}, {'ID', 'RandomNumber', 'Distance_FromSubstrate'}))
        continue;
    end
    data_temp = [objects.stats(goodObjects).(fields{i})];
    if any(data_temp < 0)
        fprintf('\nfound invalid values in field %s\n', fields{i});
        invalidProps{end + 1} = fields{i};
    end
end

% Warn user if necessary.
if ~isempty(invalidProps)
    propStr = join(invalidProps,', ');
    msg = sprintf([
        'The properties %s contain negativ values ', ...
        'which will be set to zero during export!'], propStr{:});
    title = 'Export error';
    
    % Create a field in handles.settings such that the warning message is 
    % only showed once.
    if ~isfield(handles.settings, 'showedFCSError')
        handles.settings.showedFCSError = false;
    end
    
    if handles.settings.showMsgs && ~handles.settings.showedFCSError
        uiwait(msgbox(msg, title, 'warn', 'modal'));
        handles.settings.showedFCSError = true;
    else
        warning(msg);
    end
end
    

for i = 1:numel(fields)
    switch fields{i}
        case 'ID'
            data_temp = 1:objects.NumObjects;
            data_temp = data_temp(goodObjects);
            firstEntry = 1;
        case 'RandomNumber'
            data_temp = 1000*rand(1, sum(goodObjects));
            firstEntry = 1;
        case 'Distance_FromSubstrate'
            centroids = [objects.stats.Centroid];
            centroids = centroids(3:3:end)*objects.params.scaling_dxy/1000;
            data_temp = centroids(goodObjects);
            firstEntry = 1;
        otherwise
            data_temp = [objects.stats(goodObjects).(fields{i})];
            firstEntry = objects.stats(1).(fields{i});
    end
    
    if numel(firstEntry) == 1
        fieldsSave = [fieldsSave fields(i)];
        data = [data, data_temp'];
    end
end

directory_save = fullfile(handles.settings.directory, 'data', 'fcs_output');
if ~exist(directory_save, 'dir')
    mkdir(directory_save);
end

filename = fullfile(directory_save, filename);

if exist(filename, 'file')
    fprintf('\n - deleting old file');
    delete(filename);
end


fprintf('\n - writing "%s"\n', filename);
TEXT = [];
TEXT.PnN = fieldsSave;
warning('off','backtrace')
writeFCS(filename, single(data), TEXT);
warning('on','backtrace')
fprintf('-> Done');

displayTime(ticValue);
