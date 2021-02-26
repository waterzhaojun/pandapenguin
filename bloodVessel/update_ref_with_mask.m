function update_ref_with_mask(folder)
% This function is to update the ref with mask when we edited the roi.

folder = correct_folderpath(folder);
bvfilesys = bv_file_system();
result = load([folder, bvfilesys.resultpath]);
result = result.result;
rois = result.roi;
ref = read(Tiff([folder, result.refpath],'r'));

for i = 1:length(rois)
    roi = rois{i};
    ref = addroi(ref, roi.BW);
end

imwrite(uint16(ref), [folder,result.ref_with_mask_path]);



end