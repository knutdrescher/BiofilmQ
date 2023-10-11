function [xlabel, ylabel, zlabel, clabel] = getLabelsFromGUI(handles, statsLookup)
    labelfields = {'edit_xLabel', 'edit_yLabel', 'edit_zLabel', 'edit_colorLabel'};
    labels = cell(4, 1);

    for i = 1:numel(labelfields)
        labelfield = labelfields{i};
        if ~isempty(handles.handles_analysis.uicontrols.edit.(labelfield).String)
            labels{i} = handles.handles_analysis.uicontrols.edit.(labelfield).String;
        elseif ~isempty(statsLookup{i})
            labels{i} = returnUnitLabel(statsLookup{i});
        else
            labels{i} = '';
        end
        handles.handles_analysis.uicontrols.edit.(labelfield).String = labels{i};
    end
    
    xlabel = labels{1};
    ylabel = labels{2};
    zlabel = labels{3};
    clabel = labels{4};
    
end