function histogram1D(handles, biofilmData)

savePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots, 'Value');
overwritePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots, 'Value');

directory = fullfile(handles.settings.directory, 'data', 'evaluation');
addPlot = get(handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure, 'Value');
NBinsX = str2num(get(handles.handles_analysis.uicontrols.edit.edit_binsX, 'String'));
plotType = handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType.Value;
plotErrorbars = get(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Value');

normalizeByBiovolume = false;
if strcmp(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging.Enable, 'on')
    switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value')
        case 1
            normalizeByBiovolume = true;
            method = 'normalized by biovolume';
        case 2
            averagingFcn = @nanmean;
            method = 'mean';
        case 3
            averagingFcn = @nanmedian;
            method = 'median';
        case 4
            averagingFcn = @nansum;
            method = 'sum';
        case 5
            averagingFcn = @nanmin;
            method = 'min';
        case 6
            averagingFcn = @nanmax;
            method = 'max';
    end
else
    method = '';
end

scaling = biofilmData.params.scaling_dxy/1000;

filterExp = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');

% Do not use z offset
%removeZOffset = get(handles.handles_analysis.uicontrols.checkbox.checkbox_removeZOffset, 'Value');
removeZOffset = 0;

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
database = databaseString{databaseValue};

publication = true;


if get(handles.handles_analysis.uicontrols.checkbox.checkbox_clusterBiofilm, 'Value') && databaseValue ~= 2
    if ~isfield(biofilmData.data(end).stats, 'IsRelatedToFounderCells')
       fprintf('    - clustering biofilm(s)\n');
       biofilmData = determineIsRelatedToFounderCells(handles, biofilmData);
    end
    clusterBiofilm = 1;
else
    clusterBiofilm = 0;
end

%% Generate the location and distance for binning
field_xaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String');
if plotType == 6
    field_yaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String');
else
    field_yaxis = field_xaxis;
end

%% Generate filename
if plotType == 6
    filename = [field_yaxis, ' resolved vs ', field_xaxis, ' ', method];
else
    filename = [field_xaxis];
end

%% Check if files are already generated
if exist(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']), 'file') && (~overwritePlots && savePlots)
    file = dir(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']));
    cellFiles = dir(fullfile(handles.settings.directory, 'data', '*_data.mat'));
    if file.datenum > cellFiles(1).datenum && savePlots % Only cancel if plot is older than cell file
        warning('backtrace', 'off')
        warning('File "%s" already exists. Overwriting is disabled. Aborting...', filename);
        warning('backtrace', 'on')
        return;
    end
end

%%
if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    timeShift = biofilmData.timeShift/60/60;
else
    timeShift = 0;
end

% Create plot
figHandles = findobj('Type', 'figure');
if numel(figHandles) == 1
    addPlot = 0;
end
if addPlot
    h = figHandles(2);
    figure(h);
    h_ax = gca;
else
    h = figure;
    addIcon(h);
    h_ax = axes('Parent', h);
end


set(h_ax, 'NextPlot', 'add');


%% Check wether multiple fields where entered
xFields = strtrim(strsplit(field_xaxis, ','));
yFields = strtrim(strsplit(field_yaxis, ','));
nFields = numel(xFields);

xRanges = {};
if ~get(handles.handles_analysis.uicontrols.checkbox.checkbox_autoXRange, 'Value')
     xRange = get(handles.handles_analysis.uicontrols.edit.edit_xRange, 'String');
     xRanges = strtrim(strsplit(xRange, ','));
end

if numel(xRanges) ~= nFields 
    xRanges = cell(nFields, 1);
    for i = 1:nFields
        if ~handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX.Value
            
           [~, ~, xRange] = returnUnitLabel(xFields{i});
        end
        
        if handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX.Value || ...
                (~handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeX.Value  && ...
                isempty(xRange))
            
            [~, ~, xRange] = returnUnitLabel(xFields{i}, ...
                biofilmData, ...
                database, ...
                get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodX, 'Value'), ...
                true);
        end
        
        xRanges{i} = num2str(xRange, '%.2f %.2f');
    end
    
    
    xRanges_str = join(xRanges, ', ');
    handles.handles_analysis.uicontrols.edit.edit_xRange.String = xRanges_str{:};
end


for field = 1:nFields  

    [X, Y, ~, ~, B] = extractDataBiofilm(biofilmData,...
        'database',     database,...
        'fieldX',       xFields{field},...
        'fieldY',       yFields{field},...
        'timeShift',    timeShift,...
        'scaling',      scaling,...
        'removeZOffset',removeZOffset,...
        'averagingFcn', 'none',...
        'filterExpr', filterExp,...
        'clusterBiofilm', clusterBiofilm);
    
    X = [X{:}];
    Y = [Y{:}];
    B = [B{:}];
    
    xRange = str2num(xRanges{field});
    
    if xRange(1) == xRange(2) && numel(unique(X)) == 1
        Y = sum(X);
        X = X(1);
    else
        dX = linspace(xRange(1), xRange(2), NBinsX);
        if plotType == 6
            [~, bins_idx] = histc(X , dX);
            
            bin_array = cell(numel(dX), 1);
            biovolume_array = cell(numel(dX), 1);
            
            for b = 1:numel(bin_array)
                bin_idx = find(bins_idx==b);
                if ~isempty(bin_idx)
                    bin_array{b} = Y(bin_idx);
                    biovolume_array{b} = B(bin_idx);
                end
            end
            biovolume_array(cellfun(@isempty, biovolume_array)) = {0};
            bin_array(cellfun(@isempty, bin_array)) = {0};
            
            bin_array = cellfun(@(x) x(isfinite(x)), bin_array, 'un', 0);

            
            
            if normalizeByBiovolume
                Y = cellfun(@(x, b) biovolumeAverage(x,b), bin_array, biovolume_array, 'UniformOutput', false);
                
                try
                    dY = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), bin_array, biovolume_array, Y, 'UniformOutput', true);
                catch
                    dY = cellfun(@(x, b, m) sqrt(sum((x-m).^2.*(b/sum(b)))), bin_array, biovolume_array, Y, 'UniformOutput', false);
                    dY = generateUniformOutput(dY);
                end
                dY = [dY'; dY'];
                Y = generateUniformOutput(Y)';
            else
                Y = cellfun(averagingFcn, bin_array)';
                
                if isequal(averagingFcn, @nanmean)
                    try
                        dY = cellfun(@nanstd, bin_array, 'UniformOutput', true);
                    catch
                        dY = cellfun(@nanstd, bin_array, 'UniformOutput', false);
                        dY = generateUniformOutput(dY);
                    end
                    dY = [dY'; dY'];
                    
                    
                elseif isequal(averagingFcn, @nanmedian)
                    dY = cellfun(@(x) [nanmedian(x)-prctile(x, 25) prctile(x, 75)-nanmedian(x)], bin_array, 'UniformOutput', false);
                    dY_temp1 = [dY{:}];
                    dY = [dY_temp1(1:2:end); dY_temp1(2:2:end)];
                    
                else
                    dY = zeros(size(Y));
                end
            end
        else
            Y = histc(X, dX);
        end
        X = dX;
    end
    
    set(h_ax, 'NextPlot', 'add');
    switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotStyle, 'Value')
        case 1
            scatter(h_ax, X, Y, 'filled')
        case 2
            plot(h_ax, X, Y);
        case 3
            plot(h_ax, X, Y);
            scatter(h_ax, X, Y, 'filled');
        case 4
            stairs(h_ax, X,Y);
        case 5
            bar(h_ax, X, Y);
    end
    
    if plotErrorbars && plotType == 6
        errorbar(h_ax, X, Y, dY(1,:), dY(2,:), '.')
    end
    
end


[xLabel, yLabel] = getLabelsFromGUI(handles, {'', '', '', ''});
[xUnit, yUnit] = getUnitsFromGUI(handles, {'', '', '', ''});

if isempty(yLabel)
    yLabel = 'Counts';
end


if strcmp(yUnit, '')
    ylabel(h_ax, yLabel)
else
    ylabel(h_ax, [yLabel, ' ', yUnit])
end

if publication
else
    title(h_ax, [yLabel, ' ',method]);
end

try
    if ~all(cellfun(@isempty ,xRanges))
        overallRange = cellfun(@str2num, xRanges, 'un', 0);
        overallRange = [min([overallRange{:}]), max([overallRange{:}])];
        if range(overallRange) ~= 0
            xlim(h_ax, [overallRange(1)-0.05*diff(overallRange) overallRange(2)+0.05*diff(overallRange)]);
        end
    end
catch err
    warning(err.message);
end

if strcmp(xUnit, '')
    xlabel(h_ax, xLabel)
else
    xlabel(h_ax, [xLabel, ' ', xUnit])
end

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logX, 'Value')
    set(h_ax, 'XScale', 'log', 'Xtick', [1 10 10^2 10^3 10^4], 'XTickLabel', {'1', '10', '10^2', '10^3', '10^4'});
else
    set(h_ax, 'XScale', 'linear');
end

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logY, 'Value')
    set(h_ax, 'YScale', 'log');
else
    set(h_ax, 'YScale', 'linear');
end

box(h_ax, 'on');
if nFields > 1
    legend(yFields, 'interpreter', 'None');
    for i = 1:numel(h_ax.Children)
        h_ax.Children(i).EdgeAlpha = 0.5;
        h_ax.Children(i).FaceAlpha = 0.5;
    end
end

if handles.handles_analysis.uicontrols.checkbox.checkbox_applyCustom2.Value
    if ~isempty(handles.handles_analysis.uicontrols.edit.edit_custom2.String)
        pathScript = handles.handles_analysis.uicontrols.edit.edit_custom2.String;
        try
            run(pathScript);
        catch err
            warning('backtrace', 'off')
            warning('Custom script "%s" not valid! Error msg: %s', pathScript, err.message);
            warning('backtrace', 'on')
        end
    end
end

%% save PNG
if ~savePlots
    return;
end

if ~exist(directory, 'dir')
    mkdir(directory);
end

% Mat
save(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' xy.mat']), 'X', 'Y')



savefig(h, fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']));

% Output size
set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);
set(h, 'PaperPosition', [0 0 12 9]);

if publication
    set(h_ax, 'FontSize', 16, 'LineWidth', 1)
end



print(h, '-dpng','-r300',fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.png']));
print(h, '-depsc','-r300', '-painters' ,fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.eps']));



function map = generateUniformOutput(map)
noEntry = cellfun(@(x) isempty(x), map, 'UniformOutput', true);
map(noEntry) = num2cell(NaN(sum(noEntry(:)),1));
map = cell2mat(map);

function result = biovolumeAverage(x,b)
isValid = isfinite(x);
result = sum(x(isValid).*b(isValid))/sum(b(isValid));
