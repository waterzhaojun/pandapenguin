function sbxFiberMap(animalID, dateID, run)

    path = sbxPath(animalID, dateID, run, 'clean'); 
    data = sbxReadPMT(path); % Reads in a file directly from the microscope
    ve = checkz(data); % this vector is to describe the most bright dust changes during recording. It should represent the z changes.
    
    savePath = sbxDir(animalID, dateID, run).runs;
    savePath = savePath.runs{1}.path;
    maxFiberMap(data, savePath);



    mapStr = sbxFiberMapCore(animalID, dateID, run);
    



end