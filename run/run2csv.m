function run2csv(animalID, dateID, run)
    
    file = sbxDir(animalID, dateID);
    
    if nargin <3
        run = [];
        for(i =1:length(file.runs))
           run(i) = file.runs{i}.number;
        end
    end
    
    for(i = run)
        
        runFile = load(file.runs{i}.quad);
        runFile = runFile.quad_data;
        output = zeros(1, length(runFile));
        for(j = 1:length(runFile))

            if(j == 1)
                output(1,j) = runFile(j);
            else
                output(1,j) = runFile(j)-runFile(j-1);
            end
        end
        output = abs(output);

        savepath = [file.runs{i}.path, 'speed.csv'];
        csvwrite(savepath, output);

    end
    

end