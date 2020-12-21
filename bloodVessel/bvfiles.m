function res = bvfiles(animal, date, run)

conf = bv_file_system();
path = sbxDir(animal, date, run);
path = path.runs{1};
path = path.path;


res = struct();
res.folderpath = correct_folderpath([correct_folderpath(path), conf.folderpath]);
res.layerfolderpath = {};

flist = dir(res.folderpath);
flist = flist(~ismember({flist.name},{'.','..'}));
for i = 1:length(flist)
    res.layerfolderpath{i} = correct_folderpath([correct_folderpath(flist(i).folder), flist(i).name]);
end


end