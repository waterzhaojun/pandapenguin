function postProcess3Jun(animalID, dateID, run)
% in this step, the function will load fiber map and background map. Based
% on correlation, the fiber will be grouped. At the end the function will
% output 
    
    files = sbxDirJun(animalID, dateID, run);
    
    savePath = [files.runs{1}.path, 'result.mat'];
    
    fiberBin = loadFiberMap(files.runs{1}.fiberBin);
    %bgBin = fiberBorder(fiberBin, 4);
    %bgBin = loadFiberMap('D:\twophoton_data\2photon\scan\DL56\170104_DL56\170104_DL56_run1\fiberMap_ref2.tif');
    bgBin = loadFiberMap(files.runs{1}.bgBin);
    
      
    array = sbxReadPMT(files.runs{1}.cleansbx);
    
    
    
    % Get the grouped fiber calcium value
    if isempty(files.runs{1}.casignal)
        [area, caValue] = groupFiber(array, fiberBin);
        save([files.runs{1}.sbx(1:end-3), 'casignal'], 'area', 'caValue');  % this file save value before dff.
    else
        cafile = load(files.runs{1}.casignal, '-mat');
        area = cafile.area;
        caValue = cafile.caValue;
    end
    

    % Finally save to a result file
    save(savePath, 'area', 'caValue', 'speed', 'brainmotion', 'pupil', 'bgValue');

end