function objects = tagCells(objects, params)

if any(strcmp(params.tagCells_name, fieldnames(objects.stats)))
    error(['Tagname "%s" already exists!\n', ...
        'Use "Remove object parameters" to delete the existing tag first!'], ...
        params.tagCells_name)
end

for i = 1:size(params.tagCells_rules,1)
    centroids = [objects.stats.Centroid];
    
    if strcmp(params.tagCells_rules{i,1}, 'CentroidCoordinate_x')
        x = centroids(1:3:end);
        field = [params.tagCells_rules{i,1}];
    elseif strcmp(params.tagCells_rules{i,1}, 'CentroidCoordinate_y')
        y = centroids(2:3:end);
        field = [params.tagCells_rules{i,1}];
    elseif strcmp(params.tagCells_rules{i,1}, 'CentroidCoordinate_z')
        z = centroids(3:3:end);
        field = [params.tagCells_rules{i,1}];
    elseif strcmp(params.tagCells_rules{i,1}, 'ID')
        ID = 1:numel(objects.stats);
        field = [params.tagCells_rules{i,1}];
    else
        field = ['[objects.stats.', params.tagCells_rules{i,1}, ']'];
    end
    if i == 1
        rule = [field, params.tagCells_rules{i,2}, num2str(params.tagCells_rules{i,3})];
    else
        rule = [rule, '&', field, params.tagCells_rules{i,2}, num2str(params.tagCells_rules{i,3})];
    end
end

eval(['filterField = ', rule, ';']);

filterField = num2cell(filterField);

[objects.stats.(params.tagCells_name)] = filterField{:};