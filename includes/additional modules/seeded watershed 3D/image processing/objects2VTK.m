function objects2VTK(filenameVTK, objects, resolution)

    if nargin < 3
        resolution = 1;
    end

    if ~isfield(objects, 'stats')
        objects.stats = regionprops(objects, 'BoundingBox', 'Centroid');
    end

    custom_fields_objects = fieldnames(objects.stats);
  
    custom_fields_objects = setdiff(custom_fields_objects, {'Centroid', 'BoundingBox', 'MinBoundBox_Cornerpoints', 'Cube_CenterCoord', 'Orientation_Matrix', 'Timepoint'});
    
    custom_fields_objects = union(custom_fields_objects, { ...
        'RandomNumber', ...
        'Distance_FromSubstrate', ...
        'CentroidCoordinate_z', ...
        'CentroidCoordinate_y', ...
        'CentroidCoordinate_x', ...
        'ID', ...
        });
    
    w_mask_label = labelmatrix(objects);
    
    if ~isfield(objects, 'params')
        objects.params.scaling_dxy = 1;
        objects.params.scaling_dz = 1;        
    end
    
    % fake GUI params
    params.visualization_rotation = false;
    params.visualization_rotation_axis = 3;
    params.obtainConnectedStructure = false;
    


    cells = isosurfaceLabel(w_mask_label, objects, resolution, custom_fields_objects, params);

    custom_fields = fieldnames(cells);

    mvtk_write(cells,filenameVTK, 'legacy-binary', custom_fields(3:end));