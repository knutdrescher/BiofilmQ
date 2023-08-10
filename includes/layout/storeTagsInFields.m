%Reassining Context-Menues
function handles = storeTagsInFields(handles, importedChildren, parent)

newChildren = get(parent, 'Children');

for i = 1:length(importedChildren)
    try
        type = get(importedChildren(i), 'Type');
        tag = get(importedChildren(i), 'Tag');
        
        handles.uicontrols.(type).(tag) = newChildren(i);
        
    end
end
