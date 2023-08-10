function [objects, img_noBG, img_corr] = calculateMeanIntensityPerObjectShell(objects, img, ch_task, background, range, img_noBG, img_corr)

objects_shells = calculateObjectShells(objects, range);

% check if data is avaiable
if isempty(img_noBG{ch_task})
    % Remove background
    img_noBG{ch_task} = img{ch_task}-background(ch_task);
    img_noBG{ch_task}(img_noBG{ch_task}<0) = 0;
end

% if isempty(img_corr{ch_task})
%     % Obtain background
%     try
%         img_noBG_corr = img{ch_task}-background(ch_task);
%         [maxInt, maxInd] = max(img_noBG_corr(:));
%         
%         cellSize = 1000;
%         I = zeros(1, size(img_noBG_corr, 3));
%         z = 1:numel(I);
%         parfor i=1:size(img_noBG_corr, 3)
%             img_temp = img_noBG_corr(:,:,i);
%             im_values = sort(img_temp(:));
%             I(i) = mean(im_values(end-cellSize:end));
%         end
%         img_corr{ch_task} = normalizeIntensities(img_noBG_corr, I, z, max(z), 1);
%         
%         img_corr{ch_task} = img_corr{ch_task}/img_corr{ch_task}(maxInd);
%         img_corr{ch_task} = img_corr{ch_task}*maxInt+background(ch_task);
%     catch err
%         warning(err.message);
%     end
% end

stats_temp_shell = regionprops(objects_shells, img{ch_task}, 'MeanIntensity');
stats_temp_shell = num2cell([stats_temp_shell.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Shells_Mean_ch%d_range%d', ch_task, range))] = stats_temp_shell{:};

% if ~isempty(img_corr{ch_task})
%     stats_temp_shell = regionprops(objects_shells, img_corr{ch_task}, 'MeanIntensity');
%     stats_temp_shell = num2cell([stats_temp_shell.MeanIntensity]);
%     [objects.stats.(sprintf('Intensity_Shells_Mean_zcorrected_ch%d_range%d', ch_task, range))] = stats_temp_shell{:};
% end

stats_temp_shell = regionprops(objects_shells, img_noBG{ch_task}, 'MeanIntensity');
stats_temp_shell = num2cell([stats_temp_shell.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Shells_Mean_noBackground_ch%d_range%d', ch_task, range))] = stats_temp_shell{:};


end