function data = readtable_fast(filename)

data_num = csvread(filename, 1);

fid=fopen(filename);
header = fgetl(fid);
fclose(fid);

header = strsplit(header, ', ');

data = [];
for i = 1:numel(header)
    data.(header{i}) = data_num(:,i);
end
data = struct2table(data);