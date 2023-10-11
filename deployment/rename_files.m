root = fileparts(mfilename('fullpath'));

fid = fopen(fullfile(root, '..', 'includes', 'biofilmQ_version.txt'));
versions = textscan(fid, '%s');
fclose(fid);

version_long = versions{1}{1};

filename1 = strcat('BiofilmQ-installer-', version_long, '.exe');
filename2 = strcat('BiofilmQ_MCR-installer-', version_long, '.zip');

path1 = fullfile(root, 'files-for-deployment', 'BiofilmQ', 'installers');
path2 = fullfile(root, 'files-for-deployment', 'BiofilmQ_MCR', 'installers');

source1 = fullfile(path1, 'BiofilmQ.exe');
source2 = fullfile(path2, 'BiofilmQ_MCR.zip');

dest1 = fullfile(root, 'files-for-deployment', filename1);
dest2 = fullfile(root, 'files-for-deployment', filename2);

copyfile(source1, dest1);
copyfile(source2, dest2);