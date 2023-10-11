
function [docNode, changed] = addXMLElement(tag, attribute, name, docNode)
changed = 0;

properties = docNode.getElementsByTagName('Property');
for i = 0:properties.getLength-1
    propertyAttributes = properties.item(i).getAttributes;
    if strcmp(char(propertyAttributes.getNamedItem(attribute).getValue), name)
        
        % Add new entries
        newNode = docNode.createElement(tag);
        newNode.setAttribute('name', 'range')
        newNode.setAttribute('id', '5823.Origin.range')
        properties.item(i).appendChild(newNode);
        changed = 1;
    end
end
 

if ~changed
    fprintf('%s could not be set to %s [...] (element not found)\n', name, values{1});
end