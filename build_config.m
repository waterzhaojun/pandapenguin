function build_config(animal, date, runs, configpath)

for i = 1:length(runs)
    thedir = sbxDir(animal, date, runs(i));
    thedir = thedir.runs{1}.path;
    
    copyfile(configpath, [thedir, 'config.yml']); 
    
end 