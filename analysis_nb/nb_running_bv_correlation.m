% This notebook is to analyze the correlation between running and blood
% vessel changes. we need a running data folder and a bv data folder.

list = {
    'CGRP01','201118',1;'CGRP01','201118',2;...
    
    'CGRP02','201110',2;'CGRP02','201110',3;...
    'CGRP02','201117',1;'CGRP02','201117',2;'CGRP02','201117',3;'CGRP02','201117',4;...
    'CGRP02','201119',1;'CGRP02','201119',2;'CGRP02','201119',3;...
    
    %'CGRP03','201109',1;'CGRP03','201109',2;...
    'CGRP03','201116',1;'CGRP03','201116',2;'CGRP03','201116',3;'CGRP03','201116',4;'CGRP03','201116',5;'CGRP03','201116',6;...
    'CGRP03','201118',1;'CGRP03','201118',2;'CGRP03','201118',3;'CGRP03','201118',4;'CGRP03','201118',5;'CGRP03','201118',6;'CGRP03','201118',7;...
    'CGRP03','201120',1;...
    
    'WT01','201111',1;'WT01','201111',2;'WT01','201111',3;'WT01','201111',4;...
    %'WT01','201117',1;...
    'WT01','201117',2;'WT01','201117',3;'WT01','201117',4;'WT01','201117',5;'WT01','201117',6;...
    'WT01','201119',1;'WT01','201119',2;'WT01','201119',3;'WT01','201119',4;'WT01','201119',5;...
    %'WT01','201124',1;'WT01','201124',2;'WT01','201124',3;'WT01','201124',4;...
    %'WT01','201125',1;'WT01','201125',2;...
    }

CGRPlist = {
    'CGRP01','201118',1;'CGRP01','201118',2;...
    'CGRP02','201110',2;'CGRP02','201110',3;...
    'CGRP03','201109',1;'CGRP03','201109',2;...
    }
controllist = {
    'WT01','201111',1;'WT01','201111',2;'WT01','201111',3;'WT01','201111',4;...
    
    'WT0118','201123',1;'WT0118','201123',2;'WT0118','201123',3;...
    'WT0118','201125',1;'WT0118','201125',2;'WT0118','201125',3;'WT0118','201125',4;'WT0118','201125',5;'WT0118','201125',6;...
    %'WT0118','201201',1;'WT0118','201201',2;'WT0118','201201',3;'WT0118','201201',4;'WT0118','201201',5;'WT0118','201201',6;...
    %'WT0118','201208',1;'WT0118','201208',2;'WT0118','201208',3;'WT0118','201208',4;'WT0118','201208',5;'WT0118','201208',6;'WT0118','201208',7;...
    }
    'WT0119','201123',1;'WT0119','201123',2;'WT0119','201123',3;'WT0119','201123',4;...
    'WT0119','201125',1;'WT0119','201125',2;'WT0119','201125',3;'WT0119','201125',4;'WT0119','201125',5;'WT0119','201125',6;...
    %'WT0119','201201',1;'WT0119','201201',2;'WT0119','201201',3;'WT0119','201201',4;'WT0119','201201',5;...
    %'WT0119','201208',1;'WT0119','201208',2;'WT0119','201208',3;'WT0119','201208',4;'WT0119','201208',5;'WT0119','201208',6;'WT0119','201208',7;'WT0119','201208',8;...
    
    'WT0120','201209',1;'WT0120','201209',2;'WT0120','201209',3;'WT0120','201209',4;'WT0120','201209',5;'WT0120','201209',6;'WT0120','201209',7;'WT0120','201209',8;'WT0120','201209',9;'WT0120','201209',10;...
    }

testlist = {
    'CGRP03','201109',3;'CGRP03','201109',4;
    }
saveroot = 'D:\Jun\tmp\';
cgrpbaseline = tmpfunction(CGRPlist);
controlbaseline = tmpfunction(controllist);

testbaseline = tmpfunction(testlist);
% add filter here
%filt = {'direction == 1'};
%cgrpbaseline = boutFilter(cgrpbaseline, filt);
%controlbaseline = boutFilter(controlbaseline, filt);


results = {testbaseline, testbaseline};
keys = {'speed', 'diameter_maxdff_in_5sec'};
titles = {'speed','diameter max changes'};
groups = {'CGRP baseline', 'wild type baseline'};
plotCorrelationFig(results, keys, titles, groups,...
    [saveroot, groups{1}, ' vs ', groups{2}, ' -- ', titles{1}, ' ', titles{2},'.pdf']...
    );

keys = {'maxspeed', 'diameter_maxdff_in_5sec'};
titles = {'maxspeed','diameter max changes'};
groups = {'CGRP baseline', 'wild type baseline'};
plotCorrelationFig(results, keys, titles, groups,...
    [saveroot, groups{1}, ' vs ', groups{2}, ' -- ', titles{1}, ' ', titles{2},'.pdf']...
    );

keys = {'acceleration', 'diameter_maxdff_in_5sec'};
titles = {'acceleration','diameter max changes'};
groups = {'CGRP baseline', 'wild type baseline'};
plotCorrelationFig(results, keys, titles, groups,...
    [saveroot, groups{1}, ' vs ', groups{2}, ' -- ', titles{1}, ' ', titles{2},'.pdf']...
    );

keys = {'duration', 'diameter_maxdff_in_5sec'};
titles = {'duration','diameter max changes'};
groups = {'CGRP baseline', 'wild type baseline'};
plotCorrelationFig(results, keys, titles, groups,...
    [saveroot, groups{1}, ' vs ', groups{2}, ' -- ', titles{1}, ' ', titles{2},'.pdf']...
    );


%% function for this notebook
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
                tmp = character_analysis_1D(bvresult.roi{k}.diameter, tmpstartidx,tmpendidx, bvscanrate, baseline_sec, 'analyze_response_secrange', [0,10]);
                result.bout{startidx}.diameter_baseline = tmp.baseline;
                result.bout{startidx}.diameter_maxdff_in_10sec = tmp.response_max;
                
                startidx = startidx+1;
            end
        end
    end
        
    
end


% ========================================================================
% plot part
x = [];
y = [];
for i = 1:length(result.bout)
    x = [x,result.bout{i}.speed];
    y = [y,result.bout{i}.diameter_maxdff_in_10sec];
end
scatter(x,y);

%% build time course plot
baselinePeriod = 3; %sec
responsePeriod = 10; %sec
outputfs = 1; %hz

df = correlation_table_running_bv(controllist);

% add filter here
tmpidx = [];
for i = 1:length(df)
    if strcmp(df(i).bvtype, 'artery')
        tmpidx = [tmpidx,i];
    end
end
df = df(tmpidx);
tmplist = controllist;
%extract matrix
mx = [];
for i=1:length(df)
    try
        bv = load(df(i).bvresultfile);
        bv = bv.result;
        bv = bv.roi{df(i).bvroiidx}.diameter;
        tmpstartidx = df(i).bvstartidx - baselinePeriod * df(i).bvscanrate;
        tmpendidx   = df(i).bvstartidx + responsePeriod * df(i).bvscanrate - 1;
        tmp = idx_to_1d_array(bv,tmpstartidx, tmpendidx,...
            baselinePeriod, df(i).bvscanrate);
        tmp = bint1D(tmp, df(i).bvscanrate / outputfs);
        tmp = reshape(tmp, 1, []);
        if i == 1
            mx = tmp;
        else
            mx = cat(1, mx, tmp);
        end
    catch
        disp([df(i).animal,'-', df(i).date, '-', num2str(df(i).run)]);
    end
end
% 
for i = 1:length(tmplist)
    df = get_bout_idx(tmplist{i,1},tmplist{i,2},tmplist{i,3});
    
    bvpaths = bvfiles(tmplist{i,1},tmplist{i,2},tmplist{i,3});
    bvpaths = bvpaths.layerfolderpath;
    
    for j = 1:length(bvpaths)
    	bv = load([bvpaths{j}, 'result.mat']);
        bv = bv.result;
        bvscanrate = bv.scanrate;
        for k = 1:length(bv.roi)
            roi = bv.roi{k};
            % add filter here
           % if strcmp(roi.type, 'artery') && strcmp(roi.tissue, 'pia')
                for m = 1:length(df)
                    runstartidx = df(m).startidx;
                    runscanrate = df(m).scanrate;
                    rundirection = df(m).direction;
                    % add filter here
                    if rundirection > 0
                        bvstartidx = translateIdx(runstartidx, runscanrate, bvscanrate);
                        tmp = idx_to_1d_array(roi.diameter,...
                            bvstartidx - baselinePeriod * bvscanrate, ...
                            bvstartidx + responsePeriod * bvscanrate-1, ...
                            baselinePeriod, bvscanrate);
                        tmp = bint1D(tmp, bvscanrate/outputfs);
                        if length(mx) == 0
                            mx = reshape(tmp,1,[]);
                        else
                            mx = cat(1,mx,reshape(tmp,1,[]));
                        end
                    end
                %end
            end
        end
    end
    
end

% If you plot mx' here, you can see all the timecourse.

meantl = mean(mx, 1);
stdtl = std(mx,1)/sqrt(size(mx,1));
errorbar(meantl, stdtl);