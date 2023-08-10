function e = zeroCrossings2D(imLoG, findAllNodes)
if nargin == 1
    findAllNodes = 0;
end
fprintf('      finding zero-crossings');
textprogressbar('      ');
ticValue = displayTime;

% Transform to a double precision intensity image if necessary
if ~isa(imLoG,'double') && ~isa(imLoG,'single')
    imLoG = im2single(imLoG);
end

[m,n] = size(imLoG);


% The output edge map:
e = false(m-2,n-2);

rr = 2:m-1; cc=2:n-1;

% Look for the zero crossings:  +-, -+ and their transposes
% We arbitrarily choose the edge to be the negative point

%x-direction
%disp(' - along x (- -> +)');
ind = find( imLoG(rr,cc) < 0 & imLoG(rr,cc+1) > 0);% ...
e(ind) = 1;
textprogressbar(1/6*100);

%disp(' - along x (+ -> -)');
ind = find( imLoG(rr,cc-1) > 0 & imLoG(rr,cc) < 0);% ...
e(ind) = 1;
textprogressbar(2/6*100);

%y-direction
%disp(' - along y (- -> +)');
ind = find( imLoG(rr,cc) < 0 & imLoG(rr+1,cc) > 0);% ...
e(ind) = 1;
textprogressbar(4/6*100);

%disp(' - along y (+ -> -)');
ind = find( imLoG(rr-1,cc) > 0 & imLoG(rr,cc) < 0);% ...

e(ind) = 1;
textprogressbar(6/6*100);

if ~findAllNodes
    disp(' - along x (- -> 0 -> +)');
    ind = find( imLoG(rr,cc-1) < 0 & imLoG(rr,cc) == 0 & imLoG(rr,cc+1) > 0);% ...
    e(ind) = 1;
    disp(['      ', num2str(length(ind)), ' crossings']);
    toc
    
    disp(' - along x (+ -> 0 -> -)');
    ind = find( imLoG(rr,cc-1) > 0 & imLoG(rr,cc) == 0 & imLoG(rr,cc+1) < 0);% ...
    e(ind) = 1;
    disp(['      ', num2str(length(ind)), ' crossings']);
    toc
    
    disp(' - along y (- -> 0 -> +)');
    ind = find( imLoG(rr-1,cc) < 0 & imLoG(rr,cc) == 0 & imLoG(rr+1,cc) > 0);% ...
    e(ind) = 1;
    disp(['      ', num2str(length(ind)), ' crossings']);
    toc
    
    disp(' - along y (+ -> 0 -> -)');
    ind = find( imLoG(rr-1,cc) > 0 & imLoG(rr,cc,zz) == 0 & imLoG(rr+1,cc) < 0);% ...
    e(ind) = 1;
    disp(['      ', num2str(length(ind)), ' crossings']);
    toc
end

textprogressbar(' Done.');
displayTime(ticValue);
