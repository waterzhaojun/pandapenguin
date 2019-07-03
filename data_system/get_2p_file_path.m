function path = get_2p_file_path(animalID, date, run, filetype, keyword)

root = rootpath('2p');

level1 = strcat(date, '_', animalID);

level2 = strcat(date, '_', animalID, '_run', num2str(run));

filename = strcat('*', keyword, '*.', filetype);

file = dir(fullfile(root, animalID, level1, level2, filename));

path = fullfile(file.folder, file.name);

end