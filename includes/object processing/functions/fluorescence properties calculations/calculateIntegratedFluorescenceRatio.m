function [objects, img_noBG] = calculateIntegratedFluorescenceRatio(objects, img, ch_task, background, img_noBG )


for ch_task_ratio = ch_task
    stats_MeanIntensity_temp{ch_task_ratio} = regionprops(objects, img{ch_task_ratio}, 'MeanIntensity');
    
    if isempty(img_noBG{ch_task_ratio})
        img_noBG{ch_task_ratio} = img{ch_task_ratio}-background(ch_task_ratio);
        img_noBG{ch_task_ratio}(img_noBG{ch_task_ratio}<0) = 0;
    end
    stats_MeanIntensity_noBackground_temp{ch_task_ratio} = regionprops(objects, img_noBG{ch_task_ratio}, 'MeanIntensity');
end

% Calculate intensity ratios
ratio = num2cell(([stats_MeanIntensity_temp{ch_task(2)}.MeanIntensity].*[objects.stats.Shape_Volume])./([stats_MeanIntensity_temp{ch_task(1)}.MeanIntensity].*[objects.stats.Shape_Volume]));
[objects.stats.(sprintf('Intensity_Ratio_Integrated_ch%d_ch%d', ch_task(2), ch_task(1)))] = ratio{:};

ratio = num2cell(([stats_MeanIntensity_noBackground_temp{ch_task(2)}.MeanIntensity].*[objects.stats.Shape_Volume])./([stats_MeanIntensity_noBackground_temp{ch_task(1)}.MeanIntensity].*[objects.stats.Shape_Volume]));
[objects.stats.(sprintf('Intensity_Ratio_Integrated_ch%d_ch%d_noBackground', ch_task(2), ch_task(1)))] = ratio{:};

end