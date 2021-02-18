function value = calculate_gaussfilt_std(googleSheetID, varargin)

parser = inputParser;
addRequired(parser, 'googleSheetID', @ischar );
% addParameter(parser, 'sheetID', '0');
% addParameter(parser, 'running_task_column', 5);
parse(parser,googleSheetID, varargin{:});
% 
% sheetID = parser.Results.sheetID;
% running_task_column = parser.Results.running_task_column;


explist = load_exp(googleSheetID);

array = []
for i = 2:length(explist)
    animal = explist(i).animal;
    date = explist(i).date;
    run = str2num(explist(i).run);
    path = sbxPath(animal, date, run, 'quad');
    inf = sbxInfo(path, true);
    if inf.scanmode == 1
        scanrate = 15.5;
    elseif inf.scanmode == 2
        scanrate = 31;
    end

    tmp = getRunningArray(path) * cfg.blockunit * scanrate;
    array = [array;tmp];
    
end




end