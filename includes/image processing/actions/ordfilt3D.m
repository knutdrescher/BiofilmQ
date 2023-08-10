function [Vr] = ordfilt3D(V0,ord,padoption, silent)
% ordfilt3D:    Perform 3-D order-statistic filtering on 26 neighbors
%
%   [Vr] = ordfilt3D(V0,ord,padoption)
%          use 26 neighbors
%       ord = 14 <=> median filtering
%       ord = 1 <=> min
%       ord = [1 27] <=> [min max]
%       padoption: same as in padarray
%
% Olivier Salvado, Case Western Reserve University, 16Aug04

if nargin < 3
    silent = 0;
end

if ~exist('padoption','var')
    padoption = 'replicate';
end

if ~silent
    textprogressbar('      ');
    textprogressbar(10);
end
%%
% special care for uint8
if isa(V0,'uint8')
    V = uint8(padarray(V0,[1 1 1],padoption));
    S = size(V);
    Vn = uint8(zeros(S(1),S(2),S(3),26));  % all the neighbor
else
    V = logical(padarray(V0,[1 1 1],padoption));
    S = size(V);
    Vn = false(S(1),S(2),S(3),26);  % all the neighbor
end

%%
% build the neighboord
Vn(:,:,:,1) = V;
if ~silent
    textprogressbar(20);
end
i = 1:S(1); ip1 = [i(2:end) i(end)]; im1 = [i(1) i(1:end-1)];
if ~silent
    textprogressbar(30);
end
j = 1:S(2); jp1 = [j(2:end) j(end)]; jm1 = [j(1) j(1:end-1)];
if ~silent
    textprogressbar(40);
end
k = 1:S(3); kp1 = [k(2:end) k(end)]; km1 = [k(1) k(1:end-1)];
if ~silent
    textprogressbar(50);
end
%%
% left
Vn(:,:,:,2)     = V(im1    ,jm1    ,km1);
Vn(:,:,:,3)     = V(im1    ,j      ,km1);
Vn(:,:,:,4)     = V(im1    ,jp1    ,km1);

Vn(:,:,:,5)     = V(im1    ,jm1    ,k);
Vn(:,:,:,6)     = V(im1    ,j      ,k);
Vn(:,:,:,7)     = V(im1    ,jp1    ,k);

Vn(:,:,:,8)     = V(im1    ,jm1    ,kp1);
Vn(:,:,:,9)     = V(im1    ,j      ,kp1);
Vn(:,:,:,10)    = V(im1    ,jp1    ,kp1);

if ~silent
    textprogressbar(60);
end
%%
% right
Vn(:,:,:,11)    = V(ip1    ,jm1    ,km1);
Vn(:,:,:,12)    = V(ip1    ,j      ,km1);
Vn(:,:,:,13)    = V(ip1    ,jp1    ,km1);

Vn(:,:,:,14)    = V(ip1    ,jm1    ,k);
Vn(:,:,:,15)    = V(ip1    ,j      ,k);
Vn(:,:,:,16)    = V(ip1    ,jp1    ,k);

Vn(:,:,:,17)    = V(ip1    ,jm1    ,kp1);
Vn(:,:,:,18)    = V(ip1    ,j      ,kp1);
Vn(:,:,:,19)    = V(ip1    ,jp1    ,kp1);

if ~silent
    textprogressbar(70);
end
%%
% top
Vn(:,:,:,20)    = V(i       ,jm1    ,kp1);
Vn(:,:,:,21)    = V(i       ,j      ,kp1);
Vn(:,:,:,22)    = V(i       ,jp1    ,kp1);

if ~silent
    textprogressbar(80);
end
%%
% bottom
Vn(:,:,:,23)    = V(i       ,jm1    ,km1);
Vn(:,:,:,24)    = V(i       ,j      ,km1);
Vn(:,:,:,25)    = V(i       ,jp1    ,km1);

if ~silent
    textprogressbar(90);
end
%%
% front
Vn(:,:,:,26)    = V(i       ,jp1    ,k);

%%
% back
Vn(:,:,:,27)    = V(i       ,jm1    ,k);

%%
% perform the processing
Vn = sort(Vn,4);
if ~silent
    textprogressbar(95);
end
Vr = Vn(:,:,:,ord);


%%
% remove padding on the 3 first dimensions
Vr = Vr(2:end-1,2:end-1,2:end-1,:);
if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
end


