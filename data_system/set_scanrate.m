function set_scanrate(animal, date, run, analyzeFolder)
path = sbxPath(animal, date, run, 'sbx'); 
inf = sbxInfo(path, true);
scanrate = check_scan_rate(inf);
layers = check_scan_layers(inf);

root = sbxDir(animal, date, run);
root = root.runs{1}.path;

if strcmp(analyzeFolder, 'running')
    filesys = run_file_system();
    resultpath = [root, filesys.folder, '\', filesys.resultPath];
    result = load(resultpath);
    result = result.result;
    result.scanrate = scanrate;
    save(resultpath, 'result');
    
elseif strcmp(analyzeFolder, 'bv')
    filesys = bv_file_system();
    resultpath = bvfiles(animal, date, run);
    resultpath = resultpath.layerfolderpath;
    for i = 1:length(resultpath)
        tmppath = [resultpath{i}, filesys.resultpath];
        result = load(tmppath);
        result = result.result;
        result.scanrate = scanrate / layers;
        save(tmppath, 'result');
    end
else
    error('Did not set this type yet');
end


    


end