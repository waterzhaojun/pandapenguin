function running_analysis_batch(googleSheetID, varargin)

parser = inputParser;
addRequired(parser, 'googleSheetID', @ischar );
addParameter(parser, 'sheetID', '0');
addParameter(parser, 'running_task_column', 5);
parse(parser,googleSheetID, varargin{:});

sheetID = parser.Results.sheetID;
running_task_column = parser.Results.running_task_column;

explist = load_exp(googleSheetID);

for i = 2:length(explist)
    try
        running_analysis(explist(i).animal,explist(i).date,str2num(explist(i).run));
        mat2sheets(googleSheetID, sheetID, [i running_task_column], {'Done'});
    catch
        mat2sheets(googleSheetID, sheetID, [i running_task_column], {'Failed'});
    end
end


end