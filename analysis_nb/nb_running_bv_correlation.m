% This notebook is to analyze the correlation between running and blood
% vessel changes. we need a running data folder and a bv data folder.

running_folder = 'D:\2P\CGRP03\201109_CGRP03\201109_CGRP03_run4\running';
% bv_folder shoube be the one hold all layers.
bv_folder = 'D:\2P\CGRP03\201109_CGRP03\201109_CGRP03_run4\bv';

running_folder = correct_folderpath(running_folder);
bv_folder = correct_folderpath(bv_folder);
runFileSys = run_file_system();
bvFileSys = bv_file_system();

running = load([running_folder, runFileSys.resultPath]);
running = running.result;

bv_filelist = dir(bv_folder);
bv_filelist = bv_filelist(~ismember({bv_filelist.name},{'.','..'}));

result = struct();
startidx = 1;
for i = 1:length(running.bout)
    for j = 1:length(bv_filelist)
        bvresult = load([bv_filelist(j).folder, '\', bv_filelist(j).name, '\',bvFileSys.resultpath]);
        bvresult = bvresult.result;
        for k = 1:length(bvresult.roi)
            bintrate = floor(length(running.array)/length(bvresult.roi{k}.diameter));
            tmp_running_array = running.array;
            tmp_running_array = bint1D(tmp_running_array, bintrate);
            tmpstartidx = ceil(running.bout{i}.startidx/bintrate);
            tmpendidx = ceil(running.bout{i}.endidx/bintrate);
        end
        
    end
end
        
    
   
