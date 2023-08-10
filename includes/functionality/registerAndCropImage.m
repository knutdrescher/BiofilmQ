function imgfilter = registerAndCropImage(imgfilter, params, metadata)


% Image registration
if params.imageRegistration
    try
        if size(imgfilter, 3) == 1
            imgfilter = performImageAlignment2D(imgfilter, metadata, method, 1);
        else
            imgfilter = performImageAlignment3D(imgfilter, metadata, method, 1);
        end
    catch
        disp(['Image is not registered!']);
        uiwait(msgbox(' - WARNING: Image is not registered! Cannot continue.', 'Error', 'error', 'modal'));
        displayStatus(handles, 'Processing cancelled!', 'red');
        return;
    end
end

% Image cropping
if ~isempty(params.cropRange)
    params.cropRangeAfterRegistration = params.cropRange;
    
    if params.imageRegistration
        correctCropRange = 0;
        
        params.cropRangeAfterRegistration(1:2) = params.cropRange(1:2);
        
        % Make sure that cropped image does not move outside the reference
        % frame
        if params.fixedOutputSize
            if params.cropRangeAfterRegistration(1) < params.registrationReferenceCropping(1)
                params.cropRangeAfterRegistration(1) = params.registrationReferenceCropping(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) < params.registrationReferenceCropping(2)
                params.cropRangeAfterRegistration(2) = params.registrationReferenceCropping(2);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(1) + params.cropRange(3) > params.registrationReferenceCropping(1) + params.registrationReferenceCropping(3)
                params.cropRangeAfterRegistration(3) = params.registrationReferenceCropping(1)+params.registrationReferenceCropping(3)-params.cropRange(1);
                correctCropRange = 1;
            end
            if params.cropRangeAfterRegistration(2) + params.cropRange(4) > params.registrationReferenceCropping(2) + params.registrationReferenceCropping(4)
                params.cropRangeAfterRegistration(4) = params.registrationReferenceCropping(2)+params.registrationReferenceCropping(4)-params.cropRange(2);
                correctCropRange = 1;
            end
        end
       
        if params.cropRange(3)+params.cropRangeAfterRegistration(1) > size(imgfilter,2)
            params.cropRangeAfterRegistration(3) = size(imgfilter,1)-params.cropRangeAfterRegistration(1);
            correctCropRange = 1;
        end
        
        if params.cropRange(4)+params.cropRangeAfterRegistration(2) > size(imgfilter,1)
            params.cropRangeAfterRegistration(4) = size(imgfilter,1)-params.cropRangeAfterRegistration(2);
            correctCropRange = 1;
        end
        
        if correctCropRange
            fprintf(' -> WARNING: crop range was confined by image border or crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        end
    else
        
    end
    
    imgfilter = imgfilter(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
        params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
else
    if params.imageRegistration && params.fixedOutputSize && ~isempty(params.registrationReferenceCropping)
        params.cropRange = params.registrationReferenceCropping;
        params.cropRangeAfterRegistration = params.cropRange;
        fprintf(' -> WARNING: crop range was confined by crop range of reference frame to [%d %d %d %d]\n',  params.cropRangeAfterRegistration)
        
        imgfilter = imgfilter(params.cropRangeAfterRegistration(2):params.cropRangeAfterRegistration(2)+params.cropRangeAfterRegistration(4), ...
            params.cropRangeAfterRegistration(1):params.cropRangeAfterRegistration(1)+params.cropRangeAfterRegistration(3),:);
    end
end

end

