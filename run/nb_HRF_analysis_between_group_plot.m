% After HRF analysis, each running result has a HRF field.
% This notebook is to combine all required experiment to a big struct array
% and build related plots.
googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'; 
explist = load_exp(googleSheetID, '0');
HRFcolumn = 14;

total_report_root = 'C:\2pdata\HRF_dura';
if exist(total_report_root)
    rmdir(total_report_root)
end
mkdir(total_report_root);

dfidx = 1;

for expi = 1:length(explist) % <============= Or you set you wanted range. Be careful the range should be from google sheet row +1
    animal = explist(expi).animal;
    date = explist(expi).date;
    run = str2num(explist(expi).run);
    runtask = explist(expi).running_task;
    bvtask = explist(expi).bv_task;
    alignmenttask = explist(expi).alignment_task;
    group = explist(expi).treatment;
    boutNum = str2num(explist(expi).bouts_num);
    scanmode = explist(expi).scanmode;
    hrftask = explist(expi).HRF_dura;

    %running_analysis(animal, date, run);
    
    if ~strcmp(hrftask, 'Done') || ~strcmp(group, 'baseline') || ~strcmp(scanmode, '2D') 
        continue;
    end
    disp(['find ', animal, ' ', date, ' run', num2str(run), ' finished treatment']); 
    
    runresultpath = sbxPath(animal, date, run, 'running');
    runresult = load(runresultpath.result);
    runresult = runresult.result;
    
    HRFdata = runresult.HRF;
    HRFFigPath = [runresultpath.folder, '\', runresult.HRF_pic];
    for i = 1:length(HRFdata)
        if contains(HRFdata(i).animal, 'CGRP')
            HRFdata(i).group = 'CGRP';
        elseif contains(HRFdata(i).animal, 'WT')
            HRFdata(i).group = 'WT';
        end
        HRFdata(i).figpath = HRFFigPath;
    end
    
    if dfidx == 1
        df = [HRFdata];
    else
        df = [df,HRFdata];
    end
    dfidx = dfidx + 1;
    
end


% add filter here =========
df = df(strcmp({df.bvtissue}, 'dura'));
%df = df(strcmp({df.bvtype}, 'artery'));
%df = df(strcmp({df.bvposition}, 'horizontal'));
df = df([df.coeff] > 0.50);
%df = df([df.A] > 0);
%df = df([df.baseline] < 40);
%df = df([df.td] < 5);

% save to local .mat file.
save([total_report_root, '\result.mat'], 'df');



%save to google sheet.
outputGoogleSheetId = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ';
outputGoogleSheetTab = '706547764';%'HRF_dura
excludeFields = {'oridiameter', 'diameter'};

outputdf = rmfield(df, excludeFields);

animals = get_animal_info(); % It is too slow to check it multiple times. So I get the whole table then get gender locally.

for i = 1:length(outputdf)
    outputdf(i).bvid = [outputdf(i).animal, '_', outputdf(i).bvid];
    outputdf(i).gender =  animals(strcmp({animals.animal}, outputdf(i).animal)).gender;
end

structarray2googlesheet(outputdf, outputGoogleSheetId, outputGoogleSheetTab)

% copy jpg files to report folder ======================
for i = 1:length(df)
    copyfile(df(i).figpath, [total_report_root, '\', df(i).animal, '_', df(i).date, '_', num2str(df(i).run), '_HRF.fig']);
end

% Plot the group difference
dfwt = df(strcmp({df.group}, 'WT'));
dfcgrp = df(strcmp({df.group}, 'CGRP'));
figure('Position', [10 10 1200 1200]);
tiledlayout(2,2);
nexttile;
plot_boxplot([dfwt.A], [dfcgrp.A], {'WT', 'CGRP'}, 'title', 'HRF model argument value comparison');

nexttile;
plot_boxplot([dfwt.td], [dfcgrp.td], {'WT', 'CGRP'}, 'ylabel', 'sec', 'title', 'HRF model td value comparison');

nexttile;
plot_boxplot([dfwt.tao], [dfcgrp.tao], {'WT', 'CGRP'}, 'ylabel', 'sec', 'title', 'HRF model tao value comparison');

exportgraphics(gcf,[total_report_root, '\HRF model comparison.jpg']);


