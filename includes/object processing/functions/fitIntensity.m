function [fitresult, gof] = fitIntensity(x_new, I_new)

[xData, yData] = prepareCurveData( x_new, I_new );

% Set up fittype and options.
ft = fittype( 'exp2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [-0.454840002663848 0.0470871403604514 29760.9312066629 -0.0294159930942494];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );



