function scatterPlotXY(handles, biofilmData)

savePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_savePlots, 'Value');
overwritePlots = get(handles.handles_analysis.uicontrols.checkbox.checkbox_overwritePlots, 'Value');

directory = fullfile(handles.settings.directory, 'data', 'evaluation');

timeIntervals = biofilmData.timeIntervals;

databaseValue = get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_database, 'Value');
databaseString = handles.settings.databases;
database = databaseString{databaseValue};

publication = true;

addPlot = get(handles.handles_analysis.uicontrols.checkbox.checkbox_addPlotToCurrentFigure, 'Value');

switch get(handles.handles_analysis.uicontrols.popupmenu.popupmenu_plotType, 'Value')
    case 3
        scatterType = '2D';
    case 4
        scatterType = '4D';
end


if get(handles.handles_analysis.uicontrols.checkbox.checkbox_clusterBiofilm, 'Value') && databaseValue ~= 2
    if ~isfield(biofilmData.data(end).stats, 'IsRelatedToFounderCells')
       fprintf('    - clustering biofilm(s)\n');
       biofilmData = determineIsRelatedToFounderCells(handles, biofilmData);
    end
    clusterBiofilm = 1;
else
    clusterBiofilm = 0;
end

files_range = numel(biofilmData.data);

scaling = biofilmData.params.scaling_dxy;

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_fitCellNumber, 'Value')
    fitCellNumber = true;
else
    fitCellNumber = false;
end

filterExp = get(handles.handles_analysis.uicontrols.edit.edit_filterField, 'String');

% Do not apply z offset
%removeZOffset = get(handles.handles_analysis.uicontrols.checkbox.checkbox_removeZOffset, 'Value');
removeZOffset = 0;

%% Generate the location and distance for binning
field_xaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_xaxis, 'String');
field_yaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_yaxis, 'String');
field_zaxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_zaxis, 'String');
field_caxis = get(handles.handles_analysis.uicontrols.edit.edit_kymograph_coloraxis, 'String');

filename = [field_xaxis, ' vs ', field_yaxis, ' vs ', field_zaxis, ' vs ', field_caxis, '_scatter'];

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

if get(handles.handles_analysis.uicontrols.checkbox.useRefTimepoint, 'Value')
    timeShift = biofilmData.timeShift/60/60;
else
    timeShift = 0;
end
colorPlot = 0;
Z = {};
switch scatterType
    case '2D'
        [X, Y, ~, ~, ~, C] = extractDataBiofilm(biofilmData,...
            'database',     database,...
            'fieldX',       field_xaxis,...
            'fieldY',       field_yaxis,...
            'fieldC',       field_caxis,...
            'timeIntervals',timeIntervals,...
            'timeShift',    timeShift,...
            'scaling',      scaling,...
            'fitCellNumber',fitCellNumber,...
            'removeZOffset',removeZOffset,...
            'averagingFcn', 'none',...
            'filterExpr', filterExp,...
            'clusterBiofilm', clusterBiofilm);
        
        for ind = 1:files_range
            i = ind;
            try
                x = X{i};
                y = Y{i};
                c = C{i};
                
                if isempty(c) || sum(c)~=sum(c)
                    scatter(h_ax, x, y, 8, 'filled', 'MarkerFaceColor', lines(1));
                else
                    scatter(h_ax, x, y, 8, c, 'filled');
                    colorPlot = 1;
                end
                
                if i == 1
                    set(h_ax, 'NextPlot', 'add')
                end
            catch
                disp('Error!');
            end
        end
        
        
    case '4D'
        colorPlot = 1;
        [X, Y, ~, ~, Z, C] = extractDataBiofilm(biofilmData,...
            'database',     database,...
            'fieldX',       field_xaxis,...
            'fieldY',       field_yaxis,...
            'fieldC',       field_caxis,...
            'fieldZ',       field_zaxis,...
            'timeIntervals',timeIntervals,...
            'timeShift',    timeShift,...
            'scaling',      scaling,...
            'fitCellNumber',fitCellNumber,...
            'removeZOffset',removeZOffset,...
            'averagingFcn', 'none',...
            'filterExpr', filterExp,...
            'clusterBiofilm', clusterBiofilm);
        
        for ind = 1:files_range
            i = ind;
            try
                x = X{i};
                y = Y{i};
                c = C{i};
                z = Z{i};
                
                scatter3(h_ax, x, y, z, 8, c, 'filled');
                if i == 1
                    set(h_ax, 'NextPlot', 'add')
                end
            catch
                disp('Error!');
            end
        end
end

%% Styling


[xLabel, yLabel, zLabel, cLabel] = getLabelsFromGUI(handles, ...
    {field_xaxis, field_yaxis, field_zaxis, field_caxis});
[xUnit, yUnit, zUnit, cUnit] = getUnitsFromGUI(handles, ...
    {field_xaxis, field_yaxis, field_zaxis, field_caxis});


[xRange, yRange, zRange, cRange] = getRangeFromGUI(handles, ...
    {field_xaxis, field_yaxis, field_zaxis, field_caxis}, {{X}, {Y}, {Z}, {C}});

ranges = cellfun(@str2num, {xRange, yRange, zRange, cRange}, 'un', 0);
[xRange, yRange, zRange, cRange] = ranges{:};

%% Get axis scale
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

if get(handles.handles_analysis.uicontrols.checkbox.checkbox_logZ, 'Value')
    scaleZ = 'log';
else
    scaleZ = 'linear';
end

if ~isempty(yRange)
    set(h_ax, 'ylim', yRange);
end

if ~isempty(xRange)
    set(h_ax,'xlim', xRange)
end


if strcmp(scatterType, '4D')
    
    if ~isempty(zRange)
        set(h_ax, 'zlim', zRange)
    end
    
    if ~isempty(cRange)
        set(h_ax, 'clim', cRange);
    end
    
    if strcmp(scaleZ, 'log')
        set(h_ax, 'ZScale', 'log');
    else
        set(h_ax, 'ZScale', 'linear');
    end
    
    if strcmp(zUnit, '')
        zlabel(h_ax, zLabel)
    else
        zlabel(h_ax, [zLabel, ' ', zUnit])
    end
end

if colorPlot 
    
    if ~isempty(cRange)
        set(h_ax, 'clim', cRange);
    end
    
    warning off;
    c = colorbar;
    if strcmp(cUnit, '')
        c.Label.String = cLabel;
    else
        c.Label.String = [cLabel, ' ', cUnit];
    end
    warning on;
end


if strcmp(xUnit, '')
    xlabel(h_ax, xLabel)
else
    xlabel(h_ax, [xLabel, ' ', xUnit])
end

if strcmp(yUnit, '')
    ylabel(h_ax, yLabel)
else
    ylabel(h_ax, [yLabel, ' ', yUnit])
end



if ~publication
    title(h_ax, [xLabel, ' vs. ', yLabel]);
end

box(h_ax, 'on');

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

% Output size
set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperPosition', [0 0 12 9]);

if publication
    set(h_ax, 'FontSize', 16, 'LineWidth', 1)
end

savefig(h, fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.fig']));

print(h, '-dpng','-r300',fullfile(directory, [handles.settings.databaseNames{databaseValue}, ' ', filename, '.png']));
print(h, '-depsc','-r300', '-painters' ,fullfile(directory, [database, ' ', filename, '.eps']));

