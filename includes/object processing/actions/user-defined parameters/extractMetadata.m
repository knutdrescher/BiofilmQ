% This module extract time metadata from the image filename and assigns it
% to each object

fprintf(' Extracting metadata from filenames...');
metadata = extractBetween(filename, '_time', 'h_');
metadata = str2num(metadata{1});

metadatas = num2cell(repmat(metadata, objects.NumObjects));

[objects.stats.Metadata_Time] = metadatas{:};




