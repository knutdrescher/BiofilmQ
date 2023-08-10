function [parameterTree, nodes, treeLabels, divTimes] = trimParameterTreeToMaxFrame(parameterTree, nodes, treeLabels, t_max)
% trimParameterTreeToMaxFrame deletes all items which are above a certain
% frame number
%
% 2019 Eric Jelli (eric.jelli@mpi-marburg.mpg.de)

% go through parameter tree in reverse order to delete in-place
for i = numel(parameterTree):-1:1
    frameData = parameterTree(i).frameData;
    ind = find(frameData > t_max);
    
    % Case1: all elements are above threshold
    if numel(ind) == numel(frameData)
        % delete entire edge in all return parameters
        parameterTree(i) = [];
        treeLabels(i) = [];
        nodes(i) = [];
    % Case2: some elements are above threshold
    else
        % delete elements in parameter tree
        for field = {'frameTimes', 'frameData', 'IDData', 'Track_IDData', 'parentIDData'}
            parameterTree(i).(field{:})(ind) = [];
        end       
    end
end
divTimes = [parameterTree.divTime];
