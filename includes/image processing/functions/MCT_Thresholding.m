function tv = MCT_Thresholding(inputimage)
% MCT is an algorithm written by Krishnan Padmanabhan in the lab of Justin Crowley at 
% Carnegie Mellon University and was developed in 2007.  
%For help, please contact kpadmana@andrew.cmu.edu.  

% This is a stripped down version for 1D uint16 arrays from
% https://ars.els-cdn.com/content/image/1-s2.0-S0165027010004917-mmc2.zip

minVal = min(inputimage);
maxVal = max(inputimage);

inputimage = 255*(inputimage - minVal)/(maxVal - minVal);

i = uint8(inputimage);

bd = 0:255; 
i = reshape(i,1, numel(i)); 

[hi, ~] = histcounts(i, 0:256);

m = sum(hi.*bd)/sum(hi); 

nm = sum(hi); 

nbd = bd - m; 
selfcc =  ((nbd.*nbd)*hi'); 


fbe = zeros(1,256); 
for jj = 2:256 
    beuh = zeros(1,256);
    beuh(1,jj:end) = hi(1,jj:end); 
    benh = 0:255;
    benh = benh - m; 

    nju = sum( hi(1,1:jj-1));


    fbe(1,jj-1) = (beuh*benh')/sqrt(selfcc*(((nm-nju)*(nju))/nm));
    fbe(isinf(fbe))=0;


end 
[~, bep] = max(fbe(end:-1:1));
tv = length(fbe)-bep; 
tv = tv*(maxVal - minVal)/255 + minVal;

%tv = tv/(2^8)*2^16;


        
    
    


    
    
    
    
    
    
    
    
    



