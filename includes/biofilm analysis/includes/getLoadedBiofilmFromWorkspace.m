function biofilmData = getLoadedBiofilmFromWorkspace

try
    biofilmData = evalin('base', 'biofilmData');
catch
    uiwait(msgbox('Variable "biofilmData" could not be found in the current workspace. Please reload the biofilm data from files.', 'Warning', 'warn', 'modal'))
    biofilmData = [];
end
