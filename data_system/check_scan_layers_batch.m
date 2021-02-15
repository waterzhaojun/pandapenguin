function check_scan_layers_batch(googleSheetID, varargin)


parser = inputParser;
addRequired(parser, 'googleSheetID', @ischar );
addParameter(parser, 'sheetID', '0');
addParameter(parser, 'task_column', 10);
parse(parser,googleSheetID, varargin{:});

sheetID = parser.Results.sheetID;
task_column = parser.Results.task_column;

% ====================================================
explist = load_exp(googleSheetID);

for i = [124:129]%2:length(explist)
    animal = explist(i).animal;
    date = explist(i).date;
    run = explist(i).run;
    info = sbxPath(animal, date, run, 'info');
    info = load(info);
    info = info.info;
    layers = check_scan_layers(info);
    try
        if layers == 1
            mat2sheets(googleSheetID, sheetID, [i task_column], {'2D'});
        elseif layers > 1
            mat2sheets(googleSheetID, sheetID, [i task_column], {['3D_',num2str(layers), 'layers']});
        end
    catch
        mat2sheets(googleSheetID, sheetID, [i task_column], {'Fail'});
    end

end