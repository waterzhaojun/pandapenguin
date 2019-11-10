function confirm_rois(folderpath)

if folderpath(end) ~= '\'
    folderpath = [folderpath, '\'];
end

total_mask_path = [folderpath, 'total_mask.tif'];
if ~exist(total_mask_path, 'dir)
    total_mask = 
f = dir([folderpath, 'total_mask.tif']);
flit = [];
for i = 1:length(f)
    if length(regexp(f(i).name, '[0-9]*_.*.tif')) > 0
        flit = [flit, f(i)];
    end
end
    
            



end

