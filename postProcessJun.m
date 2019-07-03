animalID = 'DL56';
dateID = '161214';
run = 2;

%function postProcessJun(animalID, dateID, run)
     
    sbxPCAClean(animalID, dateID, run);
    
    path = sbxDirJun(animalID, dateID, run);
    
    
    sbxClean = path.runs{1}.cleansbx;
    
    array = sbxReadPMT(sbxClean);
    
    maxFiberMap(array, path.runs{1}.path);
    
    fiberMapBin(animalID, dateID, run, 20000, 60000);
    
%end