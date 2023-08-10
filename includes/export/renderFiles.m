function renderFiles(hObject, eventdata, handles)
disp(['=========== Rendering files in paraview ===========']);
ticValueAll = displayTime;

range = str2num(get(handles.uicontrols.edit.action_imageRange, 'String'));

% Load parameters
params = load(fullfile(handles.settings.directory, 'parameters.mat'));
params = params.params;

if params.reducePolygons
    resolution = params.reducePolygonsTo;
else
    resolution = 1;
end

files = handles.settings.lists.files_cells;
range_new = intersect(range, 1:numel(files));
if numel(range) ~= numel(range_new)
    fprintf('NOTE: Image range was adapted to [%d, %d]\n', min(range_new), max(range_new));
end
range = range_new;
      
pathParaview = handles.uicontrols.edit.renderParaview_path.String;
renderParameter = handles.uicontrols.popupmenu.renderParaview_parameter.String{handles.uicontrols.popupmenu.renderParaview_parameter.Value};
removeZOffset = handles.uicontrols.checkbox.renderParaview_removeZOffset.String;
makeRendering(objects, fullfile(handles.settings.directory, 'data', filenameVTK), pathParaview, renderParameter, removeZOffset);

if params.sendEmail
    email_to = get(handles.uicontrols.edit.email_to, 'String');
    email_from = get(handles.uicontrols.edit.email_from, 'String');
    email_smtp = get(handles.uicontrols.edit.email_smtp, 'String');
    
    setpref('Internet','E_mail',email_from);
    setpref('Internet','SMTP_Server',email_smtp);
    
    sendmail(email_to,['[Biofilm Toolbox] Cell visualization finished: "', handles.settings.directory, '"']', ...
        ['Cell visualization of "', handles.settings.directory, '" finished (Range: ', num2str(range(1)), ':', num2str(range(end)), ').', ]);
end

updateWaitbar(handles, 0);
fprintf('-> total elapsed time')
displayTime(ticValueAll);
