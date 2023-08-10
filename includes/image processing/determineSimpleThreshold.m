function [status, thresh] = determineSimpleThreshold(imgfilter, params)

status = 0;
ticValue = displayTime;

imgfilter(imgfilter<0) = 0;

fprintf(' - determine threshold')

% Apply gamma value
% params.gamma = round(params.gamma);
% imgfilter = imgfilter.^params.gamma;

% Remove completely black slices
validXSlices = squeeze(sum(sum(imgfilter, 2), 3))>0;
validYSlices = squeeze(sum(sum(imgfilter, 1), 3))>0;
validZSlices = squeeze(sum(sum(imgfilter, 1), 2))>0;

img_temp = imgfilter(validXSlices,validYSlices,validZSlices);

% Remove the 0.0001% brightest pixels
img_temp = sort(img_temp(:));
d = round(length(img_temp)/10000);
img_temp = img_temp(d:end-d);
switch params.thresholdingMethod

    case 1
        if params.thresholdClasses > 1
            thresh = multithresh(img_temp, 2);
        else
            thresh = multithresh(img_temp);
        end
        
        if params.thresholdClasses == 2
            thresh = thresh(1);
        end
        if params.thresholdClasses == 3
            thresh = thresh(2);
        end
        
        thresh = params.thresholdSensitivity*thresh;
    case 2
        
        thresh = params.thresholdSensitivity*isodata(img_temp);
        
    case 3
        thresh = MCT_Thresholding(img_temp(:));
        thresh = params.thresholdSensitivity*thresh;
    case 4
        thresh = params.thresholdSensitivity*robustBackground(img_temp);        
    case 5
        thresh = params.manualThreshold;
end

fprintf(', [t=%d]', round(thresh))


displayTime(ticValue);

status = 1;


end
