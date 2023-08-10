function [lineageTree, fig_h] = createLineageTree(handles, nodes2, treeLabels, divTimes, Track_IDs, t_max)

%% Create lineage plot
% Create lineage tree
lineageTree = tree(0);
divTimesTree = tree(divTimes(1)/60/60);

for i = 2:numel(nodes2)
    lineageTree = lineageTree.addnode(nodes2(i), treeLabels{i});
    divTimesTree = divTimesTree.addnode(nodes2(i), divTimes(i)/60/60);
end
fig_h = figure('Name', ['Track_ID: ', Track_IDs, sprintf(' max Frame: %d', t_max)], 'Color', 'w');
lineageTree.plot(divTimesTree, 'YLabel', {'t_D/h'}, 'DrawLabels', false, 'FieldNames', handles.settings.measurementFieldsAnalysis_singleCell);
set(get(gca, 'Children'), 'Color', 'black');
