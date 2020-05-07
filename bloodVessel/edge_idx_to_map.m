function edgemap = edge_idx_to_map(map, edge_idxes)

    [r,c] = size(map);
    edgemap = zeros([r,c]);
    for i = 1:c
        
        tmp = zeros(1, r);
        tmp(edge_idxes(:,i)) = 1;
        tmp = tmp + [tmp(2:end),0] + [0, tmp(1:end-1)];
        
        edgemap(:, i) = tmp;
    end

end