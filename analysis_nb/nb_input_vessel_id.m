%% identify the information

animal = 'CGRP03';
date = '201109';
run = 1;

bvfilesys = bv_file_system();
files = bvfiles(animal, date, run);
files = files.layerfolderpath;
for i = 1:length(files)
    disp([num2str(i), ': ', files{i}]);
end

%% Check for each folder
i = 1;  % <=============================== set i for different subfolder.
resultpath = [files{i}, bvfilesys.resultpath];
refpath = [files{i}, bvfilesys.refpath];

result = load(resultpath);
result = result.result;
ref = read(Tiff(refpath,'r'));

totalpic = length(result.roi);
for j = 1:totalpic
    mask = result.roi{j};
    mask = mask.BW;
    maskmap = addroi(ref, mask);
    subplot(totalpic, 1, j);
    imshow(maskmap);
end

%% set id for each roi
ids = {'pia1'};
if length(ids) ~= totalpic
    error('Please input the same number of ids for all roi in this folder');
else
    for j = 1:totalpic
        result.roi{j}.id = ids{j};
    end
    save(resultpath, 'result');
end

%% 