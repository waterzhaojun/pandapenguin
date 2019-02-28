function diameter(animalID, dateID, run, pmt, bvid, output_video_hz, find_edge_method)

    % Prepare data matrix ================================================
    
    if nargin < 7, find_edge_method = 'kmean_slope'; end
    if nargin < 6, output_video_hz = 1; end
    if nargin < 5, bvid = false; end
    if nargin < 4, pmt = 1; end
    
    path = sbxPath(animalID, dateID, run, 'sbx'); 
    inf = sbxInfo(path, true);

    % if ~isfield(inf, 'volscan') && length(inf.otwave)>1
    if length(inf.otwave)>1
        bint = length(inf.otwave); 
    else
        bint = 1;
    end
    

    N = inf.max_idx + 1; 
    nr = inf.sz(1);
    nc = inf.sz(2);
    nf = floor(N/bint);
    
    disp('start to load data');
    x = fread(inf.fid, inf.nsamples/2*N, 'uint16=>uint16');
    maxvalue = double(intmax(class(x)));
    
    disp('start to reshape data');
    if bint > 1
        x = reshape(x(1:inf.nchan*inf.sz(2)*inf.recordsPerBuffer*bint*nf), ...
            [inf.nchan inf.sz(2) inf.recordsPerBuffer bint nf]);
        x = mean(x, 4);
    end
    
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer nf]);
    x = 65535-x;
    % x = uint8(x/255);
    display(['If you see this point, the data load is good. Has ', num2str(size(x, 4)), ' frames']);
    
    % Prepare folder to store each blood vessel data =====================
    disp('start to prepare the subfolder');
    folderpath = sbxDir(animalID, dateID, run);
    folderpath = folderpath.runs{1}.path;
    if bvid
        current_bv_folder = [folderpath, 'bv_', num2str(bvid)];
    else
        num_of_bv= length(dir([folderpath 'bv_*']))+1;
        current_bv_folder = [folderpath, 'bv_', num2str(num_of_bv)];
        mkdir(current_bv_folder);
    end
    
    % Build reference picture ============================================
    disp('start to build reference pic');
    ref_path = [current_bv_folder, '\ref.tif'];
    if isfile(ref_path)
        pic_ref = imread(ref_path);
    else
        idx_for_ref = int16(linspace(1,nf,100));
        pic_ref = squeeze(max(x(pmt+1,:,:,idx_for_ref), [], 4));
        pic_ref = permute(pic_ref, [2,1]);
        pic_ref = uint8(pic_ref/255); % It is not necessary to transfer to uint8, but it will decrease file size.
        imwrite(pic_ref, ref_path);
    end

    % get mask information ===============================================
    % when draw the rectangle, should draw clockwise with starting from left
    % side of vessel. Should as vertical to vessel as possible.
    maskpath = [current_bv_folder,  '\vesselmask.mat'];
    if isfile(maskpath)
        tmp = load(maskpath);
        BW = tmp.BW;
        angle = tmp.angle;
    else
        [BW,angle] = bwangle(pic_ref);
        save(maskpath, 'BW', 'angle');
    end
    
    ref_with_mask_path = [current_bv_folder, '\ref_with_mask.jpg'];
    if ~isfile(ref_with_mask_path)
        create_ref_pic(ref_with_mask_path, pic_ref, BW);
    end

    % calculate the diameter frame by frame ==============================
    BW_rotated = imrotate(BW, angle);
    [r,c] = find(BW_rotated == 1);
    upper = min(r);
    lower = max(r);
    left = min(c);
    right = max(c);
    BW_rotated_crop = BW_rotated(upper:lower,left:right);
    weight_line = sum(BW_rotated_crop, 1);
    
    % I tried use batch and just single frame. I found if I define the
    % matrix before loop, sinle frame even faster than batch.
    
    % init matrix
    % in result mat file, we will store a map, each column represent blood 
    % vessel brightness averaged along vertical axis. All columns represent
    % the timeline. The following steps will analyse the map and output
    % each timepoint's diameter and left(lower) and right(upper) idx for the edge.
    
    % Besides mat file, it also create a tif represent the diameter
    % timeline response.
    print_per_frames = 500;
    
    topo_merge_frames = output_video_hz * round(15 / bint);
    
    topo_path = [current_bv_folder, '\bv_video_', num2str(output_video_hz), 'Hz.tif'];
    if isfile(topo_path), delete(topo_path); end
    result_path = [current_bv_folder, '\result.mat'];
    if isfile(result_path), delete(result_path); end
        
    response_fig = zeros([size(BW_rotated_crop,2), nf]);

    for i=1:nf

        tmp = imrotate(permute(squeeze(x(pmt+1, :, :, i)), [2,1]), angle);
        tmp = double(tmp(upper:lower,left:right)) .* BW_rotated_crop;

        response_fig(:,i) = sum(tmp, 1)./weight_line;
        
        if rem(i, print_per_frames) == 0
            wd = [num2str(i), ' of ', num2str(nf), ' is done.'];
            disp(wd);
        end
    end
    % output the data to local folder
    save([current_bv_folder, '\result.mat'], 'response_fig');
    disp('finished calculate the diameter values');
    
    response_fig_bint = imadjust(bint2D(response_fig, topo_merge_frames)/maxvalue);
    create_response_figure([current_bv_folder, '\response_topo.tif'], response_fig_bint);
    
    % After get the response_fig matrix, we can start to calculate the
    % diameter.
    % output_topo_filepath = [current_bv_folder, '\response_topo.tif'];
    % create_response_topo_fig(response_fig/double(maxvalue), edge_idx_of_line, output_topo_filepath);
    
    diameter_value = zeros([1, size(response_fig,2)]);
    edge_idx_of_line = zeros([2, size(response_fig,2)]);
    for i=1:size(response_fig,2)
        [diameter_value(1, i), edge_idx_of_line(1, i), edge_idx_of_line(2, i)] = findEdge(response_fig(:,i));
    end
    save([current_bv_folder, '\result.mat'], 'diameter_value', '-append');
    edge_map = edge_idx_to_map(response_fig, edge_idx_of_line);
    edge_map_bint = bint2D(edge_map, topo_merge_frames);
    create_response_figure([current_bv_folder, '\response_topo.tif'], response_fig_bint, edge_map_bint);
    
    fig = figure;
    plot(bint1D(medfilt1(diameter_value, topo_merge_frames),topo_merge_frames));
    savefig(fig,[current_bv_folder, '\plot.fig']);
    
    

end

