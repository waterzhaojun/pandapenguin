function set_roi(animalID, dateID, run, pmt, roiid, bin_size)
    
    if nargin < 5, roiid = false; end
    if nargin < 4, pmt = 0; end
    
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
        x = squeeze(x);
    else
        x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer nf]);
    end
    
    x = 65535-x;
    
    if length(size(x)) == 3
        x = reshape(x, [1, size(x)]);
    end
    
    x = squeeze(x(pmt+1, :,:,:));
    x = permute(x, [2,1,3]);
    display(['If you see this point, the data load is good. Has ', num2str(size(x, 4)), ' frames']);
    
    % Prepare folder to store each ROI data =====================
    disp('start to prepare the subfolder');
    folderpath = sbxDir(animalID, dateID, run);
    folderpath = folderpath.runs{1}.path;
    if roiid
        current_cell_folder = [folderpath, 'cell_', num2str(roiid)];
    else
        num_of_cell= length(dir([folderpath 'cell_*']))+1;
        current_cell_folder = [folderpath, 'cell_', num2str(num_of_cell)];
        mkdir(current_cell_folder);
    end
    
    % Build reference picture ============================================
    disp('start to build reference pic');
    ref_path = [current_cell_folder, '\ref.tif'];
    if isfile(ref_path)
        pic_ref = imread(ref_path);
    else
        idx_for_ref = int16(linspace(1,nf,100));
        pic_ref = squeeze(max(x(:,:,idx_for_ref), [], 3));
        % pic_ref = permute(pic_ref, [2,1]);
        pic_ref = uint8(pic_ref/255); % It is not necessary to transfer to uint8, but it will decrease file size.
        imwrite(pic_ref, ref_path);
    end
    
    % get mask information ===============================================
    maskpath = [current_cell_folder,  '\roi.mat'];
    if isfile(maskpath)
        tmp = load(maskpath);
        coords = tmp.coords;
    else
        % from top left to bottom right
        imshow(pic_ref);
        coords = round(getrect); % [c_topleft, r_topleft, c_width, r__height]
        save(maskpath, 'coords');
    end
    
    ref_with_mask_path = [current_cell_folder, '\ref_with_mask.jpg'];
    %if ~isfile(ref_with_mask_path)
    tmp = zeros([size(pic_ref), 3]);
    tmp(:, :, 2) = imadjust(double(pic_ref)/maxvalue);
    tmp(coords(2):coords(2)+coords(4), coords(1):coords(1)+coords(3), 1) = 1;
    imwrite(tmp, ref_with_mask_path);
    %end
    
    x1 = x(coords(2):coords(2)+coords(4), coords(1):coords(1)+coords(3), :);
    x2 = bint3D(double(x1)/maxvalue, 15);
    
    roi_img_path = [current_cell_folder, '\roi_img.tiff'];
    if isfile(roi_img_path)
        delete(roi_img_path);
    end
    
    for k = 1:size(x2, 3)
        imwrite(x2(:, :, k), roi_img_path, 'WriteMode', 'append');
        if rem(k, 100) == 0
            disp([num2str(k), ' finished']);
        end
    end
    
end