function biofilmData = determineIsRelatedToFounderCells(handles, biofilmData)

if ~isfield(biofilmData.params, 'searchRadiusBiofilm')
    biofilmData.params.searchRadiusBiofilm = str2num(handles.handles_analysis.uicontrols.edit.edit_scanRadius.String);
end

fhypot = @(a,b,c) sqrt(abs(a).^2+abs(b).^2+abs(c).^2);

scanRadius = biofilmData.params.searchRadiusBiofilm/(biofilmData.params.scaling_dxy/1000);

for i = 1:numel(biofilmData.data) % go through frames
    
    if i ~= 1 && biofilmData.data(i).NumObjects > 10
        IsRelatedToFounderCells1 = [biofilmData.data(i-1).stats.IsRelatedToFounderCells];
        IsRelatedToFounderCells2 = zeros(biofilmData.data(i).NumObjects, 1);
        
        coords1 = [biofilmData.data(i-1).stats(logical(IsRelatedToFounderCells1)).Centroid];
        coords2 = {biofilmData.data(i).stats.Centroid};
        
        parfor obj2ID = 1:numel(coords2)
            
            % Determine nearby cells
            coordsOfActualCell = coords2{obj2ID};
            
            x = coords1(1:3:end);
            y = coords1(2:3:end);
            z = coords1(3:3:end);
            
            dist = fhypot(coordsOfActualCell(1)-x, coordsOfActualCell(2)-y, coordsOfActualCell(3)-z);
            
            IsRelatedToFounderCells2(obj2ID) = any(dist < scanRadius);
        end
    else
        IsRelatedToFounderCells2 = ones(biofilmData.data(i).NumObjects, 1);
    end
    
    
    IsRelatedToFounderCells2 = num2cell(logical(IsRelatedToFounderCells2));
    [biofilmData.data(i).stats.IsRelatedToFounderCells] = IsRelatedToFounderCells2{:};
end