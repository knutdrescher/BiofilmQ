function plotXY(handles, biofilmData)

savePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots, 'Value');
overwritePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots, 'Value');

directory = fullfile(handles.settings.directory, 'data', 'evaluation');

timeIntervals = biofilmData.timeIntervals;

scaling = biofilmData.params.scaling_dxy/1000;

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_fitCellNumber, 'Value')
    fitCellNumber = true;
else
    fitCellNumber = false;
end

addPlot = get(handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure, 'Value');

% Do not use z offset
%removeZOffset = get(handles.handles_analysis.uicontrols.checkbox.checkbox_removeZOffset, 'Value');
removeZOffset = 0;

plotErrorbars = get(handles.handles_analysis.uicontrols.checkbox.checkbox_errorbars, 'Value');

normalizeByBiovolume = false;
switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value')
    case 1
        normalizeByBiovolume = true;
        averagingFcn = '';
    case 2
        averagingFcn = 'nanmean';
    case 3
        averagingFcn = 'nanmedian';
    case 4
        averagingFcn = 'nansum';
    case 5
        averagingFcn = 'nanmin';
    case 6
        averagingFcn = 'nanmax';
end

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
database = databaseString{databaseValue};

if databaseValue == 1
    filterExp = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');
else
    filterExp = '';
    normalizeByBiovolume = false;
end

publication = true;

yLegend = {};

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_clusterBiofilm, 'Value') && databaseValue ~= 2
    if ~isfield(biofilmData.data(end).stats, 'IsRelatedToFounderCells')
       fprintf('    - clustering biofilm(s)\n');
       biofilmData = determineIsRelatedToFounderCells(handles, biofilmData);
    end
    clusterBiofilm = 1;
else
    clusterBiofilm = 0;
end

%% Get axis scale
if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logX, 'Value')
    scaleX = 'log';
else
    scaleX = 'linear';
end

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logY, 'Value')
    scaleY = 'log';
else
    scaleY = 'linear';
end

%% Generate the location and distance for binning
field_yaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String');
field_xaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String');


%% Generate filename
filename = [field_xaxis, ' vs ' field_yaxis];

switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_averaging, 'Value')
    case 1
        method = 'normalized by biovolume';
    case 2
        method = 'mean';
    case 3
        method = 'median';
    case 4
        method = 'sum';
    case 5
        method = 'min';
    case 6
        method = 'max';
end

y_type = field_xaxis;

%% Check if files are already generated
if exist(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type,'.fig']), 'file') && (~overwritePlots && savePlots)
    file = dir(fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type,'.fig']));
    cellFiles = dir(fullfile(handles.settings.directory, 'data', '*_data.mat'));
    if file.datenum > cellFiles(1).datenum && savePlots % Only cancel if plot is older than cell file
        warning('backtrace', 'off')
        warning('File "%s" already exists. Overwriting is disabled. Aborting...', filename);
        warning('backtrace', 'on')
        return;
    end
end

if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    timeShift = biofilmData.timeShift/60/60;
else
    timeShift = 0;
end

%% Create plot
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

yFields = strtrim(strsplit(field_yaxis, ','));
nFields = numel(yFields);

cellX = cell(nFields, 1);
cellY = cell(nFields, 1);

for field = 1:nFields
    
    field_yaxis = yFields{field};
    
    [X, Y, dX, dY] = extractDataBiofilm(biofilmData,...
        'database',     database,...
        'fieldX',       field_xaxis,...
        'fieldY',       field_yaxis,...
        'timeIntervals',timeIntervals,...
        'timeShift',    timeShift,...
        'scaling',      scaling,...
        'fitCellNumber',fitCellNumber,...
        'removeZOffset',removeZOffset,...
        'averagingFcn', averagingFcn,...
        'filterExpr', filterExp,...
        'clusterBiofilm', clusterBiofilm,...
        'normalizeByBiovolume', normalizeByBiovolume);
    


            
    if field == 2 && nFields == 2
        yyaxis(h_ax, 'right');
    end

    if plotErrorbars
        cellX{field} = X + [-1; 1] .* dX;
        cellY{field} = Y + [-1; 1] .* dY;
        
        if sum(dX) == 0
            errorbar(h_ax, X, Y, dY(1,:), dY(2,:), '.')
        else
            errorbar(h_ax, X, Y, dY(1,:), dY(2,:), dX(1,:), dX(2,:), '.')
        end
    else
        cellX{field} = X;
        cellY{field} = Y;
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

end


%% Styling

[xLabel, yLabels] = getLabelsFromGUI(handles, {field_xaxis, '', '', ''});
[xUnit, yUnits] = getUnitsFromGUI(handles, {field_xaxis,  '', '', ''});
[xRange, yRanges] = getRangeFromGUI(handles, {field_xaxis, '', '', ''}, {cellX, cellY, {}, {}});

xRange = str2num(xRange);

%% Check for multiple fields in Y
yLabels = strtrim(strsplit(yLabels, ','));
yUnits = strtrim(strsplit(yUnits, ','));
yRanges = strtrim(strsplit(yRanges, ','));


% Use default values if number of inputs do not match
if numel(yLabels) ~= nFields  
    yLabels = cellfun(@returnUnitLabel, yFields, 'un', 0);
    yLabels_str = join(yLabels, ', ');
    handles.handles_analysis.uicontrols.edit.edit_yLabel.String = yLabels_str{:};
        
end

if numel(yUnits) ~= nFields
    [~, yUnits] = cellfun(@returnUnitLabel, yFields, 'un', 0);
    yUnits_str = join(yUnits, ', ');
    handles.handles_analysis.uicontrols.edit.edit_yLabel_unit.String = yUnits_str{:};
end

if sum(~cellfun(@isempty, yRanges)) ~= nFields
    [~, ~, yRanges] = ...
        cellfun(@(yfield) ...
            returnUnitLabel(...
                 yfield, ...
                 biofilmData, ...
                 database, ...
                 handles.handles_analysis.uicontrols.popupmenu.popupmenu_rangeMethodY.Value, ...
                 handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Value), ...
             yFields, 'un', 0);
     yRanges_str = cellfun(@(range) num2str(range, '%.2f %.2f'), yRanges, 'un', 0);
     yRanges_str = join(yRanges_str, ', ');
     handles.handles_analysis.uicontrols.edit.edit_yRange.String = yRanges_str{:};
else
    if ~any(cellfun(@isempty , yRanges))
        yRanges = cellfun(@str2num, yRanges, 'un', 0);
    else
        yRanges = cell(nFields, 1);
    end
end

%%
yLegend = cellfun(@(label, unit) sprintf('%s %s', label, unit), yLabels, yUnits, 'un', 0);

if nFields == 1
    ylabel(h_ax, yLegend{1});
    if (~handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange.Value || ...
            handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Value) && ...
            ~isempty(yRanges{1})
        
        ylim(h_ax, [yRanges{1}(1) yRanges{1}(2)])
    end

elseif nFields == 2
    
    yyaxis(h_ax, 'left');
    ylabel(h_ax, yLegend{1});
    if (~handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange.Value || ...
            handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Value) && ...
            ~isempty(yRanges{1})
        
        ylim(h_ax, [yRanges{1}(1) yRanges{1}(2)])
    end
            
    yyaxis(h_ax, 'right');
    ylabel(h_ax, yLegend{2});
    if (~handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange.Value || ...
            handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Value) && ...
            ~isempty(yRanges{2})
        
        ylim(h_ax, [yRanges{2}(1) yRanges{2}(2)])
    end
else
    legend(yLegend);
    if (~handles.handles_analysis.uicontrols.checkbox.checkbox_autoYRange.Value || ...
            handles.handles_analysis.uicontrols.checkbox.checkbox_returnTrueRangeY.Value) && ...
            any(~cellfun(@isempty, yRanges))
        
        ylim(h_ax, [min(cellfun(@(yRange) yRange(1), yRanges)) ...
                    max(cellfun(@(yRange) yRange(2), yRanges))]);
    end
        
end



%%
try
    xlim(h_ax, [xRange(1)-0.05*diff(xRange) xRange(2)+0.05*diff(xRange)]);
end

if strcmp(xUnit, '')
    xlabel(h_ax, xLabel)
else
    xlabel(h_ax, [xLabel, ' ', xUnit])
end

if strcmp(scaleX, 'log')
    set(h_ax, 'XScale', 'log', 'Xtick', [1 10 10^2 10^3 10^4], 'XTickLabel', {'1', '10', '10^2', '10^3', '10^4'});
else
    set(h_ax, 'XScale', 'linear');
end

if strcmp(scaleY, 'log')
    set(h_ax, 'YScale', 'log');
else
    set(h_ax, 'YScale', 'linear');
end

box(h_ax, 'on');
if nFields > 2
    legend(yLegend);
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

if ~exist(directory, 'dir')
    mkdir(directory);
end


savefig(h, fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type, '.fig']));

% Output size
set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);
set(h, 'PaperPosition', [0 0 12 9]);

if publication
    set(h_ax, 'FontSize', 16, 'LineWidth', 1)
end



print(h, '-dpng','-r300',fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type, '.png']));
print(h, '-depsc','-r300', '-painters' ,fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, ' ', method, ' ', y_type, '.eps']));
end

