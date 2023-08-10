function [xUnit, yUnit, zUnit, cUnit] = getUnitsFromGUI(handles, statsLookup)
    unitfields = {'edit_xLabel_unit', 'edit_yLabel_unit', 'edit_zLabel_unit', 'edit_colorLabel_unit'};
    units = cell(4, 1);

    for i = 1:numel(unitfields)
        unitfield = unitfields{i};
        if ~isempty(handles.handles_analysis.uicontrols.edit.(unitfield).String)
            units{i} = handles.handles_analysis.uicontrols.edit.(unitfield).String;
        elseif ~isempty(statsLookup{i})
            [~ , units{i}] = returnUnitLabel(statsLookup{i});
        else
            units{i} = '';
        end
        handles.handles_analysis.uicontrols.edit.(unitfield).String = units{i};
    end
    
    xUnit = units{1};
    yUnit = units{2};
    zUnit = units{3};
    cUnit = units{4};
    
end