%% Helper functions
function [rangeLabel, channel] = addRangeLabel(fieldName, unit, keywords)
if nargin == 1
    unit = '';
end

if nargin < 3
    keywords = [];
end

rangeLabel = '';
range = '';

% Extract range
rangeIdx = strfind(fieldName, '_range');

if ~isempty(rangeIdx)
    rangeIdx_end = strfind(fieldName(rangeIdx+1:end), '_');
    if ~isempty(rangeIdx_end)
        range = fieldName(rangeIdx+6:rangeIdx+rangeIdx_end-1);
    else
        range = fieldName(rangeIdx+6:end);
    end
end

% Extract channels
chIdx = strfind(fieldName, '_ch');
if ~isempty(chIdx)
    channel = zeros(numel(chIdx), 1);
    for i = 1:numel(chIdx)
        channel(i) = str2num(fieldName(chIdx(i)+3));
    end
else
    channel = [];
end

% Extract keyword
if ~isempty(keywords)
    if ~iscell(keywords)
        keywords = {keywords, 'vox'};
    end
    for k = 1:2:numel(keywords)
        keyIdx = strfind(fieldName, ['_', keywords{k}]);
        if ~isempty(keyIdx)
            keyIdx_end = strfind(fieldName(keyIdx+1:end), '_');
            if ~isempty(keyIdx_end)
                key = fieldName(keyIdx+numel(keywords{k})+1:keyIdx+keyIdx_end-1);
            else
                key = fieldName(keyIdx+numel(keywords{k})+1:end);
            end
            rangeLabel = sprintf('%s (%s=%s%s)', rangeLabel, keywords{k}, key, keywords{k+1});
        end
    end
end

if ~isempty(range)
    rangeLabel = sprintf('%s (range=%s%s)', rangeLabel, range, unit);
end

% Add lineage info
ind = strfind(fieldName, '_');
if ~isempty(ind)
    range = fieldName(ind(end)+1:end);
end
try
    if strcmp(range, 'lineage')
        rangeLabel = sprintf('%s %s', rangeLabel, 'along lineage');
    end
end