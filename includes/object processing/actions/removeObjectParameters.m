function objects = removeObjectParameters(objects, fields)
fprintf('\n');

fields = strsplit(fields, ',');
fields = cellfun(@strtrim, fields, 'un', 0);

for i = 1:numel(fields)
    try
        objects.stats = rmfield(objects.stats, fields{i});
        fprintf(' - field "%s" removed\n', fields{i});
    catch
        warning('backtrace', 'off');
        warning(' - field "%s" CANNOT be removed!\n', fields{i});
        warning('backtrace', 'on');
    end
end