function [img, params] = getND2Plane(reader, pos, z, ch, t)

reader.setSeries(pos-1);
iPlane = reader.getIndex(z-1, ch-1, t-1)+1;
img = double(bfGetPlane(reader, iPlane));

omeMeta = reader.getMetadataStore();
params.t = double(omeMeta.getPlaneDeltaT(0, iPlane));
params.dxy = str2num(char(omeMeta.getPixelsPhysicalSizeX(0)));
params.dz = str2num(char(omeMeta.getPixelsPhysicalSizeZ(0)));