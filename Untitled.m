animal = 'WT0118';
date = '201208';
run = 1;

running_analysis(animal,date,run);
set_scanrate(animal,date,run,'running');
set_scanrate(animal,date,run,'bv');

folder = 'C:\2pdata\WT0118\201208_WT0118\201208_WT0118_run1\bv\1';
diameter_calculate_baseline(folder);

diameter_running_corAnalysis(animal, date, run);

googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ';
sheetID = '0';
explist = load_exp(googleSheetID);

% for i = 2:length(explist)
%     running_analysis(explist(i).animal,explist(i).date,str2num(explist(i).run));
% end

distance_column = 8;
for i = 2:length(explist)
    tmp = sbxDir(explist(i).animal,explist(i).date,str2num(explist(i).run));
    tmp = tmp.runs{1}.quad;
    tmp = load(tmp);
    tmp = tmp.quad_data;
    mat2sheets(googleSheetID, sheetID, [i distance_column], tmp(end));
    disp(i);
    %running_analysis(explist(i).animal,explist(i).date,str2num(explist(i).run));
end

for i = 2:length(explist)
    try
        tmp = extractRunningData(explist(i).animal, explist(i).date, explist(i).run);
        for j = 1:length(tmp)
            tmp(j).animal = explist(i).animal;
            tmp(j).date = explist(i).date;
            tmp(j).run = explist(i).run;
        end
        tmpbv = extractBvData(explist(i).animal, explist(i).date, explist(i).run);
        
        df = runningCorrelationAnalysis(tmp, {tmpbv}, {'bv'}, {{'diameter'}});
        if i == 2
            result = df;
        else
            result = [result;df];
        end
    catch
        disp([num2str(i), ': ', explist(i).animal, ' - ', explist(i).date, ' - ', explist(i).run]);
    end
end

hold on
for i = 1:length(result)
    plot(result(i).corArray)
end
hold off

mat2sheets('1EuLyLEjaejD1m6vHiGBrvC3JqL8qA3pxyfxK__PVXMw', '0', [6 'B'], 'Y')
https://docs.google.com/spreadsheets/d/1EuLyLEjaejD1m6vHiGBrvC3JqL8qA3pxyfxK__PVXMw/edit#gid=0