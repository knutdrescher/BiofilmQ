function [C, M] = scatImage(x, y, varargin)

Nbins = checkInput(varargin, 'Nbins', 20);
xLimits = checkInput(varargin, 'xlim', [min(x), max(x)]);
yLimits = checkInput(varargin, 'ylim', [min(y), max(y)]);
xScale = checkInput(varargin, 'xScale', 'linear');
yScale = checkInput(varargin, 'yScale', 'linear');
smoothFactor = checkInput(varargin, 'smoothFactor', 15);
plotContourLines = checkInput(varargin, 'plotContourLines', true);

if strcmp(xScale, 'linear')
    Nx = linspace(xLimits(1),xLimits(2),Nbins);
else
    if xLimits(1) == 0
        xLimits(1) = min(x(x>0));
        warning('backtrace', 'off')
        warning('Negative x-values are ignored.');
        warning('backtrace', 'on')
    end
    
    Nx = logspace(log10(xLimits(1)),log10(xLimits(2)),Nbins);
end

if strcmp(yScale, 'linear')
    Ny = linspace(yLimits(1),yLimits(2),Nbins);
else
    if yLimits(1) == 0
        yLimits(1) = min(y(y>0));
        warning('backtrace', 'off')
        warning('Negative y-values are ignored.');
        warning('backtrace', 'on')
    end
    
    Ny = logspace(log10(yLimits(1)),log10(yLimits(2)),Nbins);
end

scat_im  = hist2(x, y, Nx, Ny);

scat_im = imresize(scat_im, 4);

G = fspecial('gaussian',[smoothFactor smoothFactor],2);
scat_im = imfilter(scat_im,G,'same');

C = zeros(1, numel(x));


if strcmp(xScale, 'linear')
    xC = round((x-xLimits(1))/(xLimits(2)-xLimits(1))*Nbins*4);
else
    xC = round((log10(x/xLimits(1)))/(log10(xLimits(2)/xLimits(1)))*Nbins*4);
end

if strcmp(yScale, 'linear')
    yC = round((y-yLimits(1))/(yLimits(2)-yLimits(1))*Nbins*4);
else
    yC = round((log10(y/yLimits(1)))/(log10(yLimits(2)/yLimits(1)))*Nbins*4);
end

isValid = xC > 0 & yC > 0 & ...
          ~isinf(xC) & ~isinf(yC) & ...
          xC <= size(scat_im, 1) & yC <= size(scat_im, 2);

C(isValid) = scat_im(sub2ind(size(scat_im), xC(isValid), yC(isValid)));


if plotContourLines
    [~, M] = contour(scat_im', 10, 'EdgeColor', 'black');
    if strcmp(xScale, 'linear')
        M.XData = M.XData*(xLimits(2)-xLimits(1))/(4*Nbins) + xLimits(1);
    else
        M.XData = 10.^(M.XData*log10(xLimits(2)/xLimits(1))/(4*Nbins) + log10(xLimits(1)));
        set(gca, 'XScale', 'log')
    end
    
    if strcmp(yScale, 'linear')
        M.YData = M.YData*(yLimits(2)-yLimits(1))/(4*Nbins) + yLimits(1);
    else
        M.YData = 10.^(M.YData*log10(yLimits(2)/yLimits(1))/(4*Nbins) + log10(yLimits(1)));
    end
end


