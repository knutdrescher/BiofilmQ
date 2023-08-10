
function [docNode, changed] = changeXMLElementList(tag, attribute, name, values, docNode)
changed = 0;

properties = docNode.getElementsByTagName('Property');
for i = 0:properties.getLength-1
    propertyAttributes = properties.item(i).getAttributes;
    if strcmp(char(propertyAttributes.getNamedItem(attribute).getValue), name)
        % Remove all entries
        childNode = properties.item(i).getFirstChild;
        while ~isempty(childNode)
            oldNode = childNode;
            childNode = childNode.getNextSibling;
            properties.item(i).removeChild(oldNode);
        end
        
        % Add new entries
        for j = 1:numel(values)
            newNode = docNode.createElement(tag);
            newNode.setAttribute('index', num2str(j-1))
            newNode.setAttribute('value', values{j})
            properties.item(i).appendChild(newNode);
        end

        propertyAttributes.getNamedItem('number_of_elements').setValue(num2str(numel(values)));
        changed = 1;
    end
end
 

if ~changed
    fprintf('%s could not be set to %s [...] (element not found)\n', name, values{1});
end