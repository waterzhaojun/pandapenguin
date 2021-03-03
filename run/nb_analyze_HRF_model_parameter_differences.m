% This notebook is to analysis running induced response HRF model
% parameters. 

googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'; % <== This is where the data sheet is.
root = 'D:\test1\';  %<=============  Where you want to save the analyzed data
lists = [110]%110,128,189];  %<============== which data sheet lines do you want to analyze.

df = struct();
%% Code part. Don't change code below =======================
explist = load_exp(googleSheetID);
for expi = lists
    animal = explist(expi).animal;
    date = explist(expi).date;
    run = str2num(explist(expi).run);
    runtask = explist(expi).running_task;
    bvtask = explist(expi).bv_task;
    alignmenttask = explist(expi).alignment_task;
    group = explist(expi).situation;
    boutNum = str2num(explist(expi).bouts_num);
    scanmode = explist(expi).scanmode;
    
    if ~strcmp(runtask, 'Done') || ~strcmp(bvtask, 'Done') || ~(boutNum > 0) || ~strcmp(group, 'baseline') || ~strcmp(scanmode, '2D')%&& strcmp(alignmenttask, 'Done') 
        continue;
    end
    disp(['find ', animal, ' ', date, ' run', num2str(run), ' finished treatment']); 
    runresultpath = sbxPath(animal, date, run, 'running');
    runresult = load(runresultpath.result);
    runresult = runresult.result;
    restidx = baseline_idx_with_long_term_rest(runresult);
    running_binary = array_binary(runresult);
    if length(restidx) == 0
        continue;
    end
    disp('This trial has enough length baseline period');
    
    bvresult = extractBvData(animal, date, run);
    for i = 1:length(bvresult)
        corrArray = bvresult(i).diameter;
        baseline = mean(corrArray(restidx));
        corrArray = (corrArray - baseline)/baseline;
        [H,coeff] = train_HRF_model(running_binary, corrArray, runresult.scanrate);
        tmpstruct = struct();
        tmpstruct.animal = animal;
        tmpstruct.date = date;
        tmpstruct.run = run;
        tmpstruct.A = H(1);
        tmpstruct.td = H(2);
        tmpstruct.tao = H(3);
        tmpstruct.coeff = coeff;
    end
    df = [df,tmpstruct];
end
            
            