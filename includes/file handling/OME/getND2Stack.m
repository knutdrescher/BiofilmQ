function [img, params] = getND2Stack(reader, pos, ch, t, sX, sY, sZ)

img = zeros(sX, sY, sZ);

reader.setSeries(pos-1);

for z = 1:sZ
    iPlane = reader.getIndex(z-1, ch-1, t-1)+1;
    img(:,:,z) = double(bfGetPlane(reader, iPlane))';
end

omeMeta = reader.getMetadataStore();
try
    params.t = double(omeMeta.getPlaneDeltaT(0, iPlane).value);
catch
    params.t = NaN;
end
params.dxy = str2num(char(omeMeta.getPixelsPhysicalSizeX(0)));
params.dz = str2num(char(omeMeta.getPixelsPhysicalSizeZ(0)));