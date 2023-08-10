function output = checkInput(inputArray, variable, defaultValue)

try
    output = inputArray{find(strcmp(inputArray, variable), 1)+1};
catch
    output = defaultValue;
end
