function sbxFiberMapCore(animalID, dateID, run)

    % get the interested area coordinates
    df = sbxLoad(animalID, dateID, run, 'icamasks');
    
    map = imadjust(uint16(df.icaguidata.image_to_show));
       
    roi_index = find(df.icaguidata.ROI_list == 1);
    cords = cell(length(roi_index), 1);
    for i = 1:length(roi_index)
        cords{i} = df.icaguidata.ica(roi_index(i)).idx;
    end
    
    path = sbxDirJun(animalID, dateID, run);
    path = path.runs{1}.path;
    save([path, 'roi_fiberMap.mat'], 'map', 'cords');
    
end