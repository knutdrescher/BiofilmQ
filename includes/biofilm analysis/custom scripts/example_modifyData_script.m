%% Example script to modify data before plotting

% This script will shift the timepoints by 20 min

% Data is present in the variable "biofilmData" which this script can
% modify before the plot-command is executed
% Note: The modified data is not stored, no data is overwritten

addTime = 20; %min

for frame = 1:numel(biofilmData.data)
    time = [biofilmData.data(frame).stats.Time] + addTime/60; % add 20 min
    
    % Store again in variable
    time = num2cell(time);
    [biofilmData.data(frame).stats.Time] = time{:};
    
    % Add offset to global time intervals
    biofilmData.timeIntervals(1) = addTime*60+1; % in s
end