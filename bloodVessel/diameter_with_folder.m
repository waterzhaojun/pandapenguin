function diameter_with_folder(folder_path, find_edge_method)

    % This function is to re-calculate diameter if the initial one doesn't
    % very good.
    % In the folder path, you should have result.mat
    
    result_path = [folder_path, '\result.mat'];
    result = load(result_path);
    
    old_topo = imread([folder_path, '\response_topo.tif']);
    
    response_fig = result.response_fig;
    
    nf = size(response_fig, 2);
    topo_merge_frames = nf/size(old_topo, 2);
    
    diameter_value = zeros([1, nf]);
    edge_idx_of_line = zeros([2, nf]);
    
    for i=1:nf
        [diameter_value(1, i), edge_idx_of_line(1, i), edge_idx_of_line(2, i)] = findEdge(response_fig(:,i), 11, find_edge_method);
    end

    save([folder_path, '\', find_edge_method, '_result.mat'], 'diameter_value', 'response_fig');
    edge_map = edge_idx_to_map(response_fig, edge_idx_of_line);
    edge_map_bint = bint2D(edge_map, topo_merge_frames);
    
    response_fig_bint = double(old_topo(:,:,1))/255;
    create_response_figure([folder_path, '\', find_edge_method, '_response_topo.tif'], response_fig_bint, edge_map_bint);
    
    fig = figure;
    plot(bint1D(medfilt1(diameter_value, topo_merge_frames),topo_merge_frames));
    savefig(fig,[folder_path, '\', find_edge_method, '_plot.fig']);
end