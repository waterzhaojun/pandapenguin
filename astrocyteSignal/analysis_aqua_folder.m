function analysis_aqua_folder(animal, date, runs, configpath, pmt)

    %p = [folder, '\', 'aqua_parameters.yml'];

    %subfolders = dir(folder);
    %flags = [subfolders.isdir] & ~strcmp({subfolders.name}, '.') & ~strcmp({subfolders.name}, '..');
    %subfolders = subfolders(flags);
    %subfolders = strcat(folder, '\', {subfolders.name});
    %for i = 1:length(subfolders)
    %    disp(subfolders(i));
    %    tmp = dir(subfolders{i});
    %    tmp = tmp(~[tmp.isdir]);
    %    tmpflags = ~cellfun(@isempty, regexp({tmp.name}, '.*_pretreated.tif'));
    %    file = tmp(tmpflags);
    %    analysis_aqua([file.folder, '\', file.name]);
    if nargin<5, pmt = 0; end
    for i = 1:length(runs)
        p = load_parameters(animal, date, runs(i), configpath, pmt);
        analysis_aqua(p);
        foldername = [p.dirname, 'run', num2str(p.run), '_AQuA'];
        if ~exist(foldername, 'dir')
            mkdir(foldername);
        end
        
        movefile([p.dirname, 'FeatureTable.xlsx'], foldername);
        movefile([p.dirname, 'Movie.tif'], foldername);
        
        [a,b,c] = fileparts(p.config.related_setting_file.aqua_parameter_file);
        movefile([p.dirname, [b,c]], foldername);
        
    end
    
    

end
