function [X, Y, dX, dY, Z, C] = extractDataBiofilm(biofilmData, varargin)

dX = [];
dY = [];

%% Handle inputs
database = checkInput(varargin, 'database', 'stats');
fitCellNumber = checkInput(varargin, 'fitCellNumber', true);
TimeIntervals = checkInput(varargin, 'TimeIntervals', 0);
TimeShift = checkInput(varargin, 'timeShift', 0);
scaling = checkInput(varargin, 'scaling', 0.0632);
fieldX = checkInput(varargin, 'fieldX', 'Frame');
fieldY = checkInput(varargin, 'fieldY', 'Frame');
fieldZ = checkInput(varargin, 'fieldZ', 'Frame');
fieldC = checkInput(varargin, 'fieldC', 'Frame');
removeZOffset = checkInput(varargin, 'removeZOffset', true);
averagingFcn = checkInput(varargin, 'averagingFcn', 'nanmean');
if isempty(averagingFcn)
   averagingFcn = 'nanmean'; 
end
filterExpr = checkInput(varargin, 'filterExpr', '');
clusterBiofilm = checkInput(varargin, 'clusterBiofilm', false);
normalizeByBiovolume = checkInput(varargin, 'normalizeByBiovolume', false);

clear p;

IsRelatedToFounderCells = cell(numel(biofilmData.data), 1);
for i = 1:numel(biofilmData.data)
    if clusterBiofilm
        IsRelatedToFounderCells{i} = logical([biofilmData.data(i).stats.IsRelatedToFounderCells]);
    else
        IsRelatedToFounderCells{i} = true(biofilmData.data(i).NumObjects,1);
    end
end

%% Prepare input
switch fieldX
    case 'Cell_Number'
        %% Plot biofilm parameters versus cell numer
        cellNumber = [];
        % Obtain cells number
        try
            for i = 1:numel(biofilmData.data)
                cellNumber(i) = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i}));
            end
        catch
            for i = 1:numel(biofilmData.data)
                cellNumber(i) = biofilmData.data(i).NumObjects;
            end
        end
        x = 1:numel(biofilmData.data);
        
        % Fit cell number
        if fitCellNumber && strcmp(fieldX, 'Cell_Number')
            Nfit = smoothCellNumber(x, cellNumber);
        end
        
    otherwise
        % do nothing
end

switch fieldY
    case 'Cell_Number'
        %% Plot biofilm parameters versus cell numer
        cellNumber = [];
        % Obtain cells number
        try
            for i = 1:numel(biofilmData.data)
                cellNumber(i) = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i}));
            end
        catch
            for i = 1:numel(biofilmData.data)
                cellNumber(i) = biofilmData.data(i).NumObjects;
            end
        end
        x = 1:numel(biofilmData.data);
        
        % Fit cell number
        if fitCellNumber && strcmp(fieldX, 'Cell_Number')
            Nfit = smoothCellNumber(x, cellNumber);
        end
        
    otherwise
        % do nothing
end


%% Remove z-offsett
if removeZOffset && (strcmp(fieldX, 'z') || strcmp(fieldY, 'z'))
    zOffset = zeros(1, numel(biofilmData.data));
    for i = 1:numel(biofilmData.data)
        try
            centroids = [biofilmData.data(i).stats(IsRelatedToFounderCells{i}).Centroid];
            centroids_z = centroids(3:3:end);
            zOffset(i) = min(centroids_z);
        catch
            zOffset(i) = NaN;
        end
    end
    zOffset = nanmedian(zOffset);
else
    zOffset = 0;
end

%% Get Data
X = cell(1, numel(biofilmData.data));
Y = cell(1, numel(biofilmData.data));
Z = cell(1, numel(biofilmData.data));
C = cell(1, numel(biofilmData.data));

if normalizeByBiovolume
    B = cell(1, numel(biofilmData.data));
end

% Run through data and sort into bins
for i = 1:numel(biofilmData.data)
    try
        switch fieldX
            case 'Cell_Number'
                % Take either fitted cell number or determined one
                if fitCellNumber
                    x = Nfit(i);
                    try
                        N = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                    catch
                        N = biofilmData.data(i).NumObjects; % NCells
                    end
                    x = repmat(x, 1, N);
                else
                    try
                        x = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                    catch
                        x = biofilmData.data(i).NumObjects; % NCells
                    end
                    x = repmat(x, 1, x);
                end
                
            case 'Time'
                [x, status] = getData(biofilmData.data(i), database, fieldX, scaling, zOffset, filterExpr, clusterBiofilm);
                if ~status
                    return;
                end
                x = x + TimeShift;
                
            otherwise
                [x, status] = getData(biofilmData.data(i), database, fieldX, scaling, zOffset, filterExpr, clusterBiofilm);
                if ~status
                    return;
                end
        end
        
        switch fieldY
            case 'Cell_Number'
                % Take either fitted cell number or determined one
                if fitCellNumber
                    y = Nfit(i);
                    try
                        N = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                    catch
                        N = biofilmData.data(i).NumObjects; % NCells
                    end
                    y = repmat(y, 1, N);
                else
                    try
                        y = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                    catch
                        y = biofilmData.data(i).NumObjects; % NCells
                    end
                    y = repmat(y, 1, y);
                end
                
            case 'Time'
                [y, status] = getData(biofilmData.data(i), database, fieldY, scaling, zOffset, filterExpr, clusterBiofilm);
                if ~status
                    return;
                end
                y = y + TimeShift;
                
            otherwise
                [y, status] = getData(biofilmData.data(i), database, fieldY, scaling, zOffset, filterExpr, clusterBiofilm);
                if ~status
                    return;
                end
        end
        
        if ~isempty(fieldZ)
            switch fieldZ
                case 'Cell_Number'
                    % Take either fitted cell number or determined one
                    if fitCellNumber
                        z = Nfit(i);
                        try
                            N = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                        catch
                            N = biofilmData.data(i).NumObjects; % NCells
                        end
                        z = repmat(z, 1, N);
                    else
                        try
                            z = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                        catch
                            z = biofilmData.data(i).NumObjects; % NCells
                        end
                        z = repmat(z, 1, z);
                    end
                    
                case 'Time'
                    [z, status] = getData(biofilmData.data(i), database, fieldZ, scaling, zOffset, filterExpr, clusterBiofilm);
                    if ~status
                        return;
                    end
                    z = z + TimeShift;
                    
                otherwise
                    [z, status] = getData(biofilmData.data(i), database, fieldZ, scaling, zOffset, filterExpr, clusterBiofilm);
                    if ~status
                        return;
                    end
            end
        else
            z = NaN;
        end
        
        if ~isempty(fieldC)
            switch fieldC
                
                case 'Cell_Number'
                    % Take either fitted cell number or determined one
                    if fitCellNumber
                        c = Nfit(i);
                        try
                            N = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                        catch
                            N = biofilmData.data(i).NumObjects; % NCells
                        end
                        c = repmat(c, 1, N);
                    else
                        try
                            c = sum(biofilmData.data(i).goodObjects(IsRelatedToFounderCells{i})); % NCells
                        catch
                            c = biofilmData.data(i).NumObjects; % NCells
                        end
                        c = repmat(c, 1, c);
                    end
                    
                case 'Time'
                    [c, status] = getData(biofilmData.data(i), database, fieldC, scaling, zOffset, filterExpr, clusterBiofilm);
                    if ~status
                        return;
                    end
                    c = c + TimeShift;
                    
                otherwise
                    [c, status] = getData(biofilmData.data(i), database, fieldC, scaling, zOffset, filterExpr, clusterBiofilm);
            end
        else
            c = NaN;
        end
        
        if normalizeByBiovolume
            if ~any(contains(biofilmData.data(i).measurementFields, 'Shape_Volume'))
                % Legacy Code for datasets segmented prior to:
                % Commit 43acf62f 2019 Feb. 06: 'Volume' renamed to 'Shape_Volume'
                [biovolume, status] = getData(biofilmData.data(i), database, 'Volume', scaling, zOffset, filterExpr, clusterBiofilm);
            else
                [biovolume, status] = getData(biofilmData.data(i), database, 'Shape_Volume', scaling, zOffset, filterExpr, clusterBiofilm);
            end
        end
        
        if ~status
            return;
        end
        
        if ~isnumeric(x) || ~isnumeric(y) || ~isnumeric(z) || ~isnumeric(c)
            return;
        end
        
        X{i} = x;
        Y{i} = y;
        Z{i} = z;
        C{i} = c;
        
        if normalizeByBiovolume
           B{i} = biovolume; 
        end

    catch error
        warning('backtrace', 'off')
        warning(error.message);
        warning('backtrace', 'on')
    end
end

%% Output
if normalizeByBiovolume

    mX = cellfun(@(x, b) sum(x.*b)/sum(b), X, B, 'UniformOutput', false);
    mY = cellfun(@(x, b) sum(x.*b)/sum(b), Y, B, 'UniformOutput', false);

    try
        dX = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), X, B, mX, 'UniformOutput', true);
    catch
        dX = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), X, B, mX, 'UniformOutput', false);
        dX = generateUniformOutput(dX);
    end
    
    try
        dY = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), Y, B, mY, 'UniformOutput', true);
    catch
        dY = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), Y, B, mY, 'UniformOutput', false);
        dY = generateUniformOutput(dY);
    end
else
    switch averagingFcn
        case 'nanmean'
            try
                dX = cellfun(@(x) nanstd(x), X, 'UniformOutput', true);
            catch
                dX = cellfun(@(x) nanstd(x), X, 'UniformOutput', false);
                dX = generateUniformOutput(dX);
            end
            try
                dY = cellfun(@(x) nanstd(x), Y, 'UniformOutput', true);
            catch
                dY = cellfun(@(x) nanstd(x), Y, 'UniformOutput', false);
                dY = generateUniformOutput(dY);
            end
            
        case 'nanmedian'
            
            dX = cellfun(@(x) [nanmedian(x)-prctile(x, 25) prctile(x, 75)-nanmedian(x)], X, 'UniformOutput', false);
            dX_temp1 = [dX{:}];
            dX = [dX_temp1(1:2:end); dX_temp1(2:2:end)];
            
            dY = cellfun(@(x) [nanmedian(x)-prctile(x, 25) prctile(x, 75)-nanmedian(x)], Y, 'UniformOutput', false);
            dY_temp1 = [dY{:}];
            dY = [dY_temp1(1:2:end); dY_temp1(2:2:end)];
        otherwise
            dX = zeros(size(X));
            dY = zeros(size(Y));
    end
end

if size(dX, 1) == 1
    dX = [dX; dX];
    dY = [dY; dY];
end


if normalizeByBiovolume
    X = generateUniformOutput(mX);
    Y = generateUniformOutput(mY);
else
    if strcmp(averagingFcn, 'none')
        % do nothing
    else
        if strcmp(averagingFcn, 'nanmean') || strcmp(averagingFcn, 'nanmedian')
            try
                eval(['X = cellfun(@(x) ',averagingFcn,'(x), X, ''UniformOutput'', true);']);
            catch
                eval(['X = cellfun(@(x) ',averagingFcn,'(x), X, ''UniformOutput'', false);']);
                X = generateUniformOutput(YX);
            end
        else
            try
                X = cellfun(@(x) nanmean(x), X, 'UniformOutput', true);
            catch
                X = cellfun(@(x) nanmean(x), X, 'UniformOutput', false);
                X = generateUniformOutput(X);
            end
        end

        try
            eval(['Y = cellfun(@(x) ',averagingFcn,'(x), Y, ''UniformOutput'', true);']);
        catch
            eval(['Y = cellfun(@(x) ',averagingFcn,'(x), Y, ''UniformOutput'', false);']);
            Y = generateUniformOutput(Y);
        end
    end
end


function [output, status] = getData(data, database, field, scaling, zOffset, filterExpr, clusterBiofilm)
status = 1;

if ~isempty(filterExpr)
    try
        formulaRaw = filterExpr;
        try
            fields = extractBetween(formulaRaw,'{','}');
        catch
            fields = regexp(formulaRaw, '{.*?}', 'match');
            fields = cellfun(@(x) x(2:end-1), fields, 'UniformOutput', false);
        end
        formula = formulaRaw;
        if ~isempty(fields)
            for i = 1:numel(fields)
                formula = strrep(formula, ['{', fields{i}, '}'], sprintf('[data.%s.%s]', database, fields{i}));
            end
        else
            formula = formulaRaw;
        end
        
        eval(sprintf('filterMap = %s;', formula));
        
    catch err
        errorStr = sprintf('Filter expression (%s) is not valid! Error: %s', filterExpr, err.message);
        output = 'err';
        status = 0;
        uiwait(msgbox(errorStr, 'Error', 'error', 'modal'));
        return;
    end
else
    filterMap = true(1, numel(data.(database)));
end


output = [data.(database).(field)];

if clusterBiofilm
    IsRelatedToFounderCells = [data.stats.IsRelatedToFounderCells];
else
    IsRelatedToFounderCells = true(1, numel(data.(database)));
end

switch database
    case 'stats'
        output = output(filterMap(:) & IsRelatedToFounderCells(:) & data.goodObjects(:));
end

function map = generateUniformOutput(map)
noEntry = cellfun(@(x) isempty(x), map, 'UniformOutput', true);
map(noEntry) = num2cell(repmat(NaN, sum(noEntry(:)),1));
map = cell2mat(map);
