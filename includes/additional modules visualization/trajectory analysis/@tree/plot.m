function [vLineHandleTree, hLineHandleTree, textHandleTree] = plot(obj, heightTree, varargin)
%% PLOT  Plot the tree.
% 
%   PLOT(T) lay out the tree T on new axes, complying to Edward Tufte
%   recommandations.
%
%   PLOT(T, LT), where LT is a synchronized tree made of scalars, lay out
%   the tree, using LT data to specify the length of each vertical branch.
%   Use the empty array [] to use a default of 1 for all branches.
%
%   PLOT(T, LT, 'PropertyName', PropertyValue, ...) allows to specify extra
%   parameters for the plot:
%
%       'Ylabel' - a string or a cell array of strings: Use a label for the
%       Y axis. The axis itself becomes visible and ticks are drawn on the
%       tree.
%
%       'X' - a scalar: X leftmost position of the tree.
%
%       'Width' - a scalar: Width of the whole tree or of each branch (see
%       'NormalizeWidth')
%
%       'NormalizeWidth' - a boolean, default is false. If true, then the
%       tree total width will be adjusted so that it spans over the 'Width'
%       value. Otherwise, each branch will have a width set by this 'Width'
%       value.
%
%       'TextRotation' - a scalar: Rotation, in degrees, of the label that
%       is printed above each node.
%
%       'Parent - an axes handle: The axes handle to plot the tree in. The
%       axes are not changed, except for the YLabel.
%
%       'Sorted' - a boolean value: If true, the chlid nodes will be sorted
%       when meeting a branching point.
%
%       'DrawLabels' - a boolean value: If true (the default), the node
%       content of the specified tree will be printed next to each branch.
%
%   [ VL HL TH ] = PLOT(T, ...) returns three synchronized trees containing
%   respectively the handles for the vertical lines, the horizontal lines
%   and the text labels of each node.
%
%   EXAMPLE:
%   [ lineage duration ] = tree.example; % 1st one is made of strings only, 2nd one of integers
%   slin = lineage.subtree(19); % Work on a subset
%   sdur = duration.subtree(19);
%   [vlh hlh tlh] = slin.plot(sdur, 'YLabel', {'Division time' '(min)'});
%   rcolor = [ 0.6 0.2 0.2 ];
%   aboveTreshold = sdur > 10; % true if longer than 10 minutes
%   iterator = aboveTreshold.depthfirstiterator;
%   for i = iterator
%    if  aboveTreshold.get(i)
%        set( vlh.get(i), 'Color' , rcolor )
%        set( hlh.get(i), 'Color' , rcolor )
%        set( tlh.get(i), 'Color' , rcolor )
%    end
% end

% Jean-Yves Tinevez <tinevez AT pasteur DOT fr> March 2012

    %% CONSTANTS
    
    LINE_COLOR = [ 0.3 0.3 0.3 ];
    
    %% Deal with input
    
    if nargin < 2 || isempty(heightTree)
        heightTree = tree(obj, 1);
    end
    
    parser = inputParser;
    parser.addParamValue('YLabel', [], @(x) ischar(x) || iscell(x));
    parser.addParamValue('TextRotation', 0, @(x) isnumeric(x) && isscalar(x) );
    parser.addParamValue('Parent', [], @ishandle);
    parser.addParamValue('X', 0, @(x) isnumeric(x) && isscalar(x) );
    parser.addParamValue('Width', 1, @(x) isnumeric(x) && isscalar(x) );
    parser.addParamValue('NormalizeWidth', false, @(x) islogical(x) && numel(x) == 1 );
    parser.addParamValue('Sorted', false, @(x) islogical(x) && numel(x) ==1 );
    parser.addParamValue('DrawLabels', true, @(x) islogical(x) && numel(x) ==1 );
    parser.addParamValue('FieldNames', '', @(x) iscell(x));
    
    parser.parse(varargin{:});
    ylbl    = parser.Results.YLabel;
    textrot = mod(parser.Results.TextRotation, 360);
    ax      = parser.Results.Parent;
    xcorner = parser.Results.X;
    xwidth  = parser.Results.Width;
    normalizewidth = parser.Results.NormalizeWidth;
    sorted  = parser.Results.Sorted;
    drawlabels = parser.Results.DrawLabels;
    fieldNames = parser.Results.FieldNames;
 
    %% Compute the column width
    
    width = tree(obj, 'clear');

    % Put 1 at the leaves
    iterator = obj.depthfirstiterator(1, true);
    for i = iterator
       if width.isleaf(i)
           width = width.set(i, 1);
       end
    end
    
    % Cumsum
    width = width.recursivecumfun(@sum);
    
    % Normalize
    if normalizewidth
        maxWidth = width.get(1);
        width = width .* ( xwidth / maxWidth );
    else 
        width = width .* xwidth ;
    end
    
    %% Compute the X *column* width
    % The heavy part on arranging node in sorted order or not is done here.
    
    xcol = tree(width, 'clean');
    xcol = xcol.set(1, 0);
    
    if sorted
        
        iterator = obj.depthfirstiterator(1, true);
        for i = iterator
           
            if i == 1
                previous = 0;
            else
                previous = xcol.get( i );
            end
            
            children = obj.getchildren(i);
            contents = obj.Node(children);
            [ ~, sorting_array ] = sortrows(contents);
            children = children(sorting_array);
            
            for c = children
               xcol = xcol.set(c, previous);
               previous = previous + width.get(c);
            end
            
        end
    
    else
        
        previous = 0;
        parent = 1;
        iterator = obj.breadthfirstiterator(false);
        
        for i = iterator(2 : end) % The root is already done
            
            newParent = xcol.getparent(i);
            if newParent ~= parent
                % We just changed branch
                parent = newParent;
                previous = xcol.get(parent);
            end
            
            w = width.get(i);
            xcol = xcol.set(i, previous);
            
            previous = previous + w;
        end
    end
    
    %% Compute the actual X position
  
    xpos = tree(width, 'clean');
    xpos = xpos.set(1, 1);
    iterator = obj.breadthfirstiterator(sorted);
    for i = iterator
        xpos = xpos.set(i, xcol.get(i) + width.get(i)/2);
    end
    
    % Max of x position
    maxXpos = -1;
    for i = iterator
        xp = xpos.get(i);
        if xp > maxXpos
            maxXpos = xp;
        end
    end
    
    
    %% Compute the Y position
    
    ypos = tree(obj, 'clear');
    ypos = ypos.set(1, heightTree.get(1));
    iterator = obj.depthfirstiterator(1, sorted);
    iterator(1) = []; % Skip the root
    
    maxHeight = heightTree.get(1);
    
    for i = iterator
       parent = ypos.getparent(i);
       parentPos = ypos.get(parent);
       height = heightTree.get(i);
       ypos = ypos.set(i, parentPos + height);
       
       if maxHeight < parentPos + height
           maxHeight = parentPos + height;
       end
    end
    
    %% Prepare the axes
    
    if isempty(ax) 
        ax = axes( ...
            'FontName', 'Courier new', ...
            'FontSize', 9, ...
            'Color', 'none', ...
            'YDir', 'reverse', ...
            'TickDir', 'out', ...
            'XTickLabel', '', ...
            'XTick', [], ...
            'XLim', [0 maxXpos * 1.05]);
    end
    
    if isempty(ylbl)
        set(ax, ...
            'YTick', [], ...
            'YTickLabel', '')
    else
        ylabel(ylbl, ...
            'HorizontalAlignment', 'right', ...
            'Rotation', 0)
    end
    hold(ax, 'on')
    
    %% A first iteration for the vertical bars
        
    % Prepare holder for the vertical line handles
    vLineHandleTree = tree(obj, 'clear');
    
    iterator = obj.depthfirstiterator(1, sorted);
    for i = iterator
        
        % Vertical bars -> to parent
        
        y1 = ypos.get(i);
        
        if isempty(y1)
            continue
        end
        
        y2 = y1 - heightTree.get(i);
        
        x1 = xpos.get(i) + xcorner;
        x2 = x1;
        
        hl = line([x1 x2], [y1 y2], ...
            'Color', LINE_COLOR, ...
            'LineWidth', 1, 'ButtonDownFcn', {@clickTree, i, obj}, 'Tag', num2str(i));
        
        vLineHandleTree = vLineHandleTree.set(i, hl);
        
    end
    
    
    %% New iteration for the bars and the content
        
    % Prepare the holder for the text handles
    textHandleTree = tree(obj, 'clear');
    
    % Prepare the holder for horizontal line handles
    hLineHandleTree = tree(obj, 'clear');
    
    % Prepare display of text
    if textrot <  45 || (textrot >  135 && textrot < 225) || textrot > 315
        halign = 'center';
        valign = 'middle';
        contentfun = @(x) { x ' ' ' ' };
    else
        halign = 'left';
        valign = 'middle';
        contentfun = @(x) [ ' ' x ];
    end
    
    for i = iterator
        
         y1 = ypos.get(i);
        
        if isempty(y1)
            continue
        end
        
        y2 = y1 - heightTree.get(i);
        
        x1 = xpos.get(i) + xcorner;
        
        
        if drawlabels
            
            % The label = content
            content = obj.get(i);
            if isempty(content)
                content = '';
            end
            if ~ischar(content)
                content = num2str(content);
            end
            
            ht = text(x1, y2, contentfun(content), ...  A hack to have text displayed above bars
                'HorizontalAlignment', halign,...
                'Rotation', textrot, ...
                'VerticalAlignment', valign, ...
                'FontName', 'Courier new', ...
                'Interpreter', 'none', ...
                'FontSize', 12);
            
            textHandleTree = textHandleTree.set(i, ht);
            
        end
        
        % Horizontal bars -> children
        if obj.isleaf(i)
            continue
        end
        
        children = obj.getchildren(i);
        allX = cell2mat(xpos.Node(children)) + xcorner;
        
        y2 = y1;
        x1 = min(allX);
        x2 = max(allX);
        
        if numel(children) > 1
            hl = line([x1 x2], [y1 y2], ...
                'Color', LINE_COLOR, ...
                'LineWidth', 5, 'ButtonDownFcn', {@clickTree, i, obj}, 'Tag', num2str(i));
        else
            hl = line(x1, y1, ...
                'Color', LINE_COLOR, ...
                'Marker', '.', ...
                'MarkerSize', 14, 'ButtonDownFcn', {@clickTree, i, obj}, 'Tag', num2str(i));
            
        end
        
        hLineHandleTree = hLineHandleTree.set(i, hl);
        
    end
    
    
    % If we were given a height tree, draw white ticks on the tree, a la
    % Tufte.

    if nargin >= 2
        tree.decorateplots(ax);
    end
    
    % Add buttons and field selector
    
    uicontrol('Style', 'pushbutton', 'String', 'Reset Tree', 'Callback', {@resetTree}, 'Position', [20 20 100 20])
    uicontrol('Style', 'pushbutton', 'String', 'Snapshot', 'Callback', {@renderSnapshot, obj}, 'Position', [120 20 100 20])
    uicontrol('Style', 'text', 'String', 'Plot:', 'Position', [240 20 50 20])
    uicontrol('Style', 'popupmenu', 'Tag', 'fieldName', 'String', fieldNames, 'Callback', {@changeFieldName}, 'Position', [290 20 200 20])
    uicontrol('Style', 'checkbox', 'Tag', 'plotMode', 'String', 'Plot node only', 'Position', [500 20 100 20], 'Value', 1)
    
    y_max = max(cellfun(@max, get(findobj(gca, 'Type', 'line'), 'y')));
    ylim([0 y_max]);
end

function clickTree(src, evnt, node, obj)
cmap = colormap(lines(numel(obj.Node)));
children = num2str(find(obj.Parent == node)');
fprintf('node: %d, child of %d, parent of [%s]\n', node, obj.Node{node}, strrep(children, '  ', ', '));
try
    set(findobj('tag', num2str(node)), 'Color', cmap(node,:));
end
fieldNames = get(findobj(gcf, 'Tag', 'fieldName'), 'String');
fieldNameValue = get(findobj(gcf, 'Tag', 'fieldName'), 'Value');

plotMode = get(findobj(gcf, 'Tag', 'plotMode'), 'Value');


if plotMode
    renderSelectedCell(node, obj, 'FieldName', fieldNames{fieldNameValue});
else
    % Reconstruct the whole track
    renderSelectedCell(node, obj, 'FieldName', fieldNames{fieldNameValue}, 'PlotAllNodes', 1);
end
end

function resetTree(src, evnt)
set(findobj('Type', 'line'), 'Color', [0 0 0]);
end

function renderSnapshot(src, evnt, obj)
cmap = colormap(lines(numel(obj.Node)));
fieldNames = get(findobj(gcf, 'Tag', 'fieldName'), 'String');
fieldNameValue = get(findobj(gcf, 'Tag', 'fieldName'), 'Value');

title('Please select timepoint');
x = ginput(1);
title('');
y = x(2);

lineObj = findobj('Type', 'line');

warning off;
h = waitbar(0, 'Searching for cells...', 'Position', [50 50 270 56]);
warning on;

nodes = [];
frames = [];
for i = 1:numel(lineObj)
    try
        yCoord = get(lineObj(i), 'y');
    catch
        yCoord = get(lineObj(i), 'YData');
    end
   if yCoord(1) > y && yCoord(2) < y
       nodes(end+1) = str2num(get(lineObj(i), 'Tag'));
       set(lineObj(i), 'Color', cmap(nodes(end),:));
       frames(end+1) = (y-yCoord(2))/(yCoord(1)-yCoord(2));
       renderSelectedCell(nodes(end), obj, 'Timepoint', frames(end), 'FieldName', fieldNames{fieldNameValue})
       waitbar(i/numel(lineObj), h);
   end
end
delete(h);

end

function changeFieldName(src, evnt)
    % TODO: Probably most of the functionallity can be implemented by a
    % refactored version of renderSelectedCells
    
    % get access to data
    biofilmData = getLoadedBiofilmFromWorkspace;
    parameterTree = evalin('base', 'parameterTree');
    ParentNodes = evalin('base', 'nodes');
    
    % can get new field name from event
    fieldNames = evnt.Source.String;
    fieldNameValue = evnt.Source.Value;
    fieldName = fieldNames{fieldNameValue};
    
    % get tags of non-black nodes to look values up in parameterTree
    
    lineObjs = findobj(gcf, 'Type', 'line', '-not', 'Tag', 'TufteLine');
    plotNodes = cellfun(@str2double, {lineObjs(:).Tag});
    plotColors = reshape([lineObjs(:).Color], 3, []);
    cmap = colormap(lines(numel(unique(plotNodes))));
    
    selectedNodes = [];
    for i = 1:size(plotColors, 2)
        if any(plotColors(:, i) ~= [0, 0, 0])
            selectedNodes(end+1) = plotNodes(i);
        end
    end
    
    if isempty(selectedNodes)
        warning('No nodes have been selected yet!')
        return
    end
    
    plotMode = get(findobj(gcf, 'Tag', 'plotMode'), 'Value');
    plotNodes = selectedNodes;
    if ~plotMode % plot full path to node
        for i = selectedNodes
            % determine all nodes until the root
            currentNode = i;
            while currentNode
                currentNode = ParentNodes(currentNode);
                
                disp(currentNode)
                if currentNode
                    plotNodes = [plotNodes currentNode];
                end
            end
        end
        plotNodes = unique(plotNodes);
    end
    
    
    t = {};
    data = {};
    for i = plotNodes
        frames = parameterTree(i).frameData;
        frames(~frames) = [];
        idData = parameterTree(i).IDData;
        stats = [];
        for j = 1:numel(frames)
            fprintf('frame = %d\n', frames(j));
            fprintf('id = %d\n', idData(j));
            stats(end+1, :)=  biofilmData.data(frames(j)).stats(idData(j)).(fieldName);
        end
        t{end+1} = frames;
        data{end+1} = stats;
    end
        
    try
        h_fig = evalin('base', 'h_fig');
        figure(h_fig);
    catch
        h_fig = open('visualizeTree.fig');
        assignin('base', 'h_fig', h_fig);
    end

    h_ax3 = findobj(h_fig.Children, 'Tag', 'axes3');
    cla(h_ax3);

    h_ax3.NextPlot = 'add';
    for i = 1:numel(data)
        if size(data{i}, 2) == 1
            plot(h_ax3, t{i}, data{i}, 'o-', 'Color', cmap(plotNodes(i), :));
        else
            data_plot = data{i}
            plot3(h_ax3, data_plot(:, 1), data_plot(:, 2), data_plot(:, 3), 'o', 'Color', cmap(plotNodes(i), :));
        end
    end
        
    ylabel(h_ax3, fieldName);
end