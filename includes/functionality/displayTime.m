function ticValue = displayTime(ticValue)

if nargin == 0
    ticValue = tic;
else
    elapsedTime = toc(ticValue);
    fprintf(' ... %0.1fs\n', elapsedTime);
end