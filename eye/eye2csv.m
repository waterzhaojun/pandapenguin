function eye2csv(animalID, dateID, run)

    
    
    file = sbxDir(animalID, dateID);
    
    if nargin <3
        run = [];
        for(i =1:length(file.runs))
           run(i) = file.runs{i}.number;
        end
    end
    
    for(i = run)
        sbxPupil(animalID, dateID, i);
        path = [file.runs{i}.sbx(1:end-3), 'pdiam'];
        output = load(path, '-mat');
        output = output.pupil;
        csvwrite([file.runs{i}.path, 'eye.csv'], output);
        
    end
    

end