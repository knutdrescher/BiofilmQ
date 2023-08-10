function img_cropped = normalizeIntensities(img_cropped, I, x, z_max, removeFirstPart)
%% Normalize the Intensity based on the mean -> mean(im_values(length(im_values)-cellSize:end))
fprintf(' - normalize intensities');
ticValue = displayTime;

%Remove everything before the intensity maximum
if removeFirstPart
    [~, maxIntDisp] = max(I);
    I(end) = I(maxIntDisp)/2;
    x = x(maxIntDisp:z_max);
    I = I(maxIntDisp:z_max);
end

[fitresult, gof] = fitIntensity(x, I);

parfor i = 1:size(img_cropped,3)
    img_cropped(:,:,i) = img_cropped(:,:,i)/fitresult(i);
end
displayTime(ticValue);