function  I_base = determineBackground(hObject, eventdata, handles, params, lastSlice)
disp('== Extracting background ==');
h = 0;
if nargin == 3
    %% Load last file to extract background
    h = waitbar(0.1, 'Extracting background', 'Name', 'Please wait');
    file = handles.settings.selectedFile;

    try
        NSlices = str2num(handles.settings.lists.files_tif(file).name(strfind(handles.settings.lists.files_tif(file).name, 'Nz')+2:strfind(handles.settings.lists.files_tif(file).name, '.tif')-1));
        displayStatus(handles, ['Extracting background of the last image (',handles.settings.lists.files_tif(file).name,')'], 'black');
        lastSlice = imread(fullfile(handles.settings.directory, handles.settings.lists.files_tif(file).name), NSlices);
    catch
        displayStatus(handles, ['Extracting background of the first image (',handles.settings.lists.files_tif(file).name,')'], 'black');
        lastSlice = imread(fullfile(handles.settings.directory, handles.settings.lists.files_tif(file).name), 1);
    end
    
    params = load(fullfile(handles.settings.directory, 'parameters.mat'));
    params = params.params;
else
    displayStatus(handles, 'Extracting background...', 'black');
end
    

%% Do either denoising or Rolling Ball (Top-hat filter)
if params.denoiseImages
    %% Smoothing by convolution
    lastSlice = convolveBySlice(lastSlice, params);
    if ishandle(h)
        try
         waitbar(0.3, h);
        end
    end
end
if params.topHatFiltering
    %% Rolling ball filtering (TopHat)
    lastSlice = topHatFilter(lastSlice, params);
    if ishandle(h)
        try
         waitbar(0.7, h);
        end
    end
end

im_values = sort(lastSlice(:));
%I_base = prctile(im_values,90);
I_base = round(10*mean(im_values(end-2000:end)))/10;

displayStatus(handles, [' -> Background: I=', num2str(I_base)], 'black', 'add');
set(handles.uicontrols.edit.I_base, 'String', num2str(I_base));

if ishandle(h)
    try
    waitbar(1, h);
    delete(h);
    end
end

