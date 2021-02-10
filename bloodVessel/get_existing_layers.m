function layers = get_existing_layers(animal, date, run);

path = sbxDir(animal, date, run);
layerpath = path.runs{1}.bv.layer;
layers = {};
for i = 1:length(layerpath)
    tmp = fileparts(layerpath{i}.resultpath);
    tmp = strsplit(tmp, '\');
    tmp = strsplit(tmp{end}, 'to');
    tmparray = [];
    for j = 1:length(tmp)
        tmparray = [tmparray, str2num(tmp{j})];
    end
    layers{i} = tmparray;
end
    


end