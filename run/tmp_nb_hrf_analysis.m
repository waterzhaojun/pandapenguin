googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'; % <== This is where the data sheet is.
root = 'C:\2pdata\HRF_0412\';  %<=============  Where you want to save the analyzed data


%% Code part. Don't change code below =======================
explist = load_exp(googleSheetID);
sheetID = '0';
HRFcolumn = 14;
lists = 43:404; %2:404; %<============== which data sheet lines do you want to analyze.


for expidx = 1:length(lists)
    expi = lists(expidx);
    animal = explist(expi).animal;
    date = explist(expi).date;
    run = str2num(explist(expi).run);
    runtask = explist(expi).running_task;
    bvtask = explist(expi).bv_task;
    group = explist(expi).treatment;
    boutNum = str2num(explist(expi).bouts_num);
    scanmode = explist(expi).scanmode;
    hrfdone = explist(expi).HRFold2;
    
    %running_analysis(animal, date, run);
    
    if ~strcmp(runtask, 'Done') || ~strcmp(bvtask, 'Done') || ~strcmp(group, 'baseline') || ~strcmp(scanmode, '2D') || strcmp(hrfdone, 'Done') || strcmp(hrfdone, 'Failed')
        continue;
    end
    disp(['find ', animal, ' ', date, ' run', num2str(run), ' finished treatment']); 
    
    try
        hrf_analysis(animal, date, run, 'extra_output_folder', root);
        mat2sheets(googleSheetID, sheetID, [expi HRFcolumn], {'Done'});
    catch
        mat2sheets(googleSheetID, sheetID, [expi HRFcolumn], {'Failed'});
    end
end

animal = 'CGRP03';
date = '201116';
run = 3;

meanCoeff = hrf_analysis(animal, date, run, 'extra_output_folder', root);