%%% This function calculates and saves the biovolume which is present in all
%%% layers between minZ and maxZ, which are given in ?m 

minZ = 0;
maxZ = 3;

Distance_FromSubstrate = cellfun(@(x) x(3), {objects.stats.Centroid})*objects.params.scaling_dxy/1000;
objectsWithinRange = (Distance_FromSubstrate >= minZ) & (Distance_FromSubstrate <= maxZ);
volumes = [objects.stats.Shape_Volume];

volumes = volumes(objectsWithinRange);
minZ_str = strrep(sprintf('%0.1f', minZ), '.', '_');
maxZ_str = strrep(sprintf('%0.1f', maxZ), '.', '_');
parametername = ['BiovolumeBetween', minZ_str, 'And', maxZ_str, 'um'];
objects.globalMeasurements.(parametername) = sum(volumes);
