function smoothParameter(handles, biofilmData, nodes2, parameterTree, fieldName)

enableCancelButton(handles);

%% Start an the endpoints of the branches and smooth the growth rate for
% each lineage
smoothFactor = 20;

%% Go through the whole data structure and calculate the median of the growth rate
% Try to remove the field first
for i = 1:numel(biofilmData.data)
    try
        biofilmData.data(i).stats = rmfield(biofilmData.data(i).stats, [fieldName, '_lineage']);
    end
    [biofilmData.data(i).stats.([fieldName, '_lineage'])] = biofilmData.data(i).stats.(fieldName);
    
end

% Find all branches
nodes_branches = nodes2;

for i = find(nodes2)
    % Delete all nodes which do have a child
    nodes_branches(nodes2(i)) = 0;
end

%branches = find(nodes_branches);
nodes_branches(nodes_branches==0) = []; % Probably not used

averageMatrix = nan(numel(nodes_branches), numel(biofilmData.data), 2);

% Go through each branch and propagate down
for i = 1:numel(nodes_branches)
    if mod(i,1000) == 1
        fprintf('processing branch %d of %d\n', i, numel(nodes_branches));
        updateWaitbar(handles, i/numel(nodes_branches))
        if checkCancelButton(handles)
            return;
        end
    end
    
    % generate a path from the final branch down to the root ...
    currentNode = nodes_branches(i);
    nodes_all = nodes_branches(i);
    while currentNode %  ... while node is not root ...
        currentNode = nodes2(currentNode);
        
        if currentNode
            % ... add node to final-branch-specific node vector.
            nodes_all = [nodes_all currentNode];
        end
    end
    nodes_all = sort(nodes_all);
    
    stats = [];
    
    % Generate frame vector from node vector.
    for n = 1:numel(nodes_all)
        node = nodes_all(n);
        frames = sort(parameterTree(node).frameData);
        frames(~frames) = [];
        
        if isempty(frames)
            stats = [];
            
        else
            
            for f = 1:numel(frames)
                ind = find(parameterTree(node).frameData == frames(f));
                frame = parameterTree(node).frameData(ind);
                cellID = parameterTree(node).IDData(ind);
                stats(end+1, :) = [frame, cellID, biofilmData.data(frame).stats(cellID).(fieldName)];
            end
        end
        
    end
    
    if ~isempty(stats)
        stats(:,4) = smooth(stats(:,3), smoothFactor);
        averageMatrix(i, 1:size(stats,1), 1) = stats(:,3);
        averageMatrix(i, 1:size(stats,1), 2) = stats(:,4);
        
        % Reasign values back to the cell structure

        for c = 1:size(stats, 1)
            %data{stats(c,1)}.stats(stats(c,2)).([fieldName, '_lineage']) = [];
            try
                biofilmData.data(stats(c,1)).stats(stats(c,2)).([fieldName, '_lineage']) = [biofilmData.data(stats(c,1)).stats(stats(c,2)).([fieldName, '_lineage']) stats(c, 4)];
            catch
                biofilmData.data(stats(c,1)).stats(stats(c,2)).([fieldName, '_lineage']) = stats(c, 4);
            end
        end
    end
end

%% Go through the whole data structure and calculate the median of the growth rate
for i = 1:numel(biofilmData.data)-2
    for j = 1:length(biofilmData.data(i).stats)
        biofilmData.data(i).stats(j).([fieldName, '_lineage']) = nanmedian(biofilmData.data(i).stats(j).([fieldName, '_lineage']));
    end
end

assignin('base', 'biofilmData', biofilmData);

updateWaitbar(handles, 0)