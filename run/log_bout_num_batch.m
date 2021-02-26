function log_bout_num_batch(googleSheetID, varargin)

parser = inputParser;
addRequired(parser, 'googleSheetID', @ischar );
addOptional(parser, 'lists', []);
addParameter(parser, 'sheetID', '0');
addParameter(parser, 'bouts_num_column', 9);
parse(parser,googleSheetID, varargin{:});

lists = parser.Results.lists;
sheetID = parser.Results.sheetID;
bouts_num_column = parser.Results.bouts_num_column;


    
explist = load_exp(googleSheetID);

if length(lists) == 0
    lists = 2:length(explist)
end

for i = lists%2:length(explist)
    try
        path = sbxPath(explist(i).animal,explist(i).date,str2num(explist(i).run), 'running');
        result = load(path.result);
        result = result.result;
        mat2sheets(googleSheetID, sheetID, [i bouts_num_column], length(result.bout));
    catch
        mat2sheets(googleSheetID, sheetID, [i bouts_num_column], {'Failed'});
    end
end


end