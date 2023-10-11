function [objects, img_noBG] = calculateMeanIntensityPerObject(objects, img, ch_task, background, img_noBG)


% Obtain non-corrected intensity values
stats_MeanIntensity_temp{ch_task} = regionprops(objects, img{ch_task}, 'MeanIntensity');
stats_MeanIntensity_temp{ch_task} = num2cell([stats_MeanIntensity_temp{ch_task}.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Mean_ch%d', ch_task))] = stats_MeanIntensity_temp{ch_task}{:};

% Remove background
img_noBG{ch_task} = img{ch_task}-background(ch_task);
img_noBG{ch_task}(img_noBG{ch_task}<0) = 0;
stats_MeanIntensity_noBackground_temp{ch_task} = regionprops(objects, img_noBG{ch_task}, 'MeanIntensity');
stats_MeanIntensity_noBackground_temp{ch_task} = num2cell([stats_MeanIntensity_noBackground_temp{ch_task}.MeanIntensity]);
[objects.stats.(sprintf('Intensity_Mean_ch%d_noBackground', ch_task))] = stats_MeanIntensity_noBackground_temp{ch_task}{:};

% Obtain corrected Intensity values

% Obtain background
%         try
%             img_noBG_corr = img{ch_task}-background(ch_task);
%             [maxInt, maxInd] = max(img_noBG_corr(:));
%
%             cellSize = 1000;
%             I = zeros(1, size(img_noBG_corr, 3));
%             z = 1:numel(I);
%             parfor i=1:size(img_noBG_corr, 3)
%                 img_temp = img_noBG_corr(:,:,i);
%                 im_values = sort(img_temp(:));
%                 I(i) = mean(im_values(length(im_values)-cellSize:end));
%             end
%             img_corr{ch_task} = normalizeIntensities(img_noBG_corr, I, z, max(z), 1);
%
%             img_corr{ch_task} = img_corr{ch_task}/img_corr{ch_task}(maxInd);
%             img_corr{ch_task} = img_corr{ch_task}*maxInt+background(ch_task);
%
%             stats_MeanIntensity_corrected_temp{ch_task} = regionprops(objects, img_corr{ch_task}, 'MeanIntensity');
%             stats_MeanIntensity_corrected_temp{ch_task} = num2cell([stats_MeanIntensity_corrected_temp{ch_task}.MeanIntensity]);
%             [objects.stats.(sprintf('MeanIntensity_ch%d_corrected', ch_task))] = stats_MeanIntensity_corrected_temp{ch_task}{:};
%         catch err
%             warning(err.message);
%         end

end
