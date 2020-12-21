function res = get_bout_idx(animal, date, run)
% This function is to produce a cell containing each bout's related idx.

res = struct();
conf = run_file_system();
path = sbxDir(animal,date,run);
path = path.runs{1};
path = [path.path, correct_folderpath(conf.folder), conf.resultPath];
result = load(path);
result = result.result;
for i = 1:length(result.bout)
    res(i).startidx = result.bout{i}.startidx;
    res(i).endidx = result.bout{i}.endidx;
    res(i).scanrate = result.scanrate;
    res(i).direction = result.bout{i}.direction;
end
    
%res = cell2table(res, 'VariableNames', {'startidx', 'endidx', 'scanrate'});

end