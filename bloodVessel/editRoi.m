function editRoi(folder, mx, roiid)
% Sometimes the roi is not perfectly selected and may cause weird signal.
% This function is to help you change the roi without refill every
% information.

folder = correct_folderpath(folder);
bvfilesys = bv_file_system();
result = load([folder, bvfilesys.resultpath]);
result = result.result;
rois = result.roi;
ref = read(Tiff([folder, result.refpath],'r'));

for i = 1:length(rois)
    tmpposition = rois{i}.position;
    if strcmp(rois{i}.id, roiid)
        
        BW = rois{i}.BW;
        newref = addroi(ref, BW);
        [newBW,newangle] = bwangle(newref);
        if strcmp(tmpposition, 'vertical')
           diameter = vertical_diameter_measure(mx, newBW);
        elseif strcmp(result.roi{i}.position, 'horizontal')
           diameter = calculate_diameter(mx, newBW, newangle);
        end
        plot(diameter);
        ylim([0,50]);
        





end