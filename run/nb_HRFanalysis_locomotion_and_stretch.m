% This notebook is to try to use HRF analysis the relationship between
% locomotion and stretch.

%% analyze single exp
animal = 'WT0118';
date = '201208';
run = 4;

runresultpath = sbxPath(animal, date, run, 'running');
runresult = load(runresultpath.result);
runresult = runresult.result;
restidx = baseline_idx_with_long_term_rest(runresult);
locodata = array_binary(runresult);
stretchdata = extractAndyRegData(animal, date, run);


corrArrayori = stretchdata.shear; % <================= which deformation data you want to analyze

baseline = mean(corrArrayori(restidx));
corrArray = (corrArrayori - baseline)/baseline * 100;
[H,coeff] = train_HRF_model(locodata, corrArray, runresult.scanrate, 'bound', {[-20,-20,0],[120,20,150]});

%% analyze multiple exp based on the google sheet
googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'; 
dataGid = '0';
outputGid = '960214179';
outputFolder = 'C:\Users\Levylab\jun\HRF_loco2deform\';

boundrange = {[-20,-20,0],[120,20,150]};

explist = load_exp(googleSheetID, dataGid);

df = struct();
dfidx = 1;

for expi = 298:length(explist)
    
    animal = explist(expi).animal;
    date = explist(expi).date;
    run = str2num(explist(expi).run);
    runtask = explist(expi).running_task;
    regtask = explist(expi).alignment_task;
    group = explist(expi).treatment;
    scanmode = explist(expi).scanmode;
    
    if ~strcmp(runtask, 'Done') || ~strcmp(regtask, 'Done') || ~strcmp(group, 'baseline') || ~strcmp(scanmode, '2D') 
        continue;
    end
    disp(['find ', animal, ' ', date, ' run', num2str(run), ' qualified']); 
    try
        runresultpath = sbxPath(animal, date, run, 'running');
        runresult = load(runresultpath.result);
        runresult = runresult.result;
        restidx = baseline_idx_with_long_term_rest(runresult);
        locodata = array_binary(runresult);
        stretchdata = extractAndyRegData(animal, date, run);

        df(dfidx).animal = animal;
        df(dfidx).date = date;
        df(dfidx).run = run;

        fig = tiledlayout(3,1);

        shearori = stretchdata.shear; % <================= which deformation data you want to analyze
        shearbaseline = mean(shearori(restidx));
        shearArray = (shearori - shearbaseline)/shearbaseline * 100;
        nexttile;
        [H,coeff] = train_HRF_model(locodata, shearArray, runresult.scanrate, 'bound', boundrange);
        df(dfidx).shear_A = H(1);
        df(dfidx).shear_td = H(2);
        df(dfidx).shear_tao = H(3);
        df(dfidx).shear_coeff = coeff;
        title(['shear coeff = ', num2str(coeff)]);

        scaleori = stretchdata.scale; % <================= which deformation data you want to analyze
        scalebaseline = mean(scaleori(restidx));
        scaleArray = (scaleori - scalebaseline)/scalebaseline * 100;
        nexttile;
        [H,coeff] = train_HRF_model(locodata, scaleArray, runresult.scanrate, 'bound', boundrange);
        df(dfidx).scale_A = H(1);
        df(dfidx).scale_td = H(2);
        df(dfidx).scale_tao = H(3);
        df(dfidx).scale_coeff = coeff;
        title(['scale coeff = ', num2str(coeff)]);

        transori = stretchdata.trans; % <================= which deformation data you want to analyze
        transbaseline = mean(transori(restidx));
        transArray = (transori - transbaseline)/transbaseline * 100;
        nexttile;
        [H,coeff] = train_HRF_model(locodata, transArray, runresult.scanrate, 'bound', boundrange);
        df(dfidx).trans_A = H(1);
        df(dfidx).trans_td = H(2);
        df(dfidx).trans_tao = H(3);
        df(dfidx).trans_coeff = coeff;
        title(['trans coeff = ', num2str(coeff)]);

        saveas(gcf,[outputFolder, animal, '_', date, '_', num2str(run), '.fig']);
        close;

        dfidx = dfidx + 1;
    catch
        disp('Data not exist');
    end

end

save([outputFolder, 'result.mat'], 'df');
structarray2googlesheet(df, googleSheetID, outputGid);


