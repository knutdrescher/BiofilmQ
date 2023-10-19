function [exportX, exportY, exportCase, variables2Check, channel2Check] = variableSelectionGui(varList, ch)

% Initialize GUI components

set(0,'units','pixels')  
Pix_SS = get(0,'screensize');

f = uifigure('Name', 'Select the parameters to export:', 'Position', [max((Pix_SS(3)-1420)/2, 0) max((Pix_SS(4)-470)/2, 0) 1420 470]);
suffixes = {'_mean_biovolume', '_std_biovolume', '_max', '_mean', '_median', '_min', '_p25', '_p75', '_std'};
tabgp = uitabgroup(f, 'Position', [10 10 1055 450]);
lbl = uilabel(f,'Position',[1095 175 295 300], 'WordWrap', 'on');
lbl.Text = sprintf('%s\n\n\t%s\n\t%s\n\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\n\t%s\n\t%s\n\n\t%s\n\t%s','Advanced data export of global parameters:',...
    '1. Select the different channels by browsing', ...
    ' through the tabs', '2. Select the parameters that you want to export', ...
    ' by checking the box "Export". For the parameters', ' that include different statistics (mean, max, etc.)', ...
    ' select the ones you want. If you don''t select any', ' statistics, the default export will be the mean.', ...
    '3. Select the column and row labels and export', ' mode.', '4. Click export to export the data to the original', ...
    ' positions folder.');
for i = 1:length(ch)
    varListCh = varList{i};
    tab(i) = uitab(tabgp,'Title',ch{i});
    varListReduced = unique(erase(varListCh, suffixes));
    editable = [];
    for j = 1:length(varListReduced)
        editable(j, :) = sum(cell2mat(cellfun(@(x) strcmp(x, varListCh), strcat(varListReduced(j), suffixes), 'UniformOutput', false)));
    end
    editableCell = cell(size(editable));
    editableCell(editable==1) = {false};
    d = [varListReduced, num2cell(false(length(varListReduced), 1)), editableCell];
    uit(i) = uitable('Parent',tab(i), 'Multiselect', 'on');
    uit(i).Position = [10 10 1035 400];
    uit(i).ColumnName = ['Parameters', 'Export', cellfun(@(x) x(2:end), suffixes, 'UniformOutput', false)];
    uit(i).Data = d; 
    uit(i).ColumnWidth = [189 repmat({'auto'}, length(suffixes)+1, 1)'];
    uit(i).ColumnEditable = [false true(1, length(suffixes)+1)]; 
end

ddItems = {'Data summary (all in one sheet)', 'Different sheets'};
ddxyItems = {'Position', 'Frame', 'Variable'};
uiddx = uidropdown(f, 'Position', [1185 170 200 20], 'Items', ddxyItems, 'Value', 'Position');
uiddxLabel = uilabel(f,'Position',[1085 170 200 20], 'Text', 'Column variables:');
uiddy = uidropdown(f, 'Position', [1185 135 200 20], 'Items', ddxyItems, 'Value', 'Frame');
uiddyLabel = uilabel(f,'Position',[1102 135 200 20], 'Text', 'Row variables:');
uidd = uidropdown(f, 'Position', [1185 100 200 20], 'Items', ddItems);
uiddLabel = uilabel(f,'Position',[1110 100 200 20], 'Text', 'Export mode:');
[~] = uibutton(f, 'Position', [1185 45 200 20], 'Text', 'Export', 'ButtonPushedFcn', @(btn,event) exportButtonPushed(f, uiddx, uiddy)); 

% Wait for user to press "Export"

uiwait(f);

% Format user input for return values

variables2Check = {}; 
channel2Check = [];
counter = 1; 

for m = 1:length(uit)
    tableData = uit(m).Data; 
    
    variables = tableData(cell2mat(tableData(:, 2)), 1);
    
    for n = 1:length(variables)
        
        variablePos = find(strcmp(tableData(:, 1), variables(n)));
        statistics = tableData(variablePos, 3:end); 
        
        if sum(cellfun(@isempty, statistics))==length(suffixes)
            variables2Check{counter} = variables{n}; 
            channel2Check(counter) = m; 
        elseif sum(cell2mat(statistics)) == 0
            variables2Check{counter} = [variables{n}, '_mean'];
            channel2Check(counter) = m;
        else
            suffs = suffixes(cell2mat(statistics));
            for p = 1:length(suffs)
                variables2Check{counter} = [variables{n}, suffs{p}];
                channel2Check(counter) = m;
                counter = counter + 1; 
            end
            continue
        end
        counter = counter + 1; 
    end
          
end

exportCase = uidd.Value; 
exportX = uiddx.Value;
exportY = uiddy.Value;

close(f);

end

function exportButtonPushed(f, uiddx, uiddy)

if strcmp(uiddx.Value, uiddy.Value)
    warning('Horizontal and vertical table variables equal!')
    h = msgbox('Horizontal and vertical table variables equal! Please select different column and row variables','','warn');
    uiwait(h)
    return
end

uiresume(f)

end

