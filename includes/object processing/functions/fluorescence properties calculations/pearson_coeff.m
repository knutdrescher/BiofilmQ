function Rr=pearson_coeff(ch1, ch2)

mean1 = mean(ch1(:));
mean2 = mean(ch2(:));

numerator = sum(sum(sum((ch1-mean1).*(ch2-mean2))));
denominator = sqrt(sum(sum(sum(power((ch1-mean1),2)))).*sum(sum(sum(power((ch2-mean2),2)))));

Rr = numerator/denominator;