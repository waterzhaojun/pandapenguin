function running_analysis_batch(googleSheetID, varargin)

parser = inputParser;
addRequired(parser, 'googleSheetID', @ischar );
addOptional(parser, 'rows',[]); 
addParameter(parser, 'sheetID', '0');
addParameter(parser, 'running_task_column', 5);
parse(parser,googleSheetID, varargin{:});
rows = parser.Results.rows;
sheetID = parser.Results.sheetID;
running_task_column = parser.Results.running_task_column;

explist = load_exp(googleSheetID);
if length(rows) == 0
    rows = 2:length(explist);
end

for i = rows
    try
        running_analysis(explist(i).animal,explist(i).date,str2num(explist(i).run));
        mat2sheets(googleSheetID, sheetID, [i running_task_column], {'Done'});
    catch
        mat2sheets(googleSheetID, sheetID, [i running_task_column], {'Failed'});
    end
end


end