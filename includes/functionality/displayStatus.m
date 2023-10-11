
function displayStatus(handles, str, color, add)

maxLength = 9;
lineLimit = 90;

if nargin <= 3
    add = false;
    if strcmp(color, 'green')
        color = '003300';
    end
    
else
    add = true;
    color = 'gray';
end


try
    status_str = get(handles.uicontrols.listbox.listbox_status, 'String');
catch err
    warning(err.message)
    status_str = {''};
end


if ~iscell(status_str)
    status_str = {status_str};
end

if ~add
    
    currentLength = min([maxLength, length(status_str)]);
    currentLength = max(2, currentLength);
    
    status_str(2:currentLength) = status_str(1:currentLength-1);
    status_str{1} = sprintf('<html><font color="%s">- %s', color, str);
    
else
    oldString = status_str{1};
    
    if nonHtmlLongerThanLimit(oldString, lineLimit)
        oldString = '<html>';
    end
    status_str{1} = sprintf('%s <font color="%s">%s', oldString , color, str);
end

try
    set(handles.uicontrols.listbox.listbox_status, 'String',status_str, 'Value', 1);
    drawnow;
catch err
    warning(err.message)
end

end

function boolean = nonHtmlLongerThanLimit(str, limit)
nonHTMLstr = regexprep(str, '<.*?>', '');
boolean = length(nonHTMLstr) > limit;
end