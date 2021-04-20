function res = googleSheet2struct(googleid, sheetid)

% https://docs.google.com/spreadsheets/d/19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ/edit#gid=0
% sheetid = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'

% I want this function can finally replace load_exp
res = GetGoogleSpreadsheet(googleid, sheetid);

res = cell2struct(res(2:end, :), {res{1, :}}, 2);

%res = cell2struct(res, {'animal', 'date', 'run', 'pmt', 'running_task', 'bv_task', 'alignment_task', 'total_running', 'note'}, 2);




end