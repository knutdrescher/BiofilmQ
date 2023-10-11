function [img, x, y] = applyReferencePadding(params,img)

    currentFrame = params.cropRangeAfterRegistration;
    refFrame = params.registrationReferenceCropping;
    
    if params.scaleUp
        scaleFactor = params.scaleFactor;
    else
        scaleFactor = 1;
    end
    
    % This is new: 
    startX = round((currentFrame(2)-refFrame(2)+1)*scaleFactor);
    startX = max(startX, 1);
    dX = size(img,1)-1;
    x = round(startX:startX+dX);
    startY = round((currentFrame(1)-refFrame(1)+1)*scaleFactor);
    startY = max(startY, 1);
    dY = size(img,2)-1;
    y = round(startY:startY+dY);
    
    refStack = zeros(round((refFrame(4)+1)*scaleFactor), round((refFrame(3)+1)*scaleFactor),  size(img, 3));
    refStack(x,y,:) = img;

    img = refStack;

end

