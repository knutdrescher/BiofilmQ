function threshold = getBEM_threshold(image, params)

minVal = prctile(image(:),0.001);
maxVal = prctile(image(:),99.999);

thresholdSensitivity = params.thresholdSensitivity;
slopeThresh = thresholdSensitivity^2;

% Calculate biovolume(threshold) function
bv = zeros(256,1);
thresh = linspace(minVal, maxVal, 256); 
tic;
for j = 1:256
   bv(j) = sum(image(:)> thresh(j)); 
end 
toc;

try
    % fit curve
    ft = fittype('a*x^b+c');
    fittedCurve = fit(thresh', bv, ft, 'Startpoint', [3.2*10^6, -0.15, -1.3*10^6]);
    a = fittedCurve.a;
    b = fittedCurve.b;

    range = maxVal-minVal;
    dt = range/255;

    % func describes derivative
    func = @(x) b*a*x^(b-1);
    c = 1;
    val = (func(thresh(c)+dt)-func(thresh(c)))/func(thresh(c));
    
    % find value for which an increase in threshold changes the slope only
    % by slopeThresh or less
    while abs(val)>slopeThresh && c<255
        c = c+1;
        val = (func(thresh(c)+dt)-func(thresh(c)))/func(thresh(c));
    end

catch exception
    % If the fit fails, do a numeric slope determination
    fprintf('\n Warning: Fitting during BEM threshold determination failed. Using numerical approximations instead.');
    range = maxVal-minVal;
    dt = range/255;
    val = (deriv(bv, 2, dt)- deriv(bv, 1, dt))/deriv(bv, 1, dt);
    c = 1;
    while abs(val)>slopeThresh && c<255
        c = c+1;
        val = (deriv(bv, c+1, dt)- deriv(bv, c, dt))/deriv(bv, c, dt);
    end 
end

if c == 255
    msgbox('Thresholding by BEM did not converge. Please use another algorithm or determine the threshold manually.', 'Warning', 'warn');
end

threshold = thresh(c)
disp(c);

    function d = deriv(f, index, delta)
        if index == 1 
            d = (f(index+1)-f(index))/delta;
        elseif index ==length(f)
            d = (f(index)-f(index-1))/delta;
        else
            d = (f(index+1)-2*f(index)-f(index-1))/(2*delta);
        end
    end
end

