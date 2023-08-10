    function dist2 = distance_drop(p1, p2, imgfilter_, max_dist, dis)
    fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
    
    dist = fhypot(p1(1)-p2(:, 1), p1(2)-p2(:, 2), p1(3)-p2(:,3));
  

%     [~,order] = sort(dist);
%     if length(order)>2
%         max_dist = dist(order(3));
%     else
%         max_dist = dist(order);
%     end
        
    cond = (dist > max_dist) | (dist == 0);
    
    idcs = find(~cond);
    
    dist2 = nan(size(dist));
    
    for i_ = 1:numel(idcs)
        
        i = idcs(i_);
        
        [cx, cy, cz] = Bresenham3D(p1(1), p1(2), p1(3), p2(i, 1), p2(i, 2), p2(i, 3));
        
        profile = imgfilter_(sub2ind(size(imgfilter_), cx, cy, cz));
        
        if any(profile == 0) % crosses forbidden area
            dist2(i) = -Inf;
        else

            l = linspace(double(profile(1)), double(profile(end)), numel(profile));
            profile_ = (double(profile)-l)./l;
            if dis
                dist2(i) = min(profile_);
            else
                dist2(i) = min(profile);
            end
        end
    end
    
    
%     dist2( dist2 > 0) = 0;
%     dist2 =  abs(dist2);
%     dist2 = dist2 - min(dist2);
%     dist2 = dist2 / max(dist2) * max_dist;
%     dist = dist + dist2;
%        
%     dist(cond) = nan;
    
    end

            