function e = perim3D(w)


% Transform to a double precision intensity image if necessary
if ~isa(w,'double') && ~isa(w,'single')
    w = double(w);
end

[m,n,o] = size(w);

%thresh = 0;

if o == 1
    % The output edge map:
    e = false(m-2,n-2,1);

    rr = 2:m-1; cc=2:n-1; zz=1;
else
    % The output edge map:
    e = false(m-2,n-2,o-2);

    rr = 2:m-1; cc=2:n-1; zz=2:o-1;
end

% (k-1)(d2)(d1)+(j-1)(d1)+i
% Look for the zero crossings:  +-, -+ and their transposes
% We arbitrarily choose the edge to be the negative point

%nm = n*m;
%x-direction
%disp('Finding outlines...');
%disp(' - along x (- -> +)');
ind = find( w(rr,cc,zz) > w(rr,cc+1,zz));% ...
% & abs( w(rr,cc,zz)-w(rr,cc+1,zz) ) > thresh );   % [- +]
%e = writeInd(e, rx, cx, zx);
e(ind) = 1;
%disp(['      ', num2str(length(ind)), ' steps']);


%disp(' - along x (+ -> -)');
ind = find( w(rr,cc-1,zz) < w(rr,cc,zz));% ...
%& abs( w(rr,cc-1,zz)-w(rr,cc,zz) ) > thresh );   % [+ -]
%e = writeInd(e, rx, cx, zx);
%e((rx+1) + cx*m) = 1;
e(ind) = 1;
%disp(['      ', num2str(length(ind)), ' steps']);


%y-direction
%disp(' - along y (- -> +)');
ind = find( w(rr,cc,zz) > w(rr+1,cc,zz));% ...
%& abs( w(rr,cc,zz)-w(rr+1,cc,zz) ) > thresh);   % [- +]'
%e = writeInd(e, rx, cx, zx);
%e((rx+1) + cx*m) = 1;
e(ind) = 1;
%disp(['      ', num2str(length(ind)), ' steps']);


%disp(' - along y (+ -> -)');
ind = find( w(rr-1,cc,zz) < w(rr,cc,zz));% ...
%& abs( w(rr-1,cc,zz)-w(rr,cc,zz) ) > thresh);   % [+ -]'
%e = writeInd(e, rx, cx, zx);
%e((rx+1) + cx*m) = 1;
e(ind) = 1;
%disp(['      ', num2str(length(ind)), ' steps']);


if numel(zz) > 1
    % z-direction
    %disp(' - along z (- -> +)');
    ind = find( w(rr,cc,zz) > w(rr,cc,zz+1));% ...
    %& abs( w(rr,cc,zz)-w(rr,cc,zz+1) ) > thresh);   % [- +]'
    %e = writeInd(e, rx, cx, zx);
    %e((rx+1) + cx*m) = 1;
    e(ind) = 1;
    %disp(['      ', num2str(length(ind)), ' steps']);
    
    
    %disp(' - along z (+ -> -)');
    ind = find( w(rr,cc,zz-1) < w(rr,cc,zz));% ...
    %& abs( w(rr,cc,zz-1)-w(rr,cc,zz) ) > thresh);   % [+ -]'
    %e = writeInd(e, rx, cx, zx);
    %e((rx+1) + cx*m) = 1;
    e(ind) = 1;
    %disp(['      ', num2str(length(ind)), ' steps']);
    
    e = padarray(e, [1 1 1], 0);
else
    e = padarray(e, [1 1], 0);
end
    




