function res = load_exp(sheetid)
% https://docs.google.com/spreadsheets/d/19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ/edit#gid=0
% sheetid = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'
res = GetGoogleSpreadsheet(sheetid);

res = cell2struct(res, {res{1, :}}, 2);

%res = cell2struct(res, {'animal', 'date', 'run', 'pmt', 'running_task', 'bv_task', 'alignment_task', 'total_running', 'note'}, 2);

end