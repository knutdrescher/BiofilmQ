function handles = biofilmInfo(hObject, eventdata, handles)

biofilmData = getLoadedBiofilmFromWorkspace;
if isempty(biofilmData)
    return;
end

infoTable = {};

% biofilm info
if numel(biofilmData.timepoints) > 1
    minInterval = min(diff(biofilmData.timepoints(2:end)));
else
    minInterval = 0;
end


% Choose to display time in hours, minutes or seconds
if minInterval < 10
   factor = 1;
   t_label = 't [s]';
elseif minInterval < 100
    factor = 1/60;
    t_label = 't [min]';
else
    factor = 1/(60*60);
    t_label = 't [h]';
end
timepoints = biofilmData.timepoints*factor;
index = 1:numel(timepoints);

if sum(timepoints) == 0
    t_label = '#';
    timepoints = index;
end

table_overviewFields = {'Index', t_label, 'Ncells', 'Max track ID', 'Filename'};
try
    for i = 1:numel(biofilmData.data)
        if isfield(biofilmData.data(i).stats, 'Track_ID')
            infoTable(i, :) = {index(i), timepoints(i), biofilmData.data(i).NumObjects, max([biofilmData.data(i).stats.Track_ID]), biofilmData.data(i).Filename};
        else
            infoTable(i, :) = {index(i), timepoints(i), biofilmData.data(i).NumObjects, [], biofilmData.data(i).Filename};
        end
    end
end


additionalFields = [];
if isfield(biofilmData.data, 'globalMeasurements')
    
    additionalFields = cellfun(@getFieldnames, {biofilmData.data.globalMeasurements}, 'UniformOutput', false);
    additionalFields = unique(vertcat(additionalFields{:}));
    additionalFields(cellfun(@isempty, additionalFields)) = [];
    additionalFields = additionalFields;
    
    additionalFields = setdiff(additionalFields, {'Time', 'Cell_Number', 'Distance_FromSubstrate'});
    fieldsToShow = {};
    correspondingFields(1).reduced = '';
    correspondingFields(1).fields = {};
    appendices = {'_core_', '_shell_', '_mean', '_median', '_std', '_p25', '_p75', '_min', '_max'};
        
    columes_infoTable = size(infoTable,2);
    for i = 1:numel(biofilmData.data)
        for j = 1:numel(additionalFields)
            if isfield(biofilmData.data(i).globalMeasurements, additionalFields{j})
                if isstruct(biofilmData.data(i).globalMeasurements.(additionalFields{j}))
                    infoTable{i, columes_infoTable+j:columes_infoTable+j} = 'Multi-dim data';
                else
                    infoTable{i, columes_infoTable+j:columes_infoTable+j} = biofilmData.data(i).globalMeasurements.(additionalFields{j});
                    
                    if i==1
                        hasAppendix = @(x) any(strfind(additionalFields{j}, x));
                        ind = cellfun(hasAppendix, appendices);
                        if sum(ind)>0
                            app = find(ind);
                            ind = strfind(additionalFields{j}, appendices{app(1)});
                            index = find(cellfun(@(x) strcmp(x, ['[+] ', additionalFields{j}(1:ind-1)]), {correspondingFields.reduced}));
                            if isempty(index)
                                correspondingFields(end+1).reduced = ['[+] ', additionalFields{j}(1:ind-1)];
                                correspondingFields(end).fields = {['   ',additionalFields{j}]};
                            else
                                correspondingFields(index).fields = unique([correspondingFields(index).fields, {['   ',additionalFields{j}]}]);
                            end
                        else
                            correspondingFields(end+1).reduced = additionalFields{j};
                        end
                    end
                end
            else
                infoTable{i, columes_infoTable+j:columes_infoTable+j} = '';
            end
        end
    end
    
    tableHeader = cell(numel(additionalFields), 1);
    for i = 1:numel(additionalFields)
        [label, unit] = returnUnitLabel(additionalFields{i});
        unit = strrep(unit, '\mu', 'u');
        
        tableHeader{i} = [additionalFields{i}, ' ', unit];
    end
    table_overviewFields = [table_overviewFields tableHeader'];
    %set(handles.uitables.analysis_files, 'ColumnWidth', [50 50 50 200 repmat({100}, 1, numel(additionalFields))]);
else
    %set(handles.uitables.analysis_files, 'ColumnWidth', {50 50 50 200});
end

%set(handles.uitables.analysis_files, 'Data', infoTable);
%set(handles.uitables.analysis_files, 'ColumnName', table_overviewFields);

createJavaTable(handles.java.tableAnalysis{2}, [], handles.java.tableAnalysis{1}, infoTable, table_overviewFields, false(numel(table_overviewFields), 1));


additionalFields = [{'Time', 'Cell_Number'}, additionalFields'];
fNames = cellfun(@fieldnames, {biofilmData.data.stats}, 'UniformOutput', false);
fNames = unique(vertcat(fNames{:}));
idxInd = unique([find(cellfun(@(x) ~isempty(x), strfind(fNames, '_Idx_'))), find(cellfun(@(x) ~isempty(x), strfind(fNames, 'Foci_Intensity'))), find(cellfun(@(x) ~isempty(x), strfind(fNames, 'Foci_Quality')))]);
fNames(idxInd) = [];
fNames = setdiff(fNames, {'BoundingBox', 'MinBoundBox_Cornerpoints', 'Cube_CenterCoord', 'Orientation_Matrix', 'Centroid'});

firstFields = {'Time', 'Cell_Number', 'Distance_FromSubstrate'};
set(handles.handles_analysis.uicontrols.listbox.listbox_fieldNames, 'String', vertcat(firstFields', sort(setdiff(fNames,firstFields))), 'Value', 1);

correspondingFields = correspondingFields(2:end);
fieldsToShow = [{'Time', 'Cell_Number'}, {correspondingFields.reduced}];
fieldsToShow = unique(fieldsToShow);
firstFields = {'Time', 'Cell_Number'};
fieldsToShow = vertcat(firstFields', sort(setdiff(fieldsToShow',firstFields)));

handles.settings.measurementFieldsAnalysis_singleCell = fNames;
handles.settings.measurementFieldsAnalysis_global = additionalFields;
handles.settings.measurementFieldsAnalysis_globalReduced = fieldsToShow;
handles.settings.measurementFieldAnalysis_correspondingFields = correspondingFields;



function fNames = getFieldnames(x)

try 
    fNames = fieldnames(x);
catch
    fNames = [];
end