function postProcess(animalID, dateID, run)

    path = sbxPath(animalID, dateID, run, 'clean');
    sbxFiberMapCore(animalID, dateID, run);
    



end