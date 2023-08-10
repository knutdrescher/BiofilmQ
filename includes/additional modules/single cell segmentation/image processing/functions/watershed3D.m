function [segim, rootim, linkim] = watershed3D(inim)
ticValue = displayTime;
fprintf(' - step 3: watershedding');

textprogressbar('      ');

% define augmented input image to deal with border problems
% In principle: pad inim with max(inim) + 1 on the border
[Nx, Ny, Nz] = size(inim);
augim = zeros(Nx+2, Ny+2, Nz+2, class(inim))+(max(inim(:)) + 1);

% pre-allocating
x = 2:Nx+1;
y = 2:Ny+1;
z = 2:Nz+1;

augim(x, y, z) = inim;

% initialize minim and linkim
minim = inim;
linkim0 = uint32(reshape(1:Nx*Ny*Nz, size(inim))); % creates index matrix

linkim = linkim0;

% look for steepest path downward from each pixel
counter = 0;
for i = -1:1
    for j = -1:1
        for k = -1:1
            shiftim = augim(x+i, y+j, z+k);
            ind = find(shiftim < minim);
            ind(minim(ind) == 1) = [];
            if ~isempty(ind) 
                [u, v, w] = ind2sub([Nx Ny Nz], ind);
                minim(ind) = shiftim(ind);
                linkim(ind) = linkim0(sub2ind([Nx Ny Nz], u+i, v+j, w+k));
            end
            counter = counter + 1;
            textprogressbar(counter/30*100);
        end
    end
end
clear augim minim shiftim x y z u v w i j k counter

% propagate the links
newlink = linkim(linkim);
while any(newlink(:) ~= linkim(:))
    linkim = newlink;
    newlink = linkim(linkim);
end
clear newlink
textprogressbar(95);

% define roots
rootim = uint32(bwlabeln(linkim == linkim0));
clear linkim0

% perform the segmentation by assignin the value of the root to all the
% pixels linkiing to the root
segim = rootim(linkim);
textprogressbar(100);
textprogressbar(' Done.');
displayTime(ticValue);