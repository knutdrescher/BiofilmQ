function saveObjects(filename, objects, fieldnames, writeMode, silent)
[~, fname] = fileparts(filename);

measurementFields = fields(objects.stats);

fieldnames_save = fields(objects);

if nargin < 3
    fieldnames = 'all';
    writeMode = '-append';
end

if nargin < 4 % Create a new file, overwrite existing
    writeMode = '-append';
end

if nargin < 5 % Create a new file, overwrite existing
    silent = 0;
end

if ~silent
    fprintf(' - saving cells [%s.mat]', fname)
    ticValue = displayTime;
    textprogressbar('      ');
end

if strcmp(fieldnames, 'PixelIdxList')
    if isfield(objects, 'stats')
        objects = rmfield(objects, 'stats');
    end
end
if strcmp(fieldnames, 'stats')
    if isfield(objects, 'PixelIdxList')
        objects = rmfield(objects, 'PixelIdxList');
    end
end

% Save data
objects.measurementFields = fields(objects.stats);

props = whos('objects');

if strcmp(writeMode, '-append')
    if props.bytes*10^(-9)>2
        save(filename, '-struct', 'objects', '-append', '-v7.3');
    else
        save(filename, '-struct', 'objects', '-append');
    end
else
    if props.bytes*10^(-9)>2
        save(filename, '-struct', 'objects', '-v7.3');
    else
        save(filename, '-struct', 'objects');
    end
end


if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    displayTime(ticValue);
end
