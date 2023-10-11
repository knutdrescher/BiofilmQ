function [m1, m2]=manders_split_coloc_coeff(ch1, ch2)

numerator1 = ch1(:).*(ch2(:)>0);
numerator2 = ch2(:).*(ch1(:)>0);

numerator1 = sum(numerator1(:));
numerator2 = sum(numerator2(:));

denominator1 = sum(ch1(:));
denominator2 = sum(ch2(:));

if denominator1
    m1 = numerator1/denominator1;
else
    m1 = 0;
end
if denominator2
    m2 = numerator2/denominator2;
else
    m2 = 0;
end

