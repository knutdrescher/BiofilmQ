function objects = calculateUserDefinedParameter(handles, objects, params, scriptFilename, fileIndex, filename)

ticValue = displayTime;

run(scriptFilename)

displayTime(ticValue);