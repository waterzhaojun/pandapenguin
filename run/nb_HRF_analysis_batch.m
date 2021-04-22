% This notebook is to do batch HRF analysis for multiple experiments. Once you input the experiment
% information into the google sheet, come here and run the batch.
% This notebook doesn't have analyze and plot part.

googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'; 

explist = load_exp(googleSheetID, '0');
sheetID = '0';
HRFcolumn = 14;

for expi = 121:length(explist) % <============= Or you set you wanted range. Be careful the range should be from google sheet row +1
    animal = explist(expi).animal;
    date = explist(expi).date;
    run = str2num(explist(expi).run);
    runtask = explist(expi).running_task;
    bvtask = explist(expi).bv_task;
    alignmenttask = explist(expi).alignment_task;
    group = explist(expi).treatment;
    boutNum = str2num(explist(expi).bouts_num);
    scanmode = explist(expi).scanmode;

    %running_analysis(animal, date, run);
    
    if ~strcmp(runtask, 'Done') || ~strcmp(bvtask, 'Done') || ~strcmp(group, 'baseline') || ~strcmp(scanmode, '2D') 
        continue;
    end
    disp(['find ', animal, ' ', date, ' run', num2str(run), ' finished treatment']); 
    
    try
        hrf_analysis(animal, date, run);
        mat2sheets(googleSheetID, sheetID, [expi+1 HRFcolumn], {'Done'});
    catch
        mat2sheets(googleSheetID, sheetID, [expi+1 HRFcolumn], {'Failed'});
    end
end