function res = load_exp(sheetid, gid, varargin)
% https://docs.google.com/spreadsheets/d/19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ/edit#gid=0
% sheetid = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'

parser = inputParser;
addRequired(parser, 'sheetid', @ischar );
addRequired(parser, 'gid', @ischar); 
addParameter(parser, 'removeFirstCol', true);
parse(parser, sheetid, gid, varargin{:});

removeFirstCol = parser.Results.removeFirstCol;

res = GetGoogleSpreadsheet(sheetid, gid);

res = cell2struct(res, {res{1, :}}, 2);

if removeFirstCol
    res = res(2:end, :);
end
%res = cell2struct(res, {'animal', 'date', 'run', 'pmt', 'running_task', 'bv_task', 'alignment_task', 'total_running', 'note'}, 2);

end