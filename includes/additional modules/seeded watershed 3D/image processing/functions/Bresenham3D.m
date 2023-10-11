function [cx, cy, cz] = Bresenham3D(x1, y1, z1, x2, y2, z2)

% Adapted from https://gist.github.com/yamamushi/5823518:

    point = zeros(3, 1);

    point(1) = x1;
    point(2) = y1;
    point(3) = z1;
    dx = x2 - x1;
    dy = y2 - y1;
    dz = z2 - z1;
    x_inc = 1;
    if dx < 0
        x_inc = -1;
    end
    l = abs(dx);
    y_inc = 1;
    if (dy < 0)
        y_inc = -1;
    end
    m = abs(dy);
    z_inc = 1;
    if (dz < 0)
        z_inc = -1;
    end
    n = abs(dz);

    dx2 = l * 2;
    dy2 = m * 2;
    dz2 = n * 2;
    
    cx = zeros(1, max([abs(dx), abs(dy), abs(dz)]) + 1);
    cy = zeros(size(cx));
    cz = zeros(size(cx));

    j = 1;
    if ((l >= m) && (l >= n))
        err_1 = dy2 - l;
        err_2 = dz2 - l;
        for i = 0:l-1
            cx(j) = point(1);
            cy(j) = point(2);
            cz(j) = point(3);
            j = j + 1;
            if (err_1 > 0)
                point(2) = point(2) + y_inc;
                err_1 = err_1 - dx2;
            end
            if (err_2 > 0)
                point(3) = point(3) + z_inc;
                err_2 = err_2 - dx2;
            end
            err_1 = err_1 + dy2;
            err_2 = err_2 + dz2;
            point(1) = point(1) + x_inc;
        end
    elseif ((m >= l) && (m >= n))
        err_1 = dx2 - m;
        err_2 = dz2 - m;
        for i = 0:m-1
            cx(j) = point(1);
            cy(j) = point(2);
            cz(j) = point(3);
            j = j + 1;
            if (err_1 > 0)
                point(1) = point(1) + x_inc;
                err_1 = err_1 - dy2;
            end
            if (err_2 > 0)
                point(3) = point(3) + z_inc;
                err_2 = err_2 - dy2;
            end
            err_1 = err_1 + dx2;
            err_2 = err_2 + dz2;
            point(2) = point(2) + y_inc;
        end
    else
        err_1 = dy2 - n;
        err_2 = dx2 - n;
        for i = 0:n-1
            cx(j) = point(1);
            cy(j) = point(2);
            cz(j) = point(3);
            j = j + 1;
            if (err_1 > 0)
                point(2) = point(2) + y_inc;
                err_1 = err_1 - dz2;
            end
            if (err_2 > 0)
                point(1) = point(1) + x_inc;
                err_2 = err_2 - dz2;
            end
            err_1 =  err_1 + dy2;
            err_2 = err_2 + dx2;
            point(3) = point(3) + z_inc;
        end
    end
    
    cx(j) = point(1);
    cy(j) = point(2);
    cz(j) = point(3);

    
end