function postProcess2Jun(animalID, dateID, run)

    files = sbxDirJun(animalID, dateID, run);
    if isempty(files.runs{1}.fiberBin) 
        error('You have to create fiberMap_fiberBin.tif before postprocess step 2');
        return;
    else
        fiberBin = loadFiberMap(files.runs{1}.fiberBin);
    end
    
    
    array = sbxReadPMT(files.runs{1}.cleansbx);
    
    
    % Get the grouped fiber calcium value
    if isempty(files.runs{1}.casignal)
        [area, caValue] = groupFiber(array, fiberBin);
        save([files.runs{1}.sbx(1:end-3), 'casignal'], 'area', 'caValue');  % this file save value before dff.
    end

end