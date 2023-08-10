try
    Track_IDs = [handles.data.objects.stats.Track_ID];
    nColors = max(Track_IDs);
catch
    nColors = handles.data.objects.NumObjects;
end
    
displayStatus(handles, ['Creating colormap with ',num2str(nColors),' entries...'], 'black');


fid = fopen(fullfile(handles.settings.directory, 'data', ['cmap_N',num2str(nColors),'.json']),'wt');

str = '[\n{\n"ColorSpace" : "HSV",\n"Name" : "Preset 2",\n';

str = [str, '"RGBPoints" : ['];

prompt = {'Enter ID of cells to be highlighted (enter "rand" for random colors)'};
dlg_title = 'Colormap parameters';
num_lines = 1;
defaultans = {'rand'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if ~isempty(answer)
    if strcmp(answer{1}, 'rand')
        for i = 1:nColors
            str = [str, ' ', num2str(i), ', ', num2str(rand), ', ', '0', ', ', '0', ','];
        end
        
    else
        defaultColor = [0.9 0.9 0.9];
        entries = str2num(answer{1});
        colors = colormap(lines(numel(entries)));
        
        count = 1;
        for i = 1:nColors
            if sum(find(entries == i))
                str = [str, ' ', num2str(i), ', ', num2str(colors(count, 1)), ', ', num2str(colors(count, 2)), ', ', num2str(colors(count, 3)), ','];
                count = count + 1;
            else
                str = [str, ' ', num2str(i), ', ', num2str(defaultColor(1)), ', ', num2str(defaultColor(2)), ', ', num2str(defaultColor(3)), ','];
            end
        end
    end
    
    
    str(end) = '';
    str = [str, ' ]\n}\n]'];
    
    fprintf(fid, str);
    fclose(fid);
    
    
    displayStatus(handles, 'Done', 'black', 'add');
else
    displayStatus(handles, 'Canceled', 'black', 'add');
end
