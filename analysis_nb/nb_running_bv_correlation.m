% This notebook is to analyze the correlation between running and blood
% vessel changes. we need a running data folder and a bv data folder.

list = {
    'CGRP01','201118',1;'CGRP01','201118',2;...
    
    'CGRP02','201110',2;'CGRP02','201110',3;...
    'CGRP02','201117',1;'CGRP02','201117',2;'CGRP02','201117',3;'CGRP02','201117',4;...
    'CGRP02','201119',1;'CGRP02','201119',2;'CGRP02','201119',3;...
    
    'CGRP03','201109',1;'CGRP03','201109',2;...
    'CGRP03','201116',1;'CGRP03','201116',2;'CGRP03','201116',3;'CGRP03','201116',4;'CGRP03','201116',5;'CGRP03','201116',6;...
    'CGRP03','201118',1;'CGRP03','201118',2;'CGRP03','201118',3;'CGRP03','201118',4;'CGRP03','201118',5;'CGRP03','201118',6;'CGRP03','201118',7;...
    'CGRP03','201120',1;...
    
    'WT01','201111',1;'WT01','201111',2;'WT01','201111',3;'WT01','201111',4;...
    'WT01','201117',1;'WT01','201117',2;'WT01','201117',3;'WT01','201117',4;'WT01','201117',5;'WT01','201117',6;...
    'WT01','201119',1;'WT01','201119',2;'WT01','201119',3;'WT01','201119',4;'WT01','201119',5;...
    'WT01','201124',1;'WT01','201124',2;'WT01','201124',3;'WT01','201124',4;...
    'WT01','201125',1;'WT01','201125',2;...
    }

% some setting ==========================================================
baseline_sec = 2; % For each bout, get 2 sec pre data as baseline


% start analysis
result = struct();
startidx = 1;
for st = 1:size(list,1)
    root = sbxDir(list{st,1}, list{st,2},list{st,3});
    root = root.runs{1}.path;
    disp(list{st,1});
    disp(list{st,2});
    disp(list{st,3});
    running_folder = correct_folderpath([root, 'running']);
    % bv_folder shoube be the one hold all layers.
    bv_folder = correct_folderpath([root, 'bv']);


    runFileSys = run_file_system();
    bvFileSys = bv_file_system();

    running = load([running_folder, runFileSys.resultPath]);
    running = running.result;
    runscanrate = running.scanrate;

    bv_filelist = dir(bv_folder);
    bv_filelist = bv_filelist(~ismember({bv_filelist.name},{'.','..'}));

    for i = 1:length(running.bout)
        for j = 1:length(bv_filelist)
            bvresult = load([bv_filelist(j).folder, '\', bv_filelist(j).name, '\',bvFileSys.resultpath]);
            bvresult = bvresult.result;
            bvscanrate = bvresult.scanrate;
            for k = 1:length(bvresult.roi)
                % need to set running array rate the same as bv array.
                bintrate = round(runscanrate/bvscanrate);
                tmp_running_array = running.array;
                tmp_running_array = bint1D(tmp_running_array, bintrate, 'method', 'sum');
                tmpstartidx = ceil(running.bout{i}.startidx/bintrate);
                tmpendidx = ceil(running.bout{i}.endidx/bintrate);

                % get idx and arrays
                result.bout{startidx}.startidx = tmpstartidx;
                result.bout{startidx}.endidx = tmpendidx;
                result.bout{startidx}.running_array = tmp_running_array(tmpstartidx:tmpendidx);
                result.bout{startidx}.bv_array = bvresult.roi{k}.diameter(tmpstartidx:tmpendidx);
                baselinelength = baseline_sec * runscanrate/bintrate;
                if baselinelength < tmpstartidx
                    result.bout{startidx}.running_array_prebaseline = tmp_running_array((tmpstartidx-baselinelength):(tmpstartidx-1));
                    result.bout{startidx}.bv_array_prebaseline = bvresult.roi{k}.diameter((tmpstartidx-baselinelength):(tmpstartidx-1));
                else
                    extrapoint = tmpstartidx - baselinelength +1;
                    result.bout{startidx}.running_array_prebaseline = [zeros(1,extrapoint), tmp_running_array(1:(tmpstartidx-1))];
                    extrabvbl = mean(bvresult.roi{k}.diameter(1:(tmpstartidx-1)));
                    result.bout{startidx}.bv_array_prebaseline = [repmat(extrabvbl, 1,extrapoint), bvresult.roi{k}.diameter(1:(tmpstartidx-1))];
                end
                
                % get running characters
                result.bout{startidx}.distance = running.bout{i}.distance;
                result.bout{startidx}.duration = running.bout{i}.duration;
                result.bout{startidx}.speed = running.bout{i}.speed;
                result.bout{startidx}.maxspeed = running.bout{i}.maxspeed;
                result.bout{startidx}.direction = running.bout{i}.direction;
                result.bout{startidx}.acceleration = running.bout{i}.acceleration;
                result.bout{startidx}.acceleration_delay = running.bout{i}.acceleration_delay;

                % get diameter
                result.bout{startidx}.diameter_baseline = mean(result.bout{startidx}.bv_array_prebaseline);
                result.bout{startidx}.diameter_maxdff_in_10sec = bvresult.roi{k}.diameter(tmpstartidx:
            end
        end
    end
        
    
end
   
