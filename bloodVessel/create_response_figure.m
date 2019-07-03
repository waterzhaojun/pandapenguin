function create_response_figure(path, map, edgemap)
    
    if nargin <3
        has_edge_label = false; 
    else
        has_edge_label = true;
    end
    [r,c] = size(map);
    map3d = zeros([r, c, 3]);
    map3d(:,:,1) = map;
    
    
    if has_edge_label
        map3d(:,:,3) = edgemap;
    end
    
    imwrite(map3d, path);

end