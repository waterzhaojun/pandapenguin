function analysis_aqua_folder(folder)

    %p = [folder, '\', 'aqua_parameters.yml'];

    subfolders = dir(folder);
    flags = [subfolders.isdir] & ~strcmp({subfolders.name}, '.') & ~strcmp({subfolders.name}, '..');
    subfolders = subfolders(flags);
    subfolders = strcat(folder, '\', {subfolders.name});
    for i = 1:length(subfolders)
        disp(subfolders(i));
        tmp = dir(subfolders{i});
        tmp = tmp(~[tmp.isdir]);
        tmpflags = ~cellfun(@isempty, regexp({tmp.name}, '.*_pretreated.tif'));
        file = tmp(tmpflags);
        analysis_aqua([file.folder, '\', file.name]);
    end

end
