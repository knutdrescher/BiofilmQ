
function [docNode, changed] = changeXMLElement(tag, attribute, name, value, docNode)
changed = 0;

properties = docNode.getElementsByTagName('Property');
for i = 0:properties.getLength-1
    propertyAttributes = properties.item(i).getAttributes;
    if strcmp(char(propertyAttributes.getNamedItem(attribute).getValue), name)
        element = properties.item(i).getElementsByTagName(tag);
        elementAttributes = element.item(0).getAttributes;
        elementAttributes.getNamedItem('value').setValue(value)
        changed = 1;
    end
 end


if ~changed
    fprintf('%s could not be set to %s (element not found)\n', name, value);
end