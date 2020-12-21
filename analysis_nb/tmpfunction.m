function result = tmpfunction(list)


% some setting ==========================================================
baseline_sec = 3; % For each bout, get 2 sec pre data as baseline


% start analysis
result = struct();
startidx = 1;
for st = 1:size(list,1)
    root = sbxDir(list{st,1}, list{st,2},list{st,3});
    root = root.runs{1}.path;
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
                try
                    % need to set running array rate the same as bv array.
                    bintrate = round(runscanrate/bvscanrate);
                    tmp_running_array = running.array;
                    tmp_running_array = bint1D(tmp_running_array, bintrate, 'method', 'sum');
                    tmpstartidx = ceil(running.bout{i}.startidx/bintrate);
                    tmpendidx = ceil(running.bout{i}.endidx/bintrate);

                    % get idx and arrays
                    result.bout{startidx}.startidx = tmpstartidx;
                    result.bout{startidx}.endidx = tmpendidx;

                    % get running characters
                    result.bout{startidx}.distance = running.bout{i}.distance;
                    result.bout{startidx}.duration = running.bout{i}.duration;
                    result.bout{startidx}.speed = running.bout{i}.speed;
                    result.bout{startidx}.maxspeed = running.bout{i}.maxspeed;
                    result.bout{startidx}.direction = running.bout{i}.direction;
                    result.bout{startidx}.acceleration = running.bout{i}.acceleration;
                    result.bout{startidx}.acceleration_delay = running.bout{i}.acceleration_delay;
                    tmp = character_analysis_1D(tmp_running_array, tmpstartidx, tmpendidx, bvscanrate, baseline_sec,'dff',false);
                    result.bout{startidx}.running_array = tmp.response_array;

                    % get diameter
                    %result.bout{startidx}.position = bvresult.roi{k}.postion;
                    %result.bout{startidx}.type = bvresult.roi{k}.type;
                    %result.bout{startidx}.tissue = bvresult.roi{k}.tissue;
                    tmp = character_analysis_1D(bvresult.roi{k}.diameter, tmpstartidx,tmpendidx, bvscanrate, baseline_sec, 'analyze_response_secrange', [0,5]);
                    result.bout{startidx}.diameter_baseline = tmp.baseline;
                    result.bout{startidx}.diameter_maxdff_in_5sec = tmp.response_max;

                    startidx = startidx+1;
                catch
                    disp(running_folder);
                end
            end
        end
    end
        
    
end

end