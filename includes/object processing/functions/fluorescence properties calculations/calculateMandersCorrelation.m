function [objects, obj] = calculateMandersCorrelation(objects, img, ch_task, opts, task, handles, filename, obj, range, params)
fprintf(' - determining Manders''s correlation coefficient');

switch opts{task,7}
    case 0
        fprintf(' (per cell)');
        N = objects.NumObjects;
        % Calculate correlation for unsmoothed and smoothed images
        
        % size = 40px;
        s = round(range*(params.scaling_dxy/1000));
        fprintf(' - range corresponds to: %.2f um\n', s);
        
        [sX, sY, sZ] = size(img{ch_task(1)});
        
        M = zeros(N, 1);
        m1 = zeros(N, 1);
        m2 = zeros(N, 1);
        
        img1 = img{ch_task(1)};
        img2 = img{ch_task(2)};
        
        filename_ch1 = fullfile(handles.settings.directory, 'data', [filename(1:end-4), '_data.mat']);
        filename_ch2 = strrep(filename_ch1, sprintf('_ch%d', ch_task(1)), sprintf('_ch%d', ch_task(2)));
        
        if isempty(obj{ch_task(1)})
            obj{ch_task(1)} = loadObjects(filename_ch1);
        end
        if isempty(obj{ch_task(2)})
            obj{ch_task(2)} = loadObjects(filename_ch2);
        end
        
        img1(labelmatrix(obj{ch_task(1)})==0) = 0;
        img2(labelmatrix(obj{ch_task(2)})==0) = 0;

        centroids = [objects.stats.Centroid];
        
        centroids_floor = floor(centroids - range/2);
        centroids_ceil = ceil(centroids + range/2-1);
        
        bound_x = [centroids_floor(2:3:end); centroids_ceil(2:3:end)];
        bound_y = [centroids_floor(1:3:end); centroids_ceil(1:3:end)];
        bound_z = [centroids_floor(3:3:end); centroids_ceil(3:3:end)];
        
        bound_x(bound_x<1) = 1;
        bound_y(bound_y<1) = 1;
        bound_z(bound_z<1) = 1;
        bound_x(bound_x>sX) = sX;
        bound_y(bound_y>sY) = sY;
        bound_z(bound_z>sZ) = sZ;        
        
        
        for c = 1:N
            im1 = img1(bound_x(1,c):bound_x(2,c), bound_y(1,c):bound_y(2,c), bound_z(1,c):bound_z(2,c));
            im2 = img2(bound_x(1,c):bound_x(2,c), bound_y(1,c):bound_y(2,c), bound_z(1,c):bound_z(2,c));

            
            M(c) = manders_overlapp_coeff(im1, im2);
            [m1(c), m2(c)] = manders_split_coloc_coeff(im1, im2);
        end
        
        M = num2cell(M);
        [objects.stats.(strrep(sprintf('Correlation_Manders_ch%d_ch%d_range%d', ch_task(1), ch_task(2), range), '.', '_'))] = M{:};
        m1 = num2cell(m1);
        [objects.stats.(strrep(sprintf('Correlation_MandersSplit_ch%d_ch%d_range%d', ch_task(1), ch_task(2), range), '.', '_'))] = m1{:};
        m2 = num2cell(m2);
        [objects.stats.(strrep(sprintf('Correlation_MandersSplit_ch%d_ch%d_range%d', ch_task(2), ch_task(1), range), '.', '_'))] = m2{:};
        
    case 1
        fprintf(' (per stack)\n');
        
        img1 = img{ch_task(1)};
        img2 = img{ch_task(2)};
        
        filename_ch1 = fullfile(handles.settings.directory, 'data', [filename(1:end-4), '_data.mat']);
        filename_ch2 = strrep(filename_ch1, sprintf('_ch%d', ch_task(1)), sprintf('_ch%d', ch_task(2)));
        
        if isempty(obj{ch_task(1)})
            obj{ch_task(1)} = loadObjects(filename_ch1);
        end
        if isempty(obj{ch_task(2)})
            obj{ch_task(2)} = loadObjects(filename_ch2);
        end
        
        img1(labelmatrix(obj{ch_task(1)})==0) = 0;
        img2(labelmatrix(obj{ch_task(2)})==0) = 0;
        
        M = manders_overlapp_coeff(img1, img2);
        [m1, m2] = manders_split_coloc_coeff(img1, img2);
        
        objects.globalMeasurements.(sprintf('Biofilm_Correlation_Manders_ch%d_ch%d', ch_task(1), ch_task(2))) = M;
        objects.globalMeasurements.(sprintf('Biofilm_Correlation_MandersSplit_ch%d_ch%d', ch_task(1), ch_task(2))) = m1;
        objects.globalMeasurements.(sprintf('Biofilm_Correlation_MandersSplit_ch%d_ch%d', ch_task(2), ch_task(1))) = m2;
end

end