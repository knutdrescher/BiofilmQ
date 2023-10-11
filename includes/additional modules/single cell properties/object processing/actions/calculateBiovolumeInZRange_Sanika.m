%%% This function calculates and saves the biovolume which is present in all
%%% layers between minZ and maxZ, which are given in ?m 

minZ = 0;
maxZ = 4;

Distance_FromSubstrate = cellfun(@(x) x(3), {objects.stats.Centroid})*objects.params.scaling_dxy/1000;

objectsWithinRange = (Distance_FromSubstrate >= minZ) & (Distance_FromSubstrate <= maxZ);

volumes = [objects.stats.Shape_Volume];
completeVolume = sum(volumes);

volumes = volumes(objectsWithinRange);

minZ_str = strrep(sprintf('%0.1f', minZ), '.', '_');
maxZ_str = strrep(sprintf('%0.1f', maxZ), '.', '_');
parametername = ['BiovolumeBetween', minZ_str, 'And', maxZ_str, 'um'];

objects.globalMeasurements.(parametername) = sum(volumes);
objects.globalMeasurements.Biovolume3D = (completeVolume-sum(volumes));
objects.globalMeasurements.Biovolume3DIndex = (completeVolume-sum(volumes))/completeVolume;


mat_cells = labelmatrix(objects);
cc = bwconncomp(mat_cells>0);
mat_cells = labelmatrix(cc);
topLayer = mat_cells(:,:,end-2);
presentInTopLayer = unique(topLayer(:));
presentInTopLayer(presentInTopLayer==0) = [];
biovolumeConnected = 0;
for k = 1:length(presentInTopLayer)
   connected = mat_cells==presentInTopLayer(k);
   biovolumeConnected = biovolumeConnected + sum(connected(:));
end

objects.globalMeasurements.BiofilmIndex = biovolumeConnected;