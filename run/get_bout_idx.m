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
    res(i).animal = animal;
    res(i).date = date;
    res(i).run = run;
    res(i).startidx = result.bout{i}.startidx;
    res(i).endidx = result.bout{i}.endidx;
    res(i).run_scanrate = result.scanrate;
    res(i).direction = result.bout{i}.direction;
    res(i).speed = result.bout{i}.speed;
    res(i).acceleration = result.bout{i}.acceleration;
    res(i).maxspeed = result.bout{i}.maxspeed;
    res(i).duration = result.bout{i}.duration;
    res(i).distance = result.bout{i}.distance;
    res(i).acceleration_delay = result.bout{i}.acceleration_delay;
    res(i).boutid = i;
end
    
%res = cell2table(res, 'VariableNames', {'startidx', 'endidx', 'scanrate'});

end