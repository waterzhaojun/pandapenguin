% This notebook is to analysis running induced response HRF model
% parameters. 

googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'; % <== This is where the data sheet is.
root = 'C:\2pdata\HRF_dura\';  %<=============  Where you want to save the analyzed data


%% Code part. Don't change code below =======================
explist = load_exp(googleSheetID, '0');
sheetID = '0';
HRFcolumn = 14;
lists = 1:length%[43:51,62:69,82:83,109:114,127:135,171:202,213:231]; %<============== which data sheet lines do you want to analyze.

for expidx = 298:length(lists)
    expi = lists(expidx);
    animal = explist(expi).animal;
    date = explist(expi).date;
    run = str2num(explist(expi).run);
    runtask = explist(expi).running_task;
    bvtask = explist(expi).bv_task;
    alignmenttask = explist(expi).alignment_task;
    group = explist(expi).treatment;
    boutNum = str2num(explist(expi).bouts_num);
    scanmode = explist(expi).scanmode;
    hrfdone = explist(expi).HRF;
    
    %running_analysis(animal, date, run);
    
    if ~strcmp(runtask, 'Done') || ~strcmp(bvtask, 'Done') || ~strcmp(group, 'baseline') || ~strcmp(scanmode, '2D') || strcmp(hrfdone, 'Done') || strcmp(hrfdone, 'Failed')
        continue;
    end
    disp(['find ', animal, ' ', date, ' run', num2str(run), ' finished treatment']); 
    runresultpath = sbxPath(animal, date, run, 'running');
    runresult = load(runresultpath.result);
    runresult = runresult.result;
    restidx = baseline_idx_with_long_term_rest(runresult);
    running_binary = array_binary(runresult);
%     if length(restidx) == 0
%         continue;
%     end
%     disp('This trial has enough length baseline period');
    if length(restidx) == 0
        continue
    end
    bvresult = extractBvData(animal, date, run);
    
    try
        for i = 1:length(bvresult)
            corrArrayori = bvresult(i).diameter;

            baseline = mean(corrArrayori(restidx));

            corrArray = (corrArrayori - baseline)/baseline;
            [H,coeff] = train_HRF_model(running_binary, corrArray * 100, runresult.scanrate);
            df = struct();
            df.restidxLength = length(restidx);
            df.oridiameter = corrArrayori;
            df.baseline = baseline;
            df.diameter = corrArray;
            df.animal = animal;
            df.date = date;
            df.run = run;
            df.A = H(1);
            df.td = H(2);
            df.tao = H(3);
            df.Atao = df.A * df.tao;
            df.coeff = coeff;
            df.bvposition = bvresult(i).position;
            df.bvid = bvresult(i).id;
            df.bvtype = bvresult(i).type;
            df.bvtissue = bvresult(i).tissue;
            df.bvlayer = bvresult(i).layer;
            save([root, animal, '_',date, '_run', num2str(run),'_',num2str(i), '_df.mat'], 'df');
            exportgraphics(gcf,[root, animal, '_',date, '_run', num2str(run), '_',num2str(i), '.jpg']);%,'ContentType','vector')
            disp('Done');
        end
        mat2sheets(googleSheetID, sheetID, [expi HRFcolumn], {'Done'});
    catch
        mat2sheets(googleSheetID, sheetID, [expi HRFcolumn], {'Failed'});
    end
end

%% This part is to organize all mat files and build a big struct array.
% df = struct();

total_report_root = [root, 'report2\'];
if exist(total_report_root)
    rmdir(total_report_root)
end
mkdir(total_report_root);

dfidx = 1;
files = dir(root);
keepidx = [];
for i = 1:length(files)
    if length(files(i).name) > 2
        keepidx = [keepidx, i];
    end
end
files = files(keepidx);

for i = 1:length(files)
    if strcmp(files(i).name(end-3:end), '.mat')
        tmp = load([files(i).folder,'\',files(i).name]); 
        tmp = tmp.df;
        jpgpath = [files(i).folder,'\',files(i).name];
        tmp(1).jpgpath = [jpgpath(1:end-7), '.jpg'];
        if contains(tmp(1).animal, 'CGRP')
            tmp(1).group = 'CGRP';
        elseif contains(tmp(1).animal, 'WT')
            tmp(1).group = 'WT';
        end
        
        if dfidx == 1
            df = [tmp];
        else
            df = [df,tmp];
        end
        dfidx = dfidx + 1;
    end
end

% add filter here =========
df = df(strcmp({df.bvtissue}, 'dura'));
df = df(strcmp({df.bvtype}, 'artery'));
df = df(strcmp({df.bvposition}, 'horizontal'));
df = df([df.coeff] > 0.60);
df = df([df.A] > 0);
df = df([df.baseline] < 40);
df = df([df.td] < 5);

% save to local .mat file.
save([total_report_root, 'result.mat'], 'df');



%save to google sheet.
outputGoogleSheetId = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ';
outputGoogleSheetTab = '904542698';%'HRF_value_analysis';1805849516 for drew. 185196530 for markov
excludeFields = {'oridiameter', 'diameter'};

outputdf = rmfield(df, excludeFields);

animals = get_animal_info(); % It is too slow to check it multiple times. So I get the whole table then get gender locally.

for i = 1:length(outputdf)
    outputdf(i).bvid = [outputdf(i).animal, '_', outputdf(i).bvid];
    outputdf(i).gender =  animals(strcmp({animals.animal}, outputdf(i).animal)).gender;
end

outputdf_fields = fieldnames(outputdf);
mat2sheets(outputGoogleSheetId, outputGoogleSheetTab, [1 1], outputdf_fields');

outputdf_data = {};
for i = 1:length(outputdf)
    tmp = struct2cell(outputdf(i))';
    outputdf_data = [outputdf_data;tmp];
end
mat2sheets(outputGoogleSheetId, outputGoogleSheetTab, [2 1],outputdf_data);

% copy jpg files to report folder ======================
for i = 1:length(df)
    targetpath = strrep(df(i).jpgpath, root, total_report_root);
    copyfile(df(i).jpgpath, targetpath);
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

exportgraphics(gcf,[total_report_root, 'HRF model comparison.jpg']);


%% save unqualitied files to another folder.============================

unqualified_root = [root, 'unqualified\'];
if exist(unqualified_root)
    rmdir(unqualified_root)
end
mkdir(unqualified_root);

dfidx = 1;
files = dir(root);
keepidx = [];
for i = 1:length(files)
    if length(files(i).name) > 2
        keepidx = [keepidx, i];
    end
end
files = files(keepidx);

for i = 1:length(files)
    if strcmp(files(i).name(end-3:end), '.mat')
        tmp = load([files(i).folder,'\',files(i).name]); 
        tmp = tmp.df;
        jpgpath = [files(i).folder,'\',files(i).name];
        tmp(1).jpgpath = [jpgpath(1:end-7), '.jpg'];
        if contains(tmp(1).animal, 'CGRP')
            tmp(1).group = 'CGRP';
        elseif contains(tmp(1).animal, 'WT')
            tmp(1).group = 'WT';
        end
        
        if dfidx == 1
            df = [tmp];
        else
            df = [df,tmp];
        end
        dfidx = dfidx + 1;
    end
end

% add filter here =========
df = df(strcmp({df.bvtissue}, 'pia'));
df = df(strcmp({df.bvtype}, 'artery'));
df = df(strcmp({df.bvposition}, 'horizontal'));
df = df([df.coeff] <= 0.50);
df = df([df.A] > 0);

save([unqualified_root, 'result.mat'], 'df');

% copy jpg files to report folder ======================
for i = 1:length(df)
    targetpath = strrep(df(i).jpgpath, root, unqualified_root);
    copyfile(df(i).jpgpath, targetpath);
end