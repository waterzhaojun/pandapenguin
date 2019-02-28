function create_response_topo_fig(response_fig, edge_points, path)
    
    % response_fig is a map with double value between 0 and 1.
    % edge_points is a matrix has 2 rows and same columns with
    % response_fig.
    % path is the path of output file.
    [r, c] = size(response_fig);
    finalmap = zeros([r, c, 3], 'double');
    finalmap(:,:,1) = imadjust(response_fig);
   

    for i = 1:c
        lidx = edge_points(1, i);
        ridx = edge_points(2, i);
        lidx_array = [max([1, lidx-1]):(lidx+1)];
        ridx_array = [(ridx-1):min([ridx+1, r])];

        finalmap(lidx_array, i, 3) = 1;
        finalmap(ridx_array, i, 3) = 1;
    end
    imwrite(finalmap, path, 'tiff');

end