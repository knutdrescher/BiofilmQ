function features = getFeaturesFromName(filename)
feature_patterns = {'(?<=_pos)\d+','(?<=_ch)\d+', '(?<=_frame)\d+', '(?<=_Nz)\d+', '(?<=_time)\d+'};

% do not need to lower filename since regexpi ignores cases
% BEWARE: only returns first match!
match = cellfun(@(x) regexpi(filename, x, 'match', 'once'), ...
    feature_patterns, 'UniformOutput', false);
index = cellfun(@(x) regexpi(filename, x, 'once'), ...
    feature_patterns, 'UniformOutput', false);

% Replace all features which could not be found with NaNs
for i = find(cellfun(@isempty, match))
    match{i} = nan;
    index{i} = NaN;
end

features = [];
features.pos_str = match{1};
features.pos = str2double(match{1});
features.pos_index = index{1};
features.frame = str2double(match{3});
features.frame_index = index{3};
features.Nz = str2double(match{4});
features.Nz_index = index{4};
features.channel = str2double(match{2});
features.channel_index = index{2};
features.time = str2double(match{5});
features.time_index = index{5};

timeMultiplier = 1;
try
    idx = strfind(filename(index{5}:end), '_');
    timeUnit = filename(index{5}:idx+index{5}-2);
    
    if ~isempty(strfind(timeUnit, 'h')) || ~isempty(strfind(timeUnit, 'hrs'))
        timeMultiplier = 60*60;
    elseif ~isempty(strfind(timeUnit, 'min'))
        timeMultiplier = 60;
    elseif ~isempty(strfind(timeUnit, 'd'))
        timeMultiplier = 60*60*24;
    end
end
features.timeMultiplier = timeMultiplier;