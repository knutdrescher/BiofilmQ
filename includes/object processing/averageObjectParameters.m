function objects = averageObjectParameters(objects, silent)

if nargin < 2
    silent = 0;
end

if ~silent
    ticValue = displayTime;
end

fprintf('- averaging parameters\n');

fNames = fieldnames(objects.stats);
fNames = setdiff(fNames, {'IsRelatedToFounderCells', 'Surface_LocalThickness'});

if ~isfield(objects, 'globalMeasurements')
    objects.globalMeasurements = [];
end


if isfield(objects.stats, 'Distance_ToBiofilmCenterAtSubstrate')
    d_CM = [objects.stats.Distance_ToBiofilmCenterAtSubstrate];
    
    if isfield(objects.stats, 'IsRelatedToFounderCells')
        IsRelatedToFounderCells = [objects.stats.IsRelatedToFounderCells];
        d_CM = d_CM(IsRelatedToFounderCells);
    else
        fprintf('    - field [IsRelatedToFounderCells] not found. Averaging will be performed on all cell\n'); 
    end
    
    dCM_max = prctile(d_CM, 90);
    coreIDs = d_CM < dCM_max/2;
    shellIDs = d_CM > dCM_max/2;
else
   fprintf('    - skipping calculation of core and shell resolved parameters (reason: field [Distance_ToBiofilmCenterAtSubstrate] not existing)\n');
end

for i = 1:numel(fNames)
    field = fNames{i};
    
    if isfield(objects.stats, 'IsRelatedToFounderCells')
        data = {objects.stats(IsRelatedToFounderCells).(field)};
        biovolume = {objects.stats(IsRelatedToFounderCells).Shape_Volume};
    else
        data = {objects.stats.(field)};
        try
            biovolume = {objects.stats.Shape_Volume};
        catch err
            if strcmp(err.identifier, 'MATLAB:nonExistentField')
                % Legacy Code for datasets segmented prior to:
                % Commit 43acf62f 2019 Feb. 06: 'Volume' renamed to 'Shape_Volume'
                biovolume = {objects.stats.Volume};
            else
                rethrow(err)
            end
        end
    end
    if max(cellfun(@numel, data)) == 1 && min(cellfun(@numel, data)) == 1
        data = [data{:}];
        biovolume = [biovolume{:}];
        nans = isnan(data);
        
        
        % Calculate average values
        objects.globalMeasurements.(sprintf('%s_mean', field)) = nanmean(data);
        objects.globalMeasurements.(sprintf('%s_mean_biovolume', field)) = nansum(data.*biovolume)/sum(biovolume(~nans));
        objects.globalMeasurements.(sprintf('%s_std', field)) = nanstd(data);
        m = objects.globalMeasurements.(sprintf('%s_mean_biovolume', field));
        objects.globalMeasurements.(sprintf('%s_std_biovolume', field)) = sqrt(nansum(((data-m).^2).*biovolume)/sum(biovolume(~nans)));
        objects.globalMeasurements.(sprintf('%s_median', field)) = nanmedian(data);
        objects.globalMeasurements.(sprintf('%s_p25', field)) = prctile(data, 25);
        objects.globalMeasurements.(sprintf('%s_p75', field)) = prctile(data, 75);
        objects.globalMeasurements.(sprintf('%s_min', field)) = min(data);
        objects.globalMeasurements.(sprintf('%s_max', field)) = max(data);
        
        if isfield(objects.stats,  'Distance_ToBiofilmCenterAtSubstrate')&& ~isempty(shellIDs) && ~isempty(coreIDs)
            % Calculate average values for core and shell
            objects.globalMeasurements.(sprintf('%s_core_mean', field)) = nanmean(data(coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_mean_biovolume', field)) = nansum(data(coreIDs).*biovolume(coreIDs))/sum(biovolume(~nans & coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_std', field)) = nanstd(data(coreIDs));
            m = objects.globalMeasurements.(sprintf('%s_core_mean_biovolume', field));
            objects.globalMeasurements.(sprintf('%s_core_std_biovolume', field)) = sqrt(nansum(((data(coreIDs)-m).^2).*biovolume(coreIDs))/sum(biovolume(~nans & coreIDs)));
            objects.globalMeasurements.(sprintf('%s_core_median', field)) = nanmedian(data(coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_p25', field)) = prctile(data(coreIDs), 25);
            objects.globalMeasurements.(sprintf('%s_core_p75', field)) = prctile(data(coreIDs), 75);
            objects.globalMeasurements.(sprintf('%s_core_min', field)) = min(data(coreIDs));
            objects.globalMeasurements.(sprintf('%s_core_max', field)) = max(data(coreIDs));
            
            objects.globalMeasurements.(sprintf('%s_shell_mean', field)) = nanmean(data(shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_mean_biovolume', field)) = nansum(data(shellIDs).*biovolume(shellIDs))/sum(biovolume(~nans & shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_std', field)) = nanstd(data(shellIDs));
            m = objects.globalMeasurements.(sprintf('%s_shell_mean_biovolume', field));
            objects.globalMeasurements.(sprintf('%s_shell_std_biovolume', field)) = sqrt(nansum(((data(shellIDs)-m).^2).*biovolume(shellIDs))/sum(biovolume(~nans & shellIDs)));
            objects.globalMeasurements.(sprintf('%s_shell_median', field)) = nanmedian(data(shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_p25', field)) = prctile(data(shellIDs), 25);
            objects.globalMeasurements.(sprintf('%s_shell_p75', field)) = prctile(data(shellIDs), 75);
            objects.globalMeasurements.(sprintf('%s_shell_min', field)) = min(data(shellIDs));
            objects.globalMeasurements.(sprintf('%s_shell_max', field)) = max(data(shellIDs));
        end
    end
end

if ~silent
    displayTime(ticValue);
end
