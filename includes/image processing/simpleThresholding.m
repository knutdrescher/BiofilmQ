function [status, imgfilter_edge_filled, thresh] = ...
    simpleThresholding(imgfilter, params, thresh)

status = 0;
ticValue = displayTime;

fprintf(' - thresholding image')

imgfilter_edge_filled = imgfilter>thresh;

status = 1;


end
