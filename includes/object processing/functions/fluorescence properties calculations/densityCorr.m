function dC=densityCorr(ch1, ch2)

sum1 = sum(ch1(:));
sum2 = sum(ch2(:));

dC = sum1*sum2/(numel(ch1(:))^2);