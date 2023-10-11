function convertedValue = convertToUm(handles,curVal,exponent)

        pxSize = str2double(handles.uicontrols.edit.scaling_dxy.String)/1000;
        
        if handles.uicontrols.checkbox.scaleUp.Value
            scaling = str2double(handles.uicontrols.edit.scaleFactor.String);
            pxSize = pxSize/scaling;
        end
        pxSize = pxSize^exponent;
        
        convertedValue = pxSize*curVal;
end

