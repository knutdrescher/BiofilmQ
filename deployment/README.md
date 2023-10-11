# Bumping version
When bumping the version, the new version has to be changed in the following places:
- includes/biofilmQ_version.txt
- deployment/BiofilmQ_incl_mcr.prj
- docs/conf.py
- docs/usage/installation.rst

There is an old MATLAB script that automatizes this for all files based on content of `includes/biofilmQ_version.txt`. It works for the `BiofilmQ_incl_mcr.prj` file, but currently not for the others...