function objects = loadObjects(filename, fieldnames, silent)

if ~exist(filename, 'file')
    uiwait(msgbox(sprintf('Cell-file "%s" does not exist!', filename), 'Error', 'error'));
    return;
end

[~, fname] = fileparts(filename);


objects = struct;

try
    attr = checkVarnames(filename);
catch
    matObj = matfile(filename);
    fileDetails = whos(matObj);
    attr = {fileDetails.name};
end

if nargin == 1
    fieldnames = 'all';
    silent = 0;
end

if nargin == 2
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

if ~sum(strcmp(fieldnames, 'measurementFields')) && ~sum(strcmp(fieldnames, 'all'))
    try
        fieldnames = {fieldnames{:}, 'Connectivity', 'ImageSize', 'NumObjects', 'merged', 'splitted', 'goodObjects', 'measurementFields', 'params'};
    catch
        fieldnames = {fieldnames, 'Connectivity', 'ImageSize', 'NumObjects', 'merged', 'splitted', 'goodObjects', 'measurementFields', 'params'};
    end
    
end

if strcmp(fieldnames, 'all')
    fieldnames = attr;
end

if ~isempty(cell2mat(strfind(attr, 'objects')))
    % Load old data format
    data = load(filename, 'objects');
    objects = data.objects;
    measurementFields = fields(objects.stats);
    objects.measurementFields = measurementFields;
    save(filename, 'measurementFields', '-append');
else
    
    fieldnames_load = attr;
    
    fieldnames_load = intersect(fieldnames_load, fieldnames);
    
    %if strcmp(fieldnames, 'PixelIdxList')
    %         fieldnames_load(strcmp(fieldnames_load, 'stats')) = [];
    %     end
    %     if strcmp(fieldnames, 'stats')
    %         fieldnames_load(strcmp(fieldnames_load, 'PixelIdxList')) = [];
    %     end
    
%     if sum(strcmp(fieldnames, 'measurementFields'))
%         if ~sum(strcmp(fieldnames_load, 'measurementFields'))
%             fieldnames_load(strcmp(fieldnames_load, 'PixelIdxList')) = [];
%         else
%             objects = load(filename, 'measurementFields');
%             return;
%         end
%     end
    
    fileAttr = dir(filename);
    if ~silent
        fprintf(' - loading cells [%s.mat, %u Mb]', fname, round(fileAttr.bytes/1000/1000))
    end
    if ~silent
        textprogressbar('      ');
    end
    % Load data
    for i = 1:numel(fieldnames_load)
        data = load(filename, fieldnames_load{i});
        objects.(fieldnames_load{i}) = data.(fieldnames_load{i});
        if ~silent
            textprogressbar(i/numel(fieldnames_load)*100);
        end
    end   
    

    try
        if ~sum(strcmp(fieldnames_load, 'measurementFields'))
            measurementFields = fields(objects.stats);
            objects.measurementFields = measurementFields;
            save(filename, 'measurementFields', '-append');
        else
            try
                % Update measurement fields if the differ
                measurementFieldsFile = fields(objects.stats);
                if ~strcmp([measurementFieldsFile{:}], [objects.measurementFields{:}])
                    measurementFields = measurementFieldsFile;
                    save(filename, 'measurementFields', '-append');
                end
            end 
        end
    end

end
if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    displayTime(ticValue);
end