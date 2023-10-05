function [objects, globalParamsCsv] = writeCSV(handles, objects, custom_fields_objects, params, filename)
folder = fullfile(handles.settings.directory, 'data', 'txt_output');
if ~exist(folder, 'dir')
    mkdir(folder);
end

%% Store global parameters
if isfield(objects, 'globalMeasurements')
    badFields = [];
    fNames = fieldnames(objects.globalMeasurements);
    is_struct = cellfun(@(x) isstruct(objects.globalMeasurements.(x)), fNames);
    fNames = fNames(~is_struct);
    
    header1 = [{'Ncells', 'Timepoint'}, fNames'];
    header2 = cell(1, numel(fNames)+2);
    
    header1(1:2) = {'Ncells', 'Timepoint'};
    for f = 1:numel(fNames)
        [label, unit] = returnUnitLabel(fNames{f}, {objects}, 'globalMeasurements');
        header2{f+2} = sprintf('%s (%s)', label, unit);
    end
    
    data = cell(1, numel(fNames)+2);
    if isfield(objects.metadata.data, 'date')
        data(1:2) = {sum(objects.goodObjects), objects.metadata.data.date}; 
    else
        data(1:2) = {sum(objects.goodObjects), NaN};
    end
    for f = 1:numel(fNames)
        if ~isstruct(objects.globalMeasurements.(fNames{f}))
            data{f+2} = objects.globalMeasurements.(fNames{f});
        else
            badFields(end+1) = f;
            
            % Export seperately
            try
                filename_save = fullfile(handles.settings.directory, 'data', 'txt_output', [filename(1:end-4), '_', fNames{f}, '.csv']);
                data_temp = [];
                fNames_temp = fieldnames(objects.globalMeasurements.(fNames{f}));
                for j = 1:numel(fNames_temp)
                    data_temp(:,j) = objects.globalMeasurements.(fNames{f}).(fNames_temp{j});
                end
                cell2csv(filename_save, [fNames_temp'; num2cell(data_temp)])
            end
        end
    end
    data(badFields+2) = [];
    header1(badFields+2) = [];
    header2(badFields+2) = []; 
    
    [spacer, header0] = deal(cell(size(header1)));
    header0(1) = {filename(1:end-4)};

    globalParamsCsv = [header0; header1; header2; data; spacer];
else
    globalParamsCsv = [];
end

%% Store per object data
fNames = sort(intersect(custom_fields_objects, fieldnames(objects.stats)));

header1 = [];
header2 = [];
data = {};

column = 1;
for f = 1:numel(fNames)
    switch lower(fNames{f})
        case 'id'
            ids = 1:objects.NumObjects;
            dataEntry = ids(objects.goodObjects);
            dataEntry = num2cell(dataEntry);
        case 'timepoint'
            dataEntry = repmat({objects.metadata.data.date}, 1, sum(objects.goodObjects));
        case 'randomnumber'
            dataEntry = num2cell(rand(1, sum(objects.goodObjects)));
        case 'Distance_FromSubstrate'
            centroids = [objects.stats.Centroid];
            centroids = centroids(3:3:end)*objects.params.scaling_dxy/1000;
            dataEntry = num2cell(centroids(objects.goodObjects));
        otherwise
            dataEntry = {objects.stats(objects.goodObjects).(fNames{f})};   
    end
    
    Nentries = unique(cellfun(@numel, dataEntry));
    
    if numel(Nentries) ~= 1
        fprintf('\n    - cannot export data for field [%s]', fNames{f});
        continue;
    end
    
    for row = 1:numel(dataEntry)
        
        switch lower(fNames{f})
            case 'centroid'
                if row  == 1
                    header1 = [header1, {'Centroid_x (um)', 'Centroid_y (um)', 'Centroid_z (um)'}];
                    header2 = [header2, {'Centroid_x', 'Centroid_y', 'Centroid_z'}];
                end
                data_width = 3;
                scaling = objects.params.scaling_dxy/1000;
                data(row, column:column+data_width-1) = {dataEntry{row}(1)*scaling dataEntry{row}(2)*scaling dataEntry{row}(3)*scaling};
                
            case 'orientation_matrix'
                if row  == 1
                    header1 = [header1, {'DirVector1_x', 'DirVector1_y', 'DirVector1_z',...
                        'DirVector2_x', 'DirVector2_y', 'DirVector2_z',...
                        'DirVector3_x', 'DirVector3_y', 'DirVector3_z'}];
                    header2 = [header2, {'DirVector1_x', 'DirVector1_y', 'DirVector1_z',...
                        'DirVector2_x', 'DirVector2_y', 'DirVector2_z',...
                        'DirVector3_x', 'DirVector3_y', 'DirVector3_z'}];
                    end
                data_width = 9;
                data(row, column:column+data_width-1) = {dataEntry{row}(1,1), dataEntry{row}(2,1), dataEntry{row}(3,1),...
                    dataEntry{row}(1,2), dataEntry{row}(2,2), dataEntry{row}(3,2),...
                    dataEntry{row}(1,3), dataEntry{row}(2,3), dataEntry{row}(3,3)};
                
            otherwise
                data_width = Nentries;
                switch Nentries
                    case 1
                        if row  == 1
                            [label, unit] = returnUnitLabel(fNames{f}, {objects}, 'stats');
                            header1 = [header1, {sprintf('%s %s', label, unit)}];
                            header2 = [header2, fNames(f)];
                        end
                        data(row, column) = {dataEntry{row}};
                    case 3
                        if row  == 1
                            [label, unit] = returnUnitLabel(fNames{f}, {objects}, 'stats');
                            header1 = [header1, {sprintf('%s_x %s', label, unit), sprintf('%s_y %s', label, unit), sprintf('%s_z %s', label, unit)}];
                            header2 = [header2, {sprintf('%s_x', fNames{f}), sprintf('%s_y', fNames{f}), sprintf('%s_z', fNames{f})}];
                        end
                        data(row, column:column+data_width-1) = {dataEntry{row}(1), dataEntry{row}(2), dataEntry{row}(3)};
                    otherwise
                        if row  == 1
                            try
                                [label, unit] = returnUnitLabel(fNames{f}, {objects}, 'stats');
                            catch
                                label = fNames{f};
                                unit = 'a.u.';
                            end
                        end
                        for i = 1:numel(dataEntry{1})
                            if row  == 1
                                header1 = [header1, {sprintf('%s_%d %s', label, i, unit)}];
                                header2 = [header2, {sprintf('%s_%d', fNames{f}, i)}];
                            end
                            data(row, column+i-1) = {dataEntry{row}(i)};
                        end
                end
        end
    end
    
    column = column + data_width;
end
filename_save = fullfile(handles.settings.directory, 'data', 'txt_output', filename);
fprintf('    - writing "%s"\n', filename_save);
try
    cell2csv(filename_save, [header2; header1; data])
catch
    uiwait(msgbox(sprintf('Cannot write file "%s"! Is the file already in use?',filename), 'Error', 'error', 'modal'));
end