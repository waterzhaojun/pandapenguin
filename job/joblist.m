function joblist(path, step1)

    % path = 'D:\Analysis_scripts\Dropbox\AndermannLab\users\jzhao\job\runlist.csv'
    
    fid = fopen(path);
    out = textscan(fid,'%s%s%s','delimiter',',');
    fclose(fid);

    col1 = out{1};
    col2 = out{2};
    col3 = out{3};
    
    if step1 == 1
        for i = 37:size(col1,1)
            animalID = col1(i);
            animalID = animalID{1};
            dateID = col2(i);
            dateID = dateID{1};
            run = str2num(col3{i});

            postProcess1Jun(animalID, dateID, run);

            disp(sprintf('%d of %d done', i, size(col1,1)-1));
        end
    end

end