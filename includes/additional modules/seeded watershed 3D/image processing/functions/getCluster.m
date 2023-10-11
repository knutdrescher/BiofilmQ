function cluster = getCluster(dist, testfun)
    d = squareform(dist);
    cluster = ones(size(d, 1), 1)*(-1);

    % Check for each row whether it is connected to a previously
    % investigated maxima (columns)
    for i = 1:size(d, 1) 
        for j = 1:i-1
            if testfun(i, j, d)
                cluster(i) = cluster(j);
                break
            end
        end
         % If row has still the default value it is not connected to
         % another maxima
        if cluster(i) == -1
            cluster(i) = i;
        end
    end
end