function diameter_v2(animalID, dateID, run, pmt, bvid, fbin, find_edge_method)

% pmt is in which pmt channel the blood vessel being recorded.
%
% This function is to use the pretreated tif, which can be already
% downsampled. If you want to further downsample the frames, set fbin a number.
%
% If don't give a bvid, it will create a new id for analysis. If you want
% to recalculate the exist bv by pre decided mask, set bvid an id num.


if nargin < 7, find_edge_method = 'kmean_slope'; end
if nargin < 6, fbin = 1; end
if nargin < 5, bvid = false; end
if nargin < 4, pmt = 0; end

% set a result struct =================================================
root = sbxDir(animalID, dateID, run);
root = root.runs{1};

vb_folder = [root, 'bv'];
if ~exist(vb_folder, 'dir')
   mkdir(vb_folder)
end

% if bvid
%     current_bv_folder = [root, 'bv_', num2str(bvid)];
% else
%     num_of_bv= length(dir([root 'bv_*']))+1;
%     current_bv_folder = [root, 'bv_', num2str(num_of_bv), '\'];
%     mkdir(current_bv_folder);
% end

result = struct();
result.run = run;
result.movpath = [vb_folder,'mov.mat'];
result.refpath = [vb_folder,'ref.tif'];
result.maskpath = [vb_folder,'mask.tif'];
result.ref_with_mask_path = [vb_folder, 'ref_with_mask.tif'];
result.topopath = [vb_folder, 'topo.tif'];
result.resultpath = [vb_folder, 'result.mat'];
result.response_fig_path = [vb_folder, 'response_topo.tif'];
result.plotpath = [vb_folder, 'plot.fig'];

result.diameter = [];
result.edgeidx=[];
result.mov = [];
result.trial_length = [];


% Prepare data matrix ================================================
if isfile(result.movpath)
    result.mov = load(result.movpath);
else
    for run =runs
        tmppath = sbxDir(animalID, dateID, run);
        tmppath = tmppath.runs{1}.pretreatedmov;
        disp(['start to load run ', num2str(run)]);
        tmpmx = loadTiffStack_slow(tmppath);
        [tmpr,tmpc,tmpch,tmpf] = size(tmpmx);
        if tmpch>1
            % As we use tiff as source, pmt0 means green channel, pmt1 means red channel. 
            tmpmx = tmpmx(:,:,2-pmt,:);
        end

        if length(result.mov) == 0
            result.mov = tmpmx;
        else
            result.mov = cat(4, result.mov, tmpmx);
        end

        result.trial_length = [result.trial_length, tmpf];
    end

    save(result.movpath, 'result.mov');
end

if isfile(result.ref_with_mask_path)
    tmp = imread(result.refpath); 
    result.ref = tmp(:,:,1);
    result.mask = tmp(:,:,3);
else
    if isfile(result.refpath)
        result.ref = imread(result.refpath); 
    else
        result.ref = imadjust(uint16(squeeze(max(result.mov,[],4))));
        imwrite(result.ref, result.refpath);
    end
    [result.mask, result.angle] = bwangle(result.ref);
    create_ref_pic(result.ref_with_mask_path, result.ref, result.mask);
end





if ~isfile(result.ref_with_mask_path)
    create_ref_pic(result.ref_with_mask_path, result.ref, result.mask);
end

% calculate the diameter frame by frame ==============================
BW_rotated = imrotate(result.mask, result.angle);
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
print_per_frames = 1000;


if isfile(result.topopath), delete(result.topopath); end
if isfile(result.resultpath), delete(result.resultpath); end

[nr,nc] = size(BW_rotated_crop);
nf = length(result.mov);

response_fig = zeros([nc,nf]);
response_video = zeros([(lower-upper+1), (right-left+1), nf]);

for i=1:nf

    tmp = imrotate(squeeze(result.mov(:,:,1,i)), result.angle);
    tmp = tmp(upper:lower,left:right) .* BW_rotated_crop; %double(tmp(upper:lower,left:right)) .* BW_rotated_crop;

    response_fig(:,i) = sum(tmp, 1)./weight_line;
    response_video(:,:,i) = tmp;
    
    [tmpdiameter, edgeidx1, edgeidx2] = findEdge(response_fig(:,i));
    result.diameter = [result.diameter, tmpdiameter];
    result.edgeidx = [result.edgeidx; [edgeidx1, edgeidx2]];


    if rem(i, print_per_frames) == 0
        wd = [num2str(i), ' of ', num2str(nf), ' is done.'];
        disp(wd);
    end

end
% output the data to local folder
disp('finished calculate the diameter values');

% create_response_figure(result.response_fig_path, response_fig);

save(result.resultpath, 'result');

%this function is to produce the edge map based on the index, but some
%how I find sometimes it produce more rows than response_fig.
%I need to add a check function in this function.
edge_map = edge_idx_to_map(response_fig, result.edgeidx);
create_response_figure(result.response_fig_path, response_fig, edge_map);

fig = figure;
plot(bint1D(medfilt1(result.diameter, fbin),fbin));
savefig(fig,result.plotpath);
    

end

