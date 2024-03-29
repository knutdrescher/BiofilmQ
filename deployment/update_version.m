debug = false;


root = fileparts(mfilename('fullpath'));

fid = fopen(fullfile(root, '..', 'includes', 'biofilmQ_version.txt'));
versions = textscan(fid, '%s');
fclose(fid);

version_long = versions{1}{1};
version_long_without_v = versions{1}{1};
version_long_without_v(1) = [];
version_short = versions{1}{2};


locs = {...
    struct( ...
        'filename', fullfile(root, '..' , 'deployment', 'BiofilmQ_incl_mcr.prj'), ...
        'pattern', '(?<=<param.version>)[^\r\n]*(?=</param.version>)', ...
        'input', version_long_without_v), ...
    struct( ...
        'filename', fullfile(root, '..', 'docs', 'conf.py'), ...
        'pattern', "(?<=version = ')[^\r\n]*(?=')", ...
        'input', version_short), ...
    struct( ...
        'filename', fullfile(root, '..', 'docs', 'conf.py'), ...
        'pattern', "(?<=release = ')[^\r\n]*(?=')", ...
        'input',   version_long), ...
    struct( ...
        'filename', fullfile(root, '..', 'docs', 'usage', 'installation.rst'), ...
        'pattern',  "(?<=\s{4}\- )v\d+\.\d+[^\s]*" ,...
        'input', version_long) ...
    };
    
for i = 1:numel(locs)
    filename = locs{i}.filename;
    text = fileread(filename);
    
    fprintf('Update version string in %s to %s\n', filename, locs{i}.input)
    
    if debug
        regexp(text, locs{i}.pattern, 'match')
    end
    
    text = regexprep(text, locs{i}.pattern, locs{i}.input, 'emptymatch', 'warnings');
    lines = splitlines(text);
    mid = fopen(filename, 'w');
    fprintf(mid, '%s\n', lines{1:end-1});
    fprintf(mid, lines{end});
    fclose(mid);

end
