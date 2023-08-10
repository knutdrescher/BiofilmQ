function threshold = robustBackground(img)
    
    % Remove lowest 5% and highest 5% of values
    sorted = sort(img(:));
    d = round(length(sorted)/20);
    capped = sorted(d+1:end-d);

    % fit gaussian
    pd = fitdist(capped,'Normal');
    threshold = pd.mu + 2*pd.sigma;

end

