function [img_rotated, params] = rotateBiofilmImg(img, params, silent)
ticValue = displayTime;

if nargin <= 2
    silent = 0;
end

if ~silent
    fprintf(' - rotating image');
end

if ~isfield('params', 'slideRotationAngle')
    minMap = zeros(size(img, 1), size(img, 2));
    
    [~, brightestPlane] = max(sum(sum(img, 2), 1));
    
    t = multithresh(img(:,:,brightestPlane));
    img_t = img;
    img_t(img_t<t) = 0;
    
    for x = 1:size(img, 1)
        for y = 1:size(img, 2)
            [maxVal, idx] = max(img_t(x, y, :));
            
            if abs(brightestPlane - idx) < 5 && maxVal>0
                minMap(x, y) = idx;
            end
        end
    end
    minMap(~minMap) = NaN;
    X = 1:x;
    Y = 1:y;
    warning off;
    plane = fitPlane(X, Y, minMap);
    warning on;
    
    % Find 3 points on plane
    P = [0, 0, plane(0,0)];
    p1 = [0, 1000, plane(1000,0)-plane(0,0)];
    p2 = [1000, 0, plane(0,1000)-plane(0,0)];
    
    p1 = (p1)/norm(p1);
    p2 = (p2)/norm(p2);
    
    n = cross(p1, p2);
    n = n/norm(n);
    
    inters_line = cross(n, [0 0 1]);
    inters_line = inters_line/norm(inters_line);
    
    params.slideRotationAngle = atan2d(norm(cross(n,[0 0 1])),dot(n,[0 0 1]))-180;
end

if ~silent
    fprintf(', [angle_z=%.2f, vector=[%.2f %.2f %.2f]]', params.slideRotationAngle, inters_line(1), inters_line(2), inters_line(3));
end

img_rotated = imrotate3(img,params.slideRotationAngle,[inters_line(2) inters_line(1) inters_line(3)]);

if ~silent
    ticValue = displayTime(ticValue);
end
