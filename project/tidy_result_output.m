function tidy_result_output(animalid, dateid, run)

path = sbxDir(animalid, dateid, run); 
path = path.runs(run);
folderpath = path{1}.path;

sbxfile = path{1}.sbx;
bvfile = strcat(path{1}.base, '_redChl.tif');
runfile = path{1}.quad;

diameter(bvfile, false);