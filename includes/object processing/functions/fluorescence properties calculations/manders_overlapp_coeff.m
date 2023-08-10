function R=manders_overlapp_coeff(ch1, ch2)

numerator = sum(ch1(:).*ch2(:));
denominator = sqrt(sum(sum(sum(ch1.^2))).*sum(sum(sum(ch2.^2))));

R = numerator/denominator;