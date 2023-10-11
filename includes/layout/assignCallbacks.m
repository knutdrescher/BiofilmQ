%Reassining Context-Menues
function handles = assignCallbacks(handles, importedChildren, newParent)

newHandlesofChildren = get(newParent, 'Children');

for i = 1:length(importedChildren)
    try
        cb = get(importedChildren(i), 'Callback');
        
        set(newHandlesofChildren(i), 'Callback', cb);
    end
    
    try
        cb = get(importedChildren(i), 'CellSelectionCallback');
        
        set(newHandlesofChildren(i), 'CellSelectionCallback', cb);
    end
    
    try
        cb = get(importedChildren(i), 'CellEditCallback');
        
        set(newHandlesofChildren(i), 'CellEditCallback', cb);
    end
    
    % Assign also to nested levels (only one yet, to cover all, it needed to
    % be done iteratively)
    subChildren = get(importedChildren(i), 'Children');
    newHandlesofSubChildren = get(newHandlesofChildren(i), 'Children');
    for j = 1:length(subChildren)
        try
            cb = get(subChildren(j), 'Callback');
            
            set(newHandlesofSubChildren(j), 'Callback', cb);
        end
    end

end
