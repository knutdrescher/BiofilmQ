function enableDisableChildren(parent, state)

children = findobj(parent);

for i = 1:numel(children)
    try
        children(i).Enable = state;
    end
end