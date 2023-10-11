function [xRange, yRange, zRange, cRange] = getRangeFromGUI(handles, statsLookup, plotData)
    
    fields = {'X', 'Y', 'Z', 'Color'};
    fieldsLower = lower(fields);
    
    n = 4;
    ranges = cell(n, 1);
    
    for i = 1:n
        rangeEditTag = sprintf('edit_%sRange', fieldsLower{i});
        methodPopupmenueTag = sprintf('popupmenu_rangeMethod%s', fields{i});
        useTrueRangeTag =  sprintf('checkbox_returnTrueRange%s', fields{i});
        useAutoRangeTag = sprintf('checkbox_auto%sRange', fields{i});
       
        
        if ~handles.handles_analysis.uicontrols.checkbox.(useAutoRangeTag).Value
            
            ranges{i} = handles.handles_analysis.uicontrols.edit.(rangeEditTag).String;

        elseif handles.handles_analysis.uicontrols.checkbox.(useAutoRangeTag).Value && ...
                handles.handles_analysis.uicontrols.checkbox.(useTrueRangeTag).Value && ...
                ~isempty(plotData{i})
            
            m = numel(plotData{i});
            tmp_range = cell(m, 1);
            for j = 1:m
                
                data = plotData{i}{m};
                if iscell(data)
                    data = [data{:}];
                end
                
                switch handles.handles_analysis.uicontrols.popupmenu.(methodPopupmenueTag).Value
                    case 1
                        tmp_range{j} = prctile(data(:), [1, 99]);
                    case 2
                        tmp_range{j} = [min(data(:)) max(data(:))];
                end
            end

            range_str = cellfun(@(range) num2str(range, '%.2f %.2f'), tmp_range, 'un', 0);
            range_str = join(range_str, ', ');
            ranges{i} = range_str{:};

        elseif handles.handles_analysis.uicontrols.checkbox.(useAutoRangeTag).Value && ...
                ~isempty(statsLookup{i})
            
            [~, ~, num_range] = returnUnitLabel(statsLookup{i});
            ranges{i} = num2str(num_range, '%.2f %.2f');
            
        else
            ranges{i} = '';
            
        end
        
        handles.handles_analysis.uicontrols.edit.(rangeEditTag).String = ranges{i};
        
    end
    
    xRange = ranges{1};
    yRange = ranges{2};
    zRange = ranges{3};
    cRange = ranges{4};
    
end