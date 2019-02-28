function edgemap = edge_idx_to_map(map, edge_idxes)

    [r,c] = size(map);
    edgemap = zeros([r,c]);
    for i = 1:size(edge_idxes,2)
        uidx = edge_idxes(1, i);
        lidx = edge_idxes(2, i);
        uidx_array = [max([1, uidx-1]):(uidx+1)];
        lidx_array = [(lidx-1):min([lidx+1, r])];

        edgemap(uidx_array, i) = 1;
        edgemap(lidx_array, i) = 1;
    end

end