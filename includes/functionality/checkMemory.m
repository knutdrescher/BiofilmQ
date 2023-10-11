function checkMemory(handles, memSize, displayOutput)
if nargin == 2
    displayOutput = 1;
end

flag1 = 1;
flag2 = 1;
[~, systemview] = memory;
count = 1;
waitForMoreMem = 1;
memAvailable = [];

% If to much memory is occupied wait
% If memory cosumption is increasing, also wait

try
    handles.uicontrols.pushbutton.pushbutton_cancel.String = 'Continue';
    handles.uicontrols.pushbutton.pushbutton_cancel.Callback = @(hObject,eventdata)BiofilmQ('pushbutton_cancel_Callback',hObject,eventdata,guidata(hObject), 1);
    drawnow;
end

cancel = 0;
while waitForMoreMem
    
    memAvailable(count) = systemview.PhysicalMemory.Available;
    
    if memAvailable(end)/1e9 < memSize
        if flag1
            if displayOutput
            fprintf('\n -> waiting for %dGB of memory to be available', memSize);
            end
            flag1 = 0;
            flag2 = 1;
        end
        
        startTime = tic;
        delay = rand*60;
        while toc < startTime + delay
            if checkCancelButton(handles, 'continue')
                cancel = 1;
                break;
            end
            pause(1);
        end
    end
    
    if count > 5
       if mean(diff(memAvailable(count-5:count))) <= 1000000 %1 MB
           waitForMoreMem = 0;
       else
           if flag2
               if displayOutput
               fprintf('\n -> memory consumption is increasing, checking');
               end
               flag2 = 0;
               flag1 = 1;
           end
       end
    end
    
    pause(0.01);
    count = count + 1;    
    [~, systemview] = memory;
    
    if checkCancelButton(handles, 'continue') || cancel
        flag1 = 1;
        flag2 = 0;
        break;
    end
end

% If program was paused because of not sufficient memory available, wait
% again to prevent two instances to start syncronized.
if ~flag1
    t = rand*60;
    pause(t)
    if displayOutput
    fprintf('... starting in %d s', round(t));
    end
elseif ~flag2
    if displayOutput
    fprintf('... continuing now');
    end
end

try
    handles.uicontrols.pushbutton.pushbutton_cancel.String = 'Cancel';
    handles.uicontrols.pushbutton.pushbutton_cancel.Callback = @(hObject,eventdata)BiofilmQ('pushbutton_cancel_Callback',hObject,eventdata,guidata(hObject));
    drawnow;
end