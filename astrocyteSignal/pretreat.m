function pretreat(animalID, dateID, configpath)
    
    % Use this function to batch treat all runs in this day of this animal.
    runs = get_runs(animalID, dateID);
    
    for i = 1:length(runs)
        p = load_parameters(animalID, dateID, runs(i), configpath);
        treatsbx(p);
    end
        

end