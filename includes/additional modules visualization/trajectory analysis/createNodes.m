%% Node plot
% All nodes
% validTracks = [data{1}.stats.Track_ID];

function [parameterTree, nodes2, divTimes, treeLabels] = createNodes(handles, biofilmData, timeIntervals, validTracks)
% CREATENODES goes to through every time frame and collects the parentID
% and Track_ID of each object to genereate a parameter tree.
% It is divided into two parts:
% 1.) generates 'node_vec' structure with the vectors
% - nodes           : overall parentID of the current object
% - nodeTimes       :  time intervals of the current object
% - frameData       : frame number in which the object was observed
% - IDData          : id of the object in the corresponding time frame
% - Track_IDData     : assigned Track_ID of the object
% - parentIDData    : parentID of the object in the previous frame
% the vector index corresponds to the object id over all time frames
%
% with this node information all the final branches and division nodes are
% determined.
%
% 2.) generates 'parameterTree' which collects the information for every
% edge in a lineage tree as a array:
% - frameTimes
% - frameData
% - IDData
% - Track_IDData
% - parentIDData
% - divTime         : time when the node divides
%
% parameterTreedivTime = divTimes


enableCancelButton(handles);

nodeLength = [];
parentData_ind = [];

node_vec = struct;
linkError = 0;
for i = 1:numel(biofilmData.data)
    fprintf('processing frame %d of %d\n', i, numel(biofilmData.data));
    
    parentData = [biofilmData.data(i).stats.Track_Parent];
    parentData(isnan(parentData)) = 0;
    frameData = i*ones(1, numel(parentData));
    IDData = 1:numel(parentData);
    Track_IDData = [biofilmData.data(i).stats.Track_ID];
    parentIDData = [biofilmData.data(i).stats.Track_Parent];
    
    % Only take tracks which are already present in the first frame
    originInFirstFrame = ismember(Track_IDData, validTracks);
    
    frameData(~originInFirstFrame) = [];
    IDData(~originInFirstFrame) = [];
    Track_IDData(~originInFirstFrame) = [];
    parentIDData(~originInFirstFrame) = [];
    parentData(~originInFirstFrame) = [];
    
    parentData_mod = parentData;
    
    % Relink the parents after removing the not wanted ones
    try
        if i > 1 && all(parentData ~= 0)
            % - values in parentData_ind are unique, thus the 1st index
            %   in parentData_ind <=> all occurences of parentData values
            [~,parentData_mod] = ismember(parentData, parentData_ind);
            if any(parentData_mod == 0)
                error('Could not find parentData value in previous time frame!')
            end
        end
    catch
        linkError = 1;
    end
    
    % Save the current frame ids for next time frame
    parentData_ind = find(originInFirstFrame);
    
    % Assemble nodes
    if i == 1
        node_vec.nodes = 0*parentData_mod;
    elseif i == 2
        node_vec.nodes = [node_vec.nodes parentData_mod];
    else
        newNodes = parentData_mod;
        add_previousNodeLength = nodeLength(i-2)*(newNodes>0); % count all previous nodes
        newNodes = newNodes+add_previousNodeLength;
        node_vec.nodes = [node_vec.nodes newNodes];
    end
    
    % Assemble additional fields (time, ID, Track_ID, frame)
    if i == 1
        node_vec.nodeTimes = zeros(1, numel(node_vec.nodes));
        node_vec.frameData = frameData;
        node_vec.IDData = IDData;
        node_vec.Track_IDData = Track_IDData;
        node_vec.parentIDData = parentIDData;
    else
        node_vec.nodeTimes = [node_vec.nodeTimes timeIntervals(i)*ones(1, numel(parentData_mod))];
        node_vec.frameData = [node_vec.frameData, frameData];
        node_vec.IDData = [node_vec.IDData, IDData];
        node_vec.Track_IDData = [node_vec.Track_IDData, Track_IDData];
        node_vec.parentIDData = [node_vec.parentIDData, parentIDData];
    end
    nodeLength(i) = length(node_vec.nodes);
    
    if mod(i,10) == 1
        updateWaitbar(handles, i/numel(biofilmData.data))
        if checkCancelButton(handles)
            return;
        end
    end
end

if linkError
    uiwait(msgbox('Cells are not properly linked! Cannot continue...', 'Error', 'error'));
    return;
end

%% Create node vector with variable branch length
nodes = node_vec.nodes;
nodes = nodes+1;
nodes = [0 nodes];
nodeTimes = [0 node_vec.nodeTimes];
frameData = [0 node_vec.frameData];
IDData = [0 node_vec.IDData];
Track_IDData = [0 node_vec.Track_IDData];
parentIDData = [0 node_vec.parentIDData];

% Find all branches ...
nodes_branches = nodes;

for i = find(nodes)
    %  ... remember: nodes is the parentID of each object; if an object is
    % not referenced by any other object ...
    nodes_branches(nodes(i)) = 0;
end

% ... it has to be a final branch.
branches = find(nodes_branches);

% Find all division nodes ...
[~, ind] = unique(nodes);
% ... those are nodes which have multiple referencing objects; so deleting
% the first occurence of every unique object in the set will leave only
% objects which reference to the same object as another node before. The
% index of this object has to be a child.
dublicate_nodes = setdiff(1:numel(nodes), ind);


% Reminder: union returns sorted array without repititons.
% Combine all division nodes and endpoints of branches, to start a top-down
% node search.
parentNodes = union(nodes(dublicate_nodes), branches);

N = numel(parentNodes); % +1 to include the root

% Initialize new node-vector (same format as "nodes")
nodes2 = zeros(1, N);
currentNodeParent = zeros(N, 1);
node_tminus = zeros(N, 1);
divTimes = zeros(1, N);

parameterTree = [];

for i = 1:N % for every final branches or parent node
    if mod(i,1000) == 1
        fprintf('processing branch %d of %d\n', i, N);
        updateWaitbar(handles, i/N)
        if checkCancelButton(handles)
            return;
        end
    end
    
    currentNode = parentNodes(i);
    
    node_tminus(i) = nodes(currentNode);
    
    % Obtain parameter of the node
    divTimes(i) = nodeTimes(currentNode);
    parameterTree(i).frameTimes = nodeTimes(currentNode);
    parameterTree(i).frameData = frameData(currentNode);
    parameterTree(i).IDData = IDData(currentNode);
    parameterTree(i).Track_IDData = Track_IDData(currentNode);
    parameterTree(i).parentIDData = parentIDData(currentNode);
    
    if node_tminus(i) > 1 % root is not reached
        % go up until new parent nodes are reached
        while isempty(find(node_tminus(i) == parentNodes, 1))
            divTimes(i) = divTimes(i) + nodeTimes(node_tminus(i));
            parameterTree(i).frameTimes = [parameterTree(i).frameTimes, nodeTimes(node_tminus(i))];
            parameterTree(i).frameData = [parameterTree(i).frameData, frameData(node_tminus(i))];
            parameterTree(i).IDData = [parameterTree(i).IDData, IDData(node_tminus(i))];
            parameterTree(i).Track_IDData = [parameterTree(i).Track_IDData, Track_IDData(node_tminus(i))];
            parameterTree(i).parentIDData = [parameterTree(i).parentIDData, parentIDData(node_tminus(i))];
            
            node_tminus(i) = nodes(node_tminus(i)); % time-intervall is needed
            if node_tminus(i) == 0
                break; % root is reached
            end
        end
        if numel(parameterTree(i).IDData) > 1
            if parameterTree(i).IDData(end) ~= parameterTree(i).parentIDData(end-1)
                parameterTree(i).IDData
                parameterTree(i).parentIDData
                disp('Something is wrong with the linkage!')
            end
        end
        % link the original node (current node) with the new parent
        if node_tminus(i) == 0
            currentNodeParent(i) = 1;
        else
            currentNodeParent(i) = find(node_tminus(i) == parentNodes);
        end
    else
        currentNodeParent(i) = 1;
    end
    nodes2(i) = currentNodeParent(i);
    
    treeLabels{i} = currentNodeParent(i);
    
    parameterTree(i).divTime = divTimes(i);
    
    
end
nodes2(1) = 0;

assignin('base', 'parameterTree', parameterTree);
assignin('base', 'nodes2', nodes2);

updateWaitbar(handles, 0)