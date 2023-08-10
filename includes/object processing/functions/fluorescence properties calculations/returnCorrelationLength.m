function [x_half, y_half] = returnCorrelationLength(x, y)

if isnan(y)
    x_half = NaN;
    y_half = NaN;
    return;
end

try
    xInd = [find(y<y(1)/2, 1)-1 find(y<y(1)/2, 1)];

    % fit linear funcion
    a = (y(xInd(2))-y(xInd(1)))/(x(xInd(2))-x(xInd(1)));
    b = y(xInd(1)) - a*x(xInd(1));

    x_half = (y(1)/2-b)/a;
    y_half = a*x_half+b;
catch
    warning('backtrace', 'off');
    warning('Cannot find point of inflection of ACF');
    warning('backtrace', 'on');
    x_half = NaN;
    y_half = NaN;
end