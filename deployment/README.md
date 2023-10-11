# Bumping version
When bumping the version, the new version has to be changed in the following places:
- includes/biofilmQ_version.txt
- deployment/BiofilmQ_incl_mcr.prj
- docs/conf.py
- docs/usage/installation.rst

There is an old MATLAB script that automatizes this for all files based on content of `includes/biofilmQ_version.txt`. It works for the `BiofilmQ_incl_mcr.prj` file, but currently not for the others...

# Deploying
1. Use the `build_binary_locally.m` script
2. Afterwards, you can rename the created exe and zip files with `rename_files.m` so that they have the currently set version in their name.