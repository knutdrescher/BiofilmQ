%%
% BacStalk
%
% Copyright (c) 2018 Raimo Hartmann & Muriel van Teeseling <bacstalk@gmail.com>
% Copyright (c) 2018 Drescher-lab, Max Planck Institute for Terrestrial Microbiology, Marburg, Germany
% Copyright (c) 2018 Thanbichler-lab, Philipps Universitaet, Marburg, Germany
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%

function [jtable, jscrollpane] = createJavaTable(parent, CallbackFcn, jtable, tableData, columnNames, isEditable, autoResize)
% This function creates a jtable

if nargin == 2
    % Create table
    hc = uitable('Units', 'normalized', 'position', [0 0 1 1], 'Parent', parent, 'RowName', []);

    jscrollpane = javaObjectEDT(findjobj(hc));
    jtable = javaObjectEDT(jscrollpane.getViewport.getView);
    jtable.setAutoResizeMode(jtable.AUTO_RESIZE_SUBSEQUENT_COLUMNS)
       
    rowHeaderViewport = javaObjectEDT(jscrollpane.getComponent(0));
    rowHeader = javaObjectEDT(rowHeaderViewport.getComponent(0));
    rowHeader.setBackground(javaObjectEDT('java.awt.Color', 1, 1, 1));
    
    jtable.setSortable(true);	
    jtable.setAutoResort(true);
    jtable.setMultiColumnSortable(true);
    jtable.setPreserveSelectionsAfterSorting(true);
    jtable.setShowSortOrderNumber(true);

    theader = javaObjectEDT('com.jidesoft.grid.AutoFilterTableHeader', jtable);
    theader.setAutoFilterEnabled(true)
    theader.setShowFilterName(true)
    theader.setShowFilterIcon(true)
    jtable.setTableHeader(theader)
    
    try set(jtable, 'RowMargin', 2, 'RowHeight', 25); end
    h = handle(jtable,'CallbackProperties');
    set(h, 'KeyPressedCallback', CallbackFcn);
    set(h, 'MousePressedCallback', CallbackFcn);
    set(jtable, 'GridColor' , javaObjectEDT('java.awt.Color', 0.8,0.8,0.8))
end

if nargin >= 5
    if nargin == 5
        isEditable = false(numel(columnNames));
    end
    
    if nargin < 7
        autoResize = false;
    end
    
    % Probably better:  
    set(parent, 'Visible', false);
    
    jtable.setModel(javaObjectEDT('javax.swing.table.DefaultTableModel', tableData, columnNames));
    
    pause(0.01);
    drawnow;
    
    if ~isempty(tableData)

        for i = 0:jtable.getColumnCount-1            
            if islogical(tableData{1,i+1})
                cr0 = javaObjectEDT('com.jidesoft.grid.BooleanCheckBoxCellRenderer');
                sclass=java.lang.Boolean(false).getClass;
                editor=jtable.getDefaultEditor(sclass);
                editor.getComponent.setEnabled(false);
            end
            
            if isnumeric(tableData{1,i+1})
                cr0 = javaObjectEDT('com.jidesoft.grid.NumberCellRenderer');
                sclass=java.lang.Integer(1.0).getClass;
                editor=jtable.getDefaultEditor(sclass);
                editor.getComponent.setEnabled(false);
            end
            
            if ischar(tableData{1,i+1})
                cr0 = javaObjectEDT('com.jidesoft.grid.MultilineTableCellRenderer');
                sclass=java.lang.String('').getClass;
                editor=jtable.getDefaultEditor(sclass);
                editor.getComponent.setEnabled(false);
            end
            
            if isEditable(i+1)
                cr0.setForeground(javaObjectEDT('java.awt.Color', 0,0,0))
                editor.getComponent.setEnabled(true);
            else
                editor.setClickCountToStart(999)
                cr0.setForeground(javaObjectEDT('java.awt.Color', 0,0,0))
                if ~islogical(tableData{1,i+1})
                    editor.getComponent.setEditable(false);
                end
            end
            
            if mod(i, 2)
                cr0.setBackground(java.awt.Color(1,1,1))
            else
                cr0.setBackground(java.awt.Color(0.97,0.97,0.97))
            end
            
            if i == 0
                if strcmp(columnNames{1}, 'Index') || strcmp(columnNames{1}, 'Measurement')
                    cr0.setBackground(javaObjectEDT('java.awt.Color', 0.9412,0.9412,0.9412))
                end
            end

            switch columnNames{i+1}
                case 'Measurement'
                    jtable.getColumnModel.getColumn(i).setPreferredWidth(max(cellfun(@numel, tableData(:,1)))*8)
                case 'Comment'
                    jtable.getColumnModel.getColumn(i).setPreferredWidth(numel(columnNames{i+1})*8+400)
                otherwise
                    jtable.getColumnModel.getColumn(i).setPreferredWidth(numel(columnNames{i+1})*8+50)
            end
            
            jtable.getColumnModel.getColumn(i).setCellRenderer(cr0)
            jtable.getColumnModel.getColumn(i).setCellEditor(editor)
        end
    end
    
    if numel(columnNames) == 1 || autoResize
        jtable.setAutoResizeMode(jtable.AUTO_RESIZE_SUBSEQUENT_COLUMNS)
    else
        jtable.setAutoResizeMode(jtable.AUTO_RESIZE_OFF)
    end
    set(parent, 'Visible', true);
end

jtable.repaint;
pause(0.01);
drawnow;
